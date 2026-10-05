function data_read_utf8(path) {
  try {
    const { readFileSync, lstatSync } = require("node:fs");
    const stat = lstatSync(path);
    if (!stat.isFile()) return io_fail(22);
    if (stat.size > 1073741824) return io_fail(27);
    const bytes = readFileSync(path);
    if (bytes.includes(0)) return io_fail(84);
    return io_done(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
  } catch (error) {
    return io_fail(typeof error.errno === "number" ? Math.abs(error.errno) : 84);
  }
}
