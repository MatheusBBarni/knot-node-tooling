function tar_extract(archive, dest) {
  const fs = require("fs");
  const zlib = require("zlib");
  const path = require("path");
  let staging;
  try {
    const raw = zlib.gunzipSync(fs.readFileSync(archive));
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    staging = fs.mkdtempSync(`${dest}.tmp.`);
    let off = 0;
    while (off + 512 <= raw.length) {
      const hdr = raw.subarray(off, off + 512);
      off += 512;
      if (hdr.every((b) => b === 0)) {
        break;
      }
      const name = hdr.subarray(0, 100).toString("utf8").replace(/\0.*$/, "");
      const size = parseInt(hdr.subarray(124, 136).toString("utf8").trim(), 8) || 0;
      const type = String.fromCharCode(hdr[156]);
      const rel = name.startsWith("package/") ? name.slice(8) : name;
      if (!rel || rel.startsWith("/") || rel.includes("..")) {
        throw new Error("unsafe archive path");
      }
      const out = path.join(staging, rel);
      const data = raw.subarray(off, off + size);
      off += size;
      off += (512 - (size % 512)) % 512;
      if (type === "5") {
        fs.mkdirSync(out, { recursive: true });
      } else {
        fs.mkdirSync(path.dirname(out), { recursive: true });
        fs.writeFileSync(out, data, { flag: "wx" });
      }
    }
    fs.rmSync(dest, { recursive: true, force: true });
    fs.renameSync(staging, dest);
    staging = undefined;
    return io_done({ $: "Unit" });
  } catch (e) {
    if (staging !== undefined) {
      fs.rmSync(staging, { recursive: true, force: true });
    }
    return io_fail(e.errno ? -e.errno : 5);
  }
}
