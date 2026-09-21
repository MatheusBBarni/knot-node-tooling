#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

typedef struct {
  const char* at;
  const char* end;
  int err;
} LayoutJsonP;

static void layout_json_ws(LayoutJsonP* p) {
  while (p->at < p->end && (*p->at == ' ' || *p->at == '\n' || *p->at == '\r' || *p->at == '\t')) {
    p->at += 1;
  }
}

static int layout_json_lit(LayoutJsonP* p, const char* s) {
  size_t n = strlen(s);
  if ((size_t)(p->end - p->at) < n || memcmp(p->at, s, n) != 0) {
    p->err = 1;
    return 0;
  }
  p->at += n;
  return 1;
}

static int layout_json_string(LayoutJsonP* p, char* out, size_t out_n) {
  layout_json_ws(p);
  if (p->at >= p->end || *p->at != '"') {
    p->err = 1;
    return 0;
  }
  p->at += 1;
  size_t n = 0;
  while (p->at < p->end && *p->at != '"') {
    char c = *p->at;
    p->at += 1;
    if (c == '\\' && p->at < p->end) {
      c = *p->at;
      p->at += 1;
      if (c == 'n') {
        c = '\n';
      } else if (c == 't') {
        c = '\t';
      }
    }
    if (out != NULL) {
      if (n + 1 >= out_n) {
        p->err = 1;
        return 0;
      }
      out[n] = c;
    }
    n += 1;
  }
  if (p->at >= p->end || *p->at != '"') {
    p->err = 1;
    return 0;
  }
  p->at += 1;
  if (out != NULL) {
    out[n] = 0;
  }
  return 1;
}

static int layout_json_skip(LayoutJsonP* p);

static int layout_json_skip_object(LayoutJsonP* p) {
  if (!layout_json_lit(p, "{")) {
    return 0;
  }
  layout_json_ws(p);
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    if (!layout_json_string(p, NULL, 0)) {
      return 0;
    }
    layout_json_ws(p);
    if (!layout_json_lit(p, ":")) {
      return 0;
    }
    if (!layout_json_skip(p)) {
      return 0;
    }
    layout_json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      continue;
    }
    if (p->at < p->end && *p->at == '}') {
      p->at += 1;
      return 1;
    }
    p->err = 1;
    return 0;
  }
}

static int layout_json_skip_array(LayoutJsonP* p) {
  if (!layout_json_lit(p, "[")) {
    return 0;
  }
  layout_json_ws(p);
  if (p->at < p->end && *p->at == ']') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    if (!layout_json_skip(p)) {
      return 0;
    }
    layout_json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      continue;
    }
    if (p->at < p->end && *p->at == ']') {
      p->at += 1;
      return 1;
    }
    p->err = 1;
    return 0;
  }
}

static int layout_json_skip(LayoutJsonP* p) {
  layout_json_ws(p);
  if (p->at >= p->end) {
    p->err = 1;
    return 0;
  }
  char c = *p->at;
  if (c == '{') {
    return layout_json_skip_object(p);
  }
  if (c == '[') {
    return layout_json_skip_array(p);
  }
  if (c == '"') {
    return layout_json_string(p, NULL, 0);
  }
  if (c == 'n') {
    return layout_json_lit(p, "null");
  }
  if (c == 't') {
    return layout_json_lit(p, "true");
  }
  if (c == 'f') {
    return layout_json_lit(p, "false");
  }
  if (c == '-' || (c >= '0' && c <= '9')) {
    p->at += 1;
    while (p->at < p->end && ((*p->at >= '0' && *p->at <= '9') || *p->at == '.' || *p->at == 'e' || *p->at == 'E' || *p->at == '+' || *p->at == '-')) {
      p->at += 1;
    }
    return 1;
  }
  p->err = 1;
  return 0;
}

static int layout_json_enter(LayoutJsonP* p, const char* key) {
  layout_json_ws(p);
  if (!layout_json_lit(p, "{")) {
    return 0;
  }
  layout_json_ws(p);
  if (p->at < p->end && *p->at == '}') {
    p->err = 1;
    return 0;
  }
  for (;;) {
    char got[256];
    if (!layout_json_string(p, got, sizeof(got))) {
      return 0;
    }
    layout_json_ws(p);
    if (!layout_json_lit(p, ":")) {
      return 0;
    }
    if (strcmp(got, key) == 0) {
      return 1;
    }
    if (!layout_json_skip(p)) {
      return 0;
    }
    layout_json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      layout_json_ws(p);
      continue;
    }
    p->err = 1;
    return 0;
  }
}

