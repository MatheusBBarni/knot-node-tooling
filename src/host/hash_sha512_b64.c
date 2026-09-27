// Hash
// ====

#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

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

#ifndef __APPLE__
typedef struct {
  uint64_t h[8];
  uint64_t bits_hi;
  uint64_t bits_lo;
  unsigned char block[128];
  size_t used;
} KnotSha512;

static const uint64_t SHA512_K[80] = {
  UINT64_C(0x428a2f98d728ae22), UINT64_C(0x7137449123ef65cd),
  UINT64_C(0xb5c0fbcfec4d3b2f), UINT64_C(0xe9b5dba58189dbbc),
  UINT64_C(0x3956c25bf348b538), UINT64_C(0x59f111f1b605d019),
  UINT64_C(0x923f82a4af194f9b), UINT64_C(0xab1c5ed5da6d8118),
  UINT64_C(0xd807aa98a3030242), UINT64_C(0x12835b0145706fbe),
  UINT64_C(0x243185be4ee4b28c), UINT64_C(0x550c7dc3d5ffb4e2),
  UINT64_C(0x72be5d74f27b896f), UINT64_C(0x80deb1fe3b1696b1),
  UINT64_C(0x9bdc06a725c71235), UINT64_C(0xc19bf174cf692694),
  UINT64_C(0xe49b69c19ef14ad2), UINT64_C(0xefbe4786384f25e3),
  UINT64_C(0x0fc19dc68b8cd5b5), UINT64_C(0x240ca1cc77ac9c65),
  UINT64_C(0x2de92c6f592b0275), UINT64_C(0x4a7484aa6ea6e483),
  UINT64_C(0x5cb0a9dcbd41fbd4), UINT64_C(0x76f988da831153b5),
  UINT64_C(0x983e5152ee66dfab), UINT64_C(0xa831c66d2db43210),
  UINT64_C(0xb00327c898fb213f), UINT64_C(0xbf597fc7beef0ee4),
  UINT64_C(0xc6e00bf33da88fc2), UINT64_C(0xd5a79147930aa725),
  UINT64_C(0x06ca6351e003826f), UINT64_C(0x142929670a0e6e70),
  UINT64_C(0x27b70a8546d22ffc), UINT64_C(0x2e1b21385c26c926),
  UINT64_C(0x4d2c6dfc5ac42aed), UINT64_C(0x53380d139d95b3df),
  UINT64_C(0x650a73548baf63de), UINT64_C(0x766a0abb3c77b2a8),
  UINT64_C(0x81c2c92e47edaee6), UINT64_C(0x92722c851482353b),
  UINT64_C(0xa2bfe8a14cf10364), UINT64_C(0xa81a664bbc423001),
  UINT64_C(0xc24b8b70d0f89791), UINT64_C(0xc76c51a30654be30),
  UINT64_C(0xd192e819d6ef5218), UINT64_C(0xd69906245565a910),
  UINT64_C(0xf40e35855771202a), UINT64_C(0x106aa07032bbd1b8),
  UINT64_C(0x19a4c116b8d2d0c8), UINT64_C(0x1e376c085141ab53),
  UINT64_C(0x2748774cdf8eeb99), UINT64_C(0x34b0bcb5e19b48a8),
  UINT64_C(0x391c0cb3c5c95a63), UINT64_C(0x4ed8aa4ae3418acb),
  UINT64_C(0x5b9cca4f7763e373), UINT64_C(0x682e6ff3d6b2b8a3),
  UINT64_C(0x748f82ee5defb2fc), UINT64_C(0x78a5636f43172f60),
  UINT64_C(0x84c87814a1f0ab72), UINT64_C(0x8cc702081a6439ec),
  UINT64_C(0x90befffa23631e28), UINT64_C(0xa4506cebde82bde9),
  UINT64_C(0xbef9a3f7b2c67915), UINT64_C(0xc67178f2e372532b),
  UINT64_C(0xca273eceea26619c), UINT64_C(0xd186b8c721c0c207),
  UINT64_C(0xeada7dd6cde0eb1e), UINT64_C(0xf57d4f7fee6ed178),
  UINT64_C(0x06f067aa72176fba), UINT64_C(0x0a637dc5a2c898a6),
  UINT64_C(0x113f9804bef90dae), UINT64_C(0x1b710b35131c471b),
  UINT64_C(0x28db77f523047d84), UINT64_C(0x32caab7b40c72493),
  UINT64_C(0x3c9ebe0a15c9bebc), UINT64_C(0x431d67c49c100d4c),
  UINT64_C(0x4cc5d4becb3e42b6), UINT64_C(0x597f299cfc657e2a),
  UINT64_C(0x5fcb6fab3ad6faec), UINT64_C(0x6c44198c4a475817),
};

static uint64_t sha512_rotr(uint64_t x, unsigned int n) {
  return (x >> n) | (x << (64U - n));
}

