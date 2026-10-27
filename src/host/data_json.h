#ifndef KNOT_DATA_JSON_H
#define KNOT_DATA_JSON_H

#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "data_limits.h"
#include "span_status.h"

/* Validation does not materialize a value tree. Source bytes are retained by
 * the caller, and duplicate object keys are compared after JSON decoding. */
typedef struct {
  const unsigned char* at;
  const unsigned char* end;
  size_t nodes;
  const char* error;
} KnotDataJson;

static int knot_dj_valid_utf8(const unsigned char* at, const unsigned char* end) {
  while (at < end) {
    unsigned char first = *at++;
    if (first < 0x80) continue;
    int continuation;
    uint32_t codepoint;
    uint32_t minimum;
    if (first >= 0xc2 && first <= 0xdf) {
      continuation = 1; codepoint = first & 0x1f; minimum = 0x80;
    } else if (first >= 0xe0 && first <= 0xef) {
      continuation = 2; codepoint = first & 0x0f; minimum = 0x800;
    } else if (first >= 0xf0 && first <= 0xf4) {
      continuation = 3; codepoint = first & 0x07; minimum = 0x10000;
    } else return 0;
    if (end - at < continuation) return 0;
    for (int i = 0; i < continuation; i++) {
      unsigned char next = *at++;
      if ((next & 0xc0) != 0x80) return 0;
      codepoint = (codepoint << 6) | (next & 0x3f);
    }
    if (codepoint < minimum || codepoint > 0x10ffff || (codepoint >= 0xd800 && codepoint <= 0xdfff)) return 0;
  }
  return 1;
}

static void knot_dj_ws(KnotDataJson* p) {
  while (p->at < p->end && (*p->at == ' ' || *p->at == '\t' || *p->at == '\n' || *p->at == '\r')) p->at++;
}

static int knot_dj_hex(unsigned char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}

static int knot_dj_u4(KnotDataJson* p, uint32_t* value) {
  if ((size_t)(p->end - p->at) < 4) return 0;
  uint32_t n = 0;
  for (int i = 0; i < 4; i++) {
    int h = knot_dj_hex(*p->at++);
    if (h < 0) return 0;
    n = (n << 4) | (uint32_t)h;
  }
  *value = n;
  return 1;
}

static size_t knot_dj_utf8(char* out, uint32_t cp) {
  if (cp < 0x80) { out[0] = (char)cp; return 1; }
  if (cp < 0x800) {
    out[0] = (char)(0xc0 | (cp >> 6)); out[1] = (char)(0x80 | (cp & 63)); return 2;
  }
  if (cp < 0x10000) {
    out[0] = (char)(0xe0 | (cp >> 12)); out[1] = (char)(0x80 | ((cp >> 6) & 63));
    out[2] = (char)(0x80 | (cp & 63)); return 3;
  }
  out[0] = (char)(0xf0 | (cp >> 18)); out[1] = (char)(0x80 | ((cp >> 12) & 63));
  out[2] = (char)(0x80 | ((cp >> 6) & 63)); out[3] = (char)(0x80 | (cp & 63)); return 4;
}

