#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

static int fs_copy_mkdir_p(char* path) {
  if (path[0] == 0) {
    return 0;
  }
  for (char* p = path + 1; *p != 0; p += 1) {
    if (*p == '/') {
      *p = 0;
      if (mkdir(path, 0755) != 0 && errno != EEXIST) {
        return -1;
      }
      *p = '/';
    }
  }
  if (mkdir(path, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
}

static int fs_copy_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  int r = fs_copy_mkdir_p(path);
  *slash = '/';
  return r;
}

static int fs_copy_file(const char* src, char* dst) {
  if (fs_copy_parent(dst) != 0) {
    return -1;
  }
  int in = open(src, O_RDONLY);
  if (in < 0) {
    return -1;
  }
  int out = open(dst, O_WRONLY | O_CREAT | O_EXCL, 0644);
  if (out < 0) {
    if (errno == EEXIST) {
      close(in);
      return 0;
    }
    close(in);
    return -1;
  }
  char buf[8192];
  for (;;) {
    ssize_t n = read(in, buf, sizeof(buf));
    if (n < 0) {
      close(in);
      close(out);
      return -1;
    }
    if (n == 0) {
      break;
    }
    ssize_t off = 0;
    while (off < n) {
      ssize_t w = write(out, buf + off, (size_t)(n - off));
      if (w < 0) {
        close(in);
        close(out);
        return -1;
      }
      off += w;
    }
  }
  close(in);
  close(out);
  return 0;
}

typedef struct {
  char* src;
  char* dst;
} FsCopy;

static void fs_copy_call(IoWork* w) {
  FsCopy* g = (FsCopy*)w->data;
  io_sys_end(w, fs_copy_file(g->src, g->dst));
}

static Term fs_copy_pack(Env e, IoWork* w) {
  FsCopy* g = (FsCopy*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->src);
  free(g->dst);
  free(g);
  return r;
}

Term fs_copy_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsCopy* g = io_mem(malloc(sizeof(FsCopy)));
  g->src = io_cstr(e, f[0], &n1);
  g->dst = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->src, n1) || io_nul(g->dst, n2)) {
    w->code = EINVAL;
    return fs_copy_pack(e, w);
  }
  return io_work(w, fs_copy_call, fs_copy_pack);
}

static void __attribute__((constructor)) fs_copy_use(void) {
  io_eff(CID_FS_COPY, fs_copy_run, 0);
}
