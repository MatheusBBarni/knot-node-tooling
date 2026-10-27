#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <fts.h>
#include <netinet/in.h>
#include <poll.h>
#include <signal.h>
#include <spawn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
extern char** environ;

#ifndef O_CLOEXEC
#define O_CLOEXEC 0
#endif
#ifndef O_NOFOLLOW
#define O_NOFOLLOW 0
#endif

#define KNOT_SERVE_MAX_ARGS 4096
#define KNOT_SERVE_MAX_REQUEST 16384
#define KNOT_SERVE_MAX_PATH 4096
#define KNOT_SERVE_MAX_WATCH_ENTRIES 500000
#define KNOT_SERVE_MAX_HTML (64u * 1024u * 1024u)

typedef struct {
  char** items;
  size_t count;
  size_t capacity;
  int has_outfile;
  int has_outdir;
} KnotServeArgs;

typedef struct {
  uint64_t sum;
  uint64_t mixed;
  uint64_t count;
  int valid;
} KnotServeSnapshot;

typedef struct {
  uint32_t port;
  char* root;
  char* entry;
  int has_entry_naming;
} KnotServeRun;

static volatile sig_atomic_t knot_serve_signal = 0;

static void knot_serve_signal_handler(int signal_number) {
  knot_serve_signal = signal_number;
}

static void knot_serve_fatal(const char* message, int status) {
  fprintf(stderr, "knot serve: %s\n", message);
  fflush(stderr);
  exit(status);
}

static int knot_serve_args_push(KnotServeArgs* args, const char* value) {
  if (args->count >= KNOT_SERVE_MAX_ARGS) {
    return -1;
  }
  if (args->count == args->capacity) {
    size_t next = args->capacity == 0 ? 16 : args->capacity * 2;
    if (next > KNOT_SERVE_MAX_ARGS) {
      next = KNOT_SERVE_MAX_ARGS;
    }
    char** grown = realloc(args->items, next * sizeof(char*));
    if (grown == NULL) {
      return -1;
    }
    args->items = grown;
    args->capacity = next;
  }
  args->items[args->count] = strdup(value);
  if (args->items[args->count] == NULL) {
    return -1;
  }
  args->count += 1;
  return 0;
}

static int knot_serve_arg_is(const char* arg, const char* option) {
  size_t n = strlen(option);
  return strcmp(arg, option) == 0 || (strncmp(arg, option, n) == 0 && arg[n] == '=');
}

static int knot_serve_read_args(KnotServeArgs* args) {
  const char* argc_text = getenv("KNOT_ARGC");
  if (argc_text == NULL) {
    return -1;
  }
  char* end = NULL;
  long argc = strtol(argc_text, &end, 10);
  if (end == argc_text || *end != 0 || argc < 1 || argc > KNOT_SERVE_MAX_ARGS) {
    return -1;
  }

  for (long i = 2; i <= argc; ++i) {
    char key[32];
    snprintf(key, sizeof(key), "KNOT_ARG_%ld", i);
    const char* arg = getenv(key);
    if (arg == NULL) {
      return -1;
    }
    if (strcmp(arg, "--port") == 0) {
      if (i == argc) {
        return -1;
      }
      ++i;
      continue;
    }
    if (knot_serve_arg_is(arg, "--port")) {
      continue;
    }
    if (strcmp(arg, "--watch") == 0) {
      continue;
    }
    if (knot_serve_arg_is(arg, "--outfile")) {
      args->has_outfile = 1;
    }
    if (knot_serve_arg_is(arg, "--outdir")) {
      args->has_outdir = 1;
    }
    if (knot_serve_args_push(args, arg) != 0) {
      return -1;
    }
    if (strcmp(arg, "--outfile") == 0 || strcmp(arg, "--outdir") == 0) {
      if (i == argc) {
        return -1;
      }
      ++i;
      char value_key[32];
      snprintf(value_key, sizeof(value_key), "KNOT_ARG_%ld", i);
      const char* value = getenv(value_key);
      if (value == NULL || knot_serve_args_push(args, value) != 0) {
        return -1;
      }
    }
  }
  return 0;
}

static void knot_serve_args_free(KnotServeArgs* args) {
  for (size_t i = 0; i < args->count; ++i) {
    free(args->items[i]);
  }
  free(args->items);
  memset(args, 0, sizeof(*args));
}

static int knot_serve_build_args(const KnotServeArgs* input, const KnotServeRun* run,
  KnotServeArgs* output, int preflight) {
  if (knot_serve_args_push(output, "build") != 0) {
    return -1;
  }
  for (size_t i = 0; i < input->count; ++i) {
    const char* arg = input->items[i];
    if (knot_serve_arg_is(arg, "--outfile")) {
      if (strcmp(arg, "--outfile") == 0) {
        ++i;
      }
      continue;
    }
    if (knot_serve_args_push(output, arg) != 0) {
      return -1;
    }
  }

  if (input->has_outfile || !input->has_outdir) {
    if (knot_serve_args_push(output, "--outdir") != 0 ||
        knot_serve_args_push(output, run->root) != 0) {
      return -1;
    }
  }
  if (input->has_outfile && !run->has_entry_naming) {
    if (knot_serve_args_push(output, "--entry-naming") != 0 ||
        knot_serve_args_push(output, run->entry) != 0) {
      return -1;
    }
  }
  if (preflight && knot_serve_args_push(output, "--show-config") != 0) {
    return -1;
  }
  return 0;
}

