function fs_unlink(path) {
  const fs = require("fs");
  try {
    fs.unlinkSync(path);
    return io_done({ $: "Unit" });
  } catch (e) {
    if (e && e.code === "ENOENT") {
      return io_done({ $: "Unit" });
    }
    return io_fail(-e.errno);
  }
}
