#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/attr.h>
#include <sys/clonefile.h>
#include <sys/stat.h>

static int fs_clone_dir_mkdir_p(char* path) {
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

static int fs_clone_dir_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  int r = fs_clone_dir_mkdir_p(path);
  *slash = '/';
  return r;
}

typedef struct {
  char* src;
  char* dst;
} FsCloneDir;

static void fs_clone_dir_call(IoWork* w) {
  FsCloneDir* g = (FsCloneDir*)w->data;
  if (fs_clone_dir_parent(g->dst) != 0) {
    io_sys_end(w, -1);
    return;
  }
  if (clonefile(g->src, g->dst, 0) != 0 && errno != EEXIST) {
    io_sys_end(w, -1);
    return;
  }
  io_sys_end(w, 0);
}

static Term fs_clone_dir_pack(Env e, IoWork* w) {
  FsCloneDir* g = (FsCloneDir*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->src);
  free(g->dst);
  free(g);
  return r;
}

Term fs_clone_dir_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsCloneDir* g = io_mem(malloc(sizeof(FsCloneDir)));
  g->src = io_cstr(e, f[0], &n1);
  g->dst = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->src, n1) || io_nul(g->dst, n2)) {
    w->code = EINVAL;
    return fs_clone_dir_pack(e, w);
  }
  return io_work(w, fs_clone_dir_call, fs_clone_dir_pack);
}

static void __attribute__((constructor)) fs_clone_dir_use(void) {
  io_eff(CID_FS_CLONE_DIR, fs_clone_dir_run, 0);
}
