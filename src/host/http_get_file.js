function http_get_file(url, dest) {
  const fs = require("fs");
  const http = require("http");
  const path = require("path");
  try {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    const body = require("child_process").execFileSync(
      process.execPath,
      ["-e", "fetch(process.argv[1]).then(async (r) => { if (!r.ok) process.exit(1); process.stdout.write(Buffer.from(await r.arrayBuffer())) })", url],
      { maxBuffer: 32 * 1024 * 1024 },
    );
    fs.writeFileSync(dest, body);
    return io_done({ $: "Unit" });
  } catch (e) {
    return io_fail(e.errno ? -e.errno : 5);
  }
}
