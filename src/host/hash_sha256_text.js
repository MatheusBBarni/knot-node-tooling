function hash_sha256_text(text) {
  if (text.includes("\0")) {
    return io_fail(22);
  }
  return io_done(require("node:crypto").createHash("sha256").update(text, "utf8").digest("base64"));
}
