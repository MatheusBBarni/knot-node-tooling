function fs_rename(src, dst) {
  try {
    require("node:fs").renameSync(src, dst);
    return io_done({ $: "Unit" });
  } catch {
    return io_fail(5);
  }
}
