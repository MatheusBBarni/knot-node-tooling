function https_get(url) {
  const { execFileSync } = require("child_process");
  try {
    const body = execFileSync(
      process.execPath,
      [
        "-e",
        "fetch(process.argv[1]).then(async (r) => { if (!r.ok) process.exit(1); process.stdout.write(Buffer.from(await r.arrayBuffer())) })",
        url,
      ],
      { maxBuffer: 32 * 1024 * 1024 },
    );
    return io_done(body.toString("utf8"));
  } catch (e) {
    return io_fail(1);
  }
}
