// Hash
// ====

#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "hash_sha256_core.h"

static void hash_sha256_text_call(IoWork* w) {
  KnotSha256 ctx;
  unsigned char digest[32];
  sha256_init(&ctx);
  sha256_update(&ctx, (const unsigned char*)w->data, (size_t)w->size);
  sha256_final(&ctx, digest);
  hash256_b64(digest, sizeof(digest), w->data + w->size + 1);
  io_sys_end(w, 0);
}

static Term hash_sha256_text_pack(Env e, IoWork* w) {
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, w->data + w->size + 1, 44));
  free(w->data);
  return r;
}

Term hash_sha256_text_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size) || w->size > SIZE_MAX - 49) {
    w->code = EINVAL;
    return hash_sha256_text_pack(e, w);
  }
  w->data = io_mem(realloc(w->data, (size_t)w->size + 49));
  return io_work(w, hash_sha256_text_call, hash_sha256_text_pack);
}

static void __attribute__((constructor)) hash_sha256_text_use(void) {
  io_eff(CID_HASH_SHA256_TEXT, hash_sha256_text_run, 0);
}
