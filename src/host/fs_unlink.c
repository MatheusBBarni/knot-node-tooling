#include <errno.h>
#include <unistd.h>

static void fs_unlink_call(IoWork* w) {
  io_sys_end(w, unlink(w->data) != 0 && errno != ENOENT ? -1 : 0);
}

static Term fs_unlink_pack(Env e, IoWork* w) {
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(w->data);
  return r;
}

Term fs_unlink_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return fs_unlink_pack(e, w);
  }
  return io_work(w, fs_unlink_call, fs_unlink_pack);
}

static void __attribute__((constructor)) fs_unlink_use(void) {
  io_eff(CID_FS_UNLINK, fs_unlink_run, 0);
}
