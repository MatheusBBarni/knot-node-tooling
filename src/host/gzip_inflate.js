function gzip_inflate_file(path) {
  const fs = require("fs");
  const zlib = require("zlib");
  try {
    const buf = fs.readFileSync(path);
    return io_done(zlib.gunzipSync(buf).toString("utf8"));
  } catch {
    return io_fail(1);
  }
}
