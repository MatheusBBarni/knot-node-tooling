#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "data_json.h"

typedef struct {
  char* path;
  char* bytes;
  size_t length;
} DataReadUtf8;

static void data_read_utf8_error(IoWork* w, int code) {
  errno = code;
  io_sys_end(w, -1);
}

static void data_read_utf8_call(IoWork* w) {
  DataReadUtf8* request = (DataReadUtf8*)w->data;
  int flags = O_RDONLY;
#ifdef O_NOFOLLOW
  flags |= O_NOFOLLOW;
#endif
  int fd = open(request->path, flags);
  if (fd < 0) { io_sys_end(w, -1); return; }
  struct stat info;
  if (fstat(fd, &info) != 0) {
    int code = errno;
    close(fd);
    data_read_utf8_error(w, code);
    return;
  }
  if (!S_ISREG(info.st_mode)) {
    int code = EINVAL;
    close(fd);
    data_read_utf8_error(w, code);
    return;
  }
  if (info.st_size < 0 || info.st_size > 1073741824) {
    close(fd);
    data_read_utf8_error(w, EFBIG);
    return;
  }
  request->bytes = malloc((size_t)info.st_size + 1);
  if (!request->bytes) { close(fd); data_read_utf8_error(w, ENOMEM); return; }
  while (request->length < (size_t)info.st_size) {
    ssize_t got = read(fd, request->bytes + request->length, (size_t)info.st_size - request->length);
    if (got < 0 && errno == EINTR) continue;
    if (got <= 0) { int code = got < 0 ? errno : EIO; close(fd); data_read_utf8_error(w, code); return; }
    request->length += (size_t)got;
  }
  close(fd);
  request->bytes[request->length] = 0;
  if (memchr(request->bytes, 0, request->length) ||
      !knot_dj_valid_utf8((const unsigned char*)request->bytes,
                          (const unsigned char*)request->bytes + request->length)) {
    data_read_utf8_error(w, EILSEQ);
    return;
  }
  io_sys_end(w, 0);
}

static Term data_read_utf8_pack(Env e, IoWork* w) {
  DataReadUtf8* request = (DataReadUtf8*)w->data;
  Term result = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, request->bytes, request->length));
  free(request->path);
  free(request->bytes);
  free(request);
  return result;
}

Term data_read_utf8_run(Env e, Term* f, IoWork* w) {
  uint64_t length = 0;
  DataReadUtf8* request = io_mem(calloc(1, sizeof(*request)));
  request->path = io_cstr(e, f[0], &length);
  w->data = (char*)request;
  if (io_nul(request->path, length)) {
    w->code = EINVAL;
    return data_read_utf8_pack(e, w);
  }
  return io_work(w, data_read_utf8_call, data_read_utf8_pack);
}

static void __attribute__((constructor)) data_read_utf8_use(void) {
  io_eff(CID_Data_read_utf8, data_read_utf8_run);
}
