function fs_layout_pkg(dest, name) {
  const fs = require("fs");
  const p = require("path");
  try {
    const pkg = JSON.parse(fs.readFileSync(p.join(dest, "package.json"), "utf8"));
    const deps = Object.assign({}, pkg.dependencies || {}, pkg.peerDependencies || {});
    for (const dep of Object.keys(deps)) {
      const ups = (dest.split("/").length - 1) + (dep.split("/").length - 1);
      const target = (ups <= 0 ? "." : Array(ups).fill("..").join("/")) + "/" + dep;
      const link = p.join(dest, "node_modules", dep);
      fs.mkdirSync(p.dirname(link), { recursive: true });
      try {
        fs.symlinkSync(target, link);
      } catch (e) {
        if (!e || e.code !== "EEXIST") {
          throw e;
        }
      }
    }
    fs.mkdirSync("node_modules", { recursive: true });
    const rootTarget = name.includes("/") ? "../.knot/" + name : ".knot/" + name;
    try {
      fs.symlinkSync(rootTarget, p.join("node_modules", name));
    } catch (e) {
      if (!e || e.code !== "EEXIST") {
        throw e;
      }
    }
    const bin = pkg.bin;
    if (bin) {
      fs.mkdirSync("node_modules/.bin", { recursive: true });
      const entries = typeof bin === "string"
        ? [[name.split("/").pop(), bin]]
        : Object.entries(bin);
      for (const [cmd, rel] of entries) {
        const file = String(rel).replace(/^\.\//, "");
        try {
          fs.symlinkSync("../.knot/" + name + "/" + file, p.join("node_modules/.bin", cmd));
        } catch (e) {
          if (!e || e.code !== "EEXIST") {
            throw e;
          }
        }
      }
    }
    return io_done({ $: "Unit" });
  } catch (e) {
    return io_fail(-e.errno);
  }
}
