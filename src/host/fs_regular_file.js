function fs_regular_file(path) {
  try {
    const { lstatSync } = require("node:fs");
    if (!lstatSync(path).isFile()) return io_fail(22);
    return io_done("present");
  } catch (error) {
    if (error.code === "ENOENT") return io_done("absent");
    return io_fail(typeof error.errno === "number" ? Math.abs(error.errno) : 22);
  }
}
