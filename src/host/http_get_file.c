// Http
// ====

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/wait.h>


typedef struct {
  char* url;
  char* dest;
} HttpGetFile;

static int http_mkdir_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  for (char* p = path + 1; *p != 0; p += 1) {
    if (*p == '/') {
      *p = 0;
      if (mkdir(path, 0755) != 0 && errno != EEXIST) {
        *slash = '/';
        return -1;
      }
      *p = '/';
    }
  }
  if (mkdir(path, 0755) != 0 && errno != EEXIST) {
    *slash = '/';
    return -1;
  }
  *slash = '/';
  return 0;
}

static int http_parse(const char* url, char* host, size_t host_n, int* port,
  char* path, size_t path_n) {
  if (strncmp(url, "http://", 7) != 0) {
    errno = EPROTONOSUPPORT;
    return -1;
  }
  const char* p = url + 7;
  const char* slash = strchr(p, '/');
  const char* host_end = slash == NULL ? p + strlen(p) : slash;
  const char* colon = memchr(p, ':', (size_t)(host_end - p));
  const char* h_end = colon == NULL ? host_end : colon;
  size_t h_len = (size_t)(h_end - p);
  if (h_len == 0 || h_len >= host_n) {
    errno = EINVAL;
    return -1;
  }
  memcpy(host, p, h_len);
  host[h_len] = 0;
  *port = 80;
  if (colon != NULL) {
    *port = atoi(colon + 1);
    if (*port <= 0 || *port > 65535) {
      errno = EINVAL;
      return -1;
    }
  }
  if (slash == NULL) {
    snprintf(path, path_n, "/");
  } else if (strlen(slash) >= path_n) {
    errno = EINVAL;
    return -1;
  } else {
    snprintf(path, path_n, "%s", slash);
  }
  return 0;
}

static int https_get_file_curl(const char* url, const char* dest) {
  pid_t pid = fork();
  if (pid < 0) {
    return -1;
  }
  if (pid == 0) {
    execlp("curl", "curl", "-fsSL", "--max-time", "60", "-o", dest, url, (char*)0);
    _exit(127);
  }
  int st = 0;
  if (waitpid(pid, &st, 0) < 0) {
    return -1;
  }
  if (WIFEXITED(st) && WEXITSTATUS(st) == 0) {
    return 0;
  }
  errno = EIO;
  return -1;
}

static int http_get_file_blocking(const char* url, const char* dest) {
  if (strncmp(url, "https://", 8) == 0) {
    char dest_copy[4096];
    if (strlen(dest) >= sizeof(dest_copy)) {
      errno = ENAMETOOLONG;
      return -1;
    }
    memcpy(dest_copy, dest, strlen(dest) + 1);
    if (http_mkdir_parent(dest_copy) != 0) {
      return -1;
    }
    return https_get_file_curl(url, dest);
  }
  char host[256];
  char path[2048];
  int port = 80;

  if (http_parse(url, host, sizeof(host), &port, path, sizeof(path)) != 0) {
    return -1;
  }
  struct sockaddr_in at;
  memset(&at, 0, sizeof(at));
  at.sin_family = AF_INET;
  at.sin_port = htons((uint16_t)port);
  at.sin_addr.s_addr = inet_addr(host);
  if (at.sin_addr.s_addr == INADDR_NONE) {
    errno = EINVAL;
    return -1;
  }
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    return -1;
  }
  if (connect(fd, (struct sockaddr*)&at, sizeof(at)) != 0) {
    close(fd);
    return -1;
  }
  char req[4096];
  int req_n = snprintf(req, sizeof(req),
    "GET %s HTTP/1.1\r\nHost: %s:%d\r\nConnection: close\r\n\r\n",
    path, host, port);
  if (req_n < 0 || req_n >= (int)sizeof(req)) {
    close(fd);
    errno = EINVAL;
    return -1;
  }
  size_t sent = 0;
  while (sent < (size_t)req_n) {
    ssize_t n = send(fd, req + sent, (size_t)req_n - sent, 0);
    if (n <= 0) {
      close(fd);
      return -1;
    }
    sent += (size_t)n;
  }
  size_t cap = 1 << 16;
  size_t len = 0;
  char* buf = malloc(cap);
  if (buf == NULL) {
    close(fd);
    errno = ENOMEM;
    return -1;
  }
  for (;;) {
    if (len + 4096 >= cap) {
      if (cap >= (1u << 25)) {
        free(buf);
        close(fd);
        errno = EFBIG;
        return -1;
      }
      cap *= 2;
      char* nbuf = realloc(buf, cap);
      if (nbuf == NULL) {
        free(buf);
        close(fd);
        errno = ENOMEM;
        return -1;
      }
      buf = nbuf;
    }
    ssize_t n = recv(fd, buf + len, cap - len - 1, 0);
    if (n < 0) {
      free(buf);
      close(fd);
      return -1;
    }
    if (n == 0) {
      break;
    }
    len += (size_t)n;
  }
  close(fd);
  buf[len] = 0;
  char* head_end = strstr(buf, "\r\n\r\n");
  if (head_end == NULL) {
    free(buf);
    errno = EBADMSG;
    return -1;
  }
  if (strncmp(buf, "HTTP/1.1 200", 12) != 0 && strncmp(buf, "HTTP/1.0 200", 12) != 0) {
    free(buf);
    errno = EIO;
    return -1;
  }
  char* body = head_end + 4;
  size_t body_n = len - (size_t)(body - buf);
  char dest_copy[4096];
  if (strlen(dest) >= sizeof(dest_copy)) {
    free(buf);
    errno = ENAMETOOLONG;
    return -1;
  }
  memcpy(dest_copy, dest, strlen(dest) + 1);
  if (http_mkdir_parent(dest_copy) != 0) {
    free(buf);
    return -1;
  }
  int out = open(dest, O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (out < 0) {
    free(buf);
    return -1;
  }
  size_t wrote = 0;
  while (wrote < body_n) {
    ssize_t n = write(out, body + wrote, body_n - wrote);
    if (n <= 0) {
      close(out);
      free(buf);
      return -1;
    }
    wrote += (size_t)n;
  }
  close(out);
  free(buf);
  return 0;
}

static void http_get_file_call(IoWork* w) {
  HttpGetFile* g = (HttpGetFile*)w->data;
  io_sys_end(w, http_get_file_blocking(g->url, g->dest));
}

static Term http_get_file_pack(Env e, IoWork* w) {
  HttpGetFile* g = (HttpGetFile*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->url);
  free(g->dest);
  free(g);
  return r;
}

Term http_get_file_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  HttpGetFile* g = io_mem(malloc(sizeof(HttpGetFile)));
  g->url = io_cstr(e, f[0], &n1);
  g->dest = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->url, n1) || io_nul(g->dest, n2)) {
    w->code = EINVAL;
    return http_get_file_pack(e, w);
  }
  return io_work(w, http_get_file_call, http_get_file_pack);
}

static void __attribute__((constructor)) http_get_file_use(void) {
  io_eff(CID_HTTP_GET_FILE, http_get_file_run, 0);
}
