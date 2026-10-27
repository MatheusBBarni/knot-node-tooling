#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#include "hash_sha256_core.h"

typedef struct {
  char* op;
  char* a;
  char* b;
  char* c;
  char* d;
  char* result;
} FsPublish;

static int pub_fail(FsPublish* g, const char* status) {
  free(g->result);
  g->result = strdup(status);
  return g->result == NULL ? -1 : 0;
}

static int pub_join(char* out, size_t cap, const char* a, const char* b) {
  int n = snprintf(out, cap, "%s/%s", a, b);
  if (n < 0 || (size_t)n >= cap) {
    errno = ENAMETOOLONG;
    return -1;
  }
  return 0;
}

static int pub_reserved(const char* name) {
  return strcmp(name, "active.json") == 0 || strcmp(name, "previous.json") == 0
    || strcmp(name, "complete.json") == 0 || strcmp(name, "gc.lock") == 0
    || strcmp(name, "generations") == 0 || strcmp(name, "leases") == 0;
}

static int pub_safe_id(const char* id) {
  size_t n = 0;
  if (id == NULL || id[0] == '\0') {
    return 0;
  }
  for (const char* p = id; *p != '\0'; p += 1) {
    if (!isalnum((unsigned char)*p) && *p != '-' && *p != '_') {
      return 0;
    }
    n += 1;
    if (n > 128) {
      return 0;
    }
  }
  return 1;
}

static int pub_fsync_fd(int fd) {
  return fsync(fd) == 0 ? 0 : -1;
}

static int pub_fsync_path(const char* path) {
  int fd = open(path, O_RDONLY);
  int rc;
  if (fd < 0) {
    return -1;
  }
  rc = pub_fsync_fd(fd);
  close(fd);
  return rc;
}

static int pub_write_file(const char* path, const char* bytes, size_t n) {
  char temp[4096];
  int fd;
  int nprint = snprintf(temp, sizeof(temp), "%s.tmp-%ld", path, (long)getpid());
  if (nprint < 0 || (size_t)nprint >= sizeof(temp)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  fd = open(temp, O_CREAT | O_EXCL | O_WRONLY, 0644);
  if (fd < 0) {
    return -1;
  }
  if (write(fd, bytes, n) != (ssize_t)n || pub_fsync_fd(fd) != 0) {
    close(fd);
    unlink(temp);
    return -1;
  }
  if (close(fd) != 0) {
    unlink(temp);
    return -1;
  }
  if (rename(temp, path) != 0) {
    unlink(temp);
    return -1;
  }
  return 0;
}

static int pub_rm_rf(const char* path) {
  struct stat st;
  DIR* dir;
  if (lstat(path, &st) != 0) {
    return errno == ENOENT ? 0 : -1;
  }
  if (!S_ISDIR(st.st_mode)) {
    return unlink(path);
  }
  dir = opendir(path);
  if (dir == NULL) {
    return -1;
  }
  struct dirent* ent;
  while ((ent = readdir(dir)) != NULL) {
    char child[4096];
    if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
      continue;
    }
    if (pub_join(child, sizeof(child), path, ent->d_name) != 0 || pub_rm_rf(child) != 0) {
      closedir(dir);
      return -1;
    }
  }
  closedir(dir);
  return rmdir(path);
}

static int pub_hash_bytes(const unsigned char* bytes, size_t n, char* out) {
  KnotSha256 ctx;
  unsigned char digest[32];
  sha256_init(&ctx);
  sha256_update(&ctx, bytes, n);
  sha256_final(&ctx, digest);
  hash256_b64(digest, 32, out);
  return 0;
}

static int pub_hash_file(const char* path, char* digest, uint64_t* bytes) {
  FILE* file = fopen(path, "rb");
  KnotSha256 ctx;
  unsigned char buf[8192];
  unsigned char raw[32];
  size_t n;
  uint64_t total = 0;
  if (file == NULL) {
    return -1;
  }
  sha256_init(&ctx);
  while ((n = fread(buf, 1, sizeof(buf), file)) > 0) {
    sha256_update(&ctx, buf, n);
    total += (uint64_t)n;
  }
  if (ferror(file)) {
    fclose(file);
    return -1;
  }
  fclose(file);
  sha256_final(&ctx, raw);
  hash256_b64(raw, 32, digest);
  *bytes = total;
  return 0;
}

