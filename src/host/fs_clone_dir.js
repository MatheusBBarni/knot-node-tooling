function fs_clone_dir(src, dst) {
  const fs = require("fs");
  const p = require("path");
  try {
    fs.mkdirSync(p.dirname(dst), { recursive: true });
    fs.cpSync(src, dst, { recursive: true, errorOnExist: true });
    return io_done({ $: "Unit" });
  } catch (e) {
    if (e && e.code === "EEXIST") {
      return io_done({ $: "Unit" });
    }
    return io_fail(-e.errno);
  }
}
