function fs_symlink(target, path) {
  const fs = require("fs");
  const p = require("path");
  try {
    fs.mkdirSync(p.dirname(path), { recursive: true });
    fs.symlinkSync(target, path);
    return io_done({ $: "Unit" });
  } catch (e) {
    if (e && e.code === "EEXIST") {
      return io_done({ $: "Unit" });
    }
    return io_fail(-e.errno);
  }
}
