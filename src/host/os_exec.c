#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

typedef struct {
  char* cmd;
  char* arg;
  char* cwd;
} OsExec;

static void os_exec_call(IoWork* w) {
  OsExec* g = (OsExec*)w->data;
  pid_t pid = fork();
  if (pid < 0) {
    io_sys_end(w, -1);
    return;
  }
  if (pid == 0) {
    if (chdir(g->cwd) != 0) {
      _exit(127);
    }
    execlp(g->cmd, g->cmd, g->arg, (char*)0);
    _exit(127);
  }
  int st = 0;
  if (waitpid(pid, &st, 0) < 0) {
    io_sys_end(w, -1);
    return;
  }
  if (WIFEXITED(st) && WEXITSTATUS(st) == 0) {
    io_sys_end(w, 0);
    return;
  }
  errno = EIO;
  io_sys_end(w, -1);
}

static Term os_exec_pack(Env e, IoWork* w) {
  OsExec* g = (OsExec*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->cmd);
  free(g->arg);
  free(g->cwd);
  free(g);
  return r;
}

Term os_exec_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  uint64_t n3 = 0;
  OsExec* g = io_mem(malloc(sizeof(OsExec)));
  g->cmd = io_cstr(e, f[0], &n1);
  g->arg = io_cstr(e, f[1], &n2);
  g->cwd = io_cstr(e, f[2], &n3);
  w->data = (char*)g;
  if (io_nul(g->cmd, n1) || io_nul(g->arg, n2) || io_nul(g->cwd, n3)) {
    w->code = EINVAL;
    return os_exec_pack(e, w);
  }
  return io_work(w, os_exec_call, os_exec_pack);
}

static void __attribute__((constructor)) os_exec_use(void) {
  io_eff(CID_OS_EXEC, os_exec_run, 0);
}
