// Hash
// ====

#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include "hash_sha256_core.h"

static int hash_sha256_file(const char* path, char* out) {
  KnotSha256 ctx;
  unsigned char digest[32];
  unsigned char buf[8192];
  sha256_init(&ctx);
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    return -1;
  }
  int result = 0;
  for (;;) {
    ssize_t n = read(fd, buf, sizeof(buf));
    if (n < 0) {
      result = -1;
      break;
    }
    if (n == 0) {
      break;
    }
    sha256_update(&ctx, buf, (size_t)n);
  }
  if (close(fd) != 0) {
    result = -1;
  }
  if (result != 0) {
    return -1;
  }
  sha256_final(&ctx, digest);
  hash256_b64(digest, sizeof(digest), out);
  return 0;
}

static void hash_sha256_b64_call(IoWork* w) {
  char* out = w->data + w->size + 1;
  io_sys_end(w, hash_sha256_file(w->data, out));
}

static Term hash_sha256_b64_pack(Env e, IoWork* w) {
  char* out = w->data + w->size + 1;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, out, strlen(out)));
  free(w->data);
  return r;
}

Term hash_sha256_b64_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return hash_sha256_b64_pack(e, w);
  }
  char* buf = io_mem(realloc(w->data, w->size + 1 + 48));
  w->data = buf;
  return io_work(w, hash_sha256_b64_call, hash_sha256_b64_pack);
}

static void __attribute__((constructor)) hash_sha256_b64_use(void) {
  io_eff(CID_Hash_sha256_b64, hash_sha256_b64_run);
}