static int knot_dj_string(KnotDataJson* p, char** decoded, size_t* decoded_length) {
  if (p->at >= p->end || *p->at++ != '"') return 0;
  char* key = NULL;
  size_t count = 0;
  if (decoded) {
    key = malloc((size_t)(p->end - p->at) + 1);
    if (!key) { p->error = "resource_limit"; return 0; }
  }
  while (p->at < p->end && *p->at != '"') {
    unsigned char ch = *p->at++;
    if (ch < 0x20) goto invalid;
    if (ch == '\\') {
      if (p->at == p->end) goto invalid;
      ch = *p->at++;
      if (ch == 'u') {
        uint32_t cp;
        if (!knot_dj_u4(p, &cp)) goto invalid;
        if (cp >= 0xd800 && cp <= 0xdbff) {
          uint32_t low;
          if (p->end - p->at < 6 || p->at[0] != '\\' || p->at[1] != 'u') goto invalid;
          p->at += 2;
          if (!knot_dj_u4(p, &low) || low < 0xdc00 || low > 0xdfff) goto invalid;
          cp = 0x10000 + ((cp - 0xd800) << 10) + (low - 0xdc00);
        } else if (cp >= 0xdc00 && cp <= 0xdfff) goto invalid;
        if (key) count += knot_dj_utf8(key + count, cp);
        continue;
      }
      if (ch == 'b') ch = '\b';
      else if (ch == 'f') ch = '\f';
      else if (ch == 'n') ch = '\n';
      else if (ch == 'r') ch = '\r';
      else if (ch == 't') ch = '\t';
      else if (ch != '"' && ch != '\\' && ch != '/') goto invalid;
    }
    if (key) key[count++] = (char)ch;
  }
  if (p->at == p->end) goto invalid;
  p->at++;
  if (key) { key[count] = 0; *decoded = key; *decoded_length = count; }
  return 1;
invalid:
  free(key);
  return 0;
}

typedef struct {
  char* bytes;
  size_t length;
} KnotDataKey;

static uint64_t knot_dj_hash(const char* bytes, size_t length) {
  uint64_t h = UINT64_C(14695981039346656037);
  for (size_t i = 0; i < length; i++) h = (h ^ (unsigned char)bytes[i]) * UINT64_C(1099511628211);
  return h;
}

static int knot_dj_insert(KnotDataJson* p, KnotDataKey** table, size_t* capacity, size_t* size, KnotDataKey key) {
  if (*size * 2 >= *capacity) {
    size_t next = *capacity ? *capacity * 2 : 16;
    if (next > 2097152) { p->error = "resource_limit"; return 0; }
    KnotDataKey* enlarged = calloc(next, sizeof(*enlarged));
    if (!enlarged) { p->error = "resource_limit"; return 0; }
    for (size_t i = 0; i < *capacity; i++) if ((*table)[i].bytes) {
      size_t j = (size_t)knot_dj_hash((*table)[i].bytes, (*table)[i].length) & (next - 1);
      while (enlarged[j].bytes) j = (j + 1) & (next - 1);
      enlarged[j] = (*table)[i];
    }
    free(*table);
    *table = enlarged;
    *capacity = next;
  }
  size_t i = (size_t)knot_dj_hash(key.bytes, key.length) & (*capacity - 1);
  while ((*table)[i].bytes) {
    if ((*table)[i].length == key.length && !memcmp((*table)[i].bytes, key.bytes, key.length)) {
      p->error = "duplicate_key"; return 0;
    }
    i = (i + 1) & (*capacity - 1);
  }
  (*table)[i] = key;
  (*size)++;
  return 1;
}

static int knot_dj_value(KnotDataJson* p, size_t depth);

static int knot_dj_object(KnotDataJson* p, size_t depth) {
  KnotDataKey* keys = NULL;
  size_t capacity = 0, size = 0;
  int valid = 0;
  p->at++;
  knot_dj_ws(p);
  if (p->at < p->end && *p->at == '}') { p->at++; return 1; }
  for (;;) {
    KnotDataKey key = {NULL, 0};
    if (!knot_dj_string(p, &key.bytes, &key.length)) break;
    if (!knot_dj_insert(p, &keys, &capacity, &size, key)) { free(key.bytes); break; }
    knot_dj_ws(p);
    if (p->at == p->end || *p->at++ != ':') break;
    if (!knot_dj_value(p, depth + 1)) break;
    knot_dj_ws(p);
    if (p->at < p->end && *p->at == '}') { p->at++; valid = 1; break; }
    if (p->at == p->end || *p->at++ != ',') break;
    knot_dj_ws(p);
  }
  for (size_t i = 0; i < capacity; i++) free(keys[i].bytes);
  free(keys);
  return valid;
}