typedef struct {
  char* rel;
  uint64_t bytes;
  char digest[48];
} PubFile;

static int pub_file_cmp(const void* left, const void* right) {
  const PubFile* a = left;
  const PubFile* b = right;
  return strcmp(a->rel, b->rel);
}

static int pub_add_file(PubFile** files, size_t* count, size_t* cap, const char* rel, const char* full) {
  PubFile* next;
  char digest[48];
  uint64_t bytes = 0;
  if (pub_hash_file(full, digest, &bytes) != 0) {
    return -1;
  }
  if (*count == *cap) {
    size_t grown = *cap == 0 ? 8 : *cap * 2;
    next = realloc(*files, grown * sizeof(PubFile));
    if (next == NULL) {
      return -1;
    }
    *files = next;
    *cap = grown;
  }
  (*files)[*count].rel = strdup(rel);
  if ((*files)[*count].rel == NULL) {
    return -1;
  }
  (*files)[*count].bytes = bytes;
  memcpy((*files)[*count].digest, digest, sizeof(digest));
  *count += 1;
  return 0;
}

static int pub_collect(const char* root, const char* rel, PubFile** files, size_t* count, size_t* cap) {
  char full[4096];
  DIR* dir;
  struct dirent* ent;
  if (rel[0] == '\0') {
    memcpy(full, root, strlen(root) + 1);
  } else if (pub_join(full, sizeof(full), root, rel) != 0) {
    return -1;
  }
  dir = opendir(full);
  if (dir == NULL) {
    return -1;
  }
  while ((ent = readdir(dir)) != NULL) {
    char child_rel[4096];
    char child_full[4096];
    struct stat st;
    if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
      continue;
    }
    if (strchr(ent->d_name, '/') != NULL || strcmp(ent->d_name, "..") == 0) {
      closedir(dir);
      errno = EINVAL;
      return -1;
    }
    if (rel[0] == '\0') {
      snprintf(child_rel, sizeof(child_rel), "%s", ent->d_name);
    } else if (snprintf(child_rel, sizeof(child_rel), "%s/%s", rel, ent->d_name) >= (int)sizeof(child_rel)) {
      closedir(dir);
      errno = ENAMETOOLONG;
      return -1;
    }
    if (pub_join(child_full, sizeof(child_full), root, child_rel) != 0 || lstat(child_full, &st) != 0) {
      closedir(dir);
      return -1;
    }
    if (S_ISLNK(st.st_mode) || (!S_ISDIR(st.st_mode) && !S_ISREG(st.st_mode))) {
      closedir(dir);
      errno = EINVAL;
      return -1;
    }
    if (S_ISDIR(st.st_mode)) {
      if (pub_collect(root, child_rel, files, count, cap) != 0) {
        closedir(dir);
        return -1;
      }
    } else if (pub_add_file(files, count, cap, child_rel, child_full) != 0) {
      closedir(dir);
      return -1;
    }
  }
  closedir(dir);
  return 0;
}

static void pub_free_files(PubFile* files, size_t count) {
  for (size_t i = 0; i < count; i += 1) {
    free(files[i].rel);
  }
  free(files);
}

static int pub_buf_add(char** buf, size_t* n, size_t* cap, const char* text, size_t len) {
  if (*n + len + 1 > *cap) {
    size_t grown = *cap == 0 ? 256 : *cap;
    char* next;
    while (*n + len + 1 > grown) {
      grown *= 2;
    }
    next = realloc(*buf, grown);
    if (next == NULL) {
      return -1;
    }
    *buf = next;
    *cap = grown;
  }
  memcpy(*buf + *n, text, len);
  *n += len;
  (*buf)[*n] = '\0';
  return 0;
}

static int pub_buf_str(char** buf, size_t* n, size_t* cap, const char* text) {
  return pub_buf_add(buf, n, cap, text, strlen(text));
}

