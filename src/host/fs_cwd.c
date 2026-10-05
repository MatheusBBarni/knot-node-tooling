#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void fs_cwd_call(IoWork* w) {
  size_t capacity = 256;
  char* path = NULL;
  for (;;) {
    if (capacity > 1048576) {
      free(path);
      io_sys_end(w, ENAMETOOLONG);
      return;
    }
    char* next = realloc(path, capacity);
    if (next == NULL) {
      free(path);
      io_sys_end(w, ENOMEM);
      return;
    }
    path = next;
    if (getcwd(path, capacity) != NULL) {
      w->data = path;
      io_sys_end(w, 0);
      return;
    }
    if (errno != ERANGE) {
      int code = errno;
      free(path);
      io_sys_end(w, code);
      return;
    }
    capacity *= 2;
  }
}

static Term fs_cwd_pack(Env e, IoWork* w) {
  Term result = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, w->data, strlen(w->data)));
  free(w->data);
  return result;
}

Term fs_cwd_run(Env e, Term* f, IoWork* w) {
  w->data = NULL;
  return io_work(w, fs_cwd_call, fs_cwd_pack);
}

static void __attribute__((constructor)) fs_cwd_use(void) {
  io_eff(CID_FS_CWD, fs_cwd_run, 0);
}
