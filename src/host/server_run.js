function server_run(port, root, entry, naming) {
  const fs = require("fs");
  const http = require("http");
  const path = require("path");
  const { spawnSync } = require("child_process");
  const binary = process.env.KNOT_BINARY;
  if (!binary) {
    process.stderr.write("knot serve: native executable path is unavailable\n");
    process.exit(1);
  }

  const rootPath = path.resolve(root);
  const originalArgs = [];
  const count = Number(process.env.KNOT_ARGC || 0);
  let hasOutdir = false;
  let hasOutfile = false;
  for (let i = 2; i <= count; i += 1) {
    const value = process.env[`KNOT_ARG_${i}`];
    if (value === "--port") {
      i += 1;
      continue;
    }
    if (value.startsWith("--port=")) continue;
    if (value === "--watch") continue;
    if (value === "--outdir" || value.startsWith("--outdir=")) hasOutdir = true;
    if (value === "--outfile" || value.startsWith("--outfile=")) hasOutfile = true;
    originalArgs.push(value);
    if (value === "--outfile" || value === "--outdir") {
      i += 1;
      originalArgs.push(process.env[`KNOT_ARG_${i}`]);
    }
  }

  const buildArgs = ["build"];
  for (let i = 0; i < originalArgs.length; i += 1) {
    const value = originalArgs[i];
    if (value === "--outfile" || value.startsWith("--outfile=")) {
      if (value === "--outfile") i += 1;
      continue;
    }
    buildArgs.push(value);
  }
  if (hasOutfile || !hasOutdir) buildArgs.push("--outdir", root);
  if (hasOutfile && !naming) buildArgs.push("--entry-naming", entry);

  function runBuild(preflight) {
    const args = preflight ? [...buildArgs, "--show-config"] : buildArgs;
    const env = { ...process.env, KNOT_ARGC: String(args.length) };
    args.forEach((value, index) => { env[`KNOT_ARG_${index + 1}`] = value; });
    const result = spawnSync(binary, [], {
      cwd: process.cwd(),
      env,
      stdio: ["ignore", preflight ? "ignore" : "inherit", "inherit"],
    });
    return result.error ? 127 : result.status ?? 127;
  }

  const preflight = runBuild(true);
  if (preflight !== 0) process.exit(preflight);
  let generation = "";
  let hasActive = false;
  let version = 0;

  function readGeneration() {
    const pointer = JSON.parse(fs.readFileSync(path.join(rootPath, "active.json"), "utf8"));
    if (typeof pointer.generation !== "string" || !/^[A-Za-z0-9_-]{1,128}$/.test(pointer.generation)) return "";
    const candidate = path.join(rootPath, "generations", pointer.generation);
    if (!fs.statSync(path.join(candidate, "complete.json")).isFile()) return "";
    return pointer.generation;
  }

  function activeRoot() {
    return path.join(rootPath, "generations", generation);
  }

  function fingerprint() {
    const rows = [];
    let count = 0;
    function walk(directory) {
      for (const name of fs.readdirSync(directory).sort()) {
        const full = path.join(directory, name);
        if (full === rootPath || full.startsWith(`${rootPath}${path.sep}`)) continue;
        if (directory === process.cwd() && (name === ".git" || name === ".knot")) continue;
        const stat = fs.lstatSync(full);
        rows.push(`${full}\0${stat.mode}\0${stat.size}\0${stat.ino}\0${stat.mtimeMs}\0${stat.ctimeMs}`);
        count += 1;
        if (count > 500000) throw new Error("watch input limit exceeded");
        if (stat.isDirectory()) walk(full);
      }
    }
    walk(process.cwd());
    return rows.join("\n");
  }

  function publishSuccessfulBuild() {
    try {
      const next = readGeneration();
      if (!next) return false;
      generation = next;
      hasActive = true;
      version += 1;
      return true;
    } catch {
      return false;
    }
  }

  const listener = http.createServer((request, response) => {
    const url = new URL(request.url, "http://127.0.0.1");
    if (url.pathname === "/__knot/version") {
      response.writeHead(200, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
      response.end(String(version));
      return;
    }
    if (url.pathname === "/__knot/reload.js") {
      const expected = /^[0-9]+$/.test(url.searchParams.get("v") ?? "") ? url.searchParams.get("v") : "0";
      response.writeHead(200, { "content-type": "text/javascript; charset=utf-8", "cache-control": "no-store" });
      response.end(`(function(){const expected='${expected}';setInterval(function(){fetch('/__knot/version',{cache:'no-store'}).then(function(r){return r.text()}).then(function(v){if(v!==expected)location.reload()}).catch(function(){})},300)})();`);
      return;
    }
    if (request.method !== "GET" && request.method !== "HEAD") {
      response.writeHead(405, { allow: "GET, HEAD" });
      response.end();
      return;
    }
    if (!hasActive) {
      response.writeHead(503, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
      response.end("build is not available yet\n");
      return;
    }
    let relative;
    try {
      relative = decodeURIComponent(url.pathname.slice(1));
      if (relative.includes("\\") || relative.split("/").includes("..") || relative.includes("\0")) throw new Error("unsafe path");
    } catch {
      response.writeHead(400, { "cache-control": "no-store" });
      response.end("path is not allowed\n");
      return;
    }
    if (!relative) relative = entry;
    if (["active.json", "previous.json", "complete.json"].includes(relative) || relative.startsWith("generations/")) {
      response.writeHead(404, { "cache-control": "no-store" });
      response.end("not found\n");
      return;
    }
    const active = activeRoot();
    const file = path.resolve(active, relative);
    try {
      const resolved = fs.realpathSync(file);
      const inside = path.relative(active, resolved);
      if (inside.startsWith("..") || path.isAbsolute(inside) || !fs.statSync(resolved).isFile()) throw new Error("outside root");
      let body = fs.readFileSync(resolved);
      const extension = path.extname(resolved).toLowerCase();
      const types = {
        ".html": "text/html; charset=utf-8", ".htm": "text/html; charset=utf-8",
        ".js": "text/javascript; charset=utf-8", ".mjs": "text/javascript; charset=utf-8",
        ".css": "text/css; charset=utf-8", ".json": "application/json", ".map": "application/json",
        ".svg": "image/svg+xml", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
        ".gif": "image/gif", ".webp": "image/webp", ".ico": "image/x-icon", ".wasm": "application/wasm",
      };
      const type = types[extension] ?? "application/octet-stream";
      if (extension === ".html" || extension === ".htm") {
        const html = body.toString("utf8");
        const tag = `<script src="/__knot/reload.js?v=${version}"></script>`;
        const closing = html.search(/<\/body\b/i);
        body = Buffer.from(closing < 0 ? html + tag : html.slice(0, closing) + tag + html.slice(closing));
      }
      response.writeHead(200, {
        "content-type": type,
        "content-length": body.length,
        "cache-control": "no-store",
        "x-content-type-options": "nosniff",
      });
      response.end(request.method === "HEAD" ? undefined : body);
    } catch (error) {
      const status = error.code === "EACCES" || error.code === "ELOOP" ? 403 : 404;
      response.writeHead(status, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
      response.end("not found\n");
    }
  });

  listener.on("error", (error) => {
    process.stderr.write(error.code === "EADDRINUSE"
      ? `knot serve: port ${port} is already in use\n`
      : `knot serve: cannot bind loopback listener: ${error.message}\n`);
    process.exit(1);
  });
  listener.listen(port, "127.0.0.1", () => {
    process.stderr.write(`knot serve: http://127.0.0.1:${port}/\n`);
    let baseline;
    try { baseline = fingerprint(); } catch { baseline = ""; }
    const initial = runBuild(false);
    if (initial === 0) publishSuccessfulBuild();
    try { baseline = fingerprint(); } catch { /* Preserve the last available baseline. */ }
    setInterval(() => {
      let current;
      try { current = fingerprint(); } catch { return; }
      if (current === baseline) return;
      const before = current;
      const status = runBuild(false);
      if (status === 0) publishSuccessfulBuild();
      try { baseline = fingerprint(); } catch { baseline = before; }
      if (baseline !== before) {
        const nextStatus = runBuild(false);
        if (nextStatus === 0) publishSuccessfulBuild();
        try { baseline = fingerprint(); } catch { /* Keep the prior stable snapshot. */ }
      }
    }, 100);
  });

  process.on("SIGINT", () => listener.close(() => process.exit(130)));
  process.on("SIGTERM", () => listener.close(() => process.exit(143)));
  return io_done({ $: "Unit" });
}
