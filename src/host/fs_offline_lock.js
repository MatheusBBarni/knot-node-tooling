function fs_offline_lock() {
  const fs = require("fs");
  const os = require("os");
  const p = require("path");
  function readBackend() {
    try {
      const t = fs.readFileSync(".knot/backend", "utf8").trim();
      return t || "auto";
    } catch {
      return "auto";
    }
  }
  function rmRf(path) {
    fs.rmSync(path, { recursive: true, force: true });
  }
  function treeCopy(s, d) {
    fs.cpSync(s, d, { recursive: true, errorOnExist: false });
  }
  function treeHardlink(s, d) {
    const st = fs.lstatSync(s);
    if (st.isDirectory()) {
      fs.mkdirSync(d, { recursive: true, mode: st.mode });
      for (const name of fs.readdirSync(s)) {
        treeHardlink(p.join(s, name), p.join(d, name));
      }
      return;
    }
    if (st.isSymbolicLink()) {
      try {
        fs.symlinkSync(fs.readlinkSync(s), d);
      } catch (e) {
        if (!e || e.code !== "EEXIST") throw e;
      }
      return;
    }
    if (st.isFile()) {
      try {
        fs.linkSync(s, d);
      } catch (e) {
        if (!e || e.code !== "EEXIST") throw e;
      }
      return;
    }
    const err = new Error("unsupported");
    err.code = "ENOTSUP";
    throw err;
  }
  function materialize(src, dst) {
    if (fs.existsSync(dst)) {
      return;
    }
    fs.mkdirSync(p.dirname(dst), { recursive: true });
    const backend = readBackend();
    if (backend === "copy") {
      treeCopy(src, dst);
      return;
    }
    if (backend === "hardlink") {
      try {
        treeHardlink(src, dst);
        return;
      } catch (e) {
        rmRf(dst);
        const code = e && e.code;
        if (code !== "EXDEV" && code !== "EPERM" && code !== "ENOTSUP" && code !== "EACCES") {
          throw e;
        }
        treeCopy(src, dst);
        return;
      }
    }
    try {
      treeHardlink(src, dst);
    } catch {
      rmRf(dst);
      treeCopy(src, dst);
    }
  }
  try {
    const home = process.env.HOME || os.homedir();
    const silent = fs.existsSync(".knot/silent");
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
          if (!silent) {
            process.stderr.write("+ " + name + "@" + ver + "\n");
          }
          const key = integrity.replaceAll("/", "_");
          const unp = p.join(home, ".knot/unpacked", key);
          materialize(unp, dest);
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
