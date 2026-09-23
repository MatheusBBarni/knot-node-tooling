#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Jsx
// ===

static int jsx_lower(const char* source, const char* mode, char* out, size_t out_n) {
  const char* root = getenv("KNOT_ROOT");
  if (root == NULL || root[0] == 0) {
    errno = EINVAL;
    return -1;
  }
  char inpath[] = "/tmp/knot-jsx-in-XXXXXX";
  int fd = mkstemp(inpath);
  if (fd < 0) return -1;
  size_t len = strlen(source);
  if (write(fd, source, len) != (ssize_t)len) {
    close(fd);
    unlink(inpath);
    return -1;
  }
  close(fd);

  char cmd[4096];
  snprintf(
    cmd,
    sizeof(cmd),
    "node \"%s/scripts/jsx-lower.mjs\" %s < \"%s\"",
    root,
    (strcmp(mode, "automatic") == 0) ? "automatic" : "classic",
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
  char* mode;
  char* out;
} JsxLower;

static void jsx_lower_call(IoWork* w) {
  JsxLower* g = (JsxLower*)w->data;
  io_sys_end(w, jsx_lower(g->text, g->mode, g->out, 1 << 20));
}

static Term jsx_lower_pack(Env e, IoWork* w) {
  JsxLower* g = (JsxLower*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->mode);
  free(g->out);
  free(g);
  return r;
}

Term jsx_lower_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  JsxLower* g = io_mem(malloc(sizeof(JsxLower)));
  g->text = io_cstr(e, f[0], &n1);
  g->mode = io_cstr(e, f[1], &n2);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1) || io_nul(g->mode, n2)) {
    w->code = EINVAL;
    return jsx_lower_pack(e, w);
  }
  return io_work(w, jsx_lower_call, jsx_lower_pack);
}

static void __attribute__((constructor)) jsx_lower_use(void) {
  io_eff(CID_JSX_LOWER, jsx_lower_run, 0);
}
