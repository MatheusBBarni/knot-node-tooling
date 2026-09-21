#include <errno.h>
#include <string.h>
#include <unistd.h>

#include <sys/stat.h>
static int fs_symlink_mkdir_p(char* path) {
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

static int fs_symlink_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  int r = fs_symlink_mkdir_p(path);
  *slash = '/';
  return r;
}

typedef struct {
  char* target;
  char* path;
} FsSymlink;

static void fs_symlink_call(IoWork* w) {
  FsSymlink* g = (FsSymlink*)w->data;
  if (fs_symlink_parent(g->path) != 0) {
    io_sys_end(w, -1);
    return;
  }
  if (symlink(g->target, g->path) != 0 && errno != EEXIST) {
    io_sys_end(w, -1);
    return;
  }
  io_sys_end(w, 0);
}

static Term fs_symlink_pack(Env e, IoWork* w) {
  FsSymlink* g = (FsSymlink*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->target);
  free(g->path);
  free(g);
  return r;
}

Term fs_symlink_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsSymlink* g = io_mem(malloc(sizeof(FsSymlink)));
  g->target = io_cstr(e, f[0], &n1);
  g->path = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->target, n1) || io_nul(g->path, n2)) {
    w->code = EINVAL;
    return fs_symlink_pack(e, w);
  }
  return io_work(w, fs_symlink_call, fs_symlink_pack);
}

static void __attribute__((constructor)) fs_symlink_use(void) {
  io_eff(CID_FS_SYMLINK, fs_symlink_run, 0);
}