static int layout_json_walk(LayoutJsonP* p, const char* path) {
  char key[256];
  const char* s = path;
  while (*s) {
    size_t n = 0;
    while (s[n] && s[n] != '/') {
      if (n + 1 >= sizeof(key)) {
        return 0;
      }
      key[n] = s[n];
      n += 1;
    }
    key[n] = 0;
    if (!layout_json_enter(p, key)) {
      return 0;
    }
    s += n;
    if (*s == '/') {
      s += 1;
    }
  }
  return 1;
}

static int layout_json_pairs(LayoutJsonP* p, char* out, size_t out_n) {
  layout_json_ws(p);
  if (!layout_json_lit(p, "{")) {
    return 0;
  }
  layout_json_ws(p);
  size_t n = 0;
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    out[0] = 0;
    return 1;
  }
  for (;;) {
    char key[256];
    char val[512];
    if (!layout_json_string(p, key, sizeof(key))) {
      return 0;
    }
    layout_json_ws(p);
    if (!layout_json_lit(p, ":")) {
      return 0;
    }
    layout_json_ws(p);
    if (!layout_json_string(p, val, sizeof(val))) {
      return 0;
    }
    int w = snprintf(out + n, out_n - n, "%s%s\t%s", n == 0 ? "" : "\n", key, val);
    if (w < 0 || n + (size_t)w >= out_n) {
      p->err = 1;
      return 0;
    }
    n += (size_t)w;
    layout_json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      layout_json_ws(p);
      continue;
    }
    if (p->at < p->end && *p->at == '}') {
      p->at += 1;
      return 1;
    }
    p->err = 1;
    return 0;
  }
}

