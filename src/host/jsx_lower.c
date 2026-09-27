#include <ctype.h>
#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Native, syntax-directed JSX lowering. The compiler never shells out to a
// JavaScript runtime for this transform.

typedef struct {
  char* p;
  size_t n;
  size_t cap;
  int err;
} JxBuf;

static void jx_init(JxBuf* b) {
  b->cap = 4096;
  b->n = 0;
  b->err = 0;
  b->p = (char*)malloc(b->cap);
  if (b->p == NULL) b->err = ENOMEM;
  if (!b->err) b->p[0] = 0;
}

static void jx_reserve(JxBuf* b, size_t extra) {
  if (b->err || extra > SIZE_MAX - b->n - 1) {
    b->err = ENOMEM;
    return;
  }
  size_t need = b->n + extra + 1;
  if (need <= b->cap) return;
  size_t cap = b->cap;
  while (cap < need) {
    if (cap > SIZE_MAX / 2) {
      b->err = ENOMEM;
      return;
    }
    cap *= 2;
  }
  char* p = (char*)realloc(b->p, cap);
  if (p == NULL) {
    b->err = ENOMEM;
    return;
  }
  b->p = p;
  b->cap = cap;
}

static void jx_add_n(JxBuf* b, const char* s, size_t n) {
  jx_reserve(b, n);
  if (b->err) return;
  memcpy(b->p + b->n, s, n);
  b->n += n;
  b->p[b->n] = 0;
}

static void jx_add(JxBuf* b, const char* s) {
  jx_add_n(b, s, strlen(s));
}

static void jx_add_c(JxBuf* b, char c) {
  jx_reserve(b, 1);
  if (b->err) return;
  b->p[b->n++] = c;
  b->p[b->n] = 0;
}

static size_t jx_space(const char* s, size_t i, size_t n) {
  while (i < n && isspace((unsigned char)s[i])) i += 1;
  return i;
}

static size_t jx_ident(const char* s, size_t i, size_t n, char* out, size_t out_n) {
  size_t start = i;
  while (i < n && (isalnum((unsigned char)s[i]) || s[i] == '_' || s[i] == '$' || s[i] == '.')) i += 1;
  size_t len = i - start;
  if (out_n > 0) {
    size_t copy = len < out_n - 1 ? len : out_n - 1;
    memcpy(out, s + start, copy);
    out[copy] = 0;
  }
  return i;
}

static size_t jx_quote(const char* s, size_t i, size_t n, JxBuf* b) {
  char q = s[i++];
  jx_add_c(b, q);
  while (i < n) {
    char c = s[i++];
    jx_add_c(b, c);
    if (c == '\\' && i < n) jx_add_c(b, s[i++]);
    else if (c == q) break;
  }
  return i;
}

static char* jx_dup(const char* s, size_t n) {
  char* out = (char*)malloc(n + 1);
  if (out == NULL) return NULL;
  memcpy(out, s, n);
  out[n] = 0;
  return out;
}

static size_t jx_expr(const char* s, size_t i, size_t n, char** out) {
  size_t start = i;
  int depth = 1;
  while (i < n && depth > 0) {
    char c = s[i++];
    if (c == '\'' || c == '"') {
      char q = c;
      while (i < n) {
        char d = s[i++];
        if (d == '\\' && i < n) i += 1;
        else if (d == q) break;
      }
      continue;
    }
    if (c == '`') {
      while (i < n) {
        char d = s[i++];
        if (d == '\\' && i < n) i += 1;
        else if (d == '`') break;
      }
      continue;
    }
    if (c == '{') depth += 1;
    else if (c == '}') depth -= 1;
  }
  if (depth != 0) return 0;
  size_t end = i - 1;
  while (start < end && isspace((unsigned char)s[start])) start += 1;
  while (end > start && isspace((unsigned char)s[end - 1])) end -= 1;
  *out = jx_dup(s + start, end - start);
  return i;
}

static void jx_json_string(JxBuf* b, const char* s, size_t n) {
  jx_add_c(b, '"');
  for (size_t i = 0; i < n; i += 1) {
    char c = s[i];
    if (c == '"' || c == '\\') jx_add_c(b, '\\');
    if (c == '\n') { jx_add(b, "\\n"); continue; }
    if (c == '\r') { jx_add(b, "\\r"); continue; }
    if (c == '\t') { jx_add(b, "\\t"); continue; }
    jx_add_c(b, c);
  }
  jx_add_c(b, '"');
}

