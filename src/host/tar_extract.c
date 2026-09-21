// Tar
// ====

#include <dlfcn.h>
#include <sys/stat.h>

typedef struct {
  char* archive;
  char* dest;
} TarExtract;

typedef void* TarGz;
typedef TarGz (*TarGzOpen)(const char*, const char*);
typedef int (*TarGzRead)(TarGz, void*, unsigned int);
typedef int (*TarGzClose)(TarGz);

static int tar_mkdir_p(char* path) {
  if (path[0] == 0) {
    return 0;
  }
  for (char* p = path + 1; *p != 0; p += 1) {
    if (*p == '/') {
      *p = 0;
      if (mkdir(path, 0755) != 0 && errno != EEXIST) {
        return -1;
      }
      *p = '/';
    }
  }
  if (mkdir(path, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
}

static int tar_mkdir_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL) {
    return 0;
  }
  *slash = 0;
  int r = tar_mkdir_p(path);
  *slash = '/';
  return r;
}

static int tar_octal(const char* s, size_t n, size_t* out) {
  size_t v = 0;
  size_t i = 0;
  while (i < n && (s[i] == ' ' || s[i] == '0')) {
    i += 1;
  }
  while (i < n && s[i] >= '0' && s[i] <= '7') {
    v = (v << 3) + (size_t)(s[i] - '0');
    i += 1;
  }
  *out = v;
  return 0;
}

static int tar_safe_link(const char* target) {
  if (target[0] == 0 || target[0] == '/' || strstr(target, "..") != NULL) {
    errno = EPERM;
    return -1;
  }
  return 0;
}


static int tar_safe_name(const char* name, char* out, size_t out_n) {
  const char* n = name;
  if (n[0] == '/' || strstr(n, "..") != NULL) {
    errno = EPERM;
    return -1;
  }
  const char* slash = strchr(n, '/');
  if (slash != NULL) {
    n = slash + 1;
  }
  if (n[0] == '/') {
    errno = EPERM;
    return -1;
  }
  if (strstr(n, "..") != NULL) {
    errno = EPERM;
    return -1;
  }
  if (strlen(n) >= out_n) {
    errno = ENAMETOOLONG;
    return -1;
  }
  memcpy(out, n, strlen(n) + 1);
  return 0;
}

