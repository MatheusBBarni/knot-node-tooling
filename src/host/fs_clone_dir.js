function fs_clone_dir(src, dst) {
  const fs = require("fs");
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
  try {
    if (fs.existsSync(dst)) {
      return io_done({ $: "Unit" });
    }
    fs.mkdirSync(p.dirname(dst), { recursive: true });
    const backend = readBackend();
    if (backend === "copy") {
      treeCopy(src, dst);
      return io_done({ $: "Unit" });
    }
    if (backend === "hardlink") {
      try {
        treeHardlink(src, dst);
        return io_done({ $: "Unit" });
      } catch (e) {
        rmRf(dst);
        const code = e && e.code;
        if (code !== "EXDEV" && code !== "EPERM" && code !== "ENOTSUP" && code !== "EACCES") {
          throw e;
        }
        treeCopy(src, dst);
        return io_done({ $: "Unit" });
      }
    }
    if (backend === "clone") {
      treeCopy(src, dst);
      return io_done({ $: "Unit" });
    }
    /* auto: prefer hardlink, then copy (JS has no clonefile) */
    try {
      treeHardlink(src, dst);
    } catch {
      rmRf(dst);
      treeCopy(src, dst);
    }
    return io_done({ $: "Unit" });
  } catch (e) {
    if (e && e.code === "EEXIST") {
      return io_done({ $: "Unit" });
    }
    return io_fail(-e.errno);
  }
}
