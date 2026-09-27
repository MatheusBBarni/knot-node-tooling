#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

#include <unistd.h>

typedef struct {
  char* src;
  char* dst;
} FsRename;

static void fs_rename_call(IoWork* w) {
  FsRename* g = (FsRename*)w->data;
  io_sys_end(w, rename(g->src, g->dst));
}

static Term fs_rename_pack(Env e, IoWork* w) {
  FsRename* g = (FsRename*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->src);
  free(g->dst);
  free(g);
  return r;
}

Term fs_rename_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0, n2 = 0;
  FsRename* g = io_mem(malloc(sizeof(FsRename)));
  g->src = io_cstr(e, f[0], &n1);
  g->dst = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->src, n1) || io_nul(g->dst, n2)) {
    w->code = EINVAL;
    return fs_rename_pack(e, w);
  }
  return io_work(w, fs_rename_call, fs_rename_pack);
}

static void __attribute__((constructor)) fs_rename_use(void) {
  io_eff(CID_FS_RENAME, fs_rename_run, 0);
}
