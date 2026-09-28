#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

typedef struct {
  char* cmd;
  char* args;
  char* cwd;
  int status;
} OsExecMany;

static void os_exec_many_call(IoWork* w) {
  OsExecMany* g = (OsExecMany*)w->data;
  pid_t pid = fork();
  if (pid < 0) {
    g->status = 127;
    io_sys_end(w, 0);
    return;
  }
  if (pid == 0) {
    if (chdir(g->cwd) != 0) {
      _exit(127);
    }
    size_t count = 1;
    for (char* p = g->args; *p; ++p) {
      if (*p == '\n') {
        ++count;
      }
    }
    char** argv = calloc(count + 2, sizeof(char*));
    if (!argv) {
      _exit(127);
    }
    argv[0] = g->cmd;
    size_t i = 1;
    char* save = NULL;
    for (char* token = strtok_r(g->args, "\n", &save); token; token = strtok_r(NULL, "\n", &save)) {
      argv[i++] = token;
    }
    argv[i] = NULL;
    execvp(g->cmd, argv);
    free(argv);
    _exit(127);
  }
  int st = 0;
  if (waitpid(pid, &st, 0) < 0) {
    g->status = 127;
    io_sys_end(w, 0);
    return;
  }
  if (WIFEXITED(st)) {
    g->status = WEXITSTATUS(st);
  } else if (WIFSIGNALED(st)) {
    g->status = 128 + WTERMSIG(st);
  } else {
    g->status = 127;
  }
  io_sys_end(w, 0);
}

static Term os_exec_many_pack(Env e, IoWork* w) {
  OsExecMany* g = (OsExecMany*)w->data;
  char status[16];
  int n = snprintf(status, sizeof(status), "%d", g->status);
  Term r = io_done(e, io_str(e, status, (size_t)n));
  free(g->cmd);
  free(g->args);
  free(g->cwd);
  free(g);
  return r;
}

Term os_exec_many_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  uint64_t n3 = 0;
  OsExecMany* g = io_mem(malloc(sizeof(OsExecMany)));
  g->status = 127;
  g->cmd = io_cstr(e, f[0], &n1);
  g->args = io_cstr(e, f[1], &n2);
  g->cwd = io_cstr(e, f[2], &n3);
  w->data = (char*)g;
  if (io_nul(g->cmd, n1) || io_nul(g->args, n2) || io_nul(g->cwd, n3)) {
    w->code = EINVAL;
    return os_exec_many_pack(e, w);
  }
  return io_work(w, os_exec_many_call, os_exec_many_pack);
}

static void __attribute__((constructor)) os_exec_many_use(void) {
  io_eff(CID_OS_EXEC_MANY, os_exec_many_run, 0);
}