static int knot_dj_array(KnotDataJson* p, size_t depth) {
  p->at++;
  knot_dj_ws(p);
  if (p->at < p->end && *p->at == ']') { p->at++; return 1; }
  for (;;) {
    if (!knot_dj_value(p, depth + 1)) return 0;
    knot_dj_ws(p);
    if (p->at < p->end && *p->at == ']') { p->at++; return 1; }
    if (p->at == p->end || *p->at++ != ',') return 0;
  }
}

static int knot_dj_number(KnotDataJson* p) {
  const unsigned char* start = p->at;
  if (*p->at == '-') p->at++;
  if (p->at == p->end) return 0;
  const unsigned char* digits = p->at;
  if (*p->at == '0') p->at++;
  else {
    if (*p->at < '1' || *p->at > '9') return 0;
    do { p->at++; } while (p->at < p->end && *p->at >= '0' && *p->at <= '9');
  }
  size_t integer_length = (size_t)(p->at - digits);
  int fractional = 0;
  if (p->at < p->end && *p->at == '.') {
    fractional = 1; p->at++;
    if (p->at == p->end || *p->at < '0' || *p->at > '9') return 0;
    do { p->at++; } while (p->at < p->end && *p->at >= '0' && *p->at <= '9');
  }
  if (p->at < p->end && (*p->at == 'e' || *p->at == 'E')) {
    fractional = 1; p->at++;
    if (p->at < p->end && (*p->at == '+' || *p->at == '-')) p->at++;
    if (p->at == p->end || *p->at < '0' || *p->at > '9') return 0;
    do { p->at++; } while (p->at < p->end && *p->at >= '0' && *p->at <= '9');
  }
  if (!fractional && (integer_length > 16 || (integer_length == 16 && memcmp(digits, "9007199254740991", 16) > 0))) {
    p->error = "data_number"; return 0;
  }
  char* end = NULL;
  double number = strtod((const char*)start, &end);
  if (end != (const char*)p->at || !isfinite(number)) { p->error = "data_number"; return 0; }
  return 1;
}

static int knot_dj_value(KnotDataJson* p, size_t depth) {
  knot_dj_ws(p);
  if (depth >= knot_limit_depth() || ++p->nodes > knot_limit_nodes()) { p->error = "resource_limit"; return 0; }
  if (p->at == p->end) return 0;
  unsigned char c = *p->at;
  if (c == '{') return knot_dj_object(p, depth);
  if (c == '[') return knot_dj_array(p, depth);
  if (c == '"') return knot_dj_string(p, NULL, NULL);
  if (c == '-' || (c >= '0' && c <= '9')) return knot_dj_number(p);
  const char* word = c == 't' ? "true" : c == 'f' ? "false" : c == 'n' ? "null" : NULL;
  if (!word) return 0;
  size_t length = strlen(word);
  if ((size_t)(p->end - p->at) < length || memcmp(p->at, word, length)) return 0;
  p->at += length;
  return 1;
}

static char knot_json_status[192];

static const char* knot_data_json_validate(const char* text) {
  const unsigned char* begin = (const unsigned char*)(text == NULL ? "" : text);
  size_t length = text == NULL ? 0 : strlen(text);
  KnotDataJson parser = {begin, begin + length, 0, "syntax_error"};
  if (!knot_dj_valid_utf8(parser.at, parser.end)) {
    knot_span_status((const char*)begin, length, 0, "invalid_encoding", knot_json_status, sizeof knot_json_status);
    return knot_json_status;
  }
  if (!knot_dj_value(&parser, 0)) {
    knot_span_status((const char*)begin, length, (size_t)(parser.at - begin), parser.error, knot_json_status, sizeof knot_json_status);
    return knot_json_status;
  }
  knot_dj_ws(&parser);
  if (parser.at != parser.end) {
    knot_span_status((const char*)begin, length, (size_t)(parser.at - begin), "syntax_error", knot_json_status, sizeof knot_json_status);
    return knot_json_status;
  }
  snprintf(knot_json_status, sizeof knot_json_status, "ok");
  return knot_json_status;
}

#endif
