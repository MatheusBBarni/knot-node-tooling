#ifndef KNOT_PKG_JSON_H
#define KNOT_PKG_JSON_H

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define KNOT_PJ_MAX_ENTRIES 256
#define KNOT_PJ_MAX_CONDITIONS 64

typedef struct {
  const char* start;
  const char* end;
} KnotJsonRange;

typedef struct {
  char key[256];
  KnotJsonRange value;
} KnotJsonEntry;

typedef struct {
  const char* p;
  const char* end;
  int err;
} KnotJsonParser;

static void knot_pj_ws(KnotJsonParser* p) {
  while (p->p < p->end && isspace((unsigned char)*p->p)) p->p += 1;
}

static int knot_pj_string(KnotJsonParser* p, char* out, size_t out_n) {
  knot_pj_ws(p);
  if (p->p >= p->end || *p->p != '"') { p->err = EINVAL; return 0; }
  p->p += 1;
  size_t n = 0;
  while (p->p < p->end && *p->p != '"') {
    char c = *p->p++;
    if (c == '\\' && p->p < p->end) {
      char e = *p->p++;
      if (e == 'n') c = '\n';
      else if (e == 'r') c = '\r';
      else if (e == 't') c = '\t';
      else c = e;
    }
    if (out != NULL) {
      if (n + 1 >= out_n) { p->err = ENOMEM; return 0; }
      out[n] = c;
    }
    n += 1;
  }
  if (p->p >= p->end || *p->p != '"') { p->err = EINVAL; return 0; }
  p->p += 1;
  if (out != NULL) out[n] = 0;
  return 1;
}

static int knot_pj_skip_value(KnotJsonParser* p);

static int knot_pj_skip_object(KnotJsonParser* p) {
  knot_pj_ws(p);
  if (p->p >= p->end || *p->p++ != '{') { p->err = EINVAL; return 0; }
  knot_pj_ws(p);
  if (p->p < p->end && *p->p == '}') { p->p += 1; return 1; }
  for (;;) {
    if (!knot_pj_string(p, NULL, 0)) return 0;
    knot_pj_ws(p);
    if (p->p >= p->end || *p->p++ != ':') { p->err = EINVAL; return 0; }
    if (!knot_pj_skip_value(p)) return 0;
    knot_pj_ws(p);
    if (p->p < p->end && *p->p == ',') { p->p += 1; continue; }
    if (p->p < p->end && *p->p == '}') { p->p += 1; return 1; }
    p->err = EINVAL; return 0;
  }
}

static int knot_pj_skip_array(KnotJsonParser* p) {
  knot_pj_ws(p);
  if (p->p >= p->end || *p->p++ != '[') { p->err = EINVAL; return 0; }
  knot_pj_ws(p);
  if (p->p < p->end && *p->p == ']') { p->p += 1; return 1; }
  for (;;) {
    if (!knot_pj_skip_value(p)) return 0;
    knot_pj_ws(p);
    if (p->p < p->end && *p->p == ',') { p->p += 1; continue; }
    if (p->p < p->end && *p->p == ']') { p->p += 1; return 1; }
    p->err = EINVAL; return 0;
  }
}

static int knot_pj_skip_value(KnotJsonParser* p) {
  knot_pj_ws(p);
  if (p->p >= p->end) { p->err = EINVAL; return 0; }
  if (*p->p == '{') return knot_pj_skip_object(p);
  if (*p->p == '[') return knot_pj_skip_array(p);
  if (*p->p == '"') return knot_pj_string(p, NULL, 0);
  const char* start = p->p;
  while (p->p < p->end && !isspace((unsigned char)*p->p) && !strchr(",]}", *p->p)) p->p += 1;
  if (p->p == start) { p->err = EINVAL; return 0; }
  return 1;
}

