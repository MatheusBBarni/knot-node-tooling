function https_get(url) {
  const { execFileSync } = require("child_process");
  try {
    const body = execFileSync(
      process.execPath,
      [
        "-e",
        "(async () => { for (let i = 0; i < 3; i++) { try { const r = await fetch(process.argv[1]); if (r.ok) { process.stdout.write(Buffer.from(await r.arrayBuffer())); return; } if (r.status !== 408 && r.status !== 429 && r.status < 500) break; } catch (e) { if (i === 2) throw e; } } process.exit(1); })()",
        url,
      ],
      { maxBuffer: 32 * 1024 * 1024 },
    );
    return io_done(body.toString("utf8"));
  } catch (e) {
    return io_fail(1);
  }
}
