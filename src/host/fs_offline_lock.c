#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

int layout_pkg(const char* dest, const char* name);
int knot_materialize_dir(const char* src, const char* dst);

static void offline_sri_key(const char* s, char* out, size_t cap) {
  size_t n = 0;
  for (; *s != 0 && n + 1 < cap; s += 1) {
    out[n] = *s == '/' ? '_' : *s;
    n += 1;
  }
  out[n] = 0;
}

static int offline_exists(const char* path) {
  return access(path, F_OK) == 0;
}

static int offline_silent(void) {
  return access(".knot/silent", F_OK) == 0;
}

static int offline_one(
  const char* home,
  const char* name,
  const char* ver,
  const char* integrity
) {
  char dest[4096];
  char dest_pkg[4096];
  char key[512];
  char unp[4096];
  char unp_pkg[4096];
  if (name[0] == 0 || integrity[0] == 0) {
    return 0;
  }
  if (snprintf(dest, sizeof(dest), "node_modules/.knot/%s", name) >= (int)sizeof(dest)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(dest_pkg, sizeof(dest_pkg), "%s/package.json", dest) >= (int)sizeof(dest_pkg)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (offline_exists(dest_pkg)) {
    return 0;
  }
  if (!offline_silent()) {
    fprintf(stderr, "+ %s@%s\n", name, ver);
  }
  offline_sri_key(integrity, key, sizeof(key));
  if (snprintf(unp, sizeof(unp), "%s/.knot/unpacked/%s", home, key) >= (int)sizeof(unp)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(unp_pkg, sizeof(unp_pkg), "%s/package.json", unp) >= (int)sizeof(unp_pkg)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (!offline_exists(unp_pkg)) {
    errno = ENOENT;
    return -1;
  }
  if (knot_materialize_dir(unp, dest) != 0) {
    return -1;
  }
  return layout_pkg(dest, name);
}

static int offline_lock(char* out, size_t out_n) {
  const char* home = getenv("HOME");
  if (home == NULL || home[0] == 0) {
    errno = ENOENT;
    return -1;
  }
  FILE* f = fopen("knot.lock", "rb");
  if (f == NULL) {
    return -1;
  }
  char line[2048];
  char name[256];
  char ver[64];
  char integrity[512];
  name[0] = 0;
  ver[0] = 0;
  integrity[0] = 0;
  unsigned count = 0;
  while (fgets(line, sizeof(line), f) != NULL) {
    size_t n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
      n -= 1;
      line[n] = 0;
    }
    if (strncmp(line, "name ", 5) == 0) {
      snprintf(name, sizeof(name), "%s", line + 5);
      count += 1;
      continue;
    }
    if (strncmp(line, "version ", 8) == 0) {
      snprintf(ver, sizeof(ver), "%s", line + 8);
      continue;
    }
    if (strncmp(line, "integrity ", 10) == 0) {
      snprintf(integrity, sizeof(integrity), "%s", line + 10);
      if (offline_one(home, name, ver, integrity) != 0) {
        fclose(f);
        return -1;
      }
      name[0] = 0;
      ver[0] = 0;
      integrity[0] = 0;
    }
  }
  fclose(f);
  snprintf(out, out_n, "%u", count);
  return 0;
}

typedef struct {
  char* out;
} FsOfflineLock;

static void fs_offline_lock_call(IoWork* w) {
  FsOfflineLock* g = (FsOfflineLock*)w->data;
  io_sys_end(w, offline_lock(g->out, 32));
}

static Term fs_offline_lock_pack(Env e, IoWork* w) {
  FsOfflineLock* g = (FsOfflineLock*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->out);
  free(g);
  return r;
}

Term fs_offline_lock_run(Env e, Term* f, IoWork* w) {
  (void)f;
  FsOfflineLock* g = io_mem(malloc(sizeof(FsOfflineLock)));
  g->out = io_mem(malloc(32));
  g->out[0] = 0;
  w->data = (char*)g;
  return io_work(w, fs_offline_lock_call, fs_offline_lock_pack);
}

static void __attribute__((constructor)) fs_offline_lock_use(void) {
  io_eff(CID_FS_OFFLINE_LOCK, fs_offline_lock_run, 0);
}
