#ifndef KNOT_SPAN_STATUS_H
#define KNOT_SPAN_STATUS_H

#include <stdio.h>
#include <string.h>

/* Half-open UTF-8 offset, one-based line, one-based UTF-16 column. */
static size_t knot_span_utf16_column(const char* text, size_t line_start, size_t offset) {
  size_t column = 1;
  size_t index = line_start;
  while (index < offset && text[index] != 0) {
    unsigned char byte = (unsigned char)text[index];
    size_t width = 1;
    if ((byte & 0xe0) == 0xc0) width = 2;
    else if ((byte & 0xf0) == 0xe0) width = 3;
    else if ((byte & 0xf8) == 0xf0) width = 4;
    if (index + width > offset) break;
    index += width;
    column += width == 4 ? 2 : 1;
  }
  return column;
}

static void knot_span_status(const char* text, size_t length, size_t offset, const char* code, char* out, size_t out_n) {
  if (text == NULL) text = "";
  if (offset > length) offset = length;
  size_t line = 1;
  size_t line_start = 0;
  for (size_t index = 0; index < offset && index < length; index++) {
    if (text[index] == '\n') {
      line++;
      line_start = index + 1;
    }
  }
  size_t column = knot_span_utf16_column(text, line_start, offset);
  size_t end = offset < length ? offset + 1 : offset;
  snprintf(out, out_n, "%s\t%zu\t%zu\t%zu\t%zu", code == NULL ? "syntax_error" : code, line, column, offset, end);
}

#endif
