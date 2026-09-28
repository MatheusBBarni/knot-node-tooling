function fs_remove_dir(path) {
  try {
    require("fs").rmSync(path, { recursive: true, force: true });
    return io_done({ $: "Unit" });
  } catch (e) {
    return io_fail(-e.errno);
  }
}
