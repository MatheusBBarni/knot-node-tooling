function fs_read_dir(path) {
  const fs = require("fs");
  try {
    const names = fs.readdirSync(path).filter((n) => n !== "." && n !== "..");
    return io_done(names.join("\n"));
  } catch (e) {
    return io_fail(-e.errno);
  }
}
