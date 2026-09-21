#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

static int fs_read_dir_fill(const char* path, char* out, size_t out_n) {
  DIR* d = opendir(path);
  if (d == NULL) {
    return -1;
  }
  size_t n = 0;
  out[0] = 0;
  for (;;) {
    struct dirent* ent = readdir(d);
    if (ent == NULL) {
      break;
    }
    if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
      continue;
    }
    int w = snprintf(out + n, out_n - n, "%s%s", n == 0 ? "" : "\n", ent->d_name);
    if (w < 0 || n + (size_t)w >= out_n) {
      closedir(d);
      errno = ENOMEM;
      return -1;
    }
    n += (size_t)w;
  }
  closedir(d);
  return 0;
}

static void fs_read_dir_call(IoWork* w) {
  char* out = w->data + w->size + 1;
  io_sys_end(w, fs_read_dir_fill(w->data, out, 1 << 16));
}

static Term fs_read_dir_pack(Env e, IoWork* w) {
  char* out = w->data + w->size + 1;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, out, strlen(out)));
  free(w->data);
  return r;
}

Term fs_read_dir_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return fs_read_dir_pack(e, w);
  }
  char* buf = io_mem(realloc(w->data, w->size + 1 + (1 << 16)));
  w->data = buf;
  buf[w->size + 1] = 0;
  return io_work(w, fs_read_dir_call, fs_read_dir_pack);
}

static void __attribute__((constructor)) fs_read_dir_use(void) {
  io_eff(CID_FS_READ_DIR, fs_read_dir_run, 0);
}