static int pub_json_str(char** buf, size_t* n, size_t* cap, const char* text) {
  if (pub_buf_str(buf, n, cap, "\"") != 0) {
    return -1;
  }
  for (const unsigned char* p = (const unsigned char*)text; *p != '\0'; p += 1) {
    char esc[8];
    if (*p == '"' || *p == '\\') {
      esc[0] = '\\';
      esc[1] = (char)*p;
      esc[2] = '\0';
      if (pub_buf_str(buf, n, cap, esc) != 0) {
        return -1;
      }
    } else if (*p < 0x20) {
      snprintf(esc, sizeof(esc), "\\u%04x", *p);
      if (pub_buf_str(buf, n, cap, esc) != 0) {
        return -1;
      }
    } else if (pub_buf_add(buf, n, cap, (const char*)p, 1) != 0) {
      return -1;
    }
  }
  return pub_buf_str(buf, n, cap, "\"");
}

static int pub_copy_file(const char* src, const char* dst) {
  char parent[4096];
  FILE* in;
  FILE* out;
  char buf[8192];
  size_t n;
  char* slash;
  memcpy(parent, dst, strlen(dst) + 1);
  slash = strrchr(parent, '/');
  if (slash != NULL) {
    *slash = '\0';
    if (parent[0] != '\0' && mkdir(parent, 0755) != 0 && errno != EEXIST) {
      return -1;
    }
  }
  in = fopen(src, "rb");
  out = fopen(dst, "wb");
  if (in == NULL || out == NULL) {
    if (in != NULL) {
      fclose(in);
    }
    if (out != NULL) {
      fclose(out);
    }
    return -1;
  }
  while ((n = fread(buf, 1, sizeof(buf), in)) > 0) {
    if (fwrite(buf, 1, n, out) != n) {
      fclose(in);
      fclose(out);
      return -1;
    }
  }
  if (ferror(in) || fclose(out) != 0) {
    fclose(in);
    return -1;
  }
  fclose(in);
  return pub_fsync_path(dst);
}

