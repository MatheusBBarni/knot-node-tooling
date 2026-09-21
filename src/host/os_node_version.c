#include <stdio.h>
#include <string.h>

static char os_node_version_buf[64];

static void os_node_version_call(IoWork* w) {
  FILE* f = popen("node -v", "r");
  if (f == NULL) {
    io_sys_end(w, -1);
    return;
  }
  if (fgets(os_node_version_buf, sizeof(os_node_version_buf), f) == NULL) {
    pclose(f);
    io_sys_end(w, -1);
    return;
  }
  pclose(f);
  io_sys_end(w, 0);
}

static Term os_node_version_pack(Env e, IoWork* w) {
  char* s = os_node_version_buf;
  if (s[0] == 'v') {
    s += 1;
  }
  size_t n = strlen(s);
  while (n > 0 && (s[n - 1] == '\n' || s[n - 1] == '\r')) {
    n -= 1;
  }
  return w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, s, n));
}

Term os_node_version_run(Env e, Term* f, IoWork* w) {
  return io_work(w, os_node_version_call, os_node_version_pack);
}

static void __attribute__((constructor)) os_node_version_use(void) {
  io_eff(CID_OS_NODE_VERSION, os_node_version_run, 0);
}