static int knot_serve_spawn_build(const KnotServeArgs* input, const KnotServeRun* run, int preflight) {
  KnotServeArgs args = {0};
  if (knot_serve_build_args(input, run, &args, preflight) != 0) {
    knot_serve_args_free(&args);
    return 127;
  }

  const char* binary = getenv("KNOT_BINARY");
  if (binary == NULL || binary[0] == 0) {
    knot_serve_args_free(&args);
    knot_serve_fatal("native executable path is unavailable", 1);
  }

  char count[32];
  snprintf(count, sizeof(count), "%zu", args.count);
  if (setenv("KNOT_ARGC", count, 1) != 0) {
    knot_serve_args_free(&args);
    return 127;
  }
  for (size_t i = 0; i < args.count; ++i) {
    char key[32];
    snprintf(key, sizeof(key), "KNOT_ARG_%zu", i + 1);
    if (setenv(key, args.items[i], 1) != 0) {
      knot_serve_args_free(&args);
      return 127;
    }
  }

  posix_spawn_file_actions_t actions;
  int actions_ready = posix_spawn_file_actions_init(&actions) == 0;
  if (preflight && actions_ready) {
    posix_spawn_file_actions_addopen(&actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0);
  }
  pid_t pid = 0;
  char* child_argv[] = {(char*)binary, NULL};
  int spawn_status = posix_spawn(&pid, binary, actions_ready ? &actions : NULL, NULL, child_argv, environ);
  if (actions_ready) {
    posix_spawn_file_actions_destroy(&actions);
  }
  knot_serve_args_free(&args);
  if (spawn_status != 0) {
    fprintf(stderr, "knot serve: cannot start build process: %s\n", strerror(spawn_status));
    return 127;
  }

  int status = 0;
  for (;;) {
    pid_t waited = waitpid(pid, &status, 0);
    if (waited == pid) {
      break;
    }
    if (waited < 0 && errno == EINTR) {
      if (knot_serve_signal != 0) {
        kill(pid, knot_serve_signal);
      }
      continue;
    }
    return 127;
  }
  if (WIFEXITED(status)) {
    return WEXITSTATUS(status);
  }
  if (WIFSIGNALED(status)) {
    return 128 + WTERMSIG(status);
  }
  return 127;
}

static int knot_serve_path_absolute(const char* path, char* output, size_t capacity) {
  char cwd[KNOT_SERVE_MAX_PATH];
  if (getcwd(cwd, sizeof(cwd)) == NULL) {
    return -1;
  }
  char joined[KNOT_SERVE_MAX_PATH];
  if (path[0] == '/') {
    if (snprintf(joined, sizeof(joined), "%s", path) >= (int)sizeof(joined)) {
      return -1;
    }
  } else if (snprintf(joined, sizeof(joined), "%s/%s", cwd, path) >= (int)sizeof(joined)) {
    return -1;
  }

  char work[KNOT_SERVE_MAX_PATH];
  memcpy(work, joined, strlen(joined) + 1);
  char* parts[KNOT_SERVE_MAX_PATH / 2];
  size_t count = 0;
  char* save = NULL;
  for (char* part = strtok_r(work, "/", &save); part != NULL; part = strtok_r(NULL, "/", &save)) {
    if (strcmp(part, ".") == 0 || part[0] == 0) {
      continue;
    }
    if (strcmp(part, "..") == 0) {
      if (count > 0) {
        --count;
      }
      continue;
    }
    if (count >= sizeof(parts) / sizeof(parts[0])) {
      return -1;
    }
    parts[count++] = part;
  }

  size_t used = 0;
  if (capacity < 2) {
    return -1;
  }
  output[used++] = '/';
  output[used] = 0;
  for (size_t i = 0; i < count; ++i) {
    size_t n = strlen(parts[i]);
    if (used + n + (i + 1 < count ? 1 : 0) + 1 > capacity) {
      return -1;
    }
    memcpy(output + used, parts[i], n);
    used += n;
    if (i + 1 < count) {
      output[used++] = '/';
    }
    output[used] = 0;
  }
  return 0;
}

static int knot_serve_path_under(const char* path, const char* parent) {
  size_t n = strlen(parent);
  size_t path_size = strlen(path);
  return path_size > n && strncmp(path, parent, n) == 0 && path[n] == '/';
}

static uint64_t knot_serve_hash_bytes(uint64_t hash, const void* data, size_t length) {
  const unsigned char* bytes = (const unsigned char*)data;
  for (size_t i = 0; i < length; ++i) {
    hash ^= bytes[i];
    hash *= UINT64_C(1099511628211);
  }
  return hash;
}