static int tar_extract_blocking(const char* archive, const char* dest) {
#ifdef __APPLE__
  const char* zpath = "/usr/lib/libz.1.dylib";
#else
  const char* zpath = "libz.so.1";
#endif
  void* z = dlopen(zpath, RTLD_LAZY);
  if (z == NULL) {
    errno = ENOSYS;
    return -1;
  }
  TarGzOpen gzopen = (TarGzOpen)dlsym(z, "gzopen");
  TarGzRead gzread = (TarGzRead)dlsym(z, "gzread");
  TarGzClose gzclose = (TarGzClose)dlsym(z, "gzclose");
  if (gzopen == NULL || gzread == NULL || gzclose == NULL) {
    errno = ENOSYS;
    return -1;
  }
  TarGz gz = gzopen(archive, "rb");
  if (gz == NULL) {
    errno = EIO;
    return -1;
  }
  char dest_copy[4096];
  if (strlen(dest) >= sizeof(dest_copy)) {
    gzclose(gz);
    errno = ENAMETOOLONG;
    return -1;
  }
  memcpy(dest_copy, dest, strlen(dest) + 1);
  if (tar_mkdir_p(dest_copy) != 0) {
    gzclose(gz);
    return -1;
  }
  for (;;) {
    char hdr[512];
    int got = gzread(gz, hdr, 512);
    if (got == 0) {
      break;
    }
    if (got != 512) {
      gzclose(gz);
      errno = EBADMSG;
      return -1;
    }
    int empty = 1;
    for (int i = 0; i < 512; i += 1) {
      if (hdr[i] != 0) {
        empty = 0;
        break;
      }
    }
    if (empty) {
      break;
    }
    char name[101];
    memcpy(name, hdr, 100);
    name[100] = 0;
    size_t size = 0;
    tar_octal(hdr + 124, 12, &size);
    char type = hdr[156];
    char rel[256];
    if (tar_safe_name(name, rel, sizeof(rel)) != 0) {
      gzclose(gz);
      return -1;
    }
    if (rel[0] == 0) {
      size_t pad = (512 - (size % 512)) % 512;
      if (size + pad > 0) {
        char skip[512];
        size_t left = size + pad;
        while (left > 0) {
          unsigned int chunk = left > sizeof(skip) ? (unsigned int)sizeof(skip) : (unsigned int)left;
          int nread = gzread(gz, skip, chunk);
          if (nread <= 0) {
            gzclose(gz);
            errno = EBADMSG;
            return -1;
          }
          left -= (size_t)nread;
        }
      }
      continue;
    }
    char out_path[4096];
    if (snprintf(out_path, sizeof(out_path), "%s/%s", dest, rel) >= (int)sizeof(out_path)) {
      gzclose(gz);
      errno = ENAMETOOLONG;
      return -1;
    }
    if (type == '5') {
      if (tar_mkdir_p(out_path) != 0) {
        gzclose(gz);
        return -1;
      }
    } else if (type == '0' || type == 0) {
      if (tar_mkdir_parent(out_path) != 0) {
        gzclose(gz);
        return -1;
      }
      size_t mode_bits = 0;
      tar_octal(hdr + 100, 8, &mode_bits);
      mode_t perm = (mode_t)(mode_bits & 0777);
      if (perm == 0) {
        perm = 0644;
      }
      int out = open(out_path, O_WRONLY | O_CREAT | O_EXCL, perm);
      if (out < 0) {
        gzclose(gz);
        return -1;
      }
      size_t left = size;
      char buf[4096];
      while (left > 0) {
        unsigned int chunk = left > sizeof(buf) ? (unsigned int)sizeof(buf) : (unsigned int)left;
        int n = gzread(gz, buf, chunk);
        if (n <= 0) {
          close(out);
          gzclose(gz);
          errno = EBADMSG;
          return -1;
        }
        if (write(out, buf, (size_t)n) != n) {
          close(out);
          gzclose(gz);
          return -1;
        }
        left -= (size_t)n;
      }
      close(out);
    } else if (type == '2') {
      char target[101];
      memcpy(target, hdr + 157, 100);
      target[100] = 0;
      if (tar_safe_link(target) != 0) {
        gzclose(gz);
        return -1;
      }
      if (tar_mkdir_parent(out_path) != 0) {
        gzclose(gz);
        return -1;
      }
      if (symlink(target, out_path) != 0 && errno != EEXIST) {
        gzclose(gz);
        return -1;
      }
    } else {
      errno = EPERM;
      gzclose(gz);
      return -1;
    }
    size_t pad = (512 - (size % 512)) % 512;
    if (pad > 0) {
      char skip[512];
      if (gzread(gz, skip, (unsigned int)pad) != (int)pad) {
        gzclose(gz);
        errno = EBADMSG;
        return -1;
      }
    }
  }
  gzclose(gz);
  return 0;
}

static void tar_extract_call(IoWork* w) {
  TarExtract* g = (TarExtract*)w->data;
  io_sys_end(w, tar_extract_blocking(g->archive, g->dest));
}

static Term tar_extract_pack(Env e, IoWork* w) {
  TarExtract* g = (TarExtract*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->archive);
  free(g->dest);
  free(g);
  return r;
}

Term tar_extract_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  TarExtract* g = io_mem(malloc(sizeof(TarExtract)));
  g->archive = io_cstr(e, f[0], &n1);
  g->dest = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->archive, n1) || io_nul(g->dest, n2)) {
    w->code = EINVAL;
    return tar_extract_pack(e, w);
  }
  return io_work(w, tar_extract_call, tar_extract_pack);
}

static void __attribute__((constructor)) tar_extract_use(void) {
  io_eff(CID_TAR_EXTRACT, tar_extract_run, 0);
}