static int knot_pj_object_entries(KnotJsonParser* p, KnotJsonEntry* entries, size_t* count) {
  *count = 0;
  knot_pj_ws(p);
  if (p->p >= p->end || *p->p++ != '{') { p->err = EINVAL; return 0; }
  knot_pj_ws(p);
  if (p->p < p->end && *p->p == '}') { p->p += 1; return 1; }
  for (;;) {
    if (*count >= KNOT_PJ_MAX_ENTRIES) { p->err = E2BIG; return 0; }
    if (!knot_pj_string(p, entries[*count].key, sizeof(entries[*count].key))) return 0;
    knot_pj_ws(p);
    if (p->p >= p->end || *p->p++ != ':') { p->err = EINVAL; return 0; }
    knot_pj_ws(p);
    entries[*count].value.start = p->p;
    if (!knot_pj_skip_value(p)) return 0;
    entries[*count].value.end = p->p;
    *count += 1;
    knot_pj_ws(p);
    if (p->p < p->end && *p->p == ',') { p->p += 1; continue; }
    if (p->p < p->end && *p->p == '}') { p->p += 1; return 1; }
    p->err = EINVAL; return 0;
  }
}

static int knot_pj_entry(KnotJsonEntry* entries, size_t count, const char* key, KnotJsonRange* value) {
  for (size_t i = 0; i < count; i += 1) {
    if (strcmp(entries[i].key, key) == 0) { *value = entries[i].value; return 1; }
  }
  return 0;
}

static size_t knot_pj_conditions(const char* text, char values[KNOT_PJ_MAX_CONDITIONS][128]) {
  size_t count = 0;
  const char* p = text;
  while (*p != 0 && count < KNOT_PJ_MAX_CONDITIONS) {
    while (*p == ',' || isspace((unsigned char)*p)) p += 1;
    if (*p == 0) break;
    size_t n = 0;
    while (p[n] != 0 && p[n] != ',') n += 1;
    while (n > 0 && isspace((unsigned char)p[n - 1])) n -= 1;
    size_t copy = n < 127 ? n : 127;
    memcpy(values[count], p, copy);
    values[count][copy] = 0;
    count += 1;
    p += n;
    while (*p != 0 && *p != ',') p += 1;
  }
  return count;
}

static int knot_pj_is_subpath_object(KnotJsonEntry* entries, size_t count) {
  for (size_t i = 0; i < count; i += 1) if (entries[i].key[0] == '.') return 1;
  return 0;
}

static int knot_pj_resolve_range(KnotJsonRange range, const char* subpath, const char* conditions, char* out, size_t out_n);

static int knot_pj_resolve_array(KnotJsonRange range, const char* subpath, const char* conditions, char* out, size_t out_n) {
  KnotJsonParser p = {range.start, range.end, 0};
  knot_pj_ws(&p);
  if (p.p >= p.end || *p.p++ != '[') return 0;
  knot_pj_ws(&p);
  while (p.p < p.end && *p.p != ']') {
    KnotJsonRange item;
    item.start = p.p;
    if (!knot_pj_skip_value(&p)) return 0;
    item.end = p.p;
    if (knot_pj_resolve_range(item, subpath, conditions, out, out_n)) return 1;
    knot_pj_ws(&p);
    if (p.p < p.end && *p.p == ',') p.p += 1;
    knot_pj_ws(&p);
  }
  return 0;
}

