#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pkg_json.h"

static char* knot_read_file(const char* path) {
  FILE* f = fopen(path, "rb");
  if (f == NULL) return NULL;
  if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
  long size = ftell(f);
  if (size < 0 || size > (4 * 1024 * 1024)) { fclose(f); errno = E2BIG; return NULL; }
  rewind(f);
  char* text = (char*)malloc((size_t)size + 1);
  if (text == NULL) { fclose(f); errno = ENOMEM; return NULL; }
  size_t got = fread(text, 1, (size_t)size, f);
  fclose(f);
  if (got != (size_t)size) { free(text); errno = EIO; return NULL; }
  text[got] = 0;
  return text;
}

static int knot_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL) {
    strcpy(path, ".");
    return 1;
  }
  if (slash == path) {
    path[1] = 0;
    return 1;
  }
  *slash = 0;
  return 1;
}

static int pkg_file_side_effects_lookup(const char* path, char* out, size_t out_n) {
  char dir[4096];
  if (snprintf(dir, sizeof(dir), "%s", path[0] ? path : ".") >= (int)sizeof(dir)) { errno = ENAMETOOLONG; return -1; }
  knot_parent(dir);
  for (int depth = 0; depth < 12; depth += 1) {
    char package_path[4096];
    if (snprintf(package_path, sizeof(package_path), "%s/package.json", dir) >= (int)sizeof(package_path)) { errno = ENAMETOOLONG; return -1; }
    char* text = knot_read_file(package_path);
    if (text != NULL) {
      const char* rel = path;
      size_t dir_len = strlen(dir);
      if (strncmp(path, dir, dir_len) == 0 && path[dir_len] == '/') rel = path + dir_len + 1;
      int ok = knot_pj_side_effects(text, rel, out, out_n);
      free(text);
      return ok ? 0 : -1;
    }
    char* slash = strrchr(dir, '/');
    if (slash == NULL) break;
    if (slash == dir) { dir[1] = 0; }
    else *slash = 0;
  }
  if (out_n < 2) { errno = ENOMEM; return -1; }
  strcpy(out, "1");
  return 0;
}

typedef struct {
  char* path;
  char* out;
} PkgFileSE;

static void pkg_file_side_effects_call(IoWork* w) {
  PkgFileSE* g = (PkgFileSE*)w->data;
  io_sys_end(w, pkg_file_side_effects_lookup(g->path, g->out, 1 << 20));
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
