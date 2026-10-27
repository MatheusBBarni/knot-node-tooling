#ifndef KNOT_DATA_TOML_H
#define KNOT_DATA_TOML_H

#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "data_limits.h"
#include "span_status.h"

/* A node's mode distinguishes a header-created implicit table from a table
 * created by dotted assignments. Only the former can later be declared. */
typedef struct KnotTomlNode KnotTomlNode;
struct KnotTomlNode {
  KnotTomlNode *allocated, *first, *last, *next;
  char *name, *scalar;
  size_t name_len, scalar_len, depth;
  unsigned char kind, mode, aot;
};
enum { KT_SCALAR, KT_TABLE, KT_ARRAY };
enum { KT_ROOT, KT_IMPLICIT, KT_DOTTED, KT_EXPLICIT, KT_INLINE };
typedef struct { char *s; size_t n, cap; } KnotTomlBuf;
typedef struct { char *s; size_t n; } KnotTomlKey;
typedef struct { KnotTomlNode *parent, *child; } KnotTomlSlot;
typedef struct {
  const unsigned char *at, *end;
  KnotTomlNode *allocated, *root;
  KnotTomlSlot *slots;
  size_t capacity, count, nodes;
  const char *error;
} KnotTomlParser;

static int knot_toml_fail(KnotTomlParser *p, const char *code) {
  if (!p->error) p->error = code;
  return 0;
}
static int knot_toml_add(KnotTomlParser *p, KnotTomlBuf *b, const char *s, size_t n) {
  if (n > SIZE_MAX - b->n - 1) return knot_toml_fail(p, "resource_limit");
  if (b->n + n + 1 > b->cap) {
    size_t next = b->cap ? b->cap : 32;
    while (next < b->n + n + 1) {
      if (next > SIZE_MAX / 2) { next = b->n + n + 1; break; }
      next *= 2;
    }
    char *mem = (char *)realloc(b->s, next);
    if (!mem) return knot_toml_fail(p, "resource_limit");
    b->s = mem; b->cap = next;
  }
  if (n) memcpy(b->s + b->n, s, n);
  b->n += n; b->s[b->n] = 0;
  return 1;
}
static int knot_toml_byte(KnotTomlParser *p, KnotTomlBuf *b, char c) {
  return knot_toml_add(p, b, &c, 1);
}
static KnotTomlNode *knot_toml_node(KnotTomlParser *p, unsigned kind, unsigned mode, size_t depth) {
  if (depth >= knot_limit_depth() || p->nodes >= knot_limit_nodes()) { knot_toml_fail(p, "resource_limit"); return NULL; }
  KnotTomlNode *n = (KnotTomlNode *)calloc(1, sizeof(*n));
  if (!n) { knot_toml_fail(p, "resource_limit"); return NULL; }
  n->kind = kind; n->mode = mode; n->depth = depth;
  n->allocated = p->allocated; p->allocated = n; p->nodes++;
  return n;
}
static uint64_t knot_toml_hash(const KnotTomlNode *parent, const char *s, size_t n) {
  uint64_t h = 1469598103934665603ULL ^ (uint64_t)(uintptr_t)parent;
  for (size_t i = 0; i < n; i++) h = (h ^ (unsigned char)s[i]) * 1099511628211ULL;
  return h;
}
/* The hash index provides constant-time decoded-key lookup; the linked tree
 * separately retains input order. Its key includes the parent table. */
