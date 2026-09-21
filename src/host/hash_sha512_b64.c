// Hash
// ====

#ifdef __APPLE__
#include <CommonCrypto/CommonDigest.h>
#endif

static const char HASH_B64[] =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static void hash_b64(const unsigned char* in, size_t n, char* out) {
  size_t i = 0;
  size_t o = 0;
  while (i + 2 < n) {
    unsigned int v = ((unsigned int)in[i] << 16) | ((unsigned int)in[i + 1] << 8)
      | (unsigned int)in[i + 2];
    out[o++] = HASH_B64[(v >> 18) & 63];
    out[o++] = HASH_B64[(v >> 12) & 63];
    out[o++] = HASH_B64[(v >> 6) & 63];
    out[o++] = HASH_B64[v & 63];
    i += 3;
  }
  if (i < n) {
    unsigned int v = (unsigned int)in[i] << 16;
    if (i + 1 < n) {
      v |= (unsigned int)in[i + 1] << 8;
    }
    out[o++] = HASH_B64[(v >> 18) & 63];
    out[o++] = HASH_B64[(v >> 12) & 63];
    out[o++] = i + 1 < n ? HASH_B64[(v >> 6) & 63] : '=';
    out[o++] = '=';
  }
  out[o] = 0;
}

static int hash_sha512_file(const char* path, char* out) {
#ifdef __APPLE__
  CC_SHA512_CTX ctx;
  unsigned char dig[CC_SHA512_DIGEST_LENGTH];
  unsigned char buf[8192];
  CC_SHA512_Init(&ctx);
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    return -1;
  }
  for (;;) {
    ssize_t n = read(fd, buf, sizeof(buf));
    if (n < 0) {
      close(fd);
      return -1;
    }
    if (n == 0) {
      break;
    }
    CC_SHA512_Update(&ctx, buf, (CC_LONG)n);
  }
  close(fd);
  CC_SHA512_Final(dig, &ctx);
  hash_b64(dig, sizeof(dig), out);
  return 0;
#else
  errno = ENOSYS;
  return -1;
#endif
}

static void hash_sha512_b64_call(IoWork* w) {
  char* out = w->data + w->size + 1;
  io_sys_end(w, hash_sha512_file(w->data, out));
}

static Term hash_sha512_b64_pack(Env e, IoWork* w) {
  char* out = w->data + w->size + 1;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, out, strlen(out)));
  free(w->data);
  return r;
}

Term hash_sha512_b64_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return hash_sha512_b64_pack(e, w);
  }
  char* buf = io_mem(realloc(w->data, w->size + 1 + 96));
  w->data = buf;
  return io_work(w, hash_sha512_b64_call, hash_sha512_b64_pack);
}

static void __attribute__((constructor)) hash_sha512_b64_use(void) {
  io_eff(CID_HASH_SHA512_B64, hash_sha512_b64_run, 0);
}