static uint64_t knot_serve_hash_path(const char* path, const struct stat* st) {
  uint64_t hash = UINT64_C(1469598103934665603);
  hash = knot_serve_hash_bytes(hash, path, strlen(path));
  hash = knot_serve_hash_bytes(hash, &st->st_mode, sizeof(st->st_mode));
  hash = knot_serve_hash_bytes(hash, &st->st_size, sizeof(st->st_size));
  hash = knot_serve_hash_bytes(hash, &st->st_ino, sizeof(st->st_ino));
  hash = knot_serve_hash_bytes(hash, &st->st_mtime, sizeof(st->st_mtime));
  hash = knot_serve_hash_bytes(hash, &st->st_ctime, sizeof(st->st_ctime));
#if defined(__APPLE__)
  hash = knot_serve_hash_bytes(hash, &st->st_mtimespec.tv_nsec, sizeof(st->st_mtimespec.tv_nsec));
  hash = knot_serve_hash_bytes(hash, &st->st_ctimespec.tv_nsec, sizeof(st->st_ctimespec.tv_nsec));
#else
  hash = knot_serve_hash_bytes(hash, &st->st_mtim.tv_nsec, sizeof(st->st_mtim.tv_nsec));
  hash = knot_serve_hash_bytes(hash, &st->st_ctim.tv_nsec, sizeof(st->st_ctim.tv_nsec));
#endif
  return hash;
}

static int knot_serve_skip_dir(FTS* tree, FTSENT* entry, const char* cwd, const char* output_root) {
  if (entry->fts_info != FTS_D) {
    return 0;
  }
  if (strcmp(entry->fts_path, cwd) == 0) {
    return 0;
  }
  if (strcmp(output_root, cwd) != 0 &&
      (strcmp(entry->fts_path, output_root) == 0 || knot_serve_path_under(entry->fts_path, output_root))) {
    fts_set(tree, entry, FTS_SKIP);
    return 1;
  }
  char ignored[KNOT_SERVE_MAX_PATH];
  if (snprintf(ignored, sizeof(ignored), "%s/.git", cwd) < (int)sizeof(ignored) &&
      strcmp(entry->fts_path, ignored) == 0) {
    fts_set(tree, entry, FTS_SKIP);
    return 1;
  }
  if (snprintf(ignored, sizeof(ignored), "%s/.knot", cwd) < (int)sizeof(ignored) &&
      strcmp(entry->fts_path, ignored) == 0) {
    fts_set(tree, entry, FTS_SKIP);
    return 1;
  }
  return 0;
}

static int knot_serve_parent_path(const char* path, char* parent, size_t capacity) {
  size_t size = strlen(path);
  if (size == 0 || size >= capacity) {
    return -1;
  }
  memcpy(parent, path, size + 1);
  char* slash = strrchr(parent, '/');
  if (slash == NULL) {
    return -1;
  }
  if (slash == parent) {
    slash[1] = 0;
  } else {
    *slash = 0;
  }
  return 0;
}

static KnotServeSnapshot knot_serve_snapshot(const char* output_root) {
  KnotServeSnapshot result = {0, 0, 0, 0};
  char cwd[KNOT_SERVE_MAX_PATH];
  if (getcwd(cwd, sizeof(cwd)) == NULL) {
    return result;
  }
  char output_parent[KNOT_SERVE_MAX_PATH];
  if (knot_serve_parent_path(output_root, output_parent, sizeof(output_parent)) != 0) {
    return result;
  }
  char* paths[] = {cwd, NULL};
  FTS* tree = fts_open(paths, FTS_NOCHDIR | FTS_PHYSICAL, NULL);
  if (tree == NULL) {
    return result;
  }
  result.valid = 1;
  FTSENT* entry;
  while ((entry = fts_read(tree)) != NULL) {
    if (entry->fts_info == FTS_D && knot_serve_skip_dir(tree, entry, cwd, output_root)) {
      continue;
    }
    if (entry->fts_info == FTS_DP || entry->fts_info == FTS_DC) {
      continue;
    }
    if (entry->fts_info == FTS_ERR || entry->fts_info == FTS_DNR || entry->fts_info == FTS_NS) {
      result.valid = 0;
      break;
    }
    if (entry->fts_statp == NULL) {
      continue;
    }
    /* Build staging siblings change the output parent's mtime on every build. */
    if (strcmp(entry->fts_path, cwd) == 0 || strcmp(entry->fts_path, output_parent) == 0) {
      continue;
    }
    result.count += 1;
    if (result.count > KNOT_SERVE_MAX_WATCH_ENTRIES) {
      result.valid = 0;
      break;
    }
    uint64_t hash = knot_serve_hash_path(entry->fts_path, entry->fts_statp);
    result.sum += hash;
    result.mixed ^= (hash << (hash & 31)) | (hash >> ((64 - (hash & 31)) & 63));
  }
  if (fts_close(tree) != 0) {
    result.valid = 0;
  }
  return result;
}

static int knot_serve_snapshot_equal(KnotServeSnapshot left, KnotServeSnapshot right) {
  return left.valid && right.valid && left.sum == right.sum && left.mixed == right.mixed && left.count == right.count;
}

