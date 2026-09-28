function hash_sha256_b64(path) {
  try {
    const bytes = require("node:fs").readFileSync(path);
    const dig = require("node:crypto").createHash("sha256").update(bytes).digest("base64");
    return io_done(dig);
  } catch (e) {
    return io_fail(-e.errno);
  }
}
