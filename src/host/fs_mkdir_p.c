#include <sys/stat.h>

// Fs
// ==

static int fs_mkdir_p_path(char* path) {
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

static void fs_mkdir_p_call(IoWork* w) {
  io_sys_end(w, fs_mkdir_p_path(w->data));
}

static Term fs_mkdir_p_pack(Env e, IoWork* w) {
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(w->data);
  return r;
}

Term fs_mkdir_p_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return fs_mkdir_p_pack(e, w);
  }
  return io_work(w, fs_mkdir_p_call, fs_mkdir_p_pack);
}

static void __attribute__((constructor)) fs_mkdir_p_use(void) {
  io_eff(CID_FS_MKDIR_P, fs_mkdir_p_run, 0);
}
