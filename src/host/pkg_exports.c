#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int pkg_exports_run_cmd(
  const char* text,
  const char* subpath,
  const char* conditions,
  char* out,
  size_t out_n
) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  char inpath[] = "/tmp/knot-pex-in-XXXXXX";
  int fd = mkstemp(inpath);
  if (fd < 0) return -1;
  size_t len = strlen(text);
  if (write(fd, text, len) != (ssize_t)len) {
    close(fd);
    unlink(inpath);
    return -1;
  }
  close(fd);

  const char* sp = (subpath && subpath[0]) ? subpath : ".";
  const char* cond = (conditions && conditions[0]) ? conditions : "import,module,node,default";

  char cmd[8192];
  snprintf(
    cmd,
    sizeof(cmd),
    "node \"%s/scripts/pkg-exports.mjs\" resolve '%s' '%s' < \"%s\"",
    root,
    sp,
    cond,
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
    errno = ENOENT;
    return -1;
  }
  out[n] = 0;
  return 0;
}

typedef struct {
  char* text;
  char* subpath;
  char* conditions;
  char* out;
} PkgExports;

static void pkg_exports_call(IoWork* w) {
  PkgExports* g = (PkgExports*)w->data;
  io_sys_end(w, pkg_exports_run_cmd(g->text, g->subpath, g->conditions, g->out, 1 << 20));
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
