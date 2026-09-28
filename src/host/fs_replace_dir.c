#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int knot_materialize_dir(const char* src, const char* dst);

typedef struct {
  char* src;
  char* dst;
} FsReplaceDir;

static int fs_replace_rm_rf(const char* path) {
  struct stat st;
  if (lstat(path, &st) != 0) {
    return errno == ENOENT ? 0 : -1;
  }
  if (!S_ISDIR(st.st_mode)) {
    return unlink(path);
  }
  DIR* dir = opendir(path);
  if (dir == NULL) {
    return -1;
  }
  struct dirent* entry;
  while ((entry = readdir(dir)) != NULL) {
    if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
      continue;
    }
    size_t n = strlen(path) + strlen(entry->d_name) + 2;
    char* child = malloc(n);
    if (child == NULL) {
      closedir(dir);
      errno = ENOMEM;
      return -1;
    }
    snprintf(child, n, "%s/%s", path, entry->d_name);
    int result = fs_replace_rm_rf(child);
    free(child);
    if (result != 0) {
      closedir(dir);
      return -1;
    }
  }
  closedir(dir);
  return rmdir(path);
}

static void fs_replace_dir_call(IoWork* w) {
  FsReplaceDir* g = (FsReplaceDir*)w->data;
  char temp[4096];
  char backup[4096];
  int temp_n = snprintf(temp, sizeof(temp), "%s.knot-update-%ld", g->dst, (long)getpid());
  int backup_n = snprintf(backup, sizeof(backup), "%s.knot-backup-%ld", g->dst, (long)getpid());
  if (temp_n < 0 || backup_n < 0 || (size_t)temp_n >= sizeof(temp) || (size_t)backup_n >= sizeof(backup)) {
    errno = ENAMETOOLONG;
    fs_replace_rm_rf(g->src);
    io_sys_end(w, -1);
    return;
  }
  if (fs_replace_rm_rf(temp) != 0 || fs_replace_rm_rf(backup) != 0) {
    fs_replace_rm_rf(g->src);
    io_sys_end(w, -1);
    return;
  }
  if (knot_materialize_dir(g->src, temp) != 0) {
    fs_replace_rm_rf(temp);
    fs_replace_rm_rf(g->src);
    io_sys_end(w, -1);
    return;
  }

  struct stat old;
  int had_old = lstat(g->dst, &old) == 0;
  if (had_old && rename(g->dst, backup) != 0) {
    fs_replace_rm_rf(temp);
    fs_replace_rm_rf(g->src);
    io_sys_end(w, -1);
    return;
  }
  if (!had_old && errno != ENOENT) {
    fs_replace_rm_rf(temp);
    fs_replace_rm_rf(g->src);
    io_sys_end(w, -1);
    return;
  }
  const char* fail_step = getenv("KNOT_FAIL_REPLACE_STEP");
  if (fail_step != NULL && strcmp(fail_step, "before-activate") == 0) {
    if (had_old) {
      rename(backup, g->dst);
    }
    fs_replace_rm_rf(temp);
    fs_replace_rm_rf(g->src);
    errno = EIO;
    io_sys_end(w, -1);
    return;
  }
  if (rename(temp, g->dst) != 0) {
    if (had_old) {
      rename(backup, g->dst);
    }
    fs_replace_rm_rf(temp);
    fs_replace_rm_rf(g->src);
    return;
  }
  if (had_old) {
    fs_replace_rm_rf(backup);
  }
  fs_replace_rm_rf(g->src);
  io_sys_end(w, 0);
}

static Term fs_replace_dir_pack(Env e, IoWork* w) {
  FsReplaceDir* g = (FsReplaceDir*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->src);
  free(g->dst);
  free(g);
  return r;
}

Term fs_replace_dir_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsReplaceDir* g = io_mem(malloc(sizeof(FsReplaceDir)));
  g->src = io_cstr(e, f[0], &n1);
  g->dst = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->src, n1) || io_nul(g->dst, n2)) {
    w->code = EINVAL;
    return fs_replace_dir_pack(e, w);
  }
  return io_work(w, fs_replace_dir_call, fs_replace_dir_pack);
}

static void __attribute__((constructor)) fs_replace_dir_use(void) {
  io_eff(CID_FS_REPLACE_DIR, fs_replace_dir_run, 0);
}
