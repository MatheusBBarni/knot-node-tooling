#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "pkg_json.h"

typedef struct {
  char* text;
  char* subpath;
  char* conditions;
  char* out;
} PkgExports;

static void pkg_exports_call(IoWork* w) {
  PkgExports* g = (PkgExports*)w->data;
  int ok = knot_pj_exports(g->text, g->subpath, g->conditions, g->out, 1 << 20);
  io_sys_end(w, ok ? 0 : -1);
}

static Term pkg_exports_pack(Env e, IoWork* w) {
  PkgExports* g = (PkgExports*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->subpath);
  free(g->conditions);
  free(g->out);
  free(g);
  return r;
}

Term pkg_exports_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0, n2 = 0, n3 = 0;
  PkgExports* g = io_mem(malloc(sizeof(PkgExports)));
  g->text = io_cstr(e, f[0], &n1);
  g->subpath = io_cstr(e, f[1], &n2);
  g->conditions = io_cstr(e, f[2], &n3);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1) || io_nul(g->subpath, n2) || io_nul(g->conditions, n3)) {
    w->code = EINVAL;
    return pkg_exports_pack(e, w);
  }
  return io_work(w, pkg_exports_call, pkg_exports_pack);
}

static void __attribute__((constructor)) pkg_exports_use(void) {
  io_eff(CID_PKG_EXPORTS, pkg_exports_run, 0);
}
