function fs_offline_lock() {
  const fs = require("fs");
  const os = require("os");
  const p = require("path");
  try {
    const home = process.env.HOME || os.homedir();
    const text = fs.readFileSync("knot.lock", "utf8");
    let name = "";
    let ver = "";
    let count = 0;
    for (const line of text.split(/\r?\n/)) {
      if (line.startsWith("name ")) {
        name = line.slice(5);
        count += 1;
      } else if (line.startsWith("version ")) {
        ver = line.slice(8);
      } else if (line.startsWith("integrity ")) {
        const integrity = line.slice(10);
        const dest = p.join("node_modules/.knot", name);
        if (!fs.existsSync(p.join(dest, "package.json"))) {
          process.stderr.write("+ " + name + "@" + ver + "\n");
          const key = integrity.replaceAll("/", "_");
          const unp = p.join(home, ".knot/unpacked", key);
          fs.mkdirSync(p.dirname(dest), { recursive: true });
          fs.cpSync(unp, dest, { recursive: true, errorOnExist: false });
          fs_layout_pkg(dest, name);
        }
        name = "";
        ver = "";
      }
    }
    return io_done(String(count));
  } catch (e) {
    return io_fail(-e.errno);
  }
}
