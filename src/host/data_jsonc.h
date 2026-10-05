#ifndef KNOT_DATA_JSONC_H
#define KNOT_DATA_JSONC_H

#include <stddef.h>
#include <string.h>

/* Preserve every source offset so a future range diagnostic can refer to the
 * original input. The JSON validator remains the authority on grammar. */
static const char* knot_data_jsonc_normalize(const char* source, char* out, size_t length) {
  int quoted = 0;
  for (size_t i = 0; i < length; i++) {
    char ch = source[i];
    if (quoted) {
      out[i] = ch;
      if (ch == '\\' && i + 1 < length) { i++; out[i] = source[i]; }
      else if (ch == '"') quoted = 0;
      continue;
    }
    if (ch == '"') { quoted = 1; out[i] = ch; continue; }
    if (ch == '/' && i + 1 < length && source[i + 1] == '/') {
      out[i++] = ' '; out[i] = ' ';
      while (i + 1 < length && source[i + 1] != '\n' && source[i + 1] != '\r') out[++i] = ' ';
      continue;
    }
    if (ch == '/' && i + 1 < length && source[i + 1] == '*') {
      out[i++] = ' '; out[i] = ' ';
      int closed = 0;
      while (i + 1 < length) {
        if (source[i + 1] == '*' && i + 2 < length && source[i + 2] == '/') {
          out[++i] = ' '; out[++i] = ' '; closed = 1; break;
        }
        i++;
        out[i] = source[i] == '\n' || source[i] == '\r' ? source[i] : ' ';
      }
      if (!closed) return "syntax_error";
      continue;
    }
    out[i] = ch;
  }
  out[length] = 0;
  quoted = 0;
  for (size_t i = 0; i < length; i++) {
    if (quoted) {
      if (out[i] == '\\' && i + 1 < length) i++;
      else if (out[i] == '"') quoted = 0;
      continue;
    }
    if (out[i] == '"') { quoted = 1; continue; }
    if (out[i] != ',') continue;
    size_t next = i + 1;
    while (next < length && (out[next] == ' ' || out[next] == '\t' || out[next] == '\r' || out[next] == '\n')) next++;
    if (next < length && (out[next] == '}' || out[next] == ']')) out[i] = ' ';
  }
  return NULL;
}

#endif