typedef struct {
  const char* source;
  size_t n;
  int automatic;
  const char* factory;
  const char* fragment;
  const char* import_source;
  int used_jsx;
  int used_jsxs;
  int used_frag;
  int err;
} JxState;

static char* jx_element(JxState* st, size_t* at);

static char* jx_tag(const char* name, const char* fragment, int automatic, int* used_frag) {
  if (name[0] == 0) {
    if (automatic) *used_frag = 1;
    return jx_dup(automatic ? "Fragment" : fragment, strlen(automatic ? "Fragment" : fragment));
  }
  if (isupper((unsigned char)name[0])) return jx_dup(name, strlen(name));
  JxBuf b;
  jx_init(&b);
  jx_json_string(&b, name, strlen(name));
  char* out = b.err ? NULL : jx_dup(b.p, b.n);
  free(b.p);
  return out;
}

static char* jx_element(JxState* st, size_t* at) {
  const char* s = st->source;
  size_t i = *at;
  if (i >= st->n || s[i] != '<') { st->err = EINVAL; return NULL; }
  i += 1;
  i = jx_space(s, i, st->n);
  char name[256] = {0};
  if (i < st->n && s[i] == '>') {
    i += 1;
  } else {
    if (i >= st->n || !(isalpha((unsigned char)s[i]) || s[i] == '_' || s[i] == '$')) { st->err = EINVAL; return NULL; }
    i = jx_ident(s, i, st->n, name, sizeof(name));
  }

  JxBuf props;
  jx_init(&props);
  int prop_count = 0;
  int self_close = 0;
  if (name[0] != 0) {
    for (;;) {
      i = jx_space(s, i, st->n);
      if (i >= st->n) { st->err = EINVAL; free(props.p); return NULL; }
      if (s[i] == '/') {
        self_close = 1;
        i += 1;
        i = jx_space(s, i, st->n);
        if (i >= st->n || s[i++] != '>') { st->err = EINVAL; free(props.p); return NULL; }
        break;
      }
      if (s[i] == '>') { i += 1; break; }
      if (!(isalpha((unsigned char)s[i]) || s[i] == '_' || s[i] == '$')) { st->err = EINVAL; free(props.p); return NULL; }
      char key[256] = {0};
      i = jx_ident(s, i, st->n, key, sizeof(key));
      i = jx_space(s, i, st->n);
      if (prop_count++ > 0) jx_add(&props, ", ");
      jx_add(&props, key);
      jx_add(&props, ": ");
      if (i < st->n && s[i] == '=') {
        i = jx_space(s, i + 1, st->n);
        if (i >= st->n) { st->err = EINVAL; free(props.p); return NULL; }
        if (s[i] == '{') {
          char* expr = NULL;
          i = jx_expr(s, i + 1, st->n, &expr);
          if (!i || expr == NULL) { st->err = EINVAL; free(props.p); return NULL; }
          jx_add(&props, expr);
          free(expr);
        } else if (s[i] == '\'' || s[i] == '"') {
          size_t start = i;
          char q = s[i++];
          while (i < st->n) {
            char c = s[i++];
            if (c == '\\' && i < st->n) i += 1;
            else if (c == q) break;
          }
          jx_add_n(&props, s + start, i - start);
        } else {
          char value[256] = {0};
          i = jx_ident(s, i, st->n, value, sizeof(value));
          jx_add(&props, value);
        }
      } else {
        jx_add(&props, "true");
      }
    }
  }

  char* tag = jx_tag(name, st->fragment, st->automatic, &st->used_frag);
  if (tag == NULL) { st->err = ENOMEM; free(props.p); return NULL; }
  char* kids[256];
  size_t kid_count = 0;
  if (!self_close) {
    while (i < st->n) {
      if (s[i] == '<') {
        if (i + 1 < st->n && s[i + 1] == '/') {
          i += 2;
          i = jx_space(s, i, st->n);
          char close_name[256] = {0};
          i = jx_ident(s, i, st->n, close_name, sizeof(close_name));
          i = jx_space(s, i, st->n);
          if (i >= st->n || s[i++] != '>') { st->err = EINVAL; break; }
          if (strcmp(close_name, name) != 0) { st->err = EINVAL; break; }
          break;
        }
        if (kid_count >= 256) { st->err = E2BIG; break; }
        kids[kid_count++] = jx_element(st, &i);
        if (st->err) break;
        continue;
      }
      if (s[i] == '{') {
        if (kid_count >= 256) { st->err = E2BIG; break; }
        char* expr = NULL;
        i = jx_expr(s, i + 1, st->n, &expr);
        if (!i || expr == NULL) { st->err = EINVAL; break; }
        kids[kid_count++] = expr;
        continue;
      }
      size_t start = i;
      while (i < st->n && s[i] != '<' && s[i] != '{') i += 1;
      while (start < i && isspace((unsigned char)s[start])) start += 1;
      while (i > start && isspace((unsigned char)s[i - 1])) i -= 1;
      if (i > start && kid_count < 256) {
        JxBuf text;
        jx_init(&text);
        jx_json_string(&text, s + start, i - start);
        kids[kid_count++] = text.err ? NULL : jx_dup(text.p, text.n);
        free(text.p);
      }
    }
    if (i >= st->n && (kid_count == 0 || s[i - 1] != '>')) st->err = EINVAL;
  }

  JxBuf out;
  jx_init(&out);
  if (st->automatic) {
    if (strcmp(tag, "Fragment") == 0) st->used_frag = 1;
    if (kid_count <= 1) { st->used_jsx = 1; jx_add(&out, "jsx("); }
    else { st->used_jsxs = 1; jx_add(&out, "jsxs("); }
  } else {
    jx_add(&out, st->factory);
    jx_add_c(&out, '(');
  }
  jx_add(&out, tag);
  jx_add(&out, ", ");
  if (prop_count == 0 && kid_count == 0) {
    jx_add(&out, "null");
  } else {
    jx_add(&out, "{ ");
    if (props.n > 0) jx_add_n(&out, props.p, props.n);
    if (kid_count == 1) {
      if (props.n > 0) jx_add(&out, ", ");
      jx_add(&out, "children: ");
      if (kids[0]) jx_add(&out, kids[0]);
    } else if (kid_count > 1) {
      if (props.n > 0) jx_add(&out, ", ");
      jx_add(&out, "children: [");
      for (size_t k = 0; k < kid_count; k += 1) {
        if (k > 0) jx_add(&out, ", ");
        if (kids[k]) jx_add(&out, kids[k]);
      }
      jx_add(&out, "]");
    }
    jx_add(&out, " }");
  }
  if (!st->automatic && kid_count > 0) {
    for (size_t k = 0; k < kid_count; k += 1) {
      jx_add(&out, ", ");
      if (kids[k]) jx_add(&out, kids[k]);
    }
  }
  jx_add_c(&out, ')');
  char* result = out.err ? NULL : jx_dup(out.p, out.n);
  if (out.err) st->err = out.err;
  for (size_t k = 0; k < kid_count; k += 1) free(kids[k]);
  free(out.p);
  free(props.p);
  free(tag);
  *at = i;
  return result;
}

