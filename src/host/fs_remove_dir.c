#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int fs_remove_dir_rf(const char* path) {
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
    int result = fs_remove_dir_rf(child);
    free(child);
    if (result != 0) {
      closedir(dir);
      return -1;
    }
  }
  closedir(dir);
  return rmdir(path);
}

static void fs_remove_dir_call(IoWork* w) {
  io_sys_end(w, fs_remove_dir_rf(w->data));
}

static Term fs_remove_dir_pack(Env e, IoWork* w) {
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(w->data);
  return r;
}

Term fs_remove_dir_run(Env e, Term* f, IoWork* w) {
  w->data = io_cstr(e, f[0], &w->size);
  if (io_nul(w->data, w->size)) {
    w->code = EINVAL;
    return fs_remove_dir_pack(e, w);
  }
  return io_work(w, fs_remove_dir_call, fs_remove_dir_pack);
}

static void __attribute__((constructor)) fs_remove_dir_use(void) {
  io_eff(CID_FS_REMOVE_DIR, fs_remove_dir_run, 0);
}
