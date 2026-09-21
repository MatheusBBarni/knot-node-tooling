static Term os_platform_pack(Env e, IoWork* w) {
#ifdef __APPLE__
  const char* s = "darwin";
#elif defined(__linux__)
  const char* s = "linux";
#elif defined(_WIN32)
  const char* s = "win32";
#else
  const char* s = "unknown";
#endif
  return w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, s, strlen(s)));
}

static void os_platform_call(IoWork* w) {
  io_sys_end(w, 0);
}

Term os_platform_run(Env e, Term* f, IoWork* w) {
  return io_work(w, os_platform_call, os_platform_pack);
}

static void __attribute__((constructor)) os_platform_use(void) {
  io_eff(CID_OS_PLATFORM, os_platform_run, 0);
}