static int pub_copy_tree(const char* src, const char* dst) {
  struct stat st;
  DIR* dir;
  struct dirent* ent;
  if (lstat(src, &st) != 0) {
    return -1;
  }
  if (S_ISREG(st.st_mode)) {
    return pub_copy_file(src, dst);
  }
  if (!S_ISDIR(st.st_mode)) {
    errno = EINVAL;
    return -1;
  }
  if (mkdir(dst, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  dir = opendir(src);
  if (dir == NULL) {
    return -1;
  }
  while ((ent = readdir(dir)) != NULL) {
    char from[4096];
    char to[4096];
    if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
      continue;
    }
    if (pub_join(from, sizeof(from), src, ent->d_name) != 0
      || pub_join(to, sizeof(to), dst, ent->d_name) != 0
      || pub_copy_tree(from, to) != 0) {
      closedir(dir);
      return -1;
    }
  }
  closedir(dir);
  return 0;
}

static int pub_sync_root(const char* staged, const char* outdir) {
  DIR* dir;
  struct dirent* ent;
  if (mkdir(outdir, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  if (pub_copy_tree(staged, outdir) != 0) {
    return -1;
  }
  dir = opendir(outdir);
  if (dir == NULL) {
    return -1;
  }
  while ((ent = readdir(dir)) != NULL) {
    char staged_child[4096];
    char out_child[4096];
    struct stat st;
    if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0 || pub_reserved(ent->d_name)) {
      continue;
    }
    if (pub_join(out_child, sizeof(out_child), outdir, ent->d_name) != 0
      || pub_join(staged_child, sizeof(staged_child), staged, ent->d_name) != 0) {
      closedir(dir);
      return -1;
    }
    if (lstat(staged_child, &st) != 0) {
      if (errno != ENOENT || pub_rm_rf(out_child) != 0) {
        closedir(dir);
        return -1;
      }
    }
  }
  closedir(dir);
  return 0;
}
static int pub_lock(const char* outdir, char* lock_path, size_t cap) {
  char body[64];
  int fd;
  if (pub_join(lock_path, cap, outdir, "gc.lock") != 0) {
    return -1;
  }
  if (mkdir(outdir, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  fd = open(lock_path, O_CREAT | O_EXCL | O_WRONLY, 0644);
  if (fd < 0 && errno == EEXIST) {
    char old[64];
    FILE* file = fopen(lock_path, "r");
    long pid = 0;
    if (file != NULL && fgets(old, sizeof(old), file) != NULL) {
      pid = strtol(old, NULL, 10);
    }
    if (file != NULL) {
      fclose(file);
    }
    if (pid > 0 && kill((pid_t)pid, 0) == 0) {
      errno = EBUSY;
      return -1;
    }
    unlink(lock_path);
    fd = open(lock_path, O_CREAT | O_EXCL | O_WRONLY, 0644);
  }
  if (fd < 0) {
    return -1;
  }
  snprintf(body, sizeof(body), "%ld\n", (long)getpid());
  if (write(fd, body, strlen(body)) < 0 || close(fd) != 0) {
    unlink(lock_path);
    return -1;
  }
  return 0;
}

static void pub_unlock(const char* lock_path) {
  if (lock_path[0] != '\0') {
    unlink(lock_path);
  }
}

static int pub_field(const char* meta, int index, char* out, size_t cap) {
  const char* start = meta;
  int seen = 0;
  size_t n = 0;
  while (*start != '\0' && seen < index) {
    if (*start == '|') {
      seen += 1;
    }
    start += 1;
  }
  if (seen != index) {
    out[0] = '\0';
    return 0;
  }
  while (start[n] != '\0' && start[n] != '|') {
    if (n + 1 >= cap) {
      errno = ENAMETOOLONG;
      return -1;
    }
    out[n] = start[n];
    n += 1;
  }
  out[n] = '\0';
  return 0;
}

static int pub_publish(FsPublish* g) {
  char gen_root[4096];
  char gen_dir[4096];
  char complete_path[4096];
  char active_path[4096];
  char previous_path[4096];
  char lock_path[4096] = "";
  char digest_field[256];
  char target[128];
  char format[128];
  char public_path[1024];
  char complete_digest[48];
  char* complete = NULL;
  size_t complete_n = 0;
  size_t complete_cap = 0;
  PubFile* files = NULL;
  size_t count = 0;
  size_t cap = 0;
  char active[2048];
  const char* fail = getenv("KNOT_FAIL_PUBLISH");
  int rc = -1;
  char id[192];
  struct timespec ts;
  if (!pub_safe_id(g->c)) {
    errno = EINVAL;
    return pub_fail(g, "error");
  }
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
    return pub_fail(g, "error");
  }
  if (snprintf(id, sizeof(id), "%s-%ld%ld", g->c, (long)ts.tv_sec, ts.tv_nsec) >= (int)sizeof(id)) {
    return pub_fail(g, "error");
  }
  if (pub_field(g->d, 0, digest_field, sizeof(digest_field)) != 0
    || pub_field(g->d, 1, target, sizeof(target)) != 0
    || pub_field(g->d, 2, format, sizeof(format)) != 0
    || pub_field(g->d, 3, public_path, sizeof(public_path)) != 0) {
    return pub_fail(g, "error");
  }
  if (pub_join(gen_root, sizeof(gen_root), g->b, "generations") != 0
    || pub_join(gen_dir, sizeof(gen_dir), gen_root, id) != 0
    || pub_join(complete_path, sizeof(complete_path), gen_dir, "complete.json") != 0
    || pub_join(active_path, sizeof(active_path), g->b, "active.json") != 0
    || pub_join(previous_path, sizeof(previous_path), g->b, "previous.json") != 0) {
    return pub_fail(g, "error");
  }
  if (pub_lock(g->b, lock_path, sizeof(lock_path)) != 0) {
    pub_fail(g, errno == EBUSY ? "busy" : "error");
    return 0;
  }
  if (mkdir(gen_root, 0755) != 0 && errno != EEXIST) {
    pub_fail(g, "error");
    goto done;
  }
  if (pub_copy_tree(g->a, gen_dir) != 0 || pub_collect(gen_dir, "", &files, &count, &cap) != 0) {
    pub_rm_rf(gen_dir);
    pub_fail(g, "error");
    goto done;
  }
  qsort(files, count, sizeof(PubFile), pub_file_cmp);
  if (pub_buf_str(&complete, &complete_n, &complete_cap, "{\"version\":1,\"generation\":") != 0
    || pub_json_str(&complete, &complete_n, &complete_cap, id) != 0
    || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"configDigest\":") != 0
    || pub_json_str(&complete, &complete_n, &complete_cap, digest_field) != 0
    || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"toolVersion\":\"0.0.1\",\"target\":") != 0
    || pub_json_str(&complete, &complete_n, &complete_cap, target) != 0
    || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"format\":") != 0
    || pub_json_str(&complete, &complete_n, &complete_cap, format) != 0
    || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"publicPath\":") != 0
    || pub_json_str(&complete, &complete_n, &complete_cap, public_path) != 0
    || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"tombstone\":false,\"outputs\":[") != 0) {
    pub_rm_rf(gen_dir);
    pub_fail(g, "error");
    goto done;
  }
  for (size_t i = 0; i < count; i += 1) {
    char bytes[32];
    if (strcmp(files[i].rel, "complete.json") == 0) {
      continue;
    }
    snprintf(bytes, sizeof(bytes), "%llu", (unsigned long long)files[i].bytes);
    if ((i > 0 && pub_buf_str(&complete, &complete_n, &complete_cap, ",") != 0)
      || pub_buf_str(&complete, &complete_n, &complete_cap, "{\"path\":") != 0
      || pub_json_str(&complete, &complete_n, &complete_cap, files[i].rel) != 0
      || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"bytes\":") != 0
      || pub_buf_str(&complete, &complete_n, &complete_cap, bytes) != 0
      || pub_buf_str(&complete, &complete_n, &complete_cap, ",\"digest\":") != 0
      || pub_json_str(&complete, &complete_n, &complete_cap, files[i].digest) != 0
      || pub_buf_str(&complete, &complete_n, &complete_cap, "}") != 0) {
      pub_rm_rf(gen_dir);
      pub_fail(g, "error");
      goto done;
    }
  }
  if (pub_buf_str(&complete, &complete_n, &complete_cap, "]}") != 0
    || pub_write_file(complete_path, complete, complete_n) != 0
    || pub_fsync_path(gen_dir) != 0) {
    pub_rm_rf(gen_dir);
    pub_fail(g, "error");
    goto done;
  }
  pub_hash_bytes((const unsigned char*)complete, complete_n, complete_digest);
  if (fail != NULL && strcmp(fail, "before-activate") == 0) {
    pub_fail(g, "error");
    goto done;
  }
  {
    struct stat old;
    if (lstat(active_path, &old) == 0 && pub_copy_file(active_path, previous_path) != 0) {
      pub_fail(g, "error");
      goto done;
    }
  }
  snprintf(active, sizeof(active), "{\"version\":1,\"generation\":");
  {
    char* record = NULL;
    size_t record_n = 0;
    size_t record_cap = 0;
    if (pub_buf_str(&record, &record_n, &record_cap, "{\"version\":1,\"generation\":") != 0
      || pub_json_str(&record, &record_n, &record_cap, id) != 0
      || pub_buf_str(&record, &record_n, &record_cap, ",\"completeDigest\":") != 0
      || pub_json_str(&record, &record_n, &record_cap, complete_digest) != 0
      || pub_buf_str(&record, &record_n, &record_cap, "}") != 0
      || pub_write_file(active_path, record, record_n) != 0
      || pub_fsync_path(g->b) != 0) {
      free(record);
      pub_fail(g, "error");
      goto done;
    }
    if (pub_sync_root(g->a, g->b) != 0) {
      free(record);
      pub_fail(g, "error");
      goto done;
    }
    {
      char* status = NULL;
      size_t status_n = 0;
      size_t status_cap = 0;
      if (pub_buf_str(&status, &status_n, &status_cap, "ok|") != 0
        || pub_buf_add(&status, &status_n, &status_cap, record, record_n) != 0) {
        free(record);
        free(status);
        pub_fail(g, "error");
        goto done;
      }
      free(g->result);
      g->result = status;
      free(record);
    }
  }
  pub_rm_rf(g->a);
  rc = 0;
