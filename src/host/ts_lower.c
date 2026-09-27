#include <ctype.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// The native compiler owns the TypeScript lowering boundary.
// This adapter performs only syntax-directed rewrites; it never starts a runtime.

typedef struct {
  char* p;
  size_t n;
  size_t cap;
  int err;
} TsBuf;

static void ts_buf_init(TsBuf* b) {
  b->cap = 4096;
  b->n = 0;
  b->err = 0;
  b->p = (char*)malloc(b->cap);
  if (b->p == NULL) b->err = ENOMEM;
  if (!b->err) b->p[0] = 0;
}

static void ts_buf_reserve(TsBuf* b, size_t extra) {
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

static void ts_buf_add_n(TsBuf* b, const char* s, size_t n) {
  ts_buf_reserve(b, n);
  if (b->err) return;
  memcpy(b->p + b->n, s, n);
  b->n += n;
  b->p[b->n] = 0;
}

static void ts_buf_add(TsBuf* b, const char* s) {
  ts_buf_add_n(b, s, strlen(s));
}

static void ts_buf_add_c(TsBuf* b, char c) {
  ts_buf_reserve(b, 1);
  if (b->err) return;
  b->p[b->n++] = c;
  b->p[b->n] = 0;
}

static int ts_ident_start(char c) {
  return isalpha((unsigned char)c) || c == '_' || c == '$';
}

static int ts_ident_char(char c) {
  return ts_ident_start(c) || isdigit((unsigned char)c);
}

static size_t ts_skip_space(const char* s, size_t i, size_t n) {
  while (i < n && isspace((unsigned char)s[i])) i += 1;
  return i;
}

static size_t ts_copy_quote(const char* s, size_t i, size_t n, TsBuf* b) {
  char q = s[i++];
  ts_buf_add_c(b, q);
  while (i < n) {
    char c = s[i++];
    ts_buf_add_c(b, c);
    if (c == '\\' && i < n) {
      ts_buf_add_c(b, s[i++]);
    } else if (c == q) {
      break;
    }
  }
  return i;
}

static size_t ts_copy_comment(const char* s, size_t i, size_t n, TsBuf* b) {
  if (i + 1 >= n) return i;
  ts_buf_add_n(b, s + i, 2);
  i += 2;
  if (s[i - 2] == '/' && s[i - 1] == '/') {
    while (i < n) {
      char c = s[i++];
      ts_buf_add_c(b, c);
      if (c == '\n') break;
    }
    return i;
  }
  while (i < n) {
    char c = s[i++];
    ts_buf_add_c(b, c);
    if (c == '*' && i < n && s[i] == '/') {
      ts_buf_add_c(b, s[i++]);
      break;
    }
  }
  return i;
}

static size_t ts_balanced_end(const char* s, size_t i, size_t n, char open, char close) {
  if (i >= n || s[i] != open) return i;
  int depth = 0;
  while (i < n) {
    char c = s[i];
    if (c == '\'' || c == '"') {
      i = ts_skip_space(s, i, n);
      char q = s[i++];
      while (i < n) {
        char d = s[i++];
        if (d == '\\' && i < n) i += 1;
        else if (d == q) break;
      }
      continue;
    }
    if (c == '`') {
      i += 1;
      while (i < n) {
        char d = s[i++];
        if (d == '\\' && i < n) i += 1;
        else if (d == '`') break;
      }
      continue;
    }
    if (c == '/' && i + 1 < n && (s[i + 1] == '/' || s[i + 1] == '*')) {
      i = ts_skip_space(s, i, n);
      if (i + 1 < n) {
        i += 2;
        if (s[i - 1] == '/') while (i < n && s[i++] != '\n') {}
        else while (i + 1 < n && !(s[i] == '*' && s[i + 1] == '/')) i += 1;
        if (i + 1 <= n && i >= 2 && s[i - 2] == '*' && s[i - 1] == '/') {}
      }
      continue;
    }
    if (c == open) depth += 1;
    if (c == close) {
      depth -= 1;
      if (depth == 0) return i;
    }
    i += 1;
  }
  return n;
}

static int ts_word_at(const char* s, size_t i, size_t n, const char* word) {
  size_t m = strlen(word);
  if (i + m > n || strncmp(s + i, word, m) != 0) return 0;
  if (i > 0 && ts_ident_char(s[i - 1])) return 0;
  if (i + m < n && ts_ident_char(s[i + m])) return 0;
  return 1;
}

static size_t ts_read_word(const char* s, size_t i, size_t n, char* out, size_t out_n) {
  size_t start = i;
  while (i < n && ts_ident_char(s[i])) i += 1;
  size_t len = i - start;
  if (out_n > 0) {
    size_t copy = len < out_n - 1 ? len : out_n - 1;
    memcpy(out, s + start, copy);
    out[copy] = 0;
  }
  return i;
}

static size_t ts_try_import_equals(const char* s, size_t i, size_t n, TsBuf* b) {
  if (!ts_word_at(s, i, n, "import")) return 0;
  size_t j = ts_skip_space(s, i + 6, n);
  if (j >= n || !ts_ident_start(s[j])) return 0;
  char name[256];
  j = ts_read_word(s, j, n, name, sizeof(name));
  j = ts_skip_space(s, j, n);
  if (j >= n || s[j++] != '=') return 0;
  j = ts_skip_space(s, j, n);
  if (!ts_word_at(s, j, n, "require")) return 0;
  j = ts_skip_space(s, j + 7, n);
  if (j >= n || s[j++] != '(') return 0;
  j = ts_skip_space(s, j, n);
  if (j >= n || (s[j] != '\'' && s[j] != '"')) return 0;
  char q = s[j++];
  size_t spec_start = j;
  while (j < n && s[j] != q) {
    if (s[j] == '\\' && j + 1 < n) j += 2;
    else j += 1;
  }
  if (j >= n) return 0;
  size_t spec_len = j - spec_start;
  j = ts_skip_space(s, j + 1, n);
  if (j >= n || s[j++] != ')') return 0;
  j = ts_skip_space(s, j, n);
  if (j < n && s[j] == ';') j += 1;
  ts_buf_add(b, "import ");
  ts_buf_add(b, name);
  ts_buf_add(b, " from \"");
  ts_buf_add_n(b, s + spec_start, spec_len);
  ts_buf_add(b, "\";");
  return j;
}

static size_t ts_try_export_equals(const char* s, size_t i, size_t n, TsBuf* b) {
  if (!ts_word_at(s, i, n, "export")) return 0;
  size_t j = ts_skip_space(s, i + 6, n);
  if (j >= n || s[j] != '=') return 0;
  j = ts_skip_space(s, j + 1, n);
  size_t start = j;
  int depth = 0;
  while (j < n) {
    char c = s[j];
    if (c == '\'' || c == '"') {
      j = ts_skip_space(s, j, n);
      char q = s[j++];
      while (j < n) {
        char d = s[j++];
        if (d == '\\' && j < n) j += 1;
        else if (d == q) break;
      }
      continue;
    }
    if (c == '(' || c == '[' || c == '{') depth += 1;
    else if (c == ')' || c == ']' || c == '}') {
      if (depth > 0) depth -= 1;
    } else if (depth == 0 && (c == ';' || c == '\n')) {
      break;
    }
    j += 1;
  }
  while (j > start && isspace((unsigned char)s[j - 1])) j -= 1;
  ts_buf_add(b, "module.exports = ");
  ts_buf_add_n(b, s + start, j - start);
  ts_buf_add(b, ";");
  if (j < n && s[j] == ';') j += 1;
  return j;
}

typedef struct {
  char name[128];
} TsMember;

static int ts_member_find(TsMember* members, size_t count, const char* name) {
  for (size_t i = 0; i < count; i += 1) if (strcmp(members[i].name, name) == 0) return 1;
  return 0;
}

static void ts_replace_members(const char* s, size_t n, const char* ns, TsMember* members, size_t count, TsBuf* b) {
  size_t i = 0;
  while (i < n) {
    if (s[i] == '\'' || s[i] == '"') {
      i = ts_copy_quote(s, i, n, b);
      continue;
    }
    if (s[i] == '/' && i + 1 < n && (s[i + 1] == '/' || s[i + 1] == '*')) {
      i = ts_copy_comment(s, i, n, b);
      continue;
    }
    if (ts_ident_start(s[i])) {
      char word[128];
      size_t j = ts_read_word(s, i, n, word, sizeof(word));
      if (ts_member_find(members, count, word)) {
        ts_buf_add(b, ns);
        ts_buf_add(b, ".");
        ts_buf_add(b, word);
      } else {
        ts_buf_add_n(b, s + i, j - i);
      }
      i = j;
      continue;
    }
    ts_buf_add_c(b, s[i++]);
  }
}

static size_t ts_namespace_body(const char* ns, const char* body, size_t n, TsBuf* b) {
  TsMember members[128];
  size_t count = 0;
  size_t i = 0;
  while (i < n) {
    if (ts_word_at(body, i, n, "export")) {
      size_t j = ts_skip_space(body, i + 6, n);
      if (ts_word_at(body, j, n, "const") || ts_word_at(body, j, n, "let") || ts_word_at(body, j, n, "var")) {
        j = ts_skip_space(body, j + (body[j] == 'l' ? 3 : 5), n);
        if (j < n && ts_ident_start(body[j]) && count < 128) {
          j = ts_read_word(body, j, n, members[count].name, sizeof(members[count].name));
          count += 1;
        }
      } else if (ts_word_at(body, j, n, "function")) {
        j = ts_skip_space(body, j + 8, n);
        if (j < n && ts_ident_start(body[j]) && count < 128) {
          j = ts_read_word(body, j, n, members[count].name, sizeof(members[count].name));
          count += 1;
        }
      }
    }
    i += 1;
  }

  i = 0;
  while (i < n) {
    if (ts_word_at(body, i, n, "export")) {
      size_t j = ts_skip_space(body, i + 6, n);
      const char* kind = NULL;
      size_t kind_len = 0;
      if (ts_word_at(body, j, n, "const")) { kind = "const"; kind_len = 5; }
      else if (ts_word_at(body, j, n, "let")) { kind = "let"; kind_len = 3; }
      else if (ts_word_at(body, j, n, "var")) { kind = "var"; kind_len = 3; }
      if (kind != NULL) {
        j = ts_skip_space(body, j + kind_len, n);
        char name[128];
        j = ts_read_word(body, j, n, name, sizeof(name));
        j = ts_skip_space(body, j, n);
        if (j < n && body[j] == '=') {
          j = ts_skip_space(body, j + 1, n);
          size_t start = j;
          int depth = 0;
          while (j < n) {
            if (body[j] == '(' || body[j] == '[' || body[j] == '{') depth += 1;
            else if (body[j] == ')' || body[j] == ']' || body[j] == '}') { if (depth > 0) depth -= 1; }
            else if (depth == 0 && (body[j] == ';' || body[j] == '\n')) break;
            j += 1;
          }
          ts_buf_add(b, "  ");
          ts_buf_add(b, ns);
          ts_buf_add(b, ".");
          ts_buf_add(b, name);
          ts_buf_add(b, " = ");
          ts_replace_members(body + start, j - start, ns, members, count, b);
          ts_buf_add(b, ";\n");
          if (j < n && body[j] == ';') j += 1;
          i = j;
          continue;
        }
      }
      if (ts_word_at(body, j, n, "function")) {
        j = ts_skip_space(body, j + 8, n);
        char name[128];
        j = ts_read_word(body, j, n, name, sizeof(name));
        size_t header_start = j;
        while (j < n && body[j] != '{') j += 1;
        if (j < n) {
          size_t end = ts_balanced_end(body, j, n, '{', '}');
          ts_buf_add(b, "  function ");
          ts_buf_add(b, name);
          ts_buf_add_n(b, body + header_start, (j - header_start) + 1);
          ts_replace_members(body + j + 1, end > j + 1 ? end - j - 1 : 0, ns, members, count, b);
          ts_buf_add(b, "}\n  ");
          ts_buf_add(b, ns);
          ts_buf_add(b, ".");
          ts_buf_add(b, name);
          ts_buf_add(b, " = ");
          ts_buf_add(b, name);
          ts_buf_add(b, ";\n");
          i = end < n ? end + 1 : end;
          continue;
        }
      }
    }
    ts_buf_add_c(b, body[i++]);
  }
  return count;
}

static size_t ts_try_namespace(const char* s, size_t i, size_t n, TsBuf* b) {
  int exported = 0;
  size_t j = i;
  if (ts_word_at(s, j, n, "export")) {
    exported = 1;
    j = ts_skip_space(s, j + 6, n);
  }
  if (!ts_word_at(s, j, n, "namespace")) return 0;
  j = ts_skip_space(s, j + 9, n);
  if (j >= n || !ts_ident_start(s[j])) return 0;
  char name[128];
  j = ts_read_word(s, j, n, name, sizeof(name));
  j = ts_skip_space(s, j, n);
  if (j >= n || s[j] != '{') return 0;
  size_t end = ts_balanced_end(s, j, n, '{', '}');
  if (end <= j || end > n) return 0;
  ts_buf_add(b, exported ? "export const " : "const ");
  ts_buf_add(b, name);
  ts_buf_add(b, " = (function () {\n  const ");
  ts_buf_add(b, name);
  ts_buf_add(b, " = {};\n");
  TsBuf body;
  ts_buf_init(&body);
  ts_namespace_body(name, s + j + 1, end - j - 1, &body);
  ts_buf_add_n(b, body.p, body.n);
  free(body.p);
  ts_buf_add(b, "  return ");
  ts_buf_add(b, name);
  ts_buf_add(b, ";\n})();");
  if (end < n && s[end] == ';') end += 1;
  return end < n ? end + 1 : end;
}

static size_t ts_try_constructor(const char* s, size_t i, size_t n, TsBuf* b) {
  if (!ts_word_at(s, i, n, "constructor")) return 0;
  size_t j = ts_skip_space(s, i + 11, n);
  if (j >= n || s[j] != '(') return 0;
  size_t close = ts_balanced_end(s, j, n, '(', ')');
  if (close <= j || close > n) return 0;
  int has_prop = 0;
  for (size_t k = j + 1; k + 3 < close; k += 1) {
    if (ts_word_at(s, k, close, "public") || ts_word_at(s, k, close, "private") || ts_word_at(s, k, close, "protected")) {
      has_prop = 1;
      break;
    }
  }
  if (!has_prop) return 0;
  j += 1;
  TsBuf params;
  TsBuf assigns;
  ts_buf_init(&params);
  ts_buf_init(&assigns);
  size_t part = j;
  int depth = 0;
  while (j < close) {
    if (s[j] == '(' || s[j] == '[' || s[j] == '{') depth += 1;
    else if (s[j] == ')' || s[j] == ']' || s[j] == '}') { if (depth > 0) depth -= 1; }
    if ((s[j] == ',' && depth == 0) || j + 1 == close) {
      size_t stop = j + 1 == close ? j + 1 : j;
      size_t a = ts_skip_space(s, part, stop);
      size_t z = stop;
      while (z > a && isspace((unsigned char)s[z - 1])) z -= 1;
      size_t p = a;
      char mod[32] = {0};
      if (ts_word_at(s, p, z, "public")) { strcpy(mod, "public"); p = ts_skip_space(s, p + 6, z); }
      else if (ts_word_at(s, p, z, "private")) { strcpy(mod, "private"); p = ts_skip_space(s, p + 7, z); }
      else if (ts_word_at(s, p, z, "protected")) { strcpy(mod, "protected"); p = ts_skip_space(s, p + 9, z); }
      if (mod[0]) {
        char name[128];
        size_t name_end = ts_read_word(s, p, z, name, sizeof(name));
        ts_buf_add(&params, name);
        size_t eq = name_end;
        while (eq < z && s[eq] != '=') eq += 1;
        if (eq < z) ts_buf_add_n(&params, s + eq, z - eq);
        ts_buf_add(&assigns, " this.");
        ts_buf_add(&assigns, name);
        ts_buf_add(&assigns, " = ");
        ts_buf_add(&assigns, name);
        ts_buf_add(&assigns, ";");
      } else {
        ts_buf_add_n(&params, s + a, z - a);
      }
      if (j < close && s[j] == ',') ts_buf_add(&params, ", ");
      part = j + 1;
    }
    j += 1;
  }
  size_t body_start = ts_skip_space(s, close + 1, n);
  if (body_start >= n || s[body_start] != '{') {
    free(params.p); free(assigns.p);
    return 0;
  }
  size_t body_end = ts_balanced_end(s, body_start, n, '{', '}');
  if (body_end <= body_start || body_end > n) {
    free(params.p); free(assigns.p);
    return 0;
  }
  ts_buf_add(b, "constructor(");
  ts_buf_add_n(b, params.p, params.n);
  ts_buf_add(b, ") {");
  ts_buf_add_n(b, assigns.p, assigns.n);
  ts_buf_add_n(b, s + body_start + 1, body_end > body_start + 1 ? body_end - body_start - 1 : 0);
  ts_buf_add_c(b, '}');
  free(params.p); free(assigns.p);
  return body_end < n ? body_end + 1 : body_end;
}

static size_t ts_skip_satisfies(const char* s, size_t i, size_t n, TsBuf* b) {
  if (!ts_word_at(s, i, n, "satisfies")) return 0;
  size_t j = ts_skip_space(s, i + 9, n);
  if (j < n && s[j] == '{') {
    size_t end = ts_balanced_end(s, j, n, '{', '}');
    return end < n ? end + 1 : end;
  }
  while (j < n) {
    if (s[j] == ';' || s[j] == ',' || s[j] == ')' || s[j] == ']' || s[j] == '\n') break;
    j += 1;
  }
  return j;
}

static int ts_lower_source(const char* source, char* out, size_t out_n) {
  size_t n = strlen(source);
  TsBuf b;
  ts_buf_init(&b);
  size_t i = 0;
  while (i < n && !b.err) {
    if (source[i] == '\'' || source[i] == '"') {
      i = ts_copy_quote(source, i, n, &b);
      continue;
    }
    if (source[i] == '/' && i + 1 < n && (source[i + 1] == '/' || source[i + 1] == '*')) {
      i = ts_copy_comment(source, i, n, &b);
      continue;
    }
    size_t next = ts_try_import_equals(source, i, n, &b);
    if (next) { i = next; continue; }
    next = ts_try_export_equals(source, i, n, &b);
    if (next) { i = next; continue; }
    next = ts_try_namespace(source, i, n, &b);
    if (next) { i = next; continue; }
    next = ts_try_constructor(source, i, n, &b);
    if (next) { i = next; continue; }
    next = ts_skip_satisfies(source, i, n, &b);
    if (next) { i = next; continue; }
    ts_buf_add_c(&b, source[i++]);
  }
  int ok = !b.err && b.n + 1 <= out_n;
  if (ok) memcpy(out, b.p, b.n + 1);
  free(b.p);
  if (!ok) {
    errno = ok ? 0 : (b.err ? b.err : ENOMEM);
    return -1;
  }
  return 0;
}

typedef struct {
  char* text;
  char* out;
} TsLower;

static void ts_lower_call(IoWork* w) {
  TsLower* g = (TsLower*)w->data;
  io_sys_end(w, ts_lower_source(g->text, g->out, 1 << 20));
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
