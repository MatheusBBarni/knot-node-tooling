function fs_mkdir_p(path) {
  try {
    require("fs").mkdirSync(path, { recursive: true });
    return io_done({ $: "Unit" });
  } catch (e) {
    return io_fail(-e.errno);
  }
}
