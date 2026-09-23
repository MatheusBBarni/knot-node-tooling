#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int pkg_side_effects_run_cmd(
  const char* text,
  const char* rel,
  char* out,
  size_t out_n
) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  char inpath[] = "/tmp/knot-pse-in-XXXXXX";
  int fd = mkstemp(inpath);
  if (fd < 0) return -1;
  size_t len = strlen(text);
  if (write(fd, text, len) != (ssize_t)len) {
    close(fd);
    unlink(inpath);
    return -1;
  }
  close(fd);

  const char* rp = (rel && rel[0]) ? rel : ".";

  char cmd[8192];
  snprintf(
    cmd,
    sizeof(cmd),
    "node \"%s/scripts/pkg-exports.mjs\" sideEffects '%s' < \"%s\"",
    root,
    rp,
    inpath
  );
  FILE* p = popen(cmd, "r");
  if (p == NULL) {
    unlink(inpath);
    return -1;
  }
  size_t n = fread(out, 1, out_n - 1, p);
  int st = pclose(p);
  unlink(inpath);
  if (st != 0) {
    errno = EINVAL;
    return -1;
  }
  out[n] = 0;
  return 0;
}

typedef struct {
  char* text;
  char* rel;
  char* out;
} PkgSideEffects;

static void pkg_side_effects_call(IoWork* w) {
  PkgSideEffects* g = (PkgSideEffects*)w->data;
  io_sys_end(w, pkg_side_effects_run_cmd(g->text, g->rel, g->out, 1 << 20));
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
