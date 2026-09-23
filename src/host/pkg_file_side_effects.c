#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int pkg_file_side_effects_cmd(const char* path, char* out, size_t out_n) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  const char* rp = (path && path[0]) ? path : ".";
  char cmd[8192];
  snprintf(cmd, sizeof(cmd), "node \"%s/scripts/pkg-exports.mjs\" fileSideEffects '%s'", root, rp);
  FILE* p = popen(cmd, "r");
  if (p == NULL) return -1;
  size_t n = fread(out, 1, out_n - 1, p);
  int st = pclose(p);
  if (st != 0) {
    errno = EINVAL;
    return -1;
  }
  out[n] = 0;
  return 0;
}

typedef struct {
  char* path;
  char* out;
} PkgFileSE;

static void pkg_file_side_effects_call(IoWork* w) {
  PkgFileSE* g = (PkgFileSE*)w->data;
  io_sys_end(w, pkg_file_side_effects_cmd(g->path, g->out, 1 << 20));
}

static Term pkg_file_side_effects_pack(Env e, IoWork* w) {
  PkgFileSE* g = (PkgFileSE*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->path);
  free(g->out);
  free(g);
  return r;
}

Term pkg_file_side_effects_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  PkgFileSE* g = io_mem(malloc(sizeof(PkgFileSE)));
  g->path = io_cstr(e, f[0], &n1);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->path, n1)) {
    w->code = EINVAL;
    return pkg_file_side_effects_pack(e, w);
  }
  return io_work(w, pkg_file_side_effects_call, pkg_file_side_effects_pack);
}

static void __attribute__((constructor)) pkg_file_side_effects_use(void) {
  io_eff(CID_PKG_FILE_SIDE_EFFECTS, pkg_file_side_effects_run, 0);
}
