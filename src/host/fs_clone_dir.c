#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/clonefile.h>
#include <sys/stat.h>

static int fs_clone_dir_mkdir_p(char* path) {
  if (path[0] == 0) {
    return 0;
  }
  for (char* p = path + 1; *p != 0; p += 1) {
    if (*p == '/') {
      *p = 0;
      if (mkdir(path, 0755) != 0 && errno != EEXIST) {
        return -1;
      }
      *p = '/';
    }
  }
  if (mkdir(path, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
}

static int fs_clone_dir_parent(char* path) {
  char* slash = strrchr(path, '/');
  if (slash == NULL || slash == path) {
    return 0;
  }
  *slash = 0;
  int r = fs_clone_dir_mkdir_p(path);
  *slash = '/';
  return r;
}

static void knot_read_backend(char* out, size_t cap) {
  FILE* f = fopen(".knot/backend", "rb");
  if (f == NULL) {
    snprintf(out, cap, "auto");
    return;
  }
  size_t n = fread(out, 1, cap - 1, f);
  fclose(f);
  while (n > 0 && (out[n - 1] == '\n' || out[n - 1] == '\r' || out[n - 1] == ' ')) {
    n -= 1;
  }
  out[n] = 0;
  if (n == 0) {
    snprintf(out, cap, "auto");
  }
}

static int knot_copy_file(const char* src, const char* dst) {
  int in = open(src, O_RDONLY);
  if (in < 0) {
    return -1;
  }
  struct stat st;
  if (fstat(in, &st) != 0) {
    close(in);
    return -1;
  }
  int out = open(dst, O_WRONLY | O_CREAT | O_EXCL, st.st_mode & 0777);
  if (out < 0) {
    if (errno == EEXIST) {
      close(in);
      return 0;
    }
    close(in);
    return -1;
  }
  char buf[8192];
  for (;;) {
    ssize_t n = read(in, buf, sizeof(buf));
    if (n < 0) {
      close(in);
      close(out);
      return -1;
    }
    if (n == 0) {
      break;
    }
    ssize_t off = 0;
    while (off < n) {
      ssize_t w = write(out, buf + off, (size_t)(n - off));
      if (w < 0) {
        close(in);
        close(out);
        return -1;
      }
      off += w;
    }
  }
  close(in);
  close(out);
  return 0;
}

static int knot_rm_rf(const char* path) {
  struct stat st;
  if (lstat(path, &st) != 0) {
    return errno == ENOENT ? 0 : -1;
  }
  if (S_ISDIR(st.st_mode)) {
    DIR* d = opendir(path);
    if (d == NULL) {
      return -1;
    }
    struct dirent* ent;
    while ((ent = readdir(d)) != NULL) {
      if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
        continue;
      }
      char child[4096];
      if (snprintf(child, sizeof(child), "%s/%s", path, ent->d_name) >= (int)sizeof(child)) {
        closedir(d);
        errno = ENAMETOOLONG;
        return -1;
      }
      if (knot_rm_rf(child) != 0) {
        closedir(d);
        return -1;
      }
    }
    closedir(d);
    return rmdir(path);
  }
  return unlink(path);
}

static int knot_tree_copy(const char* src, const char* dst) {
  struct stat st;
  if (lstat(src, &st) != 0) {
    return -1;
  }
  if (S_ISDIR(st.st_mode)) {
    if (mkdir(dst, st.st_mode & 0777) != 0 && errno != EEXIST) {
      return -1;
    }
    DIR* d = opendir(src);
    if (d == NULL) {
      return -1;
    }
    struct dirent* ent;
    while ((ent = readdir(d)) != NULL) {
      if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
        continue;
      }
      char s_child[4096];
      char d_child[4096];
      if (snprintf(s_child, sizeof(s_child), "%s/%s", src, ent->d_name) >= (int)sizeof(s_child)
        || snprintf(d_child, sizeof(d_child), "%s/%s", dst, ent->d_name) >= (int)sizeof(d_child)) {
        closedir(d);
        errno = ENAMETOOLONG;
        return -1;
      }
      if (knot_tree_copy(s_child, d_child) != 0) {
        closedir(d);
        return -1;
      }
    }
    closedir(d);
    return 0;
  }
  if (S_ISLNK(st.st_mode)) {
    char target[4096];
    ssize_t n = readlink(src, target, sizeof(target) - 1);
    if (n < 0) {
      return -1;
    }
    target[n] = 0;
    if (symlink(target, dst) != 0 && errno != EEXIST) {
      return -1;
    }
    return 0;
  }
  if (S_ISREG(st.st_mode)) {
    return knot_copy_file(src, dst);
  }
  errno = ENOTSUP;
  return -1;
}

