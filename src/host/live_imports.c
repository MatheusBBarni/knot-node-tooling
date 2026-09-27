#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define KNOT_LIVE_MAX 512

typedef struct {
  char local[128];
  char imported[128];
  int used;
} KnotImport;

typedef struct {
  size_t start;
  size_t end;
} KnotImportRange;

static int knot_id_start(char c) {
  return isalpha((unsigned char)c) || c == '_' || c == '$';
}

static int knot_id_char(char c) {
  return knot_id_start(c) || isdigit((unsigned char)c);
}

static size_t knot_skip_quote(const char* s, size_t i, size_t n) {
  char q = s[i++];
  while (i < n) {
    char c = s[i++];
    if (c == '\\' && i < n) i += 1;
    else if (c == q) break;
  }
  return i;
}

static size_t knot_skip_comment(const char* s, size_t i, size_t n) {
  if (i + 1 >= n) return i + 1;
  if (s[i + 1] == '/') {
    i += 2;
    while (i < n && s[i++] != '\n') {}
    return i;
  }
  i += 2;
  while (i + 1 < n && !(s[i] == '*' && s[i + 1] == '/')) i += 1;
  return i + (i + 1 < n ? 2 : 0);
}

static size_t knot_skip_space(const char* s, size_t i, size_t n) {
  while (i < n && isspace((unsigned char)s[i])) i += 1;
  return i;
}

static size_t knot_word(const char* s, size_t i, size_t n, char* out, size_t out_n) {
  size_t start = i;
  while (i < n && knot_id_char(s[i])) i += 1;
  size_t len = i - start;
  size_t copy = len < out_n - 1 ? len : out_n - 1;
  memcpy(out, s + start, copy);
  out[copy] = 0;
  return i;
}

static int knot_word_is(const char* s, size_t i, size_t n, const char* word) {
  size_t m = strlen(word);
  return i + m <= n && strncmp(s + i, word, m) == 0
    && (i == 0 || !knot_id_char(s[i - 1]))
    && (i + m == n || !knot_id_char(s[i + m]));
}

static void knot_add_import(KnotImport* imports, size_t* count, const char* imported, const char* local) {
  if (*count >= KNOT_LIVE_MAX || local[0] == 0) return;
  for (size_t i = 0; i < *count; i += 1) {
    if (strcmp(imports[i].local, local) == 0 && strcmp(imports[i].imported, imported) == 0) return;
  }
  snprintf(imports[*count].local, sizeof(imports[*count].local), "%s", local);
  snprintf(imports[*count].imported, sizeof(imports[*count].imported), "%s", imported);
  imports[*count].used = 0;
  *count += 1;
}

static size_t knot_import_decl(const char* s, size_t i, size_t n, KnotImport* imports, size_t* count) {
  size_t start = i;
  i = knot_skip_space(s, i + 6, n);
  if (i < n && s[i] == '(') return start;
  if (i < n && (s[i] == '\'' || s[i] == '"')) return knot_skip_quote(s, i, n);
  size_t clause_start = i;
  while (i < n && s[i] != ';' && s[i] != '\n') {
    if (s[i] == '\'' || s[i] == '"') break;
    if (s[i] == '/' && i + 1 < n && (s[i + 1] == '/' || s[i + 1] == '*')) break;
    i += 1;
  }
  size_t clause_end = i;
  while (i < n && s[i] != '\'' && s[i] != '"' && s[i] != ';' && s[i] != '\n') i += 1;
  if (i >= n || (s[i] != '\'' && s[i] != '"')) return start;
  size_t spec_end = knot_skip_quote(s, i, n);
  size_t p = clause_start;
  while (p < clause_end && isspace((unsigned char)s[p])) p += 1;
  if (p < clause_end && s[p] == '{') {
    p += 1;
    while (p < clause_end && s[p] != '}') {
      p = knot_skip_space(s, p, clause_end);
      if (p >= clause_end || s[p] == '}') break;
      if (knot_word_is(s, p, clause_end, "type")) p = knot_skip_space(s, p + 4, clause_end);
      char imported[128] = {0};
      p = knot_word(s, p, clause_end, imported, sizeof(imported));
      p = knot_skip_space(s, p, clause_end);
      char local[128] = {0};
      if (knot_word_is(s, p, clause_end, "as")) {
        p = knot_skip_space(s, p + 2, clause_end);
        p = knot_word(s, p, clause_end, local, sizeof(local));
      } else {
        snprintf(local, sizeof(local), "%s", imported);
      }
      knot_add_import(imports, count, imported, local);
      while (p < clause_end && s[p] != ',' && s[p] != '}') p += 1;
      if (p < clause_end && s[p] == ',') p += 1;
    }
  } else if (p < clause_end && s[p] == '*') {
    p = knot_skip_space(s, p + 1, clause_end);
    if (knot_word_is(s, p, clause_end, "as")) {
      p = knot_skip_space(s, p + 2, clause_end);
      char local[128] = {0};
      knot_word(s, p, clause_end, local, sizeof(local));
      knot_add_import(imports, count, "*", local);
    }
  } else if (p < clause_end && knot_id_start(s[p])) {
    char local[128] = {0};
    knot_word(s, p, clause_end, local, sizeof(local));
    knot_add_import(imports, count, "default", local);
  }
  return spec_end;
}