static KnotTomlNode *knot_toml_lookup(KnotTomlParser *p, KnotTomlNode *parent, KnotTomlKey key) {
  if (!p->capacity) return NULL;
  KnotTomlSlot *slots = p->slots;
  size_t pos = (size_t)knot_toml_hash(parent, key.s, key.n) & (p->capacity - 1);
  while (slots[pos].child) {
    KnotTomlNode *n = slots[pos].child;
    if (slots[pos].parent == parent && n->name_len == key.n && !memcmp(n->name, key.s, key.n)) return n;
    pos = (pos + 1) & (p->capacity - 1);
  }
  return NULL;
}
static int knot_toml_rehash(KnotTomlParser *p) {
  size_t cap = p->capacity ? p->capacity * 2 : 64;
  if (cap < p->capacity || cap > SIZE_MAX / sizeof(KnotTomlSlot)) return knot_toml_fail(p, "resource_limit");
  KnotTomlSlot *slots = (KnotTomlSlot *)calloc(cap, sizeof(*slots));
  if (!slots) return knot_toml_fail(p, "resource_limit");
  KnotTomlSlot *old = p->slots;
  for (size_t i = 0; i < p->capacity; i++) {
    if (!old[i].child) continue;
    KnotTomlNode *n = old[i].child;
    size_t at = (size_t)knot_toml_hash(old[i].parent, n->name, n->name_len) & (cap - 1);
    while (slots[at].child) at = (at + 1) & (cap - 1);
    slots[at] = old[i];
  }
  free(old); p->slots = slots; p->capacity = cap;
  return 1;
}
static int knot_toml_attach(KnotTomlParser *p, KnotTomlNode *parent, KnotTomlKey key, KnotTomlNode *child) {
  if (p->count + 1 >= p->capacity / 2 && !knot_toml_rehash(p)) return 0;
  char *name = (char *)malloc(key.n + 1);
  if (!name) return knot_toml_fail(p, "resource_limit");
  memcpy(name, key.s, key.n); name[key.n] = 0;
  child->name = name; child->name_len = key.n;
  if (parent->last) parent->last->next = child; else parent->first = child;
  parent->last = child;
  KnotTomlSlot *slots = p->slots;
  size_t at = (size_t)knot_toml_hash(parent, key.s, key.n) & (p->capacity - 1);
  while (slots[at].child) at = (at + 1) & (p->capacity - 1);
  slots[at].parent = parent; slots[at].child = child; p->count++;
  return 1;
}
static void knot_toml_push(KnotTomlNode *array, KnotTomlNode *child) {
  if (array->last) array->last->next = child; else array->first = child;
  array->last = child;
}
static void knot_toml_space(KnotTomlParser *p) {
  while (p->at < p->end && (*p->at == ' ' || *p->at == '\t')) p->at++;
}
static int knot_toml_newline(KnotTomlParser *p) {
  if (p->at < p->end && *p->at == '\r') {
    if (p->at + 1 == p->end || p->at[1] != '\n') return knot_toml_fail(p, "syntax_error");
    p->at += 2; return 1;
  }
  if (p->at < p->end && *p->at == '\n') { p->at++; return 1; }
  return 0;
}
static void knot_toml_comment(KnotTomlParser *p) {
  if (p->at == p->end || *p->at != '#') return;
  p->at++;
  while (p->at < p->end && *p->at != '\n' && *p->at != '\r') {
    unsigned char c = *p->at++;
    if ((c < 32 && c != '\t') || c == 127) { knot_toml_fail(p, "syntax_error"); return; }
  }
}
static void knot_toml_array_space(KnotTomlParser *p) {
  while (p->at < p->end && !p->error) {
    knot_toml_space(p); knot_toml_comment(p);
    if (p->error || !knot_toml_newline(p)) break;
  }
}
static int knot_toml_hex(unsigned char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}
static int knot_toml_unicode(KnotTomlParser *p, KnotTomlBuf *b, size_t digits) {
  if ((size_t)(p->end - p->at) < digits) return knot_toml_fail(p, "syntax_error");
  uint32_t cp = 0;
  for (size_t j = 0; j < digits; j++) {
    int x = knot_toml_hex(*p->at++);
    if (x < 0) return knot_toml_fail(p, "syntax_error");
    cp = (cp << 4) | (unsigned)x;
  }
  if (cp > 0x10ffff || (cp >= 0xd800 && cp <= 0xdfff)) return knot_toml_fail(p, "syntax_error");
  char out[4]; size_t n;
  if (cp < 0x80) { out[0] = (char)cp; n = 1; }
  else if (cp < 0x800) { out[0] = (char)(0xc0 | (cp >> 6)); out[1] = (char)(0x80 | (cp & 63)); n = 2; }
  else if (cp < 0x10000) { out[0] = (char)(0xe0 | (cp >> 12)); out[1] = (char)(0x80 | ((cp >> 6) & 63)); out[2] = (char)(0x80 | (cp & 63)); n = 3; }
  else { out[0] = (char)(0xf0 | (cp >> 18)); out[1] = (char)(0x80 | ((cp >> 12) & 63)); out[2] = (char)(0x80 | ((cp >> 6) & 63)); out[3] = (char)(0x80 | (cp & 63)); n = 4; }
  return knot_toml_add(p, b, out, n);
}
static KnotTomlKey knot_toml_string(KnotTomlParser *p) {
  KnotTomlBuf b = {0};
  if (p->at == p->end) { knot_toml_fail(p, "syntax_error"); return (KnotTomlKey){0}; }
  unsigned char quote = *p->at++;
  int multi = p->end - p->at >= 2 && p->at[0] == quote && p->at[1] == quote;
  if (multi) { p->at += 2; knot_toml_newline(p); }
  while (p->at < p->end && !p->error) {
    unsigned char c = *p->at++;
    if (c == quote) {
      if (!multi) {
        if (!b.s) b.s = (char *)calloc(1, 1);
        if (!b.s) knot_toml_fail(p, "resource_limit");
        return (KnotTomlKey){b.s, b.n};
      }
      if (p->end - p->at >= 2 && p->at[0] == quote && p->at[1] == quote) {
        p->at += 2;
        for (int j = 0; j < 2 && p->at < p->end && *p->at == quote; j++, p->at++)
          if (!knot_toml_byte(p, &b, (char)quote)) break;
        if (p->at < p->end && *p->at == quote) knot_toml_fail(p, "syntax_error");
        if (!b.s) b.s = (char *)calloc(1, 1);
        if (!b.s) knot_toml_fail(p, "resource_limit");
        return (KnotTomlKey){b.s, b.n};
      }
      if (!knot_toml_byte(p, &b, (char)c)) break;
      continue;
    }
    if ((c < 32 && c != '\t' && (!multi || (c != '\n' && c != '\r'))) || c == 127 ||
        (c == '\r' && (!multi || p->at == p->end || *p->at != '\n')) || (c == '\n' && !multi)) {
      knot_toml_fail(p, "syntax_error"); break;
    }
    if (c != '\\' || quote == '\'') { if (!knot_toml_byte(p, &b, (char)c)) break; continue; }
    if (p->at == p->end) { knot_toml_fail(p, "syntax_error"); break; }
    c = *p->at++;
    char escaped;
    switch (c) {
      case 'b': escaped = '\b'; break; case 't': escaped = '\t'; break;
      case 'n': escaped = '\n'; break; case 'f': escaped = '\f'; break;
      case 'r': escaped = '\r'; break; case '"': escaped = '"'; break;
      case '\\': escaped = '\\'; break;
      case 'u': case 'U': if (!knot_toml_unicode(p, &b, c == 'u' ? 4 : 8)) break; continue;
      default:
        if (multi && (c == ' ' || c == '\t' || c == '\r' || c == '\n')) {
          p->at--;
          knot_toml_space(p);
          if (!knot_toml_newline(p)) { knot_toml_fail(p, "syntax_error"); break; }
          while (p->at < p->end && !p->error) {
            if (*p->at == ' ' || *p->at == '\t') p->at++;
            else if (*p->at == '\r' || *p->at == '\n') knot_toml_newline(p);
            else break;
          }
          continue;
        }
        knot_toml_fail(p, "syntax_error"); break;
    }
    if (!p->error && !knot_toml_byte(p, &b, escaped)) break;
  }
  knot_toml_fail(p, "syntax_error"); free(b.s); return (KnotTomlKey){0};
}
static int knot_toml_bare(unsigned char c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-';
}
static KnotTomlKey knot_toml_key(KnotTomlParser *p) {
  knot_toml_space(p);
  if (p->at < p->end && (*p->at == '"' || *p->at == '\'')) {
    if (p->end - p->at >= 3 && p->at[0] == p->at[1] && p->at[1] == p->at[2]) {
      knot_toml_fail(p, "syntax_error"); return (KnotTomlKey){0};
    }
    return knot_toml_string(p);
  }
  const unsigned char *start = p->at;
  while (p->at < p->end && knot_toml_bare(*p->at)) p->at++;
  if (p->at == start) { knot_toml_fail(p, "syntax_error"); return (KnotTomlKey){0}; }
  size_t n = (size_t)(p->at - start);
  char *s = (char *)malloc(n + 1);
  if (!s) { knot_toml_fail(p, "resource_limit"); return (KnotTomlKey){0}; }
  memcpy(s, start, n); s[n] = 0;
  return (KnotTomlKey){s, n};
}
static size_t knot_toml_path(KnotTomlParser *p, KnotTomlKey keys[129]) {
  size_t n = 0;
  do {
    if (n >= 129) { knot_toml_fail(p, "resource_limit"); break; }
    keys[n++] = knot_toml_key(p);
    if (p->error) break;
    knot_toml_space(p);
    if (p->at == p->end || *p->at != '.') break;
    p->at++;
  } while (1);
  return n;
}
static void knot_toml_free_keys(KnotTomlKey *keys, size_t n) {
  for (size_t j = 0; j < n; j++) free(keys[j].s);
}
static KnotTomlNode *knot_toml_descend(KnotTomlParser *p, KnotTomlNode *parent, KnotTomlKey key, int header) {
  KnotTomlNode *n = knot_toml_lookup(p, parent, key);
  if (!n) {
    n = knot_toml_node(p, KT_TABLE, header ? KT_IMPLICIT : KT_DOTTED, parent->depth + 1);
    if (!n || !knot_toml_attach(p, parent, key, n)) return NULL;
  }
  if (n->kind == KT_ARRAY && n->aot && header) n = n->last;
  if (!n || n->kind != KT_TABLE || n->mode == KT_INLINE) {
    knot_toml_fail(p, "duplicate_key"); return NULL;
  }
  return n;
}
static int knot_toml_digit(unsigned char c) { return c >= '0' && c <= '9'; }
static int knot_toml_date_num(const char *s) { return (s[0]-'0')*10 + s[1]-'0'; }
static int knot_toml_date(KnotTomlParser *p, const char *s, size_t n, KnotTomlBuf *out) {
  size_t at = 0;
  int hasdate = n >= 10 && knot_toml_digit(s[0]) && knot_toml_digit(s[1]) && knot_toml_digit(s[2]) && knot_toml_digit(s[3]) &&
      s[4] == '-' && knot_toml_digit(s[5]) && knot_toml_digit(s[6]) && s[7] == '-' && knot_toml_digit(s[8]) && knot_toml_digit(s[9]);
  if (hasdate) {
    int year = (s[0]-'0')*1000 + (s[1]-'0')*100 + (s[2]-'0')*10 + s[3]-'0';
    int month = knot_toml_date_num(s + 5), day = knot_toml_date_num(s + 8);
    int leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    int days = month == 2 ? (leap ? 29 : 28) : month == 4 || month == 6 || month == 9 || month == 11 ? 30 : 31;
    if (month < 1 || month > 12 || day < 1 || day > days) return knot_toml_fail(p, "syntax_error");
    if (!knot_toml_add(p, out, s, 10)) return 0;
    at = 10;
    if (at == n) return 1;
    if (s[at] != 'T' && s[at] != 't' && s[at] != ' ') return knot_toml_fail(p, "syntax_error");
    if (!knot_toml_byte(p, out, 'T')) return 0;
    at++;
  }
  if (n - at < 8 || !knot_toml_digit(s[at]) || !knot_toml_digit(s[at+1]) || s[at+2] != ':' ||
      !knot_toml_digit(s[at+3]) || !knot_toml_digit(s[at+4]) || s[at+5] != ':' ||
      !knot_toml_digit(s[at+6]) || !knot_toml_digit(s[at+7]) ||
      knot_toml_date_num(s+at) > 23 || knot_toml_date_num(s+at+3) > 59 || knot_toml_date_num(s+at+6) > 59) return knot_toml_fail(p, "syntax_error");
  if (!knot_toml_add(p, out, s + at, 8)) return 0;
  at += 8;
  if (at < n && s[at] == '.') {
    size_t start = at++;
    while (at < n && knot_toml_digit(s[at])) at++;
    if (at == start + 1 || !knot_toml_add(p, out, s + start, at - start)) return knot_toml_fail(p, "syntax_error");
  }
  if (at < n && (s[at] == 'Z' || s[at] == 'z')) {
    if (!hasdate || !knot_toml_byte(p, out, 'Z')) return knot_toml_fail(p, "syntax_error");
    at++;
  } else if (at < n && (s[at] == '+' || s[at] == '-')) {
    if (!hasdate || n-at != 6 || !knot_toml_digit(s[at+1]) || !knot_toml_digit(s[at+2]) || s[at+3] != ':' ||
        !knot_toml_digit(s[at+4]) || !knot_toml_digit(s[at+5]) ||
        knot_toml_date_num(s+at+1) > 23 || knot_toml_date_num(s+at+4) > 59 || !knot_toml_add(p, out, s+at, 6))
      return knot_toml_fail(p, "syntax_error");
    at += 6;
  }
  return at == n ? 1 : knot_toml_fail(p, "syntax_error");
}
static int knot_toml_decimal(const char *s, size_t n, size_t *at, int leading_zero) {
  size_t i = *at;
  if (i == n || !knot_toml_digit(s[i])) return 0;
  if (!leading_zero && s[i] == '0' && i + 1 < n && (knot_toml_digit(s[i+1]) || s[i+1] == '_')) return 0;
  i++;
  while (i < n && (knot_toml_digit(s[i]) || s[i] == '_')) {
    if (s[i] == '_' && (i+1 == n || !knot_toml_digit(s[i+1]) || !knot_toml_digit(s[i-1]))) return 0;
    i++;
  }
  *at = i; return 1;
}
static KnotTomlKey knot_toml_atom(KnotTomlParser *p) {
  const unsigned char *start = p->at;
  if (p->end - p->at >= 19 && knot_toml_digit(p->at[0]) && knot_toml_digit(p->at[1]) &&
      knot_toml_digit(p->at[2]) && knot_toml_digit(p->at[3]) && p->at[4] == '-' && p->at[7] == '-' &&
      p->at[10] == ' ' && knot_toml_digit(p->at[11]) && knot_toml_digit(p->at[12]) && p->at[13] == ':') p->at += 11;
  while (p->at < p->end && *p->at != ' ' && *p->at != '\t' && *p->at != '\r' && *p->at != '\n' &&
      *p->at != ',' && *p->at != '#' && *p->at != ']' && *p->at != '}') p->at++;
  return (KnotTomlKey){(char *)start, (size_t)(p->at - start)};
}
static int knot_toml_scalar(KnotTomlParser *p, KnotTomlNode *node, KnotTomlKey token) {
  const char *s = token.s; size_t n = token.n;
  if (n == 4 && !memcmp(s, "true", 4)) node->scalar = (char *)"true";
  else if (n == 5 && !memcmp(s, "false", 5)) node->scalar = (char *)"false";
  if (node->scalar) { node->scalar_len = n; node->mode = 2; return 1; }
  size_t start = s[0] == '+' || s[0] == '-' ? 1 : 0;
  if ((n-start == 3) && (!memcmp(s+start, "inf", 3) || !memcmp(s+start, "nan", 3)))
    return knot_toml_fail(p, "data_number");
  KnotTomlBuf b = {0};
  if ((n >= 10 && s[4] == '-' && s[7] == '-') || (n >= 8 && s[2] == ':' && s[5] == ':')) {
    if (!knot_toml_date(p, s, n, &b)) { free(b.s); return 0; }
    node->scalar = b.s; node->scalar_len = b.n;
    node->mode = 1; return 1; /* A date serializes as a JSON string. */
  }
  int base = 10;
  if (n >= 3 && s[0] == '0' && (s[1] == 'x' || s[1] == 'o' || s[1] == 'b')) {
    base = s[1] == 'x' ? 16 : s[1] == 'o' ? 8 : 2;
    for (size_t j = 2; j < n; j++) {
      if (s[j] == '_' && j > 2 && j+1 < n && knot_toml_hex((unsigned char)s[j-1]) >= 0 &&
          knot_toml_hex((unsigned char)s[j+1]) >= 0 && knot_toml_hex((unsigned char)s[j-1]) < base &&
          knot_toml_hex((unsigned char)s[j+1]) < base) continue;
      int digit = knot_toml_hex((unsigned char)s[j]);
      if (digit < 0 || digit >= base) return knot_toml_fail(p, "syntax_error");
    }
    uint64_t value = 0;
    for (size_t j = 2; j < n; j++) {
      if (s[j] == '_') continue;
      unsigned digit = (unsigned)knot_toml_hex((unsigned char)s[j]);
      if (value > (9007199254740991ULL - digit) / (unsigned)base) return knot_toml_fail(p, "data_number");
      value = value * (unsigned)base + digit;
    }
    char repr[32]; int written = snprintf(repr, sizeof(repr), "%llu", (unsigned long long)value);
    if (written < 0 || !knot_toml_add(p, &b, repr, (size_t)written)) return 0;
    node->scalar = b.s; node->scalar_len = b.n; return 1;
  }
  size_t at = start;
  if (!knot_toml_decimal(s, n, &at, 0)) return knot_toml_fail(p, "syntax_error");
  int floating = 0;
  if (at < n && s[at] == '.') {
    floating = 1; at++;
    if (!knot_toml_decimal(s, n, &at, 1)) return knot_toml_fail(p, "syntax_error");
  }
  if (at < n && (s[at] == 'e' || s[at] == 'E')) {
    floating = 1; at++;
    if (at < n && (s[at] == '+' || s[at] == '-')) at++;
    if (!knot_toml_decimal(s, n, &at, 1)) return knot_toml_fail(p, "syntax_error");
  }
  if (at != n) return knot_toml_fail(p, "syntax_error");
  for (size_t j = start; j < n; j++) if (s[j] != '_' && !knot_toml_byte(p, &b, s[j])) { free(b.s); return 0; }
  if (!b.s) return knot_toml_fail(p, "syntax_error");
  if (!floating) {
    uint64_t value = 0;
    for (size_t j = start; j < b.n; j++) {
      unsigned digit = (unsigned)(b.s[j] - '0');
      if (value > (9007199254740991ULL-digit)/10) { free(b.s); return knot_toml_fail(p, "data_number"); }
      value = value*10 + digit;
    }
  } else {
    /* strtod uses the process's decimal locale; adapt only its input copy.
     * The JSON representation itself always retains TOML's ASCII dot. */
    const char *decimal = localeconv()->decimal_point;
    KnotTomlBuf localized = {0};
    const char *number = b.s;
    if (strcmp(decimal, ".")) {
      const char *dot = strchr(b.s, '.');
      if (dot) {
        if (!knot_toml_add(p, &localized, b.s, (size_t)(dot - b.s)) ||
            !knot_toml_add(p, &localized, decimal, strlen(decimal)) ||
            !knot_toml_add(p, &localized, dot + 1, strlen(dot + 1))) {
          free(localized.s); free(b.s); return 0;
        }
        number = localized.s;
      }
    }
    char *endptr;
    double value = strtod(number, &endptr);
    int valid = !*endptr && isfinite(value);
    free(localized.s);
    if (!valid) { free(b.s); return knot_toml_fail(p, "data_number"); }
  }
  if (start && s[0] == '-' && !knot_toml_byte(p, &b, ' ')) { free(b.s); return 0; }
  if (start && s[0] == '-') { memmove(b.s+1, b.s, b.n-1); b.s[0] = '-'; }
  node->scalar = b.s; node->scalar_len = b.n;
  return 1;
}
static KnotTomlNode *knot_toml_value(KnotTomlParser *p, size_t depth) {
  if (p->error) return NULL;
  if (depth >= knot_limit_depth()) { knot_toml_fail(p, "resource_limit"); return NULL; }
  if (p->at == p->end) { knot_toml_fail(p, "syntax_error"); return NULL; }
  unsigned char c = *p->at;
  if (c == '"' || c == '\'') {
    KnotTomlKey str = knot_toml_string(p);
    if (p->error) { free(str.s); return NULL; }
    KnotTomlNode *n = knot_toml_node(p, KT_SCALAR, 1, depth);
    if (!n) { free(str.s); return NULL; }
    n->scalar = str.s; n->scalar_len = str.n; return n;
  }
  if (c == '[') {
    p->at++;
    KnotTomlNode *array = knot_toml_node(p, KT_ARRAY, 0, depth);
    if (!array) return NULL;
    knot_toml_array_space(p);
    if (p->at < p->end && *p->at == ']') { p->at++; return array; }
    while (!p->error) {
      KnotTomlNode *child = knot_toml_value(p, depth+1);
      if (!child) return NULL;
      knot_toml_push(array, child);
      knot_toml_array_space(p);
      if (p->at < p->end && *p->at == ']') { p->at++; return array; }
      if (p->at == p->end || *p->at++ != ',') { knot_toml_fail(p, "syntax_error"); return NULL; }
      knot_toml_array_space(p);
      if (p->at < p->end && *p->at == ']') { p->at++; return array; }
    }
    return NULL;
  }
  if (c == '{') {
    p->at++;
    KnotTomlNode *object = knot_toml_node(p, KT_TABLE, KT_INLINE, depth);
    if (!object) return NULL;
    knot_toml_space(p);
    if (p->at < p->end && *p->at == '}') { p->at++; return object; }
    while (!p->error) {
      KnotTomlKey keys[129] = {{0}};
      size_t count = knot_toml_path(p, keys);
      if (!p->error && (p->at == p->end || *p->at++ != '=')) knot_toml_fail(p, "syntax_error");
      knot_toml_space(p);
      KnotTomlNode *parent = object;
      for (size_t j = 0; !p->error && j+1 < count; j++) parent = knot_toml_descend(p, parent, keys[j], 0);
      if (!p->error && knot_toml_lookup(p, parent, keys[count-1])) knot_toml_fail(p, "duplicate_key");
      KnotTomlNode *child = !p->error ? knot_toml_value(p, parent->depth+1) : NULL;
      if (child && !p->error) knot_toml_attach(p, parent, keys[count-1], child);
      knot_toml_free_keys(keys, count);
      if (p->error) return NULL;
      knot_toml_space(p);
      if (p->at < p->end && *p->at == '}') { p->at++; return object; }
      if (p->at == p->end || *p->at++ != ',') { knot_toml_fail(p, "syntax_error"); return NULL; }
      knot_toml_space(p);
      if (p->at == p->end || *p->at == '}' || *p->at == '\r' || *p->at == '\n') {
        knot_toml_fail(p, "syntax_error"); return NULL;
      }
    }
    return NULL;
  }
  KnotTomlKey token = knot_toml_atom(p);
  if (!token.n) { knot_toml_fail(p, "syntax_error"); return NULL; }
  KnotTomlNode *node = knot_toml_node(p, KT_SCALAR, 0, depth);
  if (!node || !knot_toml_scalar(p, node, token)) return NULL;
  return node;
}
static int knot_toml_json_string(KnotTomlParser *p, KnotTomlBuf *b, const char *s, size_t n) {
  if (!knot_toml_byte(p, b, '"')) return 0;
  for (size_t j = 0; j < n; j++) {
    unsigned char c = (unsigned char)s[j];
    if (c == '"' || c == '\\') {
      if (!knot_toml_byte(p, b, '\\') || !knot_toml_byte(p, b, (char)c)) return 0;
    } else if (c < 32) {
      static const char hex[] = "0123456789abcdef";
      char escape[] = {'\\', 'u', '0', '0', hex[c >> 4], hex[c & 15]};
      if (!knot_toml_add(p, b, escape, sizeof(escape))) return 0;
    } else if (!knot_toml_byte(p, b, (char)c)) return 0;
  }
  return knot_toml_byte(p, b, '"');
}
typedef struct { KnotTomlNode *node; uint32_t index; } KnotTomlIndex;
static int knot_toml_index(KnotTomlNode *node, uint32_t *index) {
  if (!node->name_len || node->name_len > 10 || (node->name[0] == '0' && node->name_len != 1)) return 0;
  uint64_t number = 0;
  for (size_t j = 0; j < node->name_len; j++) {
    unsigned char digit = (unsigned char)node->name[j];
    if (digit < '0' || digit > '9') return 0;
    number = number * 10 + digit - '0';
  }
  if (number >= UINT32_MAX) return 0;
  *index = (uint32_t)number; return 1;
}
static int knot_toml_index_compare(const void *left, const void *right) {
  const KnotTomlIndex *a = (const KnotTomlIndex *)left, *b = (const KnotTomlIndex *)right;
  return a->index < b->index ? -1 : a->index > b->index ? 1 : 0;
}
static int knot_toml_json_node(KnotTomlParser *p, KnotTomlBuf *b, KnotTomlNode *n);
static int knot_toml_json_entry(KnotTomlParser *p, KnotTomlBuf *b, KnotTomlNode *child, int comma) {
  return (!comma || knot_toml_byte(p, b, ',')) &&
      knot_toml_json_string(p, b, child->name, child->name_len) &&
      knot_toml_byte(p, b, ':') && knot_toml_json_node(p, b, child);
}
static int knot_toml_json_node(KnotTomlParser *p, KnotTomlBuf *b, KnotTomlNode *n) {
  if (n->kind == KT_SCALAR) {
    return n->mode == 1 ? knot_toml_json_string(p, b, n->scalar, n->scalar_len) :
        knot_toml_add(p, b, n->scalar, n->scalar_len);
  }
  if (!knot_toml_byte(p, b, n->kind == KT_ARRAY ? '[' : '{')) return 0;
  if (n->kind == KT_ARRAY) {
    for (KnotTomlNode *child = n->first; child; child = child->next) {
      if ((child != n->first && !knot_toml_byte(p, b, ',')) || !knot_toml_json_node(p, b, child)) return 0;
    }
  } else {
    size_t indexed = 0;
    for (KnotTomlNode *child = n->first; child; child = child->next) {
      uint32_t index;
      if (knot_toml_index(child, &index)) indexed++;
    }
    KnotTomlIndex *sorted = NULL;
    if (indexed) {
      if (indexed > SIZE_MAX / sizeof(*sorted)) return knot_toml_fail(p, "resource_limit");
      sorted = (KnotTomlIndex *)malloc(indexed * sizeof(*sorted));
      if (!sorted) return knot_toml_fail(p, "resource_limit");
      size_t at = 0;
      for (KnotTomlNode *child = n->first; child; child = child->next) {
        uint32_t index;
        if (knot_toml_index(child, &index)) sorted[at++] = (KnotTomlIndex){child, index};
      }
      qsort(sorted, indexed, sizeof(*sorted), knot_toml_index_compare);
      for (size_t j = 0; j < indexed; j++) {
        if (!knot_toml_json_entry(p, b, sorted[j].node, j != 0)) { free(sorted); return 0; }
      }
      free(sorted);
    }
    int comma = indexed != 0;
    for (KnotTomlNode *child = n->first; child; child = child->next) {
      uint32_t index;
      if (knot_toml_index(child, &index)) continue;
      if (!knot_toml_json_entry(p, b, child, comma)) return 0;
      comma = 1;
    }
  }
  return knot_toml_byte(p, b, n->kind == KT_ARRAY ? ']' : '}');
}
static const char *knot_data_toml_json(const char *source, size_t length, char **json_out) {
  *json_out = NULL;
  KnotTomlParser p = {0};
  p.at = (const unsigned char *)source; p.end = p.at + length;
  p.root = knot_toml_node(&p, KT_TABLE, KT_ROOT, 0);
  KnotTomlNode *current = p.root;
  while (!p.error && p.at < p.end) {
    knot_toml_space(&p); knot_toml_comment(&p);
    if (p.error || p.at == p.end) break;
    if (*p.at == '\r' || *p.at == '\n') { knot_toml_newline(&p); continue; }
    if (*p.at == '[') {
      p.at++;
      int aot = p.at < p.end && *p.at == '[';
      if (aot) p.at++;
      knot_toml_space(&p);
      KnotTomlKey keys[129] = {{0}};
      size_t count = knot_toml_path(&p, keys);
      if (!p.error && (p.at == p.end || *p.at++ != ']' || (aot && (p.at == p.end || *p.at++ != ']'))))
        knot_toml_fail(&p, "syntax_error");
      KnotTomlNode *parent = p.root;
      for (size_t j = 0; !p.error && j+1 < count; j++) parent = knot_toml_descend(&p, parent, keys[j], 1);
      if (!p.error) {
        KnotTomlKey last = keys[count-1];
        KnotTomlNode *n = knot_toml_lookup(&p, parent, last);
        if (aot) {
          if (!n) {
            n = knot_toml_node(&p, KT_ARRAY, 0, parent->depth+1);
            if (n) { n->aot = 1; knot_toml_attach(&p, parent, last, n); }
          }
          if (!p.error && (n->kind != KT_ARRAY || !n->aot)) knot_toml_fail(&p, "duplicate_key");
          if (!p.error) {
            KnotTomlNode *item = knot_toml_node(&p, KT_TABLE, KT_EXPLICIT, n->depth+1);
            if (item) { knot_toml_push(n, item); current = item; }
          }
        } else {
          if (!n) {
            n = knot_toml_node(&p, KT_TABLE, KT_EXPLICIT, parent->depth+1);
            if (n) knot_toml_attach(&p, parent, last, n);
          } else if (n->kind != KT_TABLE || n->mode != KT_IMPLICIT) knot_toml_fail(&p, "duplicate_key");
          else n->mode = KT_EXPLICIT;
          if (!p.error) current = n;
        }
      }
      knot_toml_free_keys(keys, count);
    } else {
      KnotTomlKey keys[129] = {{0}};
      size_t count = knot_toml_path(&p, keys);
      if (!p.error && (p.at == p.end || *p.at++ != '=')) knot_toml_fail(&p, "syntax_error");
      knot_toml_space(&p);
      KnotTomlNode *parent = current;
      for (size_t j = 0; !p.error && j+1 < count; j++) parent = knot_toml_descend(&p, parent, keys[j], 0);
      if (!p.error && knot_toml_lookup(&p, parent, keys[count-1])) knot_toml_fail(&p, "duplicate_key");
      KnotTomlNode *value = !p.error ? knot_toml_value(&p, parent->depth+1) : NULL;
      if (value && !p.error) knot_toml_attach(&p, parent, keys[count-1], value);
      knot_toml_free_keys(keys, count);
    }
    if (p.error) break;
    knot_toml_space(&p); knot_toml_comment(&p);
    if (p.at < p.end && !knot_toml_newline(&p)) knot_toml_fail(&p, "syntax_error");
  }
  KnotTomlBuf json = {0};
  if (!p.error) knot_toml_json_node(&p, &json, p.root);
  static char knot_toml_status[192];
  const char *result = NULL;
  if (p.error) {
    size_t offset = (size_t)(p.at - (const unsigned char *)source);
    if (offset > length) offset = length;
    knot_span_status(source, length, offset, p.error, knot_toml_status, sizeof knot_toml_status);
    result = knot_toml_status;
  }
  if (!result) { *json_out = json.s; json.s = NULL; }
  free(json.s); free(p.slots);
  for (KnotTomlNode *n = p.allocated; n;) {
    KnotTomlNode *next = n->allocated;
    free(n->name);
    if (n->kind == KT_SCALAR && n->scalar && n->mode != 2) free(n->scalar);
    free(n); n = next;
  }
  return result;
}
#endif
