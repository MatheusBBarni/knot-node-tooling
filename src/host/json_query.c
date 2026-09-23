// Json
// ====

typedef struct {
  const char* at;
  const char* end;
  int err;
} JsonP;

static void json_ws(JsonP* p) {
  while (p->at < p->end && (*p->at == ' ' || *p->at == '\n' || *p->at == '\r' || *p->at == '\t')) {
    p->at += 1;
  }
}

static int json_lit(JsonP* p, const char* s) {
  size_t n = strlen(s);
  if ((size_t)(p->end - p->at) < n || memcmp(p->at, s, n) != 0) {
    p->err = 1;
    return 0;
  }
  p->at += n;
  return 1;
}

static int json_string(JsonP* p, char* out, size_t out_n) {
  json_ws(p);
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

static int json_skip(JsonP* p);

static int json_skip_object(JsonP* p) {
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    if (!json_string(p, NULL, 0)) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    if (!json_skip(p)) {
      return 0;
    }
    json_ws(p);
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

static int json_skip_array(JsonP* p) {
  if (!json_lit(p, "[")) {
    return 0;
  }
  json_ws(p);
  if (p->at < p->end && *p->at == ']') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    if (!json_skip(p)) {
      return 0;
    }
    json_ws(p);
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

static int json_skip(JsonP* p) {
  json_ws(p);
  if (p->at >= p->end) {
    p->err = 1;
    return 0;
  }
  char c = *p->at;
  if (c == '{') {
    return json_skip_object(p);
  }
  if (c == '[') {
    return json_skip_array(p);
  }
  if (c == '"') {
    return json_string(p, NULL, 0);
  }
  if (c == 'n') {
    return json_lit(p, "null");
  }
  if (c == 't') {
    return json_lit(p, "true");
  }
  if (c == 'f') {
    return json_lit(p, "false");
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

static int json_enter(JsonP* p, const char* key) {
  json_ws(p);
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  if (p->at < p->end && *p->at == '}') {
    p->err = 1;
    return 0;
  }
  for (;;) {
    char got[256];
    if (!json_string(p, got, sizeof(got))) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    if (strcmp(got, key) == 0) {
      return 1;
    }
    if (!json_skip(p)) {
      return 0;
    }
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
      continue;
    }
    p->err = 1;
    return 0;
  }
}

static int json_walk(JsonP* p, const char* path) {
  char key[256];
  const char* s = path;
  while (*s != 0) {
    const char* slash = strchr(s, '/');
    size_t n = slash == NULL ? strlen(s) : (size_t)(slash - s);
    if (n == 0 || n >= sizeof(key)) {
      p->err = 1;
      return 0;
    }
    memcpy(key, s, n);
    key[n] = 0;
    if (!json_enter(p, key)) {
      return 0;
    }
    s = slash == NULL ? s + n : slash + 1;
  }
  return 1;
}

static int json_value_as_string(JsonP* p, char* val, size_t val_n) {
  json_ws(p);
  if (p->at < p->end && *p->at == '"') {
    return json_string(p, val, val_n);
  }
  if (p->at < p->end && *p->at == '[') {
    p->at += 1;
    json_ws(p);
    if (p->at < p->end && *p->at == ']') {
      p->at += 1;
      val[0] = 0;
      return 1;
    }
    if (!json_string(p, val, val_n)) {
      return 0;
    }
    for (;;) {
      json_ws(p);
      if (p->at < p->end && *p->at == ',') {
        p->at += 1;
        if (!json_skip(p)) {
          return 0;
        }
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
  if (!json_skip(p)) {
    return 0;
  }
  val[0] = 0;
  return 1;
}

static int json_pairs(JsonP* p, char* out, size_t out_n) {
  json_ws(p);
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  size_t n = 0;
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    out[0] = 0;
    return 1;
  }
  for (;;) {
    char key[256];
    char val[512];
    if (!json_string(p, key, sizeof(key))) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    json_ws(p);
    if (!json_value_as_string(p, val, sizeof(val))) {
      return 0;
    }
    int w = snprintf(out + n, out_n - n, "%s%s\t%s", n == 0 ? "" : "\n", key, val);
    if (w < 0 || n + (size_t)w >= out_n) {
      p->err = 1;
      return 0;
    }
    n += (size_t)w;
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
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

static int json_skip_version(JsonP* p, int* dep) {
  json_ws(p);
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  *dep = 0;
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    char key[256];
    if (!json_string(p, key, sizeof(key))) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    if (strcmp(key, "deprecated") == 0) {
      *dep = 1;
    }
    if (!json_skip(p)) {
      return 0;
    }
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
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

static int json_keys(JsonP* p, char* out, size_t out_n) {
  json_ws(p);
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  size_t n = 0;
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    out[0] = 0;
    return 1;
  }
  for (;;) {
    char key[256];
    if (!json_string(p, key, sizeof(key))) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    if (!json_skip(p)) {
      return 0;
    }
    int w = snprintf(out + n, out_n - n, "%s%s", n == 0 ? "" : "\n", key);
    if (w < 0 || n + (size_t)w >= out_n) {
      p->err = 1;
      return 0;
    }
    n += (size_t)w;
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
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

static int json_undep_keys(JsonP* p, char* out, size_t out_n) {
  json_ws(p);
  if (!json_lit(p, "{")) {
    return 0;
  }
  json_ws(p);
  size_t n = 0;
  out[0] = 0;
  if (p->at < p->end && *p->at == '}') {
    p->at += 1;
    return 1;
  }
  for (;;) {
    char key[256];
    int dep = 0;
    if (!json_string(p, key, sizeof(key))) {
      return 0;
    }
    json_ws(p);
    if (!json_lit(p, ":")) {
      return 0;
    }
    if (!json_skip_version(p, &dep)) {
      return 0;
    }
    if (!dep) {
      int w = snprintf(out + n, out_n - n, "%s%s", n == 0 ? "" : "\n", key);
      if (w < 0 || n + (size_t)w >= out_n) {
        p->err = 1;
        return 0;
      }
      n += (size_t)w;
    }
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
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

static int json_lines(JsonP* p, char* out, size_t out_n) {
  json_ws(p);
  if (!json_lit(p, "[")) {
    return 0;
  }
  json_ws(p);
  size_t n = 0;
  if (p->at < p->end && *p->at == ']') {
    p->at += 1;
    out[0] = 0;
    return 1;
  }
  for (;;) {
    char item[256];
    if (!json_string(p, item, sizeof(item))) {
      return 0;
    }
    int w = snprintf(out + n, out_n - n, "%s%s", n == 0 ? "" : "\n", item);
    if (w < 0 || n + (size_t)w >= out_n) {
      p->err = 1;
      return 0;
    }
    n += (size_t)w;
    json_ws(p);
    if (p->at < p->end && *p->at == ',') {
      p->at += 1;
      json_ws(p);
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

static int json_query(const char* text, const char* path, const char* mode,
  char* out, size_t out_n) {
  JsonP p;
  p.at = text;
  p.end = text + strlen(text);
  p.err = 0;
  if (path[0] != 0 && !json_walk(&p, path)) {
    errno = ENOENT;
    return -1;
  }
  json_ws(&p);
  if (strcmp(mode, "string") == 0) {
    if (!json_string(&p, out, out_n)) {
      errno = ENOENT;
      return -1;
    }
    return 0;
  }
  if (strcmp(mode, "pairs") == 0) {
    if (!json_pairs(&p, out, out_n)) {
      errno = ENOENT;
      return -1;
    }
    return 0;
  }
  if (strcmp(mode, "keys") == 0) {
    if (!json_keys(&p, out, out_n)) {
      errno = ENOENT;
      return -1;
    }
    return 0;
  }
  if (strcmp(mode, "undep_keys") == 0) {
    if (!json_undep_keys(&p, out, out_n)) {
      errno = ENOENT;
      return -1;
    }
    return 0;
  }
  if (strcmp(mode, "lines") == 0) {
    if (!json_lines(&p, out, out_n)) {
      errno = ENOENT;
      return -1;
    }
    return 0;
  }
  errno = EINVAL;
  return -1;

}

typedef struct {
  char* text;
  char* path;
  char* mode;
  char* out;
} JsonQuery;

static void json_query_call(IoWork* w) {
  JsonQuery* g = (JsonQuery*)w->data;
  io_sys_end(w, json_query(g->text, g->path, g->mode, g->out, 1 << 20));
}

static Term json_query_pack(Env e, IoWork* w) {
  JsonQuery* g = (JsonQuery*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->path);
  free(g->mode);
  free(g->out);
  free(g);
  return r;
}

Term json_query_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  uint64_t n3 = 0;
  JsonQuery* g = io_mem(malloc(sizeof(JsonQuery)));
  g->text = io_cstr(e, f[0], &n1);
  g->path = io_cstr(e, f[1], &n2);
  g->mode = io_cstr(e, f[2], &n3);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1) || io_nul(g->path, n2) || io_nul(g->mode, n3)) {
    w->code = EINVAL;
    return json_query_pack(e, w);
  }
  return io_work(w, json_query_call, json_query_pack);
}

static void __attribute__((constructor)) json_query_use(void) {
  io_eff(CID_JSON_QUERY, json_query_run, 0);
}