static uint64_t sha512_load(const unsigned char* p) {
  return ((uint64_t)p[0] << 56) | ((uint64_t)p[1] << 48) | ((uint64_t)p[2] << 40)
    | ((uint64_t)p[3] << 32) | ((uint64_t)p[4] << 24) | ((uint64_t)p[5] << 16)
    | ((uint64_t)p[6] << 8) | (uint64_t)p[7];
}

static void sha512_store(unsigned char* p, uint64_t v) {
  p[0] = (unsigned char)(v >> 56);
  p[1] = (unsigned char)(v >> 48);
  p[2] = (unsigned char)(v >> 40);
  p[3] = (unsigned char)(v >> 32);
  p[4] = (unsigned char)(v >> 24);
  p[5] = (unsigned char)(v >> 16);
  p[6] = (unsigned char)(v >> 8);
  p[7] = (unsigned char)v;
}

static void sha512_block(KnotSha512* ctx, const unsigned char* block) {
  uint64_t w[80];
  uint64_t a = ctx->h[0];
  uint64_t b = ctx->h[1];
  uint64_t c = ctx->h[2];
  uint64_t d = ctx->h[3];
  uint64_t e = ctx->h[4];
  uint64_t f = ctx->h[5];
  uint64_t g = ctx->h[6];
  uint64_t h = ctx->h[7];
  for (size_t i = 0; i < 16; i += 1) {
    w[i] = sha512_load(block + i * 8);
  }
  for (size_t i = 16; i < 80; i += 1) {
    uint64_t s0 = sha512_rotr(w[i - 15], 1) ^ sha512_rotr(w[i - 15], 8) ^ (w[i - 15] >> 7);
    uint64_t s1 = sha512_rotr(w[i - 2], 19) ^ sha512_rotr(w[i - 2], 61) ^ (w[i - 2] >> 6);
    w[i] = w[i - 16] + s0 + w[i - 7] + s1;
  }
  for (size_t i = 0; i < 80; i += 1) {
    uint64_t s1 = sha512_rotr(e, 14) ^ sha512_rotr(e, 18) ^ sha512_rotr(e, 41);
    uint64_t ch = (e & f) ^ ((~e) & g);
    uint64_t t1 = h + s1 + ch + SHA512_K[i] + w[i];
    uint64_t s0 = sha512_rotr(a, 28) ^ sha512_rotr(a, 34) ^ sha512_rotr(a, 39);
    uint64_t maj = (a & b) ^ (a & c) ^ (b & c);
    uint64_t t2 = s0 + maj;
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

static void sha512_init(KnotSha512* ctx) {
  static const uint64_t initial[8] = {
    UINT64_C(0x6a09e667f3bcc908), UINT64_C(0xbb67ae8584caa73b),
    UINT64_C(0x3c6ef372fe94f82b), UINT64_C(0xa54ff53a5f1d36f1),
    UINT64_C(0x510e527fade682d1), UINT64_C(0x9b05688c2b3e6c1f),
    UINT64_C(0x1f83d9abfb41bd6b), UINT64_C(0x5be0cd19137e2179),
  };
  memcpy(ctx->h, initial, sizeof(initial));
  ctx->bits_hi = 0;
  ctx->bits_lo = 0;
  ctx->used = 0;
}

static void sha512_update(KnotSha512* ctx, const unsigned char* data, size_t n) {
  uint64_t old = ctx->bits_lo;
  ctx->bits_lo += (uint64_t)n << 3;
  ctx->bits_hi += ((uint64_t)n >> 61) + (ctx->bits_lo < old ? 1U : 0U);
  while (n > 0) {
    size_t take = 128 - ctx->used;
    if (take > n) {
      take = n;
    }
    memcpy(ctx->block + ctx->used, data, take);
    ctx->used += take;
    data += take;
    n -= take;
    if (ctx->used == 128) {
      sha512_block(ctx, ctx->block);
      ctx->used = 0;
    }
  }
}

static void sha512_final(KnotSha512* ctx, unsigned char* digest) {
  ctx->block[ctx->used++] = 0x80;
  if (ctx->used > 112) {
    memset(ctx->block + ctx->used, 0, 128 - ctx->used);
    sha512_block(ctx, ctx->block);
    ctx->used = 0;
  }
  memset(ctx->block + ctx->used, 0, 112 - ctx->used);
  sha512_store(ctx->block + 112, ctx->bits_hi);
  sha512_store(ctx->block + 120, ctx->bits_lo);
  sha512_block(ctx, ctx->block);
  for (size_t i = 0; i < 8; i += 1) {
    sha512_store(digest + i * 8, ctx->h[i]);
  }
}
#endif

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
  KnotSha512 ctx;
  unsigned char digest[64];
  unsigned char buf[8192];
  sha512_init(&ctx);
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
    sha512_update(&ctx, buf, (size_t)n);
  }
  if (close(fd) != 0) {
    result = -1;
  }
  if (result != 0) {
    return -1;
  }
  sha512_final(&ctx, digest);
  hash_b64(digest, sizeof(digest), out);
  return 0;
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