static int knot_range_contains(KnotImportRange* ranges, size_t count, size_t i, size_t* next) {
  for (size_t k = 0; k < count; k += 1) {
    if (i >= ranges[k].start && i < ranges[k].end) {
      *next = ranges[k].end;
      return 1;
    }
  }
  return 0;
}

static int knot_live_imports(const char* source, char* out, size_t out_n) {
  size_t n = strlen(source);
  KnotImport imports[KNOT_LIVE_MAX];
  KnotImportRange ranges[KNOT_LIVE_MAX];
  size_t import_count = 0, range_count = 0;
  size_t i = 0;
  while (i < n) {
    if (source[i] == '\'' || source[i] == '"' || source[i] == '`') { i = knot_skip_quote(source, i, n); continue; }
    if (source[i] == '/' && i + 1 < n && (source[i + 1] == '/' || source[i + 1] == '*')) { i = knot_skip_comment(source, i, n); continue; }
    if (knot_word_is(source, i, n, "import")) {
      size_t end = knot_import_decl(source, i, n, imports, &import_count);
      if (end != i && range_count < KNOT_LIVE_MAX) {
        ranges[range_count++] = (KnotImportRange){i, end};
        i = end;
        continue;
      }
    }
    i += 1;
  }

  i = 0;
  while (i < n) {
    size_t next = 0;
    if (knot_range_contains(ranges, range_count, i, &next)) { i = next; continue; }
    if (source[i] == '\'' || source[i] == '"' || source[i] == '`') { i = knot_skip_quote(source, i, n); continue; }
    if (source[i] == '/' && i + 1 < n && (source[i + 1] == '/' || source[i + 1] == '*')) { i = knot_skip_comment(source, i, n); continue; }
    if (knot_id_start(source[i])) {
      char id[128] = {0};
      size_t end = knot_word(source, i, n, id, sizeof(id));
      for (size_t k = 0; k < import_count; k += 1) if (strcmp(imports[k].local, id) == 0) imports[k].used = 1;
      i = end;
      continue;
    }
    i += 1;
  }

  size_t written = 0;
  out[0] = 0;
  for (size_t k = 0; k < import_count; k += 1) {
    if (!imports[k].used) continue;
    size_t len = strlen(imports[k].imported);
    if (written + len + (written ? 1 : 0) + 1 > out_n) { errno = ENOMEM; return -1; }
    if (written) out[written++] = '\n';
    memcpy(out + written, imports[k].imported, len);
    written += len;
    out[written] = 0;
  }
  return 0;
}

typedef struct {
  char* text;
  char* out;
} LiveImports;

static void live_imports_call(IoWork* w) {
  LiveImports* g = (LiveImports*)w->data;
  io_sys_end(w, knot_live_imports(g->text, g->out, 1 << 20));
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