static int layout_mkdir_p(char* path) {
  if (path[0] == 0) {
    return 0;
  }
  for (char* p = path + 1; *p != 0; p += 1) {
    if (*p == '/') {
      *p = 0;
      if (mkdir(path, 0755) != 0 && errno != EEXIST) {
        return -1;
      }
      *p = '/';
    }
  }
  if (mkdir(path, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
}

int layout_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  int r = layout_mkdir_p(path);
  *slash = '/';
  return r;
}

static int layout_symlink(const char* target, const char* path) {
  char buf[4096];
  if (strlen(path) >= sizeof(buf)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  memcpy(buf, path, strlen(path) + 1);
  if (layout_parent(buf) != 0) {
    return -1;
  }
  if (symlink(target, path) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
}

static int slash_count(const char* s) {
  int n = 0;
  for (; *s != 0; s += 1) {
    if (*s == '/') {
      n += 1;
    }
  }
  return n;
}

static int nested_rel(char* out, size_t cap, const char* dest, const char* name) {
  int ups = slash_count(dest) + slash_count(name);
  size_t n = 0;
  if (ups <= 0) {
    return snprintf(out, cap, "./%s", name) < 0 ? -1 : 0;
  }
  for (int i = 0; i < ups; i += 1) {
    if (i > 0) {
      if (n + 1 >= cap) {
        return -1;
      }
      out[n] = '/';
      n += 1;
    }
    if (n + 2 >= cap) {
      return -1;
    }
    out[n] = '.';
    out[n + 1] = '.';
    n += 2;
  }
  size_t name_n = strlen(name);
  if (n + 1 + name_n >= cap) {
    return -1;
  }
  out[n] = '/';
  memcpy(out + n + 1, name, name_n + 1);
  return 0;
}

static int link_child(const char* dest, const char* name) {
  if (name[0] == 0) {
    return 0;
  }
  char dir[4096];
  char path[4096];
  char target[4096];
  if (snprintf(dir, sizeof(dir), "%s/node_modules", dest) >= (int)sizeof(dir)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (layout_mkdir_p(dir) != 0) {
    return -1;
  }
  if (nested_rel(target, sizeof(target), dest, name) != 0) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(path, sizeof(path), "%s/node_modules/%s", dest, name) >= (int)sizeof(path)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  return layout_symlink(target, path);
}

static int link_root(const char* name) {
  char path[4096];
  char target[4096];
  char nm[] = "node_modules";
  if (layout_mkdir_p(nm) != 0) {
    return -1;
  }
  if (strchr(name, '/') != NULL) {
    if (snprintf(target, sizeof(target), "../.knot/%s", name) >= (int)sizeof(target)) {
      errno = ENAMETOOLONG;
      return -1;
    }
  } else if (snprintf(target, sizeof(target), ".knot/%s", name) >= (int)sizeof(target)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(path, sizeof(path), "node_modules/%s", name) >= (int)sizeof(path)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  return layout_symlink(target, path);
}

static const char* bin_rel(const char* rel) {
  if (rel[0] == '.' && rel[1] == '/') {
    return rel + 2;
  }
  return rel;
}

static const char* bin_cmd(const char* name) {
  const char* slash = strrchr(name, '/');
  return slash == NULL ? name : slash + 1;
}

static int link_bin(const char* name, const char* cmd, const char* rel) {
  char dir[] = "node_modules/.bin";
  char path[4096];
  char target[4096];
  if (layout_mkdir_p(dir) != 0) {
    return -1;
  }
  if (snprintf(target, sizeof(target), "../.knot/%s/%s", name, bin_rel(rel)) >= (int)sizeof(target)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(path, sizeof(path), "node_modules/.bin/%s", cmd) >= (int)sizeof(path)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  return layout_symlink(target, path);
}

static int each_pair_name(char* pairs, int (*fn)(const char*, const char*, void*), void* ctx) {
  char* s = pairs;
  while (*s != 0) {
    char* key = s;
    char* tab = strchr(s, '\t');
    char* nl = strchr(s, '\n');
    if (tab == NULL) {
      break;
    }
    *tab = 0;
    char* val = tab + 1;
    if (nl != NULL) {
      *nl = 0;
      s = nl + 1;
    } else {
      s += strlen(s);
    }
    if (fn(key, val, ctx) != 0) {
      return -1;
    }
  }
  return 0;
}

static int link_child_pair(const char* key, const char* val, void* ctx) {
  (void)val;
  return link_child((const char*)ctx, key);
}

static int link_bin_pair(const char* key, const char* val, void* ctx) {
  return link_bin((const char*)ctx, key, val);
}

static int layout_field_pairs(const char* text, const char* field, int (*fn)(const char*, const char*, void*), void* ctx) {
  LayoutJsonP p;
  p.at = text;
  p.end = text + strlen(text);
  p.err = 0;
  if (!layout_json_walk(&p, field)) {
    return 0;
  }
  char out[1 << 16];
  if (!layout_json_pairs(&p, out, sizeof(out))) {
    return 0;
  }
  return each_pair_name(out, fn, ctx);
}

static int layout_bins(const char* text, const char* name) {
  LayoutJsonP p;
  p.at = text;
  p.end = text + strlen(text);
  p.err = 0;
  if (!layout_json_walk(&p, "bin")) {
    return 0;
  }
  layout_json_ws(&p);
  if (p.at < p.end && *p.at == '"') {
    char rel[512];
    if (!layout_json_string(&p, rel, sizeof(rel))) {
      return 0;
    }
    return link_bin(name, bin_cmd(name), rel);
  }
  char out[1 << 16];
  if (!layout_json_pairs(&p, out, sizeof(out))) {
    return 0;
  }
  return each_pair_name(out, link_bin_pair, (void*)name);
}

static char* read_pkg_json(const char* dest) {
  char path[4096];
  if (snprintf(path, sizeof(path), "%s/package.json", dest) >= (int)sizeof(path)) {
    errno = ENAMETOOLONG;
    return NULL;
  }
  FILE* f = fopen(path, "rb");
  if (f == NULL) {
    return NULL;
  }
  char* buf = io_mem(malloc(262144));
  if (buf == NULL) {
    fclose(f);
    errno = ENOMEM;
    return NULL;
  }
  size_t n = fread(buf, 1, 262143, f);
  fclose(f);
  buf[n] = 0;
  return buf;
}

int layout_pkg(const char* dest, const char* name) {
  char* text = read_pkg_json(dest);
  if (text == NULL) {
    return -1;
  }
  if (layout_field_pairs(text, "dependencies", link_child_pair, (void*)dest) != 0) {
    free(text);
    return -1;
  }
  if (layout_field_pairs(text, "peerDependencies", link_child_pair, (void*)dest) != 0) {
    free(text);
    return -1;
  }
  if (layout_bins(text, name) != 0) {
    free(text);
    return -1;
  }
  free(text);
  return link_root(name);
}

typedef struct {
  char* dest;
  char* name;
} FsLayoutPkg;

static void fs_layout_pkg_call(IoWork* w) {
  FsLayoutPkg* g = (FsLayoutPkg*)w->data;
  io_sys_end(w, layout_pkg(g->dest, g->name));
}

static Term fs_layout_pkg_pack(Env e, IoWork* w) {
  FsLayoutPkg* g = (FsLayoutPkg*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->dest);
  free(g->name);
  free(g);
  return r;
}

Term fs_layout_pkg_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsLayoutPkg* g = io_mem(malloc(sizeof(FsLayoutPkg)));
  g->dest = io_cstr(e, f[0], &n1);
  g->name = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->dest, n1) || io_nul(g->name, n2)) {
    w->code = EINVAL;
    return fs_layout_pkg_pack(e, w);
  }
  return io_work(w, fs_layout_pkg_call, fs_layout_pkg_pack);
}

static void __attribute__((constructor)) fs_layout_pkg_use(void) {
  io_eff(CID_FS_LAYOUT_PKG, fs_layout_pkg_run, 0);
}
