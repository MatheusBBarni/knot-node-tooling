#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int knot_sv_ident_start(char c) {
  return isalpha((unsigned char)c) || c == '_' || c == '$';
}

static int knot_sv_ident_char(char c) {
  return knot_sv_ident_start(c) || isdigit((unsigned char)c);
}

static void knot_sv_error(char* out, size_t out_n, size_t line, size_t col, const char* message) {
  snprintf(out, out_n, "line %zu, column %zu: %s", line, col, message);
}

static int knot_sv_check(const char* source, char* out, size_t out_n) {
  char stack[4096];
  size_t depth = 0;
  size_t line = 1, col = 1;
  size_t n = strlen(source);
  for (size_t i = 0; i < n;) {
    char c = source[i];
    if (c == '\n') { line += 1; col = 1; i += 1; continue; }
    if (c == ' ' || c == '\t' || c == '\r') { col += 1; i += 1; continue; }
    if (c == '\'' || c == '"' || c == '`') {
      char q = c;
      size_t start_line = line, start_col = col;
      i += 1; col += 1;
      int closed = 0;
      while (i < n) {
        char d = source[i++]; col += 1;
        if (d == '\\' && i < n) { i += 1; col += 1; continue; }
        if (d == '\n') { line += 1; col = 1; }
        if (d == q) { closed = 1; break; }
      }
      if (!closed) { knot_sv_error(out, out_n, start_line, start_col, "unterminated string"); return -1; }
      continue;
    }
    if (c == '/' && i + 1 < n && source[i + 1] == '/') {
      i += 2; col += 2;
      while (i < n && source[i] != '\n') { i += 1; col += 1; }
      continue;
    }
    if (c == '/' && i + 1 < n && source[i + 1] == '*') {
      size_t start_line = line, start_col = col;
      i += 2; col += 2;
      int closed = 0;
      while (i + 1 < n) {
        if (source[i] == '*' && source[i + 1] == '/') { i += 2; col += 2; closed = 1; break; }
        if (source[i] == '\n') { line += 1; col = 1; i += 1; }
        else { i += 1; col += 1; }
      }
      if (!closed) { knot_sv_error(out, out_n, start_line, start_col, "unterminated comment"); return -1; }
      continue;
    }
    if (knot_sv_ident_start(c)) {
      size_t start = i;
      while (i < n && knot_sv_ident_char(source[i])) { i += 1; col += 1; }
      size_t len = i - start;
      int declaration = (len == 5 && strncmp(source + start, "const", 5) == 0)
        || (len == 3 && strncmp(source + start, "let", 3) == 0)
        || (len == 3 && strncmp(source + start, "var", 3) == 0);
      if (declaration) {
        size_t j = i;
        while (j < n && (source[j] == ' ' || source[j] == '\t' || source[j] == '\r')) j += 1;
        if (j >= n || source[j] == '=' || source[j] == ';' || source[j] == ',' || source[j] == ')' || source[j] == '}') {
          knot_sv_error(out, out_n, line, col, "declaration requires a binding");
          return -1;
        }
      }
      continue;
    }
    if (c == '(' || c == '[' || c == '{') {
      if (depth >= sizeof(stack)) { knot_sv_error(out, out_n, line, col, "nesting limit exceeded"); return -1; }
      stack[depth++] = c;
      i += 1; col += 1; continue;
    }
    if (c == ')' || c == ']' || c == '}') {
      char want = c == ')' ? '(' : c == ']' ? '[' : '{';
      if (depth == 0 || stack[depth - 1] != want) { knot_sv_error(out, out_n, line, col, "unmatched delimiter"); return -1; }
      depth -= 1;
      i += 1; col += 1; continue;
    }
    i += 1; col += 1;
  }
  if (depth != 0) {
    knot_sv_error(out, out_n, line, col, "unclosed delimiter");
    return -1;
  }
  out[0] = 0;
  return 0;
}

typedef struct {
  char* source;
  char* out;
} SyntaxValidate;

static void syntax_validate_call(IoWork* w) {
  SyntaxValidate* g = (SyntaxValidate*)w->data;
  io_sys_end(w, knot_sv_check(g->source, g->out, 1 << 16));
}

static Term syntax_validate_pack(Env e, IoWork* w) {
  SyntaxValidate* g = (SyntaxValidate*)w->data;
  Term r = w->code != 0 ? io_done(e, io_str(e, g->out, strlen(g->out)))
    : io_done(e, io_str(e, "", 0));
  free(g->source);
  free(g->out);
  free(g);
  return r;
}

Term syntax_validate_run(Env e, Term* f, IoWork* w) {
  uint64_t n = 0;
  SyntaxValidate* g = io_mem(malloc(sizeof(SyntaxValidate)));
  g->source = io_cstr(e, f[0], &n);
  g->out = io_mem(malloc(1 << 16));
  g->out[0] = 0;
  w->data = (char*)g;
  if (io_nul(g->source, n)) {
    w->code = EINVAL;
    return syntax_validate_pack(e, w);
  }
  return io_work(w, syntax_validate_call, syntax_validate_pack);
}

static void __attribute__((constructor)) syntax_validate_use(void) {
  io_eff(CID_SYNTAX_VALIDATE, syntax_validate_run, 0);
}