static int knot_serve_safe_generation(const char* text, char* generation, size_t capacity) {
  const char* field = strstr(text, "\"generation\"");
  if (field == NULL) {
    return -1;
  }
  field = strchr(field, ':');
  if (field == NULL) {
    return -1;
  }
  ++field;
  while (*field == ' ' || *field == '\t' || *field == '\r' || *field == '\n') {
    ++field;
  }
  if (*field++ != '"') {
    return -1;
  }
  size_t n = 0;
  while (*field != 0 && *field != '"') {
    unsigned char c = (unsigned char)*field++;
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
          (c >= '0' && c <= '9') || c == '_' || c == '-')) {
      return -1;
    }
    if (n + 1 >= capacity) {
      return -1;
    }
    generation[n++] = (char)c;
  }
  if (n == 0 || *field != '"') {
    return -1;
  }
  generation[n] = 0;
  return 0;
}

static int knot_serve_read_generation(const char* root, char* generation, size_t capacity) {
  int root_fd = open(root, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
  if (root_fd < 0) {
    return -1;
  }
  int active_fd = openat(root_fd, "active.json", O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
  if (active_fd < 0) {
    close(root_fd);
    return -1;
  }
  struct stat st;
  if (fstat(active_fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size <= 0 || st.st_size > 65536) {
    close(active_fd);
    close(root_fd);
    return -1;
  }
  size_t size = (size_t)st.st_size;
  char* text = malloc(size + 1);
  if (text == NULL) {
    close(active_fd);
    close(root_fd);
    return -1;
  }
  size_t offset = 0;
  while (offset < size) {
    ssize_t n = read(active_fd, text + offset, size - offset);
    if (n <= 0) {
      free(text);
      close(active_fd);
      close(root_fd);
      return -1;
    }
    offset += (size_t)n;
  }
  text[size] = 0;
  close(active_fd);
  int valid = knot_serve_safe_generation(text, generation, capacity);
  free(text);
  if (valid != 0) {
    close(root_fd);
    return -1;
  }
  int generations_fd = openat(root_fd, "generations", O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
  close(root_fd);
  if (generations_fd < 0) {
    return -1;
  }
  int generation_fd = openat(generations_fd, generation, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
  close(generations_fd);
  if (generation_fd < 0) {
    return -1;
  }
  int complete_fd = openat(generation_fd, "complete.json", O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
  if (complete_fd < 0) {
    close(generation_fd);
    return -1;
  }
  if (fstat(complete_fd, &st) != 0 || !S_ISREG(st.st_mode)) {
    close(complete_fd);
    close(generation_fd);
    return -1;
  }
  close(complete_fd);
  close(generation_fd);
  return 0;
}

static int knot_serve_send_all(int fd, const char* bytes, size_t length) {
  size_t sent = 0;
  while (sent < length) {
    ssize_t n = send(fd, bytes + sent, length - sent, 0);
    if (n < 0 && errno == EINTR) {
      continue;
    }
    if (n <= 0) {
      return -1;
    }
    sent += (size_t)n;
  }
  return 0;
}

static void knot_serve_response(int fd, int status, const char* reason, const char* content_type,
  const char* body, size_t length) {
  char header[1024];
  int n = snprintf(header, sizeof(header),
    "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\n"
    "Cache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nConnection: close\r\n\r\n",
    status, reason, content_type, length);
  if (n <= 0 || (size_t)n >= sizeof(header)) {
    return;
  }
  knot_serve_send_all(fd, header, (size_t)n);
  knot_serve_send_all(fd, body, length);
}

static const char* knot_serve_mime(const char* path) {
  const char* dot = strrchr(path, '.');
  if (dot == NULL) return "application/octet-stream";
  if (strcasecmp(dot, ".html") == 0 || strcasecmp(dot, ".htm") == 0) return "text/html; charset=utf-8";
  if (strcasecmp(dot, ".css") == 0) return "text/css; charset=utf-8";
  if (strcasecmp(dot, ".js") == 0 || strcasecmp(dot, ".mjs") == 0) return "text/javascript; charset=utf-8";
  if (strcasecmp(dot, ".json") == 0 || strcasecmp(dot, ".map") == 0) return "application/json";
  if (strcasecmp(dot, ".svg") == 0) return "image/svg+xml";
  if (strcasecmp(dot, ".png") == 0) return "image/png";
  if (strcasecmp(dot, ".jpg") == 0 || strcasecmp(dot, ".jpeg") == 0) return "image/jpeg";
  if (strcasecmp(dot, ".gif") == 0) return "image/gif";
  if (strcasecmp(dot, ".webp") == 0) return "image/webp";
  if (strcasecmp(dot, ".ico") == 0) return "image/x-icon";
  if (strcasecmp(dot, ".woff") == 0) return "font/woff";
  if (strcasecmp(dot, ".woff2") == 0) return "font/woff2";
  if (strcasecmp(dot, ".wasm") == 0) return "application/wasm";
  if (strcasecmp(dot, ".txt") == 0) return "text/plain; charset=utf-8";
  return "application/octet-stream";
}

static int knot_serve_hex(unsigned char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}

static int knot_serve_decode_path(const char* source, char* output, size_t capacity) {
  size_t used = 0;
  if (source[0] != '/') {
    return -1;
  }
  for (size_t i = 1; source[i] != 0 && source[i] != '?' && source[i] != '#'; ++i) {
    unsigned char c = (unsigned char)source[i];
    if (c == '%') {
      int hi = knot_serve_hex((unsigned char)source[i + 1]);
      int lo = source[i + 1] == 0 ? -1 : knot_serve_hex((unsigned char)source[i + 2]);
      if (hi < 0 || lo < 0) {
        return -1;
      }
      c = (unsigned char)((hi << 4) | lo);
      i += 2;
    }
    if (c == 0 || c == '\\' || c < 0x20 || c == 0x7f || used + 1 >= capacity) {
      return -1;
    }
    output[used++] = (char)c;
  }
  output[used] = 0;
  const char* segment = output;
  for (const char* cursor = output;; ++cursor) {
    if (*cursor != '/' && *cursor != 0) {
      continue;
    }
    size_t length = (size_t)(cursor - segment);
    if (length == 2 && segment[0] == '.' && segment[1] == '.') {
      return -2;
    }
    if (*cursor == 0) {
      break;
    }
    segment = cursor + 1;
  }
  return 0;
}

static int knot_serve_open_relative(int root_fd, char* path) {
  if (path[0] == 0 || strcmp(path, "complete.json") == 0) {
    errno = ENOENT;
    return -1;
  }
  int current = dup(root_fd);
  if (current < 0) {
    return -1;
  }
  char* save = NULL;
  char* part = strtok_r(path, "/", &save);
  while (part != NULL) {
    char* next = strtok_r(NULL, "/", &save);
    if (strcmp(part, ".") == 0 || part[0] == 0) {
      part = next;
      continue;
    }
    if (strcmp(part, "..") == 0) {
      close(current);
      errno = EACCES;
      return -1;
    }
    int flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK;
    if (next != NULL) {
      flags |= O_DIRECTORY;
    }
    int child = openat(current, part, flags);
    close(current);
    if (child < 0) {
      return -1;
    }
    current = child;
    part = next;
  }
  struct stat st;
  if (fstat(current, &st) != 0 || !S_ISREG(st.st_mode)) {
    close(current);
    errno = EACCES;
    return -1;
  }
  return current;
}

static char* knot_serve_body_with_reload(const char* body, size_t body_size, uint64_t version, size_t* output_size) {
  char tag[256];
  int tag_size = snprintf(tag, sizeof(tag),
    "<script src=\"/__knot/reload.js?v=%llu\"></script>", (unsigned long long)version);
  if (tag_size <= 0 || (size_t)tag_size >= sizeof(tag) || body_size > SIZE_MAX - (size_t)tag_size - 1) {
    return NULL;
  }
  size_t position = body_size;
  for (size_t i = 0; i + 7 <= body_size; ++i) {
    if (strncasecmp(body + i, "</body", 6) == 0) {
      position = i;
      break;
    }
  }
  size_t total = body_size + (size_t)tag_size;
  char* output = malloc(total == 0 ? 1 : total);
  if (output == NULL) {
    return NULL;
  }
  memcpy(output, body, position);
  memcpy(output + position, tag, (size_t)tag_size);
  memcpy(output + position + (size_t)tag_size, body + position, body_size - position);
  *output_size = total;
  return output;
}

static int knot_serve_read_file(int file_fd, char** bytes, size_t* size) {
  struct stat st;
  if (fstat(file_fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size < 0 ||
      (uint64_t)st.st_size > KNOT_SERVE_MAX_HTML) {
    return -1;
  }
  size_t length = (size_t)st.st_size;
  char* buffer = malloc(length == 0 ? 1 : length);
  if (buffer == NULL) {
    return -1;
  }
  size_t offset = 0;
  while (offset < length) {
    ssize_t n = read(file_fd, buffer + offset, length - offset);
    if (n < 0 && errno == EINTR) {
      continue;
    }
    if (n <= 0) {
      free(buffer);
      return -1;
    }
    offset += (size_t)n;
  }
  *bytes = buffer;
  *size = length;
  return 0;
}

static int knot_serve_read_query_version(const char* target, char* version, size_t capacity) {
  const char* query = strchr(target, '?');
  if (query == NULL) {
    return -1;
  }
  const char* value = strstr(query + 1, "v=");
  if (value == NULL) {
    return -1;
  }
  value += 2;
  size_t n = 0;
  while (value[n] >= '0' && value[n] <= '9') {
    if (n + 1 >= capacity) return -1;
    version[n] = value[n];
    ++n;
  }
  if (n == 0) return -1;
  version[n] = 0;
  return 0;
}

static int knot_serve_html_script(char* output, size_t capacity, const char* expected, size_t* length) {
  int n = snprintf(output, capacity,
    "(function(){const expected='%s';setInterval(function(){fetch('/__knot/version',{cache:'no-store'})"
    ".then(function(r){return r.text()}).then(function(v){if(v!==expected)location.reload()})"
    ".catch(function(){})},300)})();",
    expected);
  if (n <= 0 || (size_t)n >= capacity) {
    return -1;
  }
  *length = (size_t)n;
  return 0;
}

static void knot_serve_handle_client(int client, const KnotServeRun* run, const char* root_abs,
  const char* generation, int has_active, uint64_t version) {
  struct timeval timeout = {2, 0};
  setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
  setsockopt(client, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
  char request[KNOT_SERVE_MAX_REQUEST + 1];
  size_t used = 0;
  while (used < KNOT_SERVE_MAX_REQUEST) {
    ssize_t n = recv(client, request + used, KNOT_SERVE_MAX_REQUEST - used, 0);
    if (n < 0 && errno == EINTR) continue;
    if (n <= 0) return;
    used += (size_t)n;
    request[used] = 0;
    if (strstr(request, "\r\n\r\n") != NULL) break;
  }
  if (used == KNOT_SERVE_MAX_REQUEST) {
    const char body[] = "request headers too large\n";
    knot_serve_response(client, 431, "Request Header Fields Too Large", "text/plain", body, sizeof(body) - 1);
    return;
  }

  char method[16];
  char target[KNOT_SERVE_MAX_PATH];
  char protocol[16];
  if (sscanf(request, "%15s %4095s %15s", method, target, protocol) != 3 ||
      (strcmp(method, "GET") != 0 && strcmp(method, "HEAD") != 0)) {
    const char body[] = "invalid request\n";
    knot_serve_response(client, 400, "Bad Request", "text/plain", body, sizeof(body) - 1);
    return;
  }
  int head_only = strcmp(method, "HEAD") == 0;
  if (strcmp(target, "/__knot/version") == 0 || strncmp(target, "/__knot/version?", 16) == 0) {
    char body[32];
    int n = snprintf(body, sizeof(body), "%llu", (unsigned long long)version);
    if (n > 0) knot_serve_response(client, 200, "OK", "text/plain; charset=utf-8", body, (size_t)n);
    return;
  }
  if (strncmp(target, "/__knot/reload.js", 17) == 0) {
    char expected[32];
    char body[512];
    size_t body_size = 0;
    if (knot_serve_read_query_version(target, expected, sizeof(expected)) != 0 ||
        knot_serve_html_script(body, sizeof(body), expected, &body_size) != 0) {
      const char error[] = "invalid reload request\n";
      knot_serve_response(client, 400, "Bad Request", "text/plain", error, sizeof(error) - 1);
      return;
    }
    knot_serve_response(client, 200, "OK", "text/javascript; charset=utf-8", body, body_size);
    return;
  }
  if (!has_active) {
    const char body[] = "build is not available yet\n";
    knot_serve_response(client, 503, "Service Unavailable", "text/plain; charset=utf-8", body, sizeof(body) - 1);
    return;
  }

  char relative[KNOT_SERVE_MAX_PATH];
  int path_status = knot_serve_decode_path(target, relative, sizeof(relative));
  if (path_status != 0) {
    const char body[] = "path is not allowed\n";
    knot_serve_response(client, path_status == -2 ? 403 : 400,
      path_status == -2 ? "Forbidden" : "Bad Request", "text/plain; charset=utf-8", body, sizeof(body) - 1);
    return;
  }
  if (relative[0] == 0) {
    if (snprintf(relative, sizeof(relative), "%s", run->entry) >= (int)sizeof(relative)) {
      const char body[] = "entry path is too long\n";
      knot_serve_response(client, 500, "Internal Server Error", "text/plain", body, sizeof(body) - 1);
      return;
    }
  }
  if (strcmp(relative, "complete.json") == 0 || strcmp(relative, "active.json") == 0 ||
      strcmp(relative, "previous.json") == 0 || strncmp(relative, "generations/", 11) == 0) {
    const char body[] = "not found\n";
    knot_serve_response(client, 404, "Not Found", "text/plain", body, sizeof(body) - 1);
    return;
  }

  char active_path[KNOT_SERVE_MAX_PATH];
  if (snprintf(active_path, sizeof(active_path), "%s/generations/%s", root_abs, generation) >= (int)sizeof(active_path)) {
    const char body[] = "output path is too long\n";
    knot_serve_response(client, 500, "Internal Server Error", "text/plain", body, sizeof(body) - 1);
    return;
  }
  int root_fd = open(active_path, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
  if (root_fd < 0) {
    const char body[] = "output is unavailable\n";
    knot_serve_response(client, 503, "Service Unavailable", "text/plain", body, sizeof(body) - 1);
    return;
  }
  int file_fd = knot_serve_open_relative(root_fd, relative);
  close(root_fd);
  if (file_fd < 0) {
    int status = errno == EACCES || errno == ELOOP ? 403 : 404;
    const char* reason = status == 403 ? "Forbidden" : "Not Found";
    const char body[] = "not found\n";
    knot_serve_response(client, status, reason, "text/plain; charset=utf-8", body, sizeof(body) - 1);
    return;
  }

  const char* mime = knot_serve_mime(relative);
  if (strncasecmp(mime, "text/html", 9) == 0) {
    char* source = NULL;
    size_t source_size = 0;
    if (knot_serve_read_file(file_fd, &source, &source_size) != 0) {
      close(file_fd);
      const char body[] = "output is too large or unreadable\n";
      knot_serve_response(client, 500, "Internal Server Error", "text/plain", body, sizeof(body) - 1);
      return;
    }
    close(file_fd);
    size_t response_size = 0;
    char* response = knot_serve_body_with_reload(source, source_size, version, &response_size);
    free(source);
    if (response == NULL) {
      const char body[] = "cannot prepare page response\n";
      knot_serve_response(client, 500, "Internal Server Error", "text/plain", body, sizeof(body) - 1);
      return;
    }
    if (head_only) {
      char header[1024];
      int n = snprintf(header, sizeof(header),
        "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %zu\r\n"
        "Cache-Control: no-store\r\nConnection: close\r\n\r\n", mime, response_size);
      if (n > 0 && (size_t)n < sizeof(header)) knot_serve_send_all(client, header, (size_t)n);
    } else {
      knot_serve_response(client, 200, "OK", mime, response, response_size);
    }
    free(response);
    return;
  }

  struct stat st;
  if (fstat(file_fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size < 0) {
    close(file_fd);
    const char body[] = "not found\n";
    knot_serve_response(client, 404, "Not Found", "text/plain", body, sizeof(body) - 1);
    return;
  }
  char header[1024];
  int n = snprintf(header, sizeof(header),
    "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %llu\r\n"
    "Cache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nConnection: close\r\n\r\n",
    mime, (unsigned long long)st.st_size);
  if (n > 0 && (size_t)n < sizeof(header)) knot_serve_send_all(client, header, (size_t)n);
  if (!head_only) {
    char buffer[65536];
    for (;;) {
      ssize_t size = read(file_fd, buffer, sizeof(buffer));
      if (size < 0 && errno == EINTR) continue;
      if (size <= 0) break;
      if (knot_serve_send_all(client, buffer, (size_t)size) != 0) break;
    }
  }
  close(file_fd);
}

static int knot_serve_listener(uint32_t port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    knot_serve_fatal("cannot create loopback listener", 1);
  }
  int descriptor_flags = fcntl(fd, F_GETFD, 0);
  if (descriptor_flags < 0 || fcntl(fd, F_SETFD, descriptor_flags | FD_CLOEXEC) != 0) {
    close(fd);
    knot_serve_fatal("cannot protect loopback listener descriptor", 1);
  }
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags >= 0) fcntl(fd, F_SETFL, flags | O_NONBLOCK);
  int yes = 1;
  setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
  struct sockaddr_in address;
  memset(&address, 0, sizeof(address));
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  address.sin_port = htons((uint16_t)port);
  if (bind(fd, (struct sockaddr*)&address, sizeof(address)) != 0) {
    int conflict = errno == EADDRINUSE;
    close(fd);
    if (conflict) {
      char message[128];
      snprintf(message, sizeof(message), "port %u is already in use", port);
      knot_serve_fatal(message, 1);
    }
    knot_serve_fatal("cannot bind loopback listener", 1);
  }
  if (listen(fd, 64) != 0) {
    close(fd);
    knot_serve_fatal("cannot listen on loopback port", 1);
  }
  return fd;
}

static void knot_serve_install_signals(void) {
  struct sigaction action;
  memset(&action, 0, sizeof(action));
  action.sa_handler = knot_serve_signal_handler;
  sigemptyset(&action.sa_mask);
  sigaction(SIGINT, &action, NULL);
  sigaction(SIGTERM, &action, NULL);
  signal(SIGPIPE, SIG_IGN);
}

static void knot_serve_run_builds(const KnotServeArgs* args, const KnotServeRun* run,
  const char* root_abs, uint64_t* version, char* generation, int* has_active,
  KnotServeSnapshot* baseline, int initial) {
  KnotServeSnapshot before = knot_serve_snapshot(root_abs);
  int status = knot_serve_spawn_build(args, run, 0);
  if (knot_serve_signal != 0) {
    return;
  }
  if (status == 0) {
    char next_generation[256];
    if (knot_serve_read_generation(root_abs, next_generation, sizeof(next_generation)) == 0) {
      memcpy(generation, next_generation, strlen(next_generation) + 1);
      *has_active = 1;
      *version += 1;
    } else {
      fprintf(stderr, "knot serve: successful build did not publish a complete output generation\n");
    }
  }
  KnotServeSnapshot after = knot_serve_snapshot(root_abs);
  if (!after.valid) {
    *baseline = before;
    return;
  }
  *baseline = after;
  if (!before.valid || knot_serve_snapshot_equal(before, after) || initial) {
    return;
  }

  while (knot_serve_signal == 0) {
    before = after;
    status = knot_serve_spawn_build(args, run, 0);
    if (knot_serve_signal != 0) return;
    if (status == 0) {
      char next_generation[256];
      if (knot_serve_read_generation(root_abs, next_generation, sizeof(next_generation)) == 0) {
        memcpy(generation, next_generation, strlen(next_generation) + 1);
        *has_active = 1;
        *version += 1;
      } else {
        fprintf(stderr, "knot serve: successful build did not publish a complete output generation\n");
      }
    }
    after = knot_serve_snapshot(root_abs);
    if (!after.valid) {
      *baseline = before;
      return;
    }
    *baseline = after;
    if (knot_serve_snapshot_equal(before, after)) {
      return;
    }
  }
}

static void knot_serve_main(KnotServeRun* run) {
  if (run->port < 1 || run->port > 65535) {
    knot_serve_fatal("invalid --port value", 2);
  }
  KnotServeArgs args = {0};
  if (knot_serve_read_args(&args) != 0) {
    knot_serve_args_free(&args);
    knot_serve_fatal("cannot read command arguments", 2);
  }

  int preflight = knot_serve_spawn_build(&args, run, 1);
  if (preflight != 0) {
    knot_serve_args_free(&args);
    exit(preflight > 0 && preflight < 256 ? preflight : 1);
  }

  char root_abs[KNOT_SERVE_MAX_PATH];
  if (knot_serve_path_absolute(run->root, root_abs, sizeof(root_abs)) != 0) {
    knot_serve_args_free(&args);
    knot_serve_fatal("output root path is too long", 2);
  }
  char project_root[KNOT_SERVE_MAX_PATH];
  if (getcwd(project_root, sizeof(project_root)) == NULL) {
    knot_serve_args_free(&args);
    knot_serve_fatal("cannot resolve project root", 1);
  }
  if (strcmp(root_abs, project_root) == 0) {
    knot_serve_args_free(&args);
    knot_serve_fatal("output root must be a project subdirectory", 2);
  }
  int listener = knot_serve_listener(run->port);
  knot_serve_install_signals();
  fprintf(stderr, "knot serve: http://127.0.0.1:%u/\n", run->port);
  fflush(stderr);

  char generation[256] = "";
  int has_active = 0;
  uint64_t version = 0;
  KnotServeSnapshot baseline = knot_serve_snapshot(root_abs);
  knot_serve_run_builds(&args, run, root_abs, &version, generation, &has_active, &baseline, 0);

  while (knot_serve_signal == 0) {
    struct pollfd descriptor = {listener, POLLIN, 0};
    int ready = poll(&descriptor, 1, 100);
    if (ready < 0 && errno != EINTR) {
      close(listener);
      knot_serve_args_free(&args);
      knot_serve_fatal("loopback listener failed", 1);
    }
    if (knot_serve_signal != 0) {
      break;
    }
    if (ready > 0 && (descriptor.revents & POLLIN) != 0) {
      struct sockaddr_in peer;
      socklen_t peer_size = sizeof(peer);
      int client = accept(listener, (struct sockaddr*)&peer, &peer_size);
      if (client >= 0) {
        int client_flags = fcntl(client, F_GETFL, 0);
        if (client_flags < 0 || fcntl(client, F_SETFL, client_flags & ~O_NONBLOCK) != 0) {
          close(client);
        } else {
          int descriptor_flags = fcntl(client, F_GETFD, 0);
          if (descriptor_flags >= 0 && fcntl(client, F_SETFD, descriptor_flags | FD_CLOEXEC) == 0) {
            knot_serve_handle_client(client, run, root_abs, generation, has_active, version);
          }
          close(client);
        }
      }
    }
    KnotServeSnapshot current = knot_serve_snapshot(root_abs);
    if (baseline.valid && current.valid && !knot_serve_snapshot_equal(baseline, current)) {
      knot_serve_run_builds(&args, run, root_abs, &version, generation, &has_active, &baseline, 0);
    } else if (!baseline.valid && current.valid) {
      baseline = current;
    }
  }

  close(listener);
  knot_serve_args_free(&args);
  exit(knot_serve_signal == SIGINT ? 130 : 143);
}

static void knot_serve_call(IoWork* w) {
  KnotServeRun* run = (KnotServeRun*)w->data;
  knot_serve_main(run);
  w->code = 0;
}

static Term knot_serve_pack(Env e, IoWork* w) {
  KnotServeRun* run = (KnotServeRun*)w->data;
  Term result = io_done(e, term_pak(CID_Unit, 0));
  free(run->root);
  free(run->entry);
  free(run);
  return result;
}

Term server_run_run(Env e, Term* f, IoWork* w) {
  KnotServeRun* run = io_mem(malloc(sizeof(KnotServeRun)));
  if (run == NULL) {
    knot_serve_fatal("out of memory", 1);
  }
  run->port = (uint32_t)f[0];
  run->root = io_cstr(e, f[1], &w->size);
  uint64_t entry_size = 0;
  run->entry = io_cstr(e, f[2], &entry_size);
  run->has_entry_naming = (uint32_t)f[3] != 0;
  if (io_nul(run->root, w->size) || io_nul(run->entry, entry_size)) {
    free(run->root);
    free(run->entry);
    free(run);
    knot_serve_fatal("invalid path argument", 2);
  }
  w->data = (char*)run;
  return io_work(w, knot_serve_call, knot_serve_pack);
}

static void __attribute__((constructor)) server_run_use(void) {
  io_eff(CID_Server_run, server_run_run);
}