done:
  pub_unlock(lock_path);
  pub_free_files(files, count);
  free(complete);
  if (g->result == NULL) {
    pub_fail(g, "error");
  }
  return rc;
}

static int pub_read_all(const char* path, char** out, size_t* n) {
  FILE* file = fopen(path, "rb");
  char* buf;
  long len;
  if (file == NULL) {
    return -1;
  }
  if (fseek(file, 0, SEEK_END) != 0 || (len = ftell(file)) < 0 || fseek(file, 0, SEEK_SET) != 0) {
    fclose(file);
    return -1;
  }
  buf = malloc((size_t)len + 1);
  if (buf == NULL) {
    fclose(file);
    return -1;
  }
  if (fread(buf, 1, (size_t)len, file) != (size_t)len) {
    free(buf);
    fclose(file);
    return -1;
  }
  buf[len] = '\0';
  fclose(file);
  *out = buf;
  *n = (size_t)len;
  return 0;
}

static int pub_json_value(const char* json, const char* key, char* out, size_t cap) {
  char needle[128];
  const char* found;
  size_t n = 0;
  snprintf(needle, sizeof(needle), "\"%s\":\"", key);
  found = strstr(json, needle);
  if (found == NULL) {
    return -1;
  }
  found += strlen(needle);
  while (found[n] != '\0' && found[n] != '"') {
    if (n + 1 >= cap) {
      return -1;
    }
    out[n] = found[n];
    n += 1;
  }
  if (found[n] != '"') {
    return -1;
  }
  out[n] = '\0';
  return 0;
}

