#include "data_limits.h"

#include <errno.h>
#include <stdlib.h>

static size_t knot_limit_depth_value = 128;
static size_t knot_limit_nodes_value = 1000000;

size_t knot_limit_depth(void) {
  return knot_limit_depth_value == 0 ? 128 : knot_limit_depth_value;
}

size_t knot_limit_nodes(void) {
  return knot_limit_nodes_value == 0 ? 1000000 : knot_limit_nodes_value;
}

void knot_limit_set(size_t depth, size_t nodes) {
  if (depth > 0) knot_limit_depth_value = depth;
  if (nodes > 0) knot_limit_nodes_value = nodes;
}

static int knot_limit_parse(const char* spec, size_t* depth, size_t* nodes) {
  char* end = NULL;
  unsigned long parsed_depth = strtoul(spec, &end, 10);
  if (end == spec || *end != ':' || parsed_depth == 0) return 0;
  char* node_end = NULL;
  unsigned long parsed_nodes = strtoul(end + 1, &node_end, 10);
  if (node_end == end + 1 || *node_end != 0 || parsed_nodes == 0) return 0;
  *depth = (size_t)parsed_depth;
  *nodes = (size_t)parsed_nodes;
  return 1;
}

static Term data_limits_pack(Env env, IoWork* work) {
  int code = work->code;
  free(work->data);
  return code ? io_fail(env, code, NULL) : io_done(env, term_pak(CID_UNIT, 0));
}

static void data_limits_call(IoWork* work) {
  size_t depth = 0;
  size_t nodes = 0;
  if (!knot_limit_parse((const char*)work->data, &depth, &nodes)) {
    errno = EINVAL;
    io_sys_end(work, -1);
    return;
  }
  knot_limit_set(depth, nodes);
  io_sys_end(work, 0);
}

Term data_limits_run(Env env, Term* args, IoWork* work) {
  uint64_t length = 0;
  char* spec = io_cstr(env, args[0], &length);
  work->data = spec;
  if (io_nul(spec, length)) {
    work->code = EINVAL;
    return data_limits_pack(env, work);
  }
  return io_work(work, data_limits_call, data_limits_pack);
}

static void __attribute__((constructor)) data_limits_use(void) {
  io_eff(CID_DATA_LIMITS, data_limits_run, 0);
}
