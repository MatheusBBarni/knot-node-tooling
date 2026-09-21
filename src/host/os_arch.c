static Term os_arch_pack(Env e, IoWork* w) {
#if defined(__aarch64__) || defined(__arm64__)
  const char* s = "arm64";
#elif defined(__x86_64__) || defined(_M_X64)
  const char* s = "x64";
#elif defined(__i386__) || defined(_M_IX86)
  const char* s = "ia32";
#elif defined(__arm__)
  const char* s = "arm";
#else
  const char* s = "unknown";
#endif
  return w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, s, strlen(s)));
}

static void os_arch_call(IoWork* w) {
  io_sys_end(w, 0);
}

Term os_arch_run(Env e, Term* f, IoWork* w) {
  return io_work(w, os_arch_call, os_arch_pack);
}

static void __attribute__((constructor)) os_arch_use(void) {
  io_eff(CID_OS_ARCH, os_arch_run, 0);
}
