import fs from "node:fs";
import path from "node:path";

class PkgExports {
  static isObject(v) {
    return v != null && typeof v === "object" && !Array.isArray(v);
  }

  static resolveTarget(target, conditions) {
    if (typeof target === "string") return target;
    if (Array.isArray(target)) {
      for (const t of target) {
        const r = PkgExports.resolveTarget(t, conditions);
        if (r) return r;
      }
      return null;
    }
    if (!PkgExports.isObject(target)) return null;

    for (const c of conditions) {
      if (c in target) {
        const r = PkgExports.resolveTarget(target[c], conditions);
        if (r) return r;
      }
    }
    if ("default" in target && !conditions.includes("default")) {
      const r = PkgExports.resolveTarget(target.default, conditions);
      if (r) return r;
    }
    return null;
  }

  static resolve(pkg, subpath, conditions) {
    const exportsField = pkg.exports;
    if (exportsField == null) return null;

    if (typeof exportsField === "string") {
      return subpath === "." ? exportsField : null;
    }

    if (!PkgExports.isObject(exportsField)) return null;

    const keys = Object.keys(exportsField);
    const looksLikeConditions = keys.every((k) => !k.startsWith(".") && k !== ".");
    if (looksLikeConditions && subpath === ".") {
      return PkgExports.resolveTarget(exportsField, conditions);
    }

    const key = subpath === "." ? "." : subpath.startsWith("./") ? subpath : "./" + subpath;
    if (key in exportsField) {
      return PkgExports.resolveTarget(exportsField[key], conditions);
    }
    if (subpath === "." && "default" in exportsField) {
      return PkgExports.resolveTarget(exportsField.default, conditions);
    }
    return null;
  }

  static hasSideEffects(pkg, relPath) {
    const se = pkg.sideEffects;
    if (se === false) return false;
    if (se === true || se == null) return true;
    if (!Array.isArray(se)) return true;
    const norm = relPath.replace(/^\.\//, "");
    return se.some((pat) => {
      const p = String(pat).replace(/^\.\//, "");
      if (p === norm) return true;
      if (p.endsWith("/*")) return norm.startsWith(p.slice(0, -1));
      if (p.includes("*")) {
        const re = new RegExp("^" + p.replace(/\./g, "\\.").replace(/\*/g, ".*") + "$");
        return re.test(norm);
      }
      return false;
    });
  }
}

const mode = process.argv[2] || "resolve";

if (mode === "fileSideEffects") {
  const filePath = process.argv[3] || "";
  let dir = path.dirname(path.resolve(filePath));
  let pkgPath = null;
  for (let i = 0; i < 12; i++) {
    const cand = path.join(dir, "package.json");
    if (fs.existsSync(cand)) {
      pkgPath = cand;
      break;
    }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  if (!pkgPath) {
    process.stdout.write("1");
    process.exit(0);
  }
  const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
  const rel = path.relative(path.dirname(pkgPath), path.resolve(filePath)).split(path.sep).join("/");
  const keep = PkgExports.hasSideEffects(pkg, rel || ".");
  process.stdout.write(keep ? "1" : "0");
  process.exit(0);
}

const text = fs.readFileSync(0, "utf8");
const pkg = JSON.parse(text);

if (mode === "resolve") {
  const subpath = process.argv[3] || ".";
  const conditions = (process.argv[4] || "import,module,node,default").split(",").map((s) => s.trim()).filter(Boolean);
  const r = PkgExports.resolve(pkg, subpath, conditions);
  if (!r) {
    process.exit(2);
  }
  process.stdout.write(r);
} else if (mode === "sideEffects") {
  const rel = process.argv[3] || ".";
  const keep = PkgExports.hasSideEffects(pkg, rel);
  process.stdout.write(keep ? "1" : "0");
} else {
  process.exit(22);
}
