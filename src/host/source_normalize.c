#include <errno.h>
#include <stdlib.h>
#include <string.h>

#define KNOT_SN_MAX (4 * 1024 * 1024)

typedef struct {
  char* source;
  char* out;
} SourceNormalize;

static int knot_sn_push(char* out, size_t* n, char c) {
  if (*n + 1 >= KNOT_SN_MAX) { errno = E2BIG; return 0; }
  out[*n] = c;
  *n += 1;
  out[*n] = 0;
  return 1;
}

static int knot_sn_copy_string(const char* source, size_t* i, size_t length, char* out, size_t* n, char quote) {
  if (!knot_sn_push(out, n, '"')) return 0;
  *i += 1;
  while (*i < length) {
    char c = source[*i];
    *i += 1;
    if (c == '\\') {
      if (!knot_sn_push(out, n, c)) return 0;
      if (*i >= length) { errno = EINVAL; return 0; }
      if (!knot_sn_push(out, n, source[*i])) return 0;
      *i += 1;
      continue;
    }
    if (c == quote) {
      return knot_sn_push(out, n, '"');
    }
    if (c == '"') {
      if (!knot_sn_push(out, n, '\\')) return 0;
    }
    if (!knot_sn_push(out, n, c)) return 0;
  }
  errno = EINVAL;
  return 0;
}

static int knot_sn_copy_opaque(const char* source, size_t* i, size_t length, char* out, size_t* n, char quote) {
  if (!knot_sn_push(out, n, quote)) return 0;
  *i += 1;
  while (*i < length) {
    char c = source[*i];
    *i += 1;
    if (!knot_sn_push(out, n, c)) return 0;
    if (c == '\\') {
      if (*i >= length || !knot_sn_push(out, n, source[*i])) return 0;
      *i += 1;
      continue;

    }
    if (c == quote) return 1;
  }
  errno = EINVAL;
  return 0;
}
static int knot_sn_is_ident_start(char c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_' || c == '$';
}

static int knot_sn_is_ident_char(char c) {
  return knot_sn_is_ident_start(c) || (c >= '0' && c <= '9');
}

static int knot_sn_validate_declarations(const char* source) {
  size_t n = strlen(source);
  size_t i = 0;
  char stack[4096];
  size_t depth = 0;
  while (i < n) {
    if (source[i] == '\'' || source[i] == '\"' || source[i] == '`') {
      char quote = source[i++];
      while (i < n) {
        char c = source[i++];
        if (c == '\\' && i < n) { i += 1; continue; }
        if (c == quote) break;
      }
      continue;
    }
    if (source[i] == '/' && i + 1 < n && source[i + 1] == '/') {
      i += 2;
      while (i < n && source[i] != '\n') i += 1;
      continue;
    }
    if (source[i] == '/' && i + 1 < n && source[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(source[i] == '*' && source[i + 1] == '/')) i += 1;
      if (i + 1 >= n) { errno = EINVAL; return -1; }
      i += 2;
      continue;
    }
    if (source[i] == '(' || source[i] == '[' || source[i] == '{') {
      if (depth >= sizeof(stack)) { errno = E2BIG; return -1; }
      stack[depth++] = source[i];
      i += 1;
      continue;
    }
    if (source[i] == ')' || source[i] == ']' || source[i] == '}') {
      char want = source[i] == ')' ? '(' : source[i] == ']' ? '[' : '{';
      if (depth == 0 || stack[depth - 1] != want) { errno = EINVAL; return -1; }
      depth -= 1;
      i += 1;
      continue;
    }
    if (!knot_sn_is_ident_start(source[i])) { i += 1; continue; }
    size_t start = i;
    while (i < n && knot_sn_is_ident_char(source[i])) i += 1;
    size_t length = i - start;
    int declaration = (length == 5 && strncmp(source + start, "const", 5) == 0)
      || (length == 3 && strncmp(source + start, "let", 3) == 0)
      || (length == 3 && strncmp(source + start, "var", 3) == 0);
    if (declaration) {
      size_t j = i;
      while (j < n && (source[j] == ' ' || source[j] == '\t' || source[j] == '\r' || source[j] == '\n')) j += 1;
      if (j >= n || source[j] == '=' || source[j] == ';' || source[j] == ',' || source[j] == ')' || source[j] == '}') {
        errno = EINVAL;
        return -1;
      }
    }
  }
  if (depth != 0) { errno = EINVAL; return -1; }
  return 0;
}

static int knot_sn_normalize(const char* source, char* out) {
  if (knot_sn_validate_declarations(source) != 0) return -1;
  size_t length = strlen(source);
  size_t i = 0, n = 0;
  out[0] = 0;
  while (i < length) {
    char c = source[i];
    if (c == '\'' ) {
      if (!knot_sn_copy_string(source, &i, length, out, &n, '\'')) return -1;
      continue;
    }
    if (c == '"' || c == '`') {
      if (!knot_sn_copy_opaque(source, &i, length, out, &n, c)) return -1;
      continue;
    }
    if (c == '/' && i + 1 < length && source[i + 1] == '/') {
      do {
        if (!knot_sn_push(out, &n, source[i])) return -1;
        i += 1;
      } while (i < length && source[i - 1] != '\n');
      continue;
    }
    if (c == '/' && i + 1 < length && source[i + 1] == '*') {
      if (!knot_sn_push(out, &n, source[i])) return -1;
      if (!knot_sn_push(out, &n, source[i + 1])) return -1;
      i += 2;
      int closed = 0;
      while (i < length) {
        if (!knot_sn_push(out, &n, source[i])) return -1;
        if (i + 1 < length && source[i] == '*' && source[i + 1] == '/') {
          if (!knot_sn_push(out, &n, source[i + 1])) return -1;
          i += 2;
          closed = 1;
          break;
        }
        i += 1;
      }
      if (!closed) { errno = EINVAL; return -1; }
      continue;
    }
    if (!knot_sn_push(out, &n, c)) return -1;
    i += 1;
  }
  return 0;
}

static void source_normalize_call(IoWork* w) {
  SourceNormalize* g = (SourceNormalize*)w->data;
  io_sys_end(w, knot_sn_normalize(g->source, g->out));
}

static Term source_normalize_pack(Env e, IoWork* w) {
  SourceNormalize* g = (SourceNormalize*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->source);
  free(g->out);
  free(g);
  return r;
}

Term source_normalize_run(Env e, Term* f, IoWork* w) {
  uint64_t n = 0;
  SourceNormalize* g = io_mem(malloc(sizeof(SourceNormalize)));
  g->source = io_cstr(e, f[0], &n);
  g->out = io_mem(malloc(KNOT_SN_MAX));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->source, n)) {
    w->code = EINVAL;
    return source_normalize_pack(e, w);
  }
  return io_work(w, source_normalize_call, source_normalize_pack);
}

static void __attribute__((constructor)) source_normalize_use(void) {
  io_eff(CID_SOURCE_NORMALIZE, source_normalize_run, 0);
}
