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
    const child = spawn("agent-browser", args, { cwd, stdio: "ignore" });
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      reject(new Error(`agent-browser timed out: ${args.join(" ")}`));
    }, 30_000);
    child.once("error", (error) => {
      clearTimeout(timer);
      reject(error);
    });
    child.once("close", (status, signal) => {
      clearTimeout(timer);
      resolve({ status, signal });
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
      response.setHeader("Connection", "close");
      response.setHeader("Content-Type", candidate.endsWith(".js") ? "text/javascript" : "text/html");
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

test("built HTML executes in a real browser", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "index.html": '<script type="module" src="./main.ts"></script>\n',
    "main.ts": 'document.addEventListener("DOMContentLoaded", () => { document.body.textContent = "Knot browser runtime OK"; });\n',
  });
  t.after(() => removeWorkspace(workspace));

  const build = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(build.status, 0, build.stderr);

  const { server, port } = await startStaticServer(path.join(workspace, "dist"));
  t.after(() => {
    server.closeAllConnections();
    server.close();
  });

  const session = `knot-bundler-e2e-${process.pid}`;

  try {
    const open = await runBrowser(["--session", session, "open", `http://127.0.0.1:${port}/`], workspace);
    assert.equal(open.status, 0);
    const wait = await runBrowser(["--session", session, "wait", "--text", "Knot browser runtime OK"], workspace);
    assert.equal(wait.status, 0);
  } finally {
    await runBrowser(["--session", session, "close"], workspace);
  }
});
