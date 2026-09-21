#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

typedef struct {
  char* url;
  char* body;
  size_t n;
} HttpsGet;

static int https_get_curl(const char* url, char** out, size_t* n) {
  int fds[2];
  if (pipe(fds) != 0) {
    return -1;
  }
  pid_t pid = fork();
  if (pid < 0) {
    close(fds[0]);
    close(fds[1]);
    return -1;
  }
  if (pid == 0) {
    close(fds[0]);
    if (dup2(fds[1], 1) < 0) {
      _exit(127);
    }
    close(fds[1]);
    execlp("curl", "curl", "-fsSL", "--max-time", "60", "-H", "Accept: application/vnd.npm.install-v1+json", url, (char*)0);
    _exit(127);
  }
  close(fds[1]);
  size_t cap = 4096;
  size_t len = 0;
  char* buf = malloc(cap);
  if (buf == NULL) {
    close(fds[0]);
    waitpid(pid, NULL, 0);
    errno = ENOMEM;
    return -1;
  }
  for (;;) {
    if (len == cap) {
      if (cap > (32u << 20)) {
        free(buf);
        close(fds[0]);
        waitpid(pid, NULL, 0);
        errno = EFBIG;
        return -1;
      }
      cap *= 2;
      char* next = realloc(buf, cap);
      if (next == NULL) {
        free(buf);
        close(fds[0]);
        waitpid(pid, NULL, 0);
        errno = ENOMEM;
        return -1;
      }
      buf = next;
    }
    ssize_t r = read(fds[0], buf + len, cap - len);
    if (r < 0) {
      free(buf);
      close(fds[0]);
      waitpid(pid, NULL, 0);
      return -1;
    }
    if (r == 0) {
      break;
    }
    len += (size_t)r;
  }
  close(fds[0]);
  int st = 0;
  if (waitpid(pid, &st, 0) < 0) {
    free(buf);
    return -1;
  }
  if (!(WIFEXITED(st) && WEXITSTATUS(st) == 0)) {
    free(buf);
    errno = EIO;
    return -1;
  }
  *out = buf;
  *n = len;
  return 0;
}

static void https_get_call(IoWork* w) {
  HttpsGet* g = (HttpsGet*)w->data;
  io_sys_end(w, https_get_curl(g->url, &g->body, &g->n));
}

static Term https_get_pack(Env e, IoWork* w) {
  HttpsGet* g = (HttpsGet*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->body ? g->body : "", g->n));
  free(g->url);
  free(g->body);
  free(g);
  return r;
}

Term https_get_run(Env e, Term* f, IoWork* w) {
  uint64_t n = 0;
  HttpsGet* g = io_mem(malloc(sizeof(HttpsGet)));
  g->url = io_cstr(e, f[0], &n);
  g->body = NULL;
  g->n = 0;
  w->data = (char*)g;
  if (io_nul(g->url, n)) {
    w->code = EINVAL;
    return https_get_pack(e, w);
  }
  return io_work(w, https_get_call, https_get_pack);
}

static void __attribute__((constructor)) https_get_use(void) {
  io_eff(CID_HTTPS_GET, https_get_run, 0);
}
