#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pthread.h>

int layout_pkg(const char* dest, const char* name);
int knot_materialize_dir(const char* src, const char* dst);

static void offline_sri_key(const char* s, char* out, size_t cap) {
  size_t n = 0;
  for (; *s != 0 && n + 1 < cap; s += 1) {
    out[n] = *s == '/' ? '_' : *s;
    n += 1;
  }
  out[n] = 0;
}

static int offline_exists(const char* path) {
  return access(path, F_OK) == 0;
}

static int offline_silent(void) {
  return access(".knot/silent", F_OK) == 0;
}

typedef struct {
  char name[256];
  char ver[64];
  char integrity[512];
  int installed;
  int error;
} OfflineJob;

typedef struct {
  OfflineJob* jobs;
  size_t count;
  size_t next;
  pthread_mutex_t mutex;
} OfflineBatch;

static int offline_one(
  const char* home,
  const char* name,
  const char* integrity,
  int* installed
) {
  char dest[4096];
  char dest_pkg[4096];
  char key[512];
  char unp[4096];
  char unp_pkg[4096];
  *installed = 0;
  if (name[0] == 0 || integrity[0] == 0) {
    return 0;
  }
  if (snprintf(dest, sizeof(dest), "node_modules/.knot/%s", name) >= (int)sizeof(dest)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(dest_pkg, sizeof(dest_pkg), "%s/package.json", dest) >= (int)sizeof(dest_pkg)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (offline_exists(dest_pkg)) {
    return 0;
  }
  offline_sri_key(integrity, key, sizeof(key));
  if (snprintf(unp, sizeof(unp), "%s/.knot/unpacked/%s", home, key) >= (int)sizeof(unp)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (snprintf(unp_pkg, sizeof(unp_pkg), "%s.complete", unp) >= (int)sizeof(unp_pkg)) {
    errno = ENAMETOOLONG;
    return -1;
  }
  if (!offline_exists(unp_pkg)) {
    errno = ENOENT;
    return -1;
  }
  if (knot_materialize_dir(unp, dest) != 0) {
    return -1;
  }
  if (layout_pkg(dest, name) != 0) {
    return -1;
  }
  *installed = 1;
  return 0;
}

static void* offline_worker(void* arg) {
  OfflineBatch* batch = (OfflineBatch*)arg;
  const char* home = getenv("HOME");
  for (;;) {
    pthread_mutex_lock(&batch->mutex);
    size_t index = batch->next;
    if (index < batch->count) {
      batch->next += 1;
    }
    pthread_mutex_unlock(&batch->mutex);
    if (index >= batch->count) {
      return NULL;
    }
    OfflineJob* job = &batch->jobs[index];
    if (offline_one(home, job->name, job->integrity, &job->installed) != 0) {
      job->error = errno == 0 ? EIO : errno;
    }
  }
}

static int offline_run_jobs(OfflineJob* jobs, size_t count) {
  if (count == 0) {
    return 0;
  }
  long cpus = sysconf(_SC_NPROCESSORS_ONLN);
  size_t thread_count = cpus > 0 ? (size_t)cpus : 1;
  if (thread_count > count) {
    thread_count = count;
  }
  if (thread_count > 8) {
    thread_count = 8;
  }
  OfflineBatch batch = {jobs, count, 0, PTHREAD_MUTEX_INITIALIZER};
  pthread_t threads[8];
  size_t started = 0;
  while (started < thread_count && pthread_create(&threads[started], NULL, offline_worker, &batch) == 0) {
    started += 1;
  }
  if (started == 0) {
    offline_worker(&batch);
  }
  for (size_t i = 0; i < started; i += 1) {
    pthread_join(threads[i], NULL);
  }
  pthread_mutex_destroy(&batch.mutex);
  int first_error = 0;
  int silent = offline_silent();
  for (size_t i = 0; i < count; i += 1) {
    if (jobs[i].installed && !silent) {
      fprintf(stderr, "+ %s@%s\n", jobs[i].name, jobs[i].ver);
    }
    if (first_error == 0 && jobs[i].error != 0) {
      first_error = jobs[i].error;
    }
  }
  if (first_error != 0) {
    errno = first_error;
    return -1;
  }
  return 0;
}

static int offline_lock(char* out, size_t out_n) {
  const char* home = getenv("HOME");
  if (home == NULL || home[0] == 0) {
    errno = ENOENT;
    return -1;
  }
  FILE* f = fopen("knot.lock", "rb");
  if (f == NULL) {
    return -1;
  }
  char line[2048];
  char name[256];
  char ver[64];
  char integrity[512];
  name[0] = 0;
  ver[0] = 0;
  integrity[0] = 0;
  unsigned count = 0;
  size_t job_count = 0;
  size_t job_cap = 0;
  OfflineJob* jobs = NULL;
  while (fgets(line, sizeof(line), f) != NULL) {
    size_t n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
      n -= 1;
      line[n] = 0;
    }
    if (strncmp(line, "name ", 5) == 0) {
      snprintf(name, sizeof(name), "%s", line + 5);
      count += 1;
      continue;
    }
    if (strncmp(line, "version ", 8) == 0) {
      snprintf(ver, sizeof(ver), "%s", line + 8);
      continue;
    }
    if (strncmp(line, "integrity ", 10) == 0) {
      snprintf(integrity, sizeof(integrity), "%s", line + 10);
      if (job_count == job_cap) {
        size_t next_cap = job_cap == 0 ? 32 : job_cap * 2;
        OfflineJob* next_jobs = realloc(jobs, next_cap * sizeof(*jobs));
        if (next_jobs == NULL) {
          free(jobs);
          fclose(f);
          errno = ENOMEM;
          return -1;
        }
        jobs = next_jobs;
        job_cap = next_cap;
      }
      OfflineJob* job = &jobs[job_count];
      snprintf(job->name, sizeof(job->name), "%s", name);
      snprintf(job->ver, sizeof(job->ver), "%s", ver);
      snprintf(job->integrity, sizeof(job->integrity), "%s", integrity);
      job->installed = 0;
      job->error = 0;
      job_count += 1;
      name[0] = 0;
      ver[0] = 0;
      integrity[0] = 0;
    }
  }
  fclose(f);
  int result = offline_run_jobs(jobs, job_count);
  free(jobs);
  if (result != 0) {
    return -1;
  }
  snprintf(out, out_n, "%u", count);
  return 0;
}

typedef struct {
  char* out;
} FsOfflineLock;

static void fs_offline_lock_call(IoWork* w) {
  FsOfflineLock* g = (FsOfflineLock*)w->data;
  io_sys_end(w, offline_lock(g->out, 32));
}

static Term fs_offline_lock_pack(Env e, IoWork* w) {
  FsOfflineLock* g = (FsOfflineLock*)w->data;
  Term r = w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, g->out, strlen(g->out)));
  free(g->out);
  free(g);
  return r;
}

Term fs_offline_lock_run(Env e, Term* f, IoWork* w) {
  (void)f;
  FsOfflineLock* g = io_mem(malloc(sizeof(FsOfflineLock)));
  g->out = io_mem(malloc(32));
  g->out[0] = 0;
  w->data = (char*)g;
  return io_work(w, fs_offline_lock_call, fs_offline_lock_pack);
}

static void __attribute__((constructor)) fs_offline_lock_use(void) {
  io_eff(CID_FS_OFFLINE_LOCK, fs_offline_lock_run, 0);
}
