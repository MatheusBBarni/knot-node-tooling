#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char* result;
} ProtocolRequest;

static int proto_fail(ProtocolRequest* g, const char* status) {
  free(g->result);
  g->result = strdup(status);
  return g->result == NULL ? -1 : 0;
}

static const char* proto_key(const char* json, const char* key) {
  char pattern[160];
  const char* found;
  int n = snprintf(pattern, sizeof(pattern), "\"%s\"", key);
  if (n < 0 || (size_t)n >= sizeof(pattern)) {
    return NULL;
  }
  found = strstr(json, pattern);
  if (found == NULL) {
    return NULL;
  }
  found += strlen(pattern);
  while (*found == ' ' || *found == '\t' || *found == '\n' || *found == '\r') {
    found += 1;
  }
  if (*found != ':') {
    return NULL;
  }
  found += 1;
  while (*found == ' ' || *found == '\t' || *found == '\n' || *found == '\r') {
    found += 1;
  }
  return found;
}

static int proto_copy_string(const char* at, char* out, size_t cap) {
  size_t n = 0;
  if (at == NULL || *at != '"') {
    return -1;
  }
  at += 1;
  while (*at != '\0' && *at != '"') {
    if (*at == '\\' || *at == '|' || *at == '\n') {
      return -1;
    }
    if (n + 1 >= cap) {
      return -1;
    }
    out[n++] = *at++;
  }
  if (*at != '"') {
    return -1;
  }
  out[n] = '\0';
  return 0;
}

static int proto_field(const char* json, const char* key, char* out, size_t cap) {
  return proto_copy_string(proto_key(json, key), out, cap);
}

static int proto_version(const char* json, long* version) {
  const char* at = proto_key(json, "protocolVersion");
  char* end = NULL;
  if (at == NULL || !isdigit((unsigned char)*at)) {
    return -1;
  }
  *version = strtol(at, &end, 10);
  return end == at ? -1 : 0;
}

static int proto_entries(const char* json, char* out, size_t cap) {
  const char* at = proto_key(json, "entries");
  size_t n = 0;
  int count = 0;
  if (at == NULL || *at != '[') {
    return -1;
  }
  at += 1;
  while (*at == ' ' || *at == '\n' || *at == '\t') {
    at += 1;
  }
  if (*at == ']') {
    return -1;
  }
  while (*at == '"') {
    char item[512];
    if (proto_copy_string(at, item, sizeof(item)) != 0) {
      return -1;
    }
    if (count > 0) {
      if (n + 1 >= cap) {
        return -1;
      }
      out[n++] = ',';
    }
    if (n + strlen(item) >= cap) {
      return -1;
    }
    memcpy(out + n, item, strlen(item));
    n += strlen(item);
    at += strlen(item) + 2;
    while (*at == ' ' || *at == '\n' || *at == '\t') {
      at += 1;
    }
    count += 1;
    if (*at == ',') {
      at += 1;
      while (*at == ' ' || *at == '\n' || *at == '\t') {
        at += 1;
      }
      continue;
    }
    break;
  }
  out[n] = '\0';
  return *at == ']' && count > 0 ? 0 : -1;
}

static int proto_bool_true(const char* json, const char* key) {
  const char* at = proto_key(json, key);
  return at != NULL && strncmp(at, "true", 4) == 0;
}

static char* proto_join(const char* status, const char* id, const char* entry, const char* outdir, const char* format, const char* target) {
  size_t n = strlen(status) + strlen(id) + strlen(entry) + strlen(outdir) + strlen(format) + strlen(target) + 8;
  char* out = malloc(n);
  if (out == NULL) {
    return NULL;
  }
  snprintf(out, n, "%s|%s|%s|%s|%s|%s", status, id, entry, outdir, format, target);
  return out;
}

static int proto_parse(ProtocolRequest* g, const char* json) {
  char id[256];
  char operation[32];
  char entry[512];
  char outdir[512];
  char format[32];
  char target[32];
  long version = 0;
  if (json[0] != '{') {
    return proto_fail(g, "malformed");
  }
  if (proto_version(json, &version) != 0) {
    return proto_fail(g, "malformed");
  }
  if (proto_field(json, "id", id, sizeof(id)) != 0) {
    return proto_fail(g, "malformed");
  }
  if (version != 1) {
    char status[320];
    snprintf(status, sizeof(status), "bad-version|%s", id);
    return proto_fail(g, status);
  }
  if (proto_field(json, "operation", operation, sizeof(operation)) != 0) {
    return proto_fail(g, "malformed");
  }
  if (strcmp(operation, "build") != 0) {
    char status[320];
    snprintf(status, sizeof(status), "missing|%s", id);
    return proto_fail(g, status);
  }
  if (proto_bool_true(json, "returnArtifacts")) {
    char status[320];
    snprintf(status, sizeof(status), "artifacts|%s", id);
    return proto_fail(g, status);
  }
  if (proto_entries(json, entry, sizeof(entry)) != 0
    || proto_field(json, "dir", outdir, sizeof(outdir)) != 0
    || proto_field(json, "format", format, sizeof(format)) != 0
    || proto_field(json, "target", target, sizeof(target)) != 0) {
    char status[320];
    snprintf(status, sizeof(status), "missing|%s", id);
    return proto_fail(g, status);
  }
  free(g->result);
  g->result = proto_join("ok", id, entry, outdir, format, target);
  return g->result == NULL ? -1 : 0;
}

static void protocol_request_call(IoWork* w) {
  ProtocolRequest* g = (ProtocolRequest*)w->data;
  char* buf = NULL;
  size_t cap = 256;
  size_t n = 0;
  int ch;
  buf = malloc(cap);
  if (buf == NULL) {
    proto_fail(g, "malformed");
    io_sys_end(w, g->result == NULL ? -1 : 0);
    return;
  }
  while ((ch = fgetc(stdin)) != EOF && ch != '\n') {
    if (n + 1 >= cap) {
      size_t grown = cap * 2;
      char* next;
      if (grown > 64u * 1024u * 1024u) {
        free(buf);
        proto_fail(g, "limit");
        io_sys_end(w, 0);
        return;
      }
      next = realloc(buf, grown);
      if (next == NULL) {
        free(buf);
        proto_fail(g, "malformed");
        io_sys_end(w, 0);
        return;
      }
      buf = next;
      cap = grown;
    }
    buf[n++] = (char)ch;
  }
  buf[n] = '\0';
  if (n == 0) {
    proto_fail(g, "eof");
  } else {
    proto_parse(g, buf);
  }
  free(buf);
  io_sys_end(w, g->result == NULL ? -1 : 0);
}

static Term protocol_request_pack(Env e, IoWork* w) {
  ProtocolRequest* g = (ProtocolRequest*)w->data;
  Term r = g->result == NULL ? io_fail(e, 1, NULL) : io_done(e, io_str(e, g->result, strlen(g->result)));
  free(g->result);
  free(g);
  return r;
}

Term protocol_request_run(Env e, Term* f, IoWork* w) {
  ProtocolRequest* g = io_mem(malloc(sizeof(ProtocolRequest)));
  (void)f;
  g->result = NULL;
  w->data = (char*)g;
  return io_work(w, protocol_request_call, protocol_request_pack);
}

static void __attribute__((constructor)) protocol_request_use(void) {
  io_eff(CID_Protocol_request, protocol_request_run);
}