static int jx_is_start(const char* source, size_t i, size_t n, size_t out_len, const char* out) {
  if (i + 1 >= n) return 0;
  size_t j = i + 1;
  while (j < n && isspace((unsigned char)source[j])) j += 1;
  if (j >= n || !(source[j] == '>' || source[j] == '/' || isalpha((unsigned char)source[j]) || source[j] == '_' || source[j] == '$')) return 0;
  size_t k = out_len;
  while (k > 0 && isspace((unsigned char)out[k - 1])) k -= 1;
  if (k == 0) return 1;
  char prev = out[k - 1];
  if (strchr("([{=,?:;>", prev) != NULL) return 1;
  if (k >= 6 && strncmp(out + k - 6, "return", 6) == 0) return 1;
  if (isalpha((unsigned char)prev) || isdigit((unsigned char)prev) || prev == '_' || prev == '$' || prev == ')' || prev == ']') return 0;
  return 1;
}

static int jsx_lower_source(const char* source, const char* mode, const char* factory, const char* fragment, const char* import_source, char* out, size_t out_n) {
  JxState st = {source, strlen(source), strcmp(mode, "automatic") == 0, factory, fragment, import_source, 0, 0, 0, 0};
  JxBuf result;
  jx_init(&result);
  size_t i = 0;
  while (i < st.n && !st.err) {
    if (source[i] == '\'' || source[i] == '"' || source[i] == '`') {
      i = jx_quote(source, i, st.n, &result);
      continue;
    }
    if (source[i] == '/' && i + 1 < st.n && (source[i + 1] == '/' || source[i + 1] == '*')) {
      size_t start = i;
      i += 2;
      if (source[start + 1] == '/') while (i < st.n && source[i++] != '\n') {}
      else while (i + 1 < st.n && !(source[i] == '*' && source[i + 1] == '/')) i += 1;
      if (i + 1 < st.n) i += 2;
      jx_add_n(&result, source + start, i - start);
      continue;
    }
    if (source[i] == '<' && jx_is_start(source, i, st.n, result.n, result.p)) {
      char* element = jx_element(&st, &i);
      if (element == NULL) break;
      jx_add(&result, element);
      free(element);
      continue;
    }
    jx_add_c(&result, source[i++]);
  }
  if (st.err || result.err || result.n + 1 > out_n) {
    free(result.p);
    errno = st.err ? st.err : (result.err ? result.err : ENOMEM);
    return -1;
  }
  if (st.automatic && (st.used_jsx || st.used_jsxs || st.used_frag)) {
    JxBuf prefix;
    jx_init(&prefix);
    jx_add(&prefix, "import { ");
    int first = 1;
    if (st.used_jsx) { jx_add(&prefix, "jsx"); first = 0; }
    if (st.used_jsxs) { if (!first) jx_add(&prefix, ", "); jx_add(&prefix, "jsxs"); first = 0; }
    if (st.used_frag) { if (!first) jx_add(&prefix, ", "); jx_add(&prefix, "Fragment"); }
    jx_add(&prefix, " } from \"");
    jx_add(&prefix, import_source);
    jx_add(&prefix, "/jsx-runtime\";\n");
    jx_add_n(&prefix, result.p, result.n);
    free(result.p);
    result = prefix;
  }
  int ok = !result.err && result.n + 1 <= out_n;
  if (ok) memcpy(out, result.p, result.n + 1);
  free(result.p);
  if (!ok) { errno = ENOMEM; return -1; }
  return 0;
}