static int knot_tree_hardlink(const char* src, const char* dst) {
  struct stat st;
  if (lstat(src, &st) != 0) {
    return -1;
  }
  if (S_ISDIR(st.st_mode)) {
    if (mkdir(dst, st.st_mode & 0777) != 0 && errno != EEXIST) {
      return -1;
    }
    DIR* d = opendir(src);
    if (d == NULL) {
      return -1;
    }
    struct dirent* ent;
    while ((ent = readdir(d)) != NULL) {
      if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
        continue;
      }
      char s_child[4096];
      char d_child[4096];
      if (snprintf(s_child, sizeof(s_child), "%s/%s", src, ent->d_name) >= (int)sizeof(s_child)
        || snprintf(d_child, sizeof(d_child), "%s/%s", dst, ent->d_name) >= (int)sizeof(d_child)) {
        closedir(d);
        errno = ENAMETOOLONG;
        return -1;
      }
      if (knot_tree_hardlink(s_child, d_child) != 0) {
        closedir(d);
        return -1;
      }
    }
    closedir(d);
    return 0;
  }
  if (S_ISLNK(st.st_mode)) {
    char target[4096];
    ssize_t n = readlink(src, target, sizeof(target) - 1);
    if (n < 0) {
      return -1;
    }
    target[n] = 0;
    if (symlink(target, dst) != 0 && errno != EEXIST) {
      return -1;
    }
    return 0;
  }
  if (S_ISREG(st.st_mode)) {
    if (link(src, dst) != 0 && errno != EEXIST) {
      return -1;
    }
    return 0;
  }
  errno = ENOTSUP;
  return -1;
}

static int knot_try_clone(const char* src, const char* dst) {
  if (clonefile(src, dst, 0) == 0 || errno == EEXIST) {
    return 0;
  }
  return -1;
}

int knot_materialize_dir(const char* src, const char* dst) {
  char backend[32];
  char parent[4096];
  struct stat st;
  knot_read_backend(backend, sizeof(backend));
  if (lstat(dst, &st) == 0) {
    return 0;
  }
  if (strlen(dst) >= sizeof(parent)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  memcpy(parent, dst, strlen(dst) + 1);
  if (fs_clone_dir_parent(parent) != 0) {
    return -1;
  }
  if (strcmp(backend, "copy") == 0) {
    return knot_tree_copy(src, dst);
  }
  if (strcmp(backend, "hardlink") == 0) {
    if (knot_tree_hardlink(src, dst) == 0) {
      return 0;
    }
    int e = errno;
    knot_rm_rf(dst);
    if (e != EXDEV && e != EPERM && e != ENOTSUP && e != EACCES) {
      errno = e;
      return -1;
    }
    if (knot_try_clone(src, dst) == 0) {
      return 0;
    }
    knot_rm_rf(dst);
    return knot_tree_copy(src, dst);
  }
  if (knot_try_clone(src, dst) == 0) {
    return 0;
  }
  if (strcmp(backend, "clone") == 0) {
    int e = errno;
    knot_rm_rf(dst);
    errno = e;
    return -1;
  }
  /* auto: clone -> hardlink -> copy */
  knot_rm_rf(dst);
  if (knot_tree_hardlink(src, dst) == 0) {
    return 0;
  }
  knot_rm_rf(dst);
  return knot_tree_copy(src, dst);
}

typedef struct {
  char* src;
  char* dst;
} FsCloneDir;

static void fs_clone_dir_call(IoWork* w) {
  FsCloneDir* g = (FsCloneDir*)w->data;
  io_sys_end(w, knot_materialize_dir(g->src, g->dst));
}

static Term fs_clone_dir_pack(Env e, IoWork* w) {
  FsCloneDir* g = (FsCloneDir*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(CID_UNIT, 0));
  free(g->src);
  free(g->dst);
  free(g);
  return r;
}

Term fs_clone_dir_run(Env e, Term* f, IoWork* w) {
  uint64_t n1 = 0;
  uint64_t n2 = 0;
  FsCloneDir* g = io_mem(malloc(sizeof(FsCloneDir)));
  g->src = io_cstr(e, f[0], &n1);
  g->dst = io_cstr(e, f[1], &n2);
  w->data = (char*)g;
  if (io_nul(g->src, n1) || io_nul(g->dst, n2)) {
    w->code = EINVAL;
    return fs_clone_dir_pack(e, w);
  }
  return io_work(w, fs_clone_dir_call, fs_clone_dir_pack);
}

static void __attribute__((constructor)) fs_clone_dir_use(void) {
  io_eff(CID_FS_CLONE_DIR, fs_clone_dir_run, 0);
}
