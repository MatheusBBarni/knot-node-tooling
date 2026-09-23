#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Ts
// ==

static int ts_lower(
  const char* source,
  char* out,
  size_t out_n
) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  char inpath[] = "/tmp/knot-ts-in-XXXXXX";
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
  snprintf(
    cmd,
    sizeof(cmd),
    "node \"%s/scripts/ts-lower.mjs\" < \"%s\"",
    root,
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
  char* out;
} TsLower;

static void ts_lower_call(IoWork* w) {
  TsLower* g = (TsLower*)w->data;
  io_sys_end(w, ts_lower(g->text, g->out, 1 << 20));
}

static Term ts_lower_pack(Env e, IoWork* w) {
  TsLower* g = (TsLower*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->out);
  free(g);
  return r;
}

Term ts_lower_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  TsLower* g = io_mem(malloc(sizeof(TsLower)));
  g->text = io_cstr(e, f[0], &n1);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1)) {
    w->code = EINVAL;
    return ts_lower_pack(e, w);
  }
  return io_work(w, ts_lower_call, ts_lower_pack);
}

static void __attribute__((constructor)) ts_lower_use(void) {
  io_eff(CID_TS_LOWER, ts_lower_run, 0);
}
