#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

static void fs_regular_file_call(IoWork* w) {
  struct stat info;
  if (lstat(w->data, &info) == 0) {
    w->size = 1;
    if (!S_ISREG(info.st_mode)) { errno = EINVAL; io_sys_end(w, -1); return; }
    io_sys_end(w, 0);
    return;
  }
  if (errno == ENOENT) {
    w->size = 0;
    io_sys_end(w, 0);
    return;
  }
  io_sys_end(w, -1);
}

static Term fs_regular_file_pack(Env e, IoWork* w) {
  const char* state = w->size == 1 ? "present" : "absent";
  Term result = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, state, strlen(state)));
  free(w->data);
  return result;
}

Term fs_regular_file_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return fs_regular_file_pack(e, w);
  }
  return io_work(w, fs_regular_file_call, fs_regular_file_pack);
}

static void __attribute__((constructor)) fs_regular_file_use(void) {
  io_eff(CID_FS_REGULAR_FILE, fs_regular_file_run, 0);
}
