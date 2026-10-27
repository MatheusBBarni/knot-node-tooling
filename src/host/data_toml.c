#include "data_toml.h"

typedef struct {
  char *source;
  char *output;
  size_t length;
} DataToml;

static void data_toml_call(IoWork *work) {
  DataToml *request = (DataToml *)work->data;
  const char *error = knot_data_toml_json(request->source, request->length, &request->output);
  if (error) {
    size_t length = strlen(error);
    request->output = malloc(length + 5);
    if (!request->output) { errno = ENOMEM; io_sys_end(work, -1); return; }
    memcpy(request->output, "ERR:", 4);
    memcpy(request->output + 4, error, length + 1);
  }
  io_sys_end(work, 0);
}

static Term data_toml_pack(Env env, IoWork *work) {
  DataToml *request = (DataToml *)work->data;
  Term result = work->code ? io_fail(env, work->code, NULL)
    : io_done(env, io_str(env, request->output, strlen(request->output)));
  free(request->source);
  free(request->output);
  free(request);
  return result;
}

Term data_toml_run(Env env, Term *args, IoWork *work) {
  uint64_t length = 0;
  DataToml *request = io_mem(calloc(1, sizeof(*request)));
  request->source = io_cstr(env, args[0], &length);
  request->length = length;
  work->data = (char *)request;
  if (io_nul(request->source, length)) {
    work->code = EINVAL;
    return data_toml_pack(env, work);
  }
  return io_work(work, data_toml_call, data_toml_pack);
}

static void __attribute__((constructor)) data_toml_use(void) {
  io_eff(CID_Data_toml, data_toml_run);
}
