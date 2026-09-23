#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int live_imports_cmd(const char* source, char* out, size_t out_n) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  char inpath[] = "/tmp/knot-li-in-XXXXXX";
  int fd = mkstemp(inpath);
  if (fd < 0) return -1;
  size_t len = strlen(source);
  if (write(fd, source, len) != (ssize_t)len) {
    close(fd);
    unlink(inpath);
    return -1;
  }
  close(fd);
  char cmd[8192];
  snprintf(cmd, sizeof(cmd), "node \"%s/scripts/live-imports.mjs\" < \"%s\"", root, inpath);
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
  char* out;
} LiveImports;

static void live_imports_call(IoWork* w) {
  LiveImports* g = (LiveImports*)w->data;
  io_sys_end(w, live_imports_cmd(g->text, g->out, 1 << 20));
}

static Term live_imports_pack(Env e, IoWork* w) {
  LiveImports* g = (LiveImports*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->out);
  free(g);
  return r;
}

Term live_imports_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  LiveImports* g = io_mem(malloc(sizeof(LiveImports)));
  g->text = io_cstr(e, f[0], &n1);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1)) {
    w->code = EINVAL;
    return live_imports_pack(e, w);
  }
  return io_work(w, live_imports_call, live_imports_pack);
}

static void __attribute__((constructor)) live_imports_use(void) {
  io_eff(CID_LIVE_IMPORTS, live_imports_run, 0);
}
