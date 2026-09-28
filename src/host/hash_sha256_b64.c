// Hash
// ====

#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char HASH256_B64[] =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static void hash256_b64(const unsigned char* in, size_t n, char* out) {
  size_t i = 0;
  size_t o = 0;
  while (i + 2 < n) {
    unsigned int v = ((unsigned int)in[i] << 16) | ((unsigned int)in[i + 1] << 8)
      | (unsigned int)in[i + 2];
    out[o++] = HASH256_B64[(v >> 18) & 63];
    out[o++] = HASH256_B64[(v >> 12) & 63];
    out[o++] = HASH256_B64[(v >> 6) & 63];
    out[o++] = HASH256_B64[v & 63];
    i += 3;
  }
  if (i < n) {
    unsigned int v = (unsigned int)in[i] << 16;
    if (i + 1 < n) {
      v |= (unsigned int)in[i + 1] << 8;
    }
    out[o++] = HASH256_B64[(v >> 18) & 63];
    out[o++] = HASH256_B64[(v >> 12) & 63];
    out[o++] = i + 1 < n ? HASH256_B64[(v >> 6) & 63] : '=';
    out[o++] = '=';
  }
  out[o] = 0;
}

typedef struct {
  uint32_t h[8];
  uint64_t bits;
  unsigned char block[64];
  size_t used;
} KnotSha256;

static const uint32_t SHA256_K[64] = {
  UINT32_C(0x428a2f98), UINT32_C(0x71374491), UINT32_C(0xb5c0fbcf), UINT32_C(0xe9b5dba5),
  UINT32_C(0x3956c25b), UINT32_C(0x59f111f1), UINT32_C(0x923f82a4), UINT32_C(0xab1c5ed5),
  UINT32_C(0xd807aa98), UINT32_C(0x12835b01), UINT32_C(0x243185be), UINT32_C(0x550c7dc3),
  UINT32_C(0x72be5d74), UINT32_C(0x80deb1fe), UINT32_C(0x9bdc06a7), UINT32_C(0xc19bf174),
  UINT32_C(0xe49b69c1), UINT32_C(0xefbe4786), UINT32_C(0x0fc19dc6), UINT32_C(0x240ca1cc),
  UINT32_C(0x2de92c6f), UINT32_C(0x4a7484aa), UINT32_C(0x5cb0a9dc), UINT32_C(0x76f988da),
  UINT32_C(0x983e5152), UINT32_C(0xa831c66d), UINT32_C(0xb00327c8), UINT32_C(0xbf597fc7),
  UINT32_C(0xc6e00bf3), UINT32_C(0xd5a79147), UINT32_C(0x06ca6351), UINT32_C(0x14292967),
  UINT32_C(0x27b70a85), UINT32_C(0x2e1b2138), UINT32_C(0x4d2c6dfc), UINT32_C(0x53380d13),
  UINT32_C(0x650a7354), UINT32_C(0x766a0abb), UINT32_C(0x81c2c92e), UINT32_C(0x92722c85),
  UINT32_C(0xa2bfe8a1), UINT32_C(0xa81a664b), UINT32_C(0xc24b8b70), UINT32_C(0xc76c51a3),
  UINT32_C(0xd192e819), UINT32_C(0xd6990624), UINT32_C(0xf40e3585), UINT32_C(0x106aa070),
  UINT32_C(0x19a4c116), UINT32_C(0x1e376c08), UINT32_C(0x2748774c), UINT32_C(0x34b0bcb5),
  UINT32_C(0x391c0cb3), UINT32_C(0x4ed8aa4a), UINT32_C(0x5b9cca4f), UINT32_C(0x682e6ff3),
  UINT32_C(0x748f82ee), UINT32_C(0x78a5636f), UINT32_C(0x84c87814), UINT32_C(0x8cc70208),
  UINT32_C(0x90befffa), UINT32_C(0xa4506ceb), UINT32_C(0xbef9a3f7), UINT32_C(0xc67178f2),
};

static uint32_t sha256_rotr(uint32_t x, unsigned int n) {
  return (x >> n) | (x << (32U - n));
}

