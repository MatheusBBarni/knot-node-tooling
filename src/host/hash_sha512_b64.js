function hash_sha512_b64(path) {
  try {
    const bytes = require("fs").readFileSync(path);
    const dig = require("crypto").createHash("sha512").update(bytes).digest("base64");
    return io_done(dig);
  } catch (e) {
    return io_fail(-e.errno);
  }
}
