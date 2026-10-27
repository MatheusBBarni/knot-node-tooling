const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

function fail(status) {
  return io_done(status);
}

function safeId(id) {
  return /^[A-Za-z0-9_-]{1,128}$/.test(id);
}

function walk(root, rel, files) {
  for (const name of fs.readdirSync(path.join(root, rel))) {
    const child = rel ? `${rel}/${name}` : name;
    const full = path.join(root, child);
    const st = fs.lstatSync(full);
    if (st.isSymbolicLink() || (!st.isDirectory() && !st.isFile())) {
      throw new Error("unsafe publication entry");
    }
    if (st.isDirectory()) {
      walk(root, child, files);
    } else {
      const bytes = fs.readFileSync(full);
      files.push({
        path: child,
        bytes: bytes.length,
        digest: crypto.createHash("sha256").update(bytes).digest("base64"),
      });
    }
  }
}

function writeAtomic(file, text) {
  const temp = `${file}.tmp-${process.pid}`;
  fs.writeFileSync(temp, text);
  fs.renameSync(temp, file);
}

function copyTree(src, dst) {
  fs.mkdirSync(dst, { recursive: true });
  for (const name of fs.readdirSync(src)) {
    const from = path.join(src, name);
    const to = path.join(dst, name);
    const st = fs.lstatSync(from);
    if (st.isDirectory()) {
      copyTree(from, to);
    } else {
      fs.mkdirSync(path.dirname(to), { recursive: true });
      fs.copyFileSync(from, to);
    }
  }
}

function publish(staged, outdir, generation, meta) {
  if (!safeId(generation)) {
    return fail("error");
  }
  const [digest = "", target = "", format = "", publicPath = ""] = meta.split("|");
  const gen = path.join(outdir, "generations", generation);
  fs.mkdirSync(path.dirname(gen), { recursive: true });
  copyTree(staged, gen);
  const files = [];
  walk(gen, "", files);
  files.sort((left, right) => left.path < right.path ? -1 : left.path > right.path ? 1 : 0);
  const outputs = files.filter((file) => file.path !== "complete.json").map((file) => (
    `{"path":${JSON.stringify(file.path)},"bytes":${file.bytes},"digest":${JSON.stringify(file.digest)}}`
  ));
  const complete = `{"version":1,"generation":${JSON.stringify(generation)},"configDigest":${JSON.stringify(digest)},"toolVersion":"0.0.1","target":${JSON.stringify(target)},"format":${JSON.stringify(format)},"publicPath":${JSON.stringify(publicPath)},"tombstone":false,"outputs":[${outputs.join(",")}]}`;
  writeAtomic(path.join(gen, "complete.json"), complete);
  if (process.env.KNOT_FAIL_PUBLISH === "before-activate") {
    return fail("error");
  }
  const completeDigest = crypto.createHash("sha256").update(complete).digest("base64");
  const activePath = path.join(outdir, "active.json");
  if (fs.existsSync(activePath)) {
    fs.copyFileSync(activePath, path.join(outdir, "previous.json"));
  }
  const active = `{"version":1,"generation":${JSON.stringify(generation)},"completeDigest":${JSON.stringify(completeDigest)}}`;
  writeAtomic(activePath, active);
  copyTree(staged, outdir);
  fs.rmSync(staged, { recursive: true, force: true });
  return io_done(`ok|${active}`);
}

function snapshot(outdir, dest) {
  if (fs.existsSync(dest)) {
    return fail("exists");
  }
  const activePath = path.join(outdir, "active.json");
  if (!fs.existsSync(activePath)) {
    return fail("missing");
  }
  const active = JSON.parse(fs.readFileSync(activePath, "utf8"));
  if (!safeId(active.generation)) {
    return fail("recovery");
  }
  const gen = path.join(outdir, "generations", active.generation);
  const completePath = path.join(gen, "complete.json");
  const completeBytes = fs.readFileSync(completePath);
  const digest = crypto.createHash("sha256").update(completeBytes).digest("base64");
  if (digest !== active.completeDigest) {
    return fail("recovery");
  }
  const complete = JSON.parse(completeBytes.toString("utf8"));
  const stage = `${dest}.knot-snapshot-${process.pid}`;
  fs.rmSync(stage, { recursive: true, force: true });
  copyTree(gen, stage);
  fs.rmSync(path.join(stage, "complete.json"), { force: true });
  if (process.env.KNOT_FAIL_SNAPSHOT === "before-rename") {
    fs.rmSync(stage, { recursive: true, force: true });
    return fail("error");
  }
  fs.renameSync(stage, dest);
  return io_done(`ok|${JSON.stringify({
    version: 1,
    generation: active.generation,
    completeDigest: active.completeDigest,
    publicPath: complete.publicPath ?? "",
  })}`);
}

function fs_publish(op, a, b, c, d) {
  try {
    if (op === "publish") {
      return publish(a, b, c, d);
    }
    if (op === "snapshot") {
      return snapshot(a, b);
    }
    return fail("error");
  } catch {
    return fail("error");
  }
}