static int pub_load_pointer(const char* root, const char* name, char* generation, size_t generation_cap, char* digest, size_t digest_cap, char* gen_dir, size_t gen_dir_cap) {
  char pointer_path[4096];
  char generations[4096];
  char complete_path[4096];
  char actual[48];
  char* pointer = NULL;
  char* complete = NULL;
  size_t pointer_n = 0;
  size_t complete_n = 0;
  uint64_t bytes = 0;
  int ok = -1;
  if (pub_join(pointer_path, sizeof(pointer_path), root, name) != 0) {
    return -1;
  }
  if (pub_read_all(pointer_path, &pointer, &pointer_n) != 0) {
    goto done;
  }
  if (pub_json_value(pointer, "generation", generation, generation_cap) != 0
    || pub_json_value(pointer, "completeDigest", digest, digest_cap) != 0
    || !pub_safe_id(generation)) {
    goto done;
  }
  if (pub_join(generations, sizeof(generations), root, "generations") != 0
    || pub_join(gen_dir, gen_dir_cap, generations, generation) != 0
    || pub_join(complete_path, sizeof(complete_path), gen_dir, "complete.json") != 0
    || pub_read_all(complete_path, &complete, &complete_n) != 0
    || pub_hash_file(complete_path, actual, &bytes) != 0
    || strcmp(actual, digest) != 0) {
    goto done;
  }
  ok = 0;
done:
  free(pointer);
  free(complete);
  return ok;
}

