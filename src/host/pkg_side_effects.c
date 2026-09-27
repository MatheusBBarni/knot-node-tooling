#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "pkg_json.h"

typedef struct {
  char* text;
  char* rel;
  char* out;
} PkgSideEffects;

static void pkg_side_effects_call(IoWork* w) {
  PkgSideEffects* g = (PkgSideEffects*)w->data;
  int ok = knot_pj_side_effects(g->text, g->rel, g->out, 1 << 20);
  io_sys_end(w, ok ? 0 : -1);
}

static Term pkg_side_effects_pack(Env e, IoWork* w) {
  PkgSideEffects* g = (PkgSideEffects*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->rel);
  free(g->out);
  free(g);
  return r;
}

Term pkg_side_effects_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0, n2 = 0;
  PkgSideEffects* g = io_mem(malloc(sizeof(PkgSideEffects)));
  g->text = io_cstr(e, f[0], &n1);
  g->rel = io_cstr(e, f[1], &n2);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1) || io_nul(g->rel, n2)) {
    w->code = EINVAL;
    return pkg_side_effects_pack(e, w);
  }
  return io_work(w, pkg_side_effects_call, pkg_side_effects_pack);
}

static void __attribute__((constructor)) pkg_side_effects_use(void) {
  io_eff(CID_PKG_SIDE_EFFECTS, pkg_side_effects_run, 0);
}