static uint32_t sha256_load(const unsigned char* p) {
  return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16)
    | ((uint32_t)p[2] << 8) | (uint32_t)p[3];
}

static void sha256_store(unsigned char* p, uint32_t v) {
  p[0] = (unsigned char)(v >> 24);
  p[1] = (unsigned char)(v >> 16);
  p[2] = (unsigned char)(v >> 8);
  p[3] = (unsigned char)v;
}

static void sha256_block(KnotSha256* ctx, const unsigned char* block) {
  uint32_t w[64];
  uint32_t a = ctx->h[0];
  uint32_t b = ctx->h[1];
  uint32_t c = ctx->h[2];
  uint32_t d = ctx->h[3];
  uint32_t e = ctx->h[4];
  uint32_t f = ctx->h[5];
  uint32_t g = ctx->h[6];
  uint32_t h = ctx->h[7];
  for (size_t i = 0; i < 16; i += 1) {
    w[i] = sha256_load(block + i * 4);
  }
  for (size_t i = 16; i < 64; i += 1) {
    uint32_t s0 = sha256_rotr(w[i - 15], 7) ^ sha256_rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
    uint32_t s1 = sha256_rotr(w[i - 2], 17) ^ sha256_rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
    w[i] = w[i - 16] + s0 + w[i - 7] + s1;
  }
  for (size_t i = 0; i < 64; i += 1) {
    uint32_t s1 = sha256_rotr(e, 6) ^ sha256_rotr(e, 11) ^ sha256_rotr(e, 25);
    uint32_t ch = (e & f) ^ ((~e) & g);
    uint32_t t1 = h + s1 + ch + SHA256_K[i] + w[i];
    uint32_t s0 = sha256_rotr(a, 2) ^ sha256_rotr(a, 13) ^ sha256_rotr(a, 22);
    uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
    uint32_t t2 = s0 + maj;
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  }
  ctx->h[0] += a;
  ctx->h[1] += b;
  ctx->h[2] += c;
  ctx->h[3] += d;
  ctx->h[4] += e;
  ctx->h[5] += f;
  ctx->h[6] += g;
  ctx->h[7] += h;
}

static void sha256_init(KnotSha256* ctx) {
  static const uint32_t initial[8] = {
    UINT32_C(0x6a09e667), UINT32_C(0xbb67ae85), UINT32_C(0x3c6ef372), UINT32_C(0xa54ff53a),
    UINT32_C(0x510e527f), UINT32_C(0x9b05688c), UINT32_C(0x1f83d9ab), UINT32_C(0x5be0cd19),
  };
  memcpy(ctx->h, initial, sizeof(initial));
  ctx->bits = 0;
  ctx->used = 0;
}

static void sha256_update(KnotSha256* ctx, const unsigned char* data, size_t n) {
  ctx->bits += (uint64_t)n << 3;
  while (n > 0) {
    size_t take = 64 - ctx->used;
    if (take > n) {
      take = n;
    }
    memcpy(ctx->block + ctx->used, data, take);
    ctx->used += take;
    data += take;
    n -= take;
    if (ctx->used == 64) {
      sha256_block(ctx, ctx->block);
      ctx->used = 0;
    }
  }
}

static void sha256_final(KnotSha256* ctx, unsigned char* digest) {
  ctx->block[ctx->used++] = 0x80;
  if (ctx->used > 56) {
    memset(ctx->block + ctx->used, 0, 64 - ctx->used);
    sha256_block(ctx, ctx->block);
    ctx->used = 0;
  }
  memset(ctx->block + ctx->used, 0, 56 - ctx->used);
  sha256_store(ctx->block + 56, (uint32_t)(ctx->bits >> 32));
  sha256_store(ctx->block + 60, (uint32_t)ctx->bits);
  sha256_block(ctx, ctx->block);
  for (size_t i = 0; i < 8; i += 1) {
    sha256_store(digest + i * 4, ctx->h[i]);
  }
}

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
  io_eff(CID_HASH_SHA256_B64, hash_sha256_b64_run, 0);
}