static int pub_snapshot(FsPublish* g) {
  char gen_dir[4096];
  char complete_path[4096];
  char lock_path[4096] = "";
  char stage[4096];
  char lease_dir[4096];
  char lease_path[4096];
  char generation[160];
  char complete_digest[80];
  char public_path[1024];
  char* complete = NULL;
  size_t complete_n = 0;
  struct stat dest_st;
  const char* fail = getenv("KNOT_FAIL_SNAPSHOT");
  if (lstat(g->b, &dest_st) == 0) {
    return pub_fail(g, "exists");
  }
  if (pub_lock(g->a, lock_path, sizeof(lock_path)) != 0) {
    return pub_fail(g, errno == EBUSY ? "busy" : "error");
  }
  if (pub_load_pointer(g->a, "active.json", generation, sizeof(generation), complete_digest, sizeof(complete_digest), gen_dir, sizeof(gen_dir)) != 0
    && pub_load_pointer(g->a, "previous.json", generation, sizeof(generation), complete_digest, sizeof(complete_digest), gen_dir, sizeof(gen_dir)) != 0) {
    pub_fail(g, "recovery");
    goto done;
  }
  if (pub_join(complete_path, sizeof(complete_path), gen_dir, "complete.json") != 0
    || pub_read_all(complete_path, &complete, &complete_n) != 0) {
    pub_fail(g, "recovery");
    goto done;
  }
  if (pub_json_value(complete, "publicPath", public_path, sizeof(public_path)) != 0) {
    public_path[0] = '\0';
  }
  snprintf(lease_dir, sizeof(lease_dir), "%s/leases/%s", g->a, generation);
  snprintf(lease_path, sizeof(lease_path), "%s/%ld-%ld", lease_dir, (long)getpid(), (long)getppid());
  if (mkdir(g->a, 0755) != 0 && errno != EEXIST) {
    pub_fail(g, "error");
    goto done;
  }
  {
    char leases[4096];
    if (pub_join(leases, sizeof(leases), g->a, "leases") != 0
      || (mkdir(leases, 0755) != 0 && errno != EEXIST)
      || (mkdir(lease_dir, 0755) != 0 && errno != EEXIST)
      || pub_write_file(lease_path, generation, strlen(generation)) != 0) {
      pub_fail(g, "error");
      goto done;
    }
  }
  snprintf(stage, sizeof(stage), "%s.knot-snapshot-%ld", g->b, (long)getpid());
  pub_rm_rf(stage);
  if (pub_copy_tree(gen_dir, stage) != 0) {
    pub_fail(g, "error");
    goto snapshot_fail;
  }
  {
    char staged_complete[4096];
    if (pub_join(staged_complete, sizeof(staged_complete), stage, "complete.json") != 0 || unlink(staged_complete) != 0) {
      pub_fail(g, "error");
      goto snapshot_fail;
    }
  }
  if (fail != NULL && strcmp(fail, "before-rename") == 0) {
    pub_fail(g, "error");
    goto snapshot_fail;
  }
  if (rename(stage, g->b) != 0) {
    pub_fail(g, "error");
    goto snapshot_fail;
  }
  {
    char parent[4096];
    char* slash;
    memcpy(parent, g->b, strlen(g->b) + 1);
    slash = strrchr(parent, '/');
    if (slash != NULL) {
      *slash = '\0';
      pub_fsync_path(parent[0] == '\0' ? "/" : parent);
    }
  }
  unlink(lease_path);
  rmdir(lease_dir);
  {
    char* status = NULL;
    size_t status_n = 0;
    size_t status_cap = 0;
    if (pub_buf_str(&status, &status_n, &status_cap, "ok|{\"version\":1,\"generation\":") != 0
      || pub_json_str(&status, &status_n, &status_cap, generation) != 0
      || pub_buf_str(&status, &status_n, &status_cap, ",\"completeDigest\":") != 0
      || pub_json_str(&status, &status_n, &status_cap, complete_digest) != 0
      || pub_buf_str(&status, &status_n, &status_cap, ",\"publicPath\":") != 0
      || pub_json_str(&status, &status_n, &status_cap, public_path) != 0
      || pub_buf_str(&status, &status_n, &status_cap, "}") != 0) {
      pub_fail(g, "error");
      free(status);
      goto done;
    }
    free(g->result);
    g->result = status;
  }
  goto done;
snapshot_fail:
  pub_rm_rf(stage);
done:
  pub_unlock(lock_path);
  free(complete);
  if (g->result == NULL) {
    pub_fail(g, "error");
  }
  return 0;
}

static void fs_publish_call(IoWork* w) {
  FsPublish* g = (FsPublish*)w->data;
  if (strcmp(g->op, "publish") == 0) {
    pub_publish(g);
  } else if (strcmp(g->op, "snapshot") == 0) {
    pub_snapshot(g);
  } else {
    pub_fail(g, "error");
  }
  io_sys_end(w, g->result == NULL ? -1 : 0);
}

static Term fs_publish_pack(Env e, IoWork* w) {
  FsPublish* g = (FsPublish*)w->data;
  Term r = g->result == NULL ? io_fail(e, w->code == 0 ? 1 : w->code, NULL)
    : io_done(e, io_str(e, g->result, strlen(g->result)));
  free(g->op);
  free(g->a);
  free(g->b);
  free(g->c);
  free(g->d);
  free(g->result);
  free(g);
  return r;
}

Term fs_publish_run(Env e, Term* f, IoWork* w) {
  uint64_t n0 = 0, n1 = 0, n2 = 0, n3 = 0, n4 = 0;
  FsPublish* g = io_mem(malloc(sizeof(FsPublish)));
  g->op = io_cstr(e, f[0], &n0);
  g->a = io_cstr(e, f[1], &n1);
  g->b = io_cstr(e, f[2], &n2);
  g->c = io_cstr(e, f[3], &n3);
  g->d = io_cstr(e, f[4], &n4);
  g->result = NULL;
  w->data = (char*)g;
  if (io_nul(g->op, n0) || io_nul(g->a, n1) || io_nul(g->b, n2)) {
    pub_fail(g, "error");
    return fs_publish_pack(e, w);
  }
  return io_work(w, fs_publish_call, fs_publish_pack);
}

static void __attribute__((constructor)) fs_publish_use(void) {
  io_eff(CID_Fs_publish, fs_publish_run);
}
