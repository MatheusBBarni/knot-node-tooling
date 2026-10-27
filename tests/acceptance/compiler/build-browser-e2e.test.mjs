import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

function runBrowser(args, cwd) {
  return new Promise((resolve, reject) => {
    let stdout = "";
    let stderr = "";
    const child = spawn("agent-browser", args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      reject(new Error(`agent-browser timed out: ${args.join(" ")}`));
    }, 30_000);
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => { stdout += chunk; });
    child.stderr.on("data", (chunk) => { stderr += chunk; });
    child.once("error", (error) => {
      clearTimeout(timer);
      reject(error);
    });
    child.once("close", (status, signal) => {
      clearTimeout(timer);
      resolve({ status, signal, stdout, stderr });
    });
  });
}

function startStaticServer(root) {
  const server = createServer(async (request, response) => {
    const requestPath = decodeURIComponent((request.url ?? "/").split("?", 1)[0]);
    const candidate = path.resolve(root, `.${requestPath === "/" ? "/index.html" : requestPath}`);
    if (!candidate.startsWith(`${path.resolve(root)}${path.sep}`)) {
      response.writeHead(400);
      response.end("bad path");
      return;
    }
    try {
      const extension = path.extname(candidate);
      const contentType = {
        ".css": "text/css",
        ".html": "text/html",
        ".js": "text/javascript",
        ".map": "application/json",
        ".svg": "image/svg+xml",
      }[extension] ?? "application/octet-stream";
      response.setHeader("Connection", "close");
      response.setHeader("Content-Type", contentType);
      response.writeHead(200);
      response.end(await readFile(candidate));
    } catch {
      if (!response.headersSent) response.writeHead(404);
      if (!response.writableEnded) response.end("not found");
    }
  });
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      resolve({ server, port: address.port });
    });
  });
}

test("built HTML applies CSS, loads assets and maps, and executes chunks in a real browser", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "index.html": '<!doctype html><html><head><link rel="stylesheet" href="./style.css"></head><body><img id="logo" src="./logo.svg"><output id="result">pending</output><button id="load">Load lazy chunk</button><script type="module" crossorigin="anonymous" src="./main.ts"></script></body></html>\n',
    "logo.svg": '<svg xmlns="http://www.w3.org/2000/svg" width="2" height="2"><rect width="2" height="2" fill="red"/></svg>',
    "main.ts": [
      'const result = document.getElementById("result");',
      'const image = document.getElementById("logo");',
      'document.getElementById("load").addEventListener("click", async () => {',
      '  const module = await import("./lazy.ts");',
      '  result.textContent = module.value;',
      '});',
      'document.addEventListener("DOMContentLoaded", async () => {',
      '  const [jsMap, cssMap] = await Promise.all([',
      '    fetch("./main.js.map").then((response) => response.json()),',
      '    fetch("./style.css.map").then((response) => response.json()),',
      '  ]);',
      '  await image.decode();',
      '  result.dataset.color = getComputedStyle(document.body).color;',
      '  result.dataset.content = getComputedStyle(result, "::before").content;',
      '  result.dataset.asset = String(image.naturalWidth > 0);',
      '  result.dataset.maps = `${jsMap.version},${cssMap.version}`;',
      '  result.textContent = "Knot browser runtime OK";',
      '});',
      "",
    ].join("\n"),
    "lazy.ts": 'export const value = "lazy chunk executed";\n',
    "style.css": 'body { color: rgb(255, 0, 0); }\n#result::before { content: "alpha  0px /* literal */ beta"; }\n',
  });
  t.after(() => removeWorkspace(workspace));

  const build = await runProcess(knot, ["build", "index.html", "--outdir", "dist", "--splitting", "--preload", "static", "--sourcemap", "linked", "--minify"], { cwd: workspace });
  assert.equal(build.status, 0, build.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /<link rel="modulepreload" href="main\.js"/);

  const { server, port } = await startStaticServer(path.join(workspace, "dist"));
  t.after(() => {
    server.closeAllConnections();
    server.close();
  });

  const session = `knot-bundler-e2e-${process.pid}`;

  try {
    const open = await runBrowser(["--session", session, "open", `http://127.0.0.1:${port}/`], workspace);
    assert.equal(open.status, 0, open.stderr);
    const wait = await runBrowser(["--session", session, "wait", "--text", "Knot browser runtime OK"], workspace);
    assert.equal(wait.status, 0, wait.stderr);
    const observed = await runBrowser([
      "--session",
      session,
      "eval",
      '({ color: document.getElementById("result").dataset.color, content: document.getElementById("result").dataset.content, asset: document.getElementById("result").dataset.asset, maps: document.getElementById("result").dataset.maps, preload: [...document.querySelectorAll(\'link[rel="modulepreload"]\')].map((link) => new URL(link.href).pathname) })',
    ], workspace);
    assert.equal(observed.status, 0, observed.stderr);
    assert.deepEqual(JSON.parse(observed.stdout), {
      asset: "true",
      color: "rgb(255, 0, 0)",
      content: '"alpha  0px /* literal */ beta"',
      maps: "3,3",
      preload: ["/main.js"],
    });

    const click = await runBrowser(["--session", session, "click", "#load"], workspace);
    assert.equal(click.status, 0, click.stderr);
    const lazy = await runBrowser(["--session", session, "wait", "--text", "lazy chunk executed"], workspace);
    assert.equal(lazy.status, 0, lazy.stderr);
  } finally {
    await runBrowser(["--session", session, "close"], workspace);
  }
});
