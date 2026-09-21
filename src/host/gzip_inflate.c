#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
typedef struct {
  char* path;
  char* out;
  size_t out_n;
} GzipInflate;

static int gzip_inflate_file_proc(const char* path, char** out, size_t* n) {
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
    int dn = open("/dev/null", O_WRONLY);
    if (dn >= 0) {
      dup2(dn, 2);
      close(dn);
    }
    execlp("gzip", "gzip", "-dc", path, (char*)0);
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

static void gzip_inflate_call(IoWork* w) {
  GzipInflate* g = (GzipInflate*)w->data;
  io_sys_end(w, gzip_inflate_file_proc(g->path, &g->out, &g->out_n));
}

static Term gzip_inflate_pack(Env e, IoWork* w) {
  GzipInflate* g = (GzipInflate*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out ? g->out : "", g->out_n));
  free(g->path);
  free(g->out);
  free(g);
  return r;
}

Term gzip_inflate_file_run(Env e, Term* f, IoWork* w) {
  uint64_t n = 0;
  GzipInflate* g = io_mem(malloc(sizeof(GzipInflate)));
  g->path = io_cstr(e, f[0], &n);
  g->out = NULL;
  g->out_n = 0;
  w->data = (char*)g;
  if (io_nul(g->path, n)) {
    w->code = EINVAL;
    return gzip_inflate_pack(e, w);
  }
  return io_work(w, gzip_inflate_call, gzip_inflate_pack);
}

static void __attribute__((constructor)) gzip_inflate_file_use(void) {
  io_eff(CID_GZIP_INFLATE_FILE, gzip_inflate_file_run, 0);
}