static int knot_pj_resolve_range(KnotJsonRange range, const char* subpath, const char* conditions, char* out, size_t out_n) {
  KnotJsonParser p = {range.start, range.end, 0};
  knot_pj_ws(&p);
  if (p.p >= p.end) return 0;
  if (*p.p == '"') return knot_pj_string(&p, out, out_n) && p.err == 0;
  if (*p.p == '[') return knot_pj_resolve_array(range, subpath, conditions, out, out_n);
  if (*p.p != '{') return 0;

  KnotJsonEntry entries[KNOT_PJ_MAX_ENTRIES];
  size_t count = 0;
  if (!knot_pj_object_entries(&p, entries, &count)) return 0;
  if (knot_pj_is_subpath_object(entries, count)) {
    const char* key = subpath[0] == 0 ? "." : subpath;
    if (key[0] != '.') {
      static char normalized[512];
      snprintf(normalized, sizeof(normalized), "./%s", key);
      key = normalized;
    }
    KnotJsonRange child;
    if (!knot_pj_entry(entries, count, key, &child)) return 0;
    return knot_pj_resolve_range(child, ".", conditions, out, out_n);
  }

  char conds[KNOT_PJ_MAX_CONDITIONS][128];
  size_t cond_count = knot_pj_conditions(conditions, conds);
  for (size_t c = 0; c < cond_count; c += 1) {
    KnotJsonRange child;
    if (knot_pj_entry(entries, count, conds[c], &child)
        && knot_pj_resolve_range(child, subpath, conditions, out, out_n)) return 1;
  }
  if (knot_pj_entry(entries, count, "default", &(KnotJsonRange){0}) && cond_count == 0) return 0;
  KnotJsonRange child;
  if (knot_pj_entry(entries, count, "default", &child)) return knot_pj_resolve_range(child, subpath, conditions, out, out_n);
  return 0;
}

static int knot_pj_exports(const char* text, const char* subpath, const char* conditions, char* out, size_t out_n) {
  KnotJsonParser p = {text, text + strlen(text), 0};
  KnotJsonEntry entries[KNOT_PJ_MAX_ENTRIES];
  size_t count = 0;
  if (!knot_pj_object_entries(&p, entries, &count)) return 0;
  KnotJsonRange exports;
  if (!knot_pj_entry(entries, count, "exports", &exports)) return 0;
  return knot_pj_resolve_range(exports, subpath, conditions, out, out_n);
}

static int knot_pj_pattern(const char* pattern, const char* rel) {
  while (*pattern == '.' && pattern[1] == '/') pattern += 2;
  while (*rel == '.' && rel[1] == '/') rel += 2;
  size_t pn = strlen(pattern), rn = strlen(rel);
  if (pn >= 2 && strcmp(pattern + pn - 2, "/*") == 0) return strncmp(pattern, rel, pn - 1) == 0;
  for (size_t i = 0; i < pn; i += 1) {
    if (pattern[i] == '*') {
      size_t prefix = i;
      size_t suffix = pn - i - 1;
      return rn >= prefix + suffix && strncmp(pattern, rel, prefix) == 0
        && strcmp(pattern + i + 1, rel + rn - suffix) == 0;
    }
  }
  return strcmp(pattern, rel) == 0;
}

static int knot_pj_side_effects(const char* text, const char* rel, char* out, size_t out_n) {
  KnotJsonParser p = {text, text + strlen(text), 0};
  KnotJsonEntry entries[KNOT_PJ_MAX_ENTRIES];
  size_t count = 0;
  if (!knot_pj_object_entries(&p, entries, &count)) return 0;
  KnotJsonRange se;
  if (!knot_pj_entry(entries, count, "sideEffects", &se)) {
    if (out_n < 2) return 0;
    strcpy(out, "1");
    return 1;
  }
  KnotJsonParser v = {se.start, se.end, 0};
  knot_pj_ws(&v);
  if (v.p < v.end && *v.p == 'f') { strcpy(out, "0"); return 1; }
  if (v.p < v.end && *v.p == 't') { strcpy(out, "1"); return 1; }
  if (v.p < v.end && *v.p == '[') {
    v.p += 1;
    while (v.p < v.end && *v.p != ']') {
      char pattern[512];
      if (!knot_pj_string(&v, pattern, sizeof(pattern))) return 0;
      if (knot_pj_pattern(pattern, rel)) { strcpy(out, "1"); return 1; }
      knot_pj_ws(&v);
      if (v.p < v.end && *v.p == ',') v.p += 1;
      knot_pj_ws(&v);
    }
    strcpy(out, "0");
    return 1;
  }
  strcpy(out, "1");
  return 1;
}

#endif