typedef struct {
  char* text;
  char* mode;
  char* factory;
  char* fragment;
  char* import_source;
  char* out;
} JsxLower;

static void jsx_lower_call(IoWork* w) {
  JsxLower* g = (JsxLower*)w->data;
  io_sys_end(w, jsx_lower_source(g->text, g->mode, g->factory, g->fragment, g->import_source, g->out, 1 << 20));
}

static Term jsx_lower_pack(Env e, IoWork* w) {
  JsxLower* g = (JsxLower*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->text);
  free(g->mode);
  free(g->factory);
  free(g->fragment);
  free(g->import_source);
  free(g->out);
  free(g);
  return r;
}

Term jsx_lower_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0;
  JsxLower* g = io_mem(malloc(sizeof(JsxLower)));
  g->text = io_cstr(e, f[0], &n1);
  g->mode = io_cstr(e, f[1], &n2);
  g->factory = io_cstr(e, f[2], &n3);
  g->fragment = io_cstr(e, f[3], &n4);
  g->import_source = io_cstr(e, f[4], &n5);
  g->out = io_mem(malloc(1 << 20));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->text, n1) || io_nul(g->mode, n2) || io_nul(g->factory, n3)
      || io_nul(g->fragment, n4) || io_nul(g->import_source, n5)) {
    w->code = EINVAL;
    return jsx_lower_pack(e, w);
  }
  return io_work(w, jsx_lower_call, jsx_lower_pack);
}

static void __attribute__((constructor)) jsx_lower_use(void) {
  io_eff(CID_JSX_LOWER, jsx_lower_run, 0);
}
