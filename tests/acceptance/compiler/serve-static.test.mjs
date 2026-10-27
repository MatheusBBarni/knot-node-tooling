import os from "node:os";
import { readFile, symlink, writeFile } from "node:fs/promises";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import net from "node:net";
import path from "node:path";
import { setTimeout as delay } from "node:timers/promises";
import test from "node:test";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

async function unusedPort() {
  const server = net.createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const { port } = server.address();
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  return port;
}

function request(url, timeoutMs = 2_000) {
  return fetch(url, { signal: AbortSignal.timeout(timeoutMs) });
}

function startServer(cwd, port, argsBeforeEntry = []) {
  const args = ["serve", ...argsBeforeEntry, "index.html"];
  if (port !== undefined) args.push("--port", String(port));
  const child = spawn(knot, args, {
    cwd,
    stdio: ["ignore", "pipe", "pipe"],
  });
  child.stderr.setEncoding("utf8");
  child.stdout.setEncoding("utf8");
  child.stderrText = "";
  child.stdoutText = "";
  child.stderr.on("data", (chunk) => { child.stderrText += chunk; });
  child.stdout.on("data", (chunk) => { child.stdoutText += chunk; });
  return child;
}

async function waitForPage(child, port, timeoutMs = 8_000) {
  const started = Date.now();
  let lastError;
  while (Date.now() - started < timeoutMs) {
    if (child.exitCode !== null) {
      throw new Error(`knot serve exited ${child.exitCode}: ${child.stderrText}`);
    }
    try {
      const response = await request(`http://127.0.0.1:${port}/`);
      return response;
    } catch (error) {
      lastError = error;
      await delay(50);
    }
  }
  throw new Error(`knot serve did not become ready: ${lastError ?? "no response"}; stderr: ${child.stderrText}`);
}

async function stop(child) {
  if (child.exitCode !== null) return child.exitCode;
  const closed = new Promise((resolve) => child.once("close", (status) => resolve(status)));
  const forceKill = setTimeout(() => child.kill("SIGKILL"), 5_000);
  child.kill("SIGTERM");
  try {
    return await closed;
  } finally {
    clearTimeout(forceKill);
  }
}

test("serve defaults to loopback port 3000", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "serve-default-port", type: "module" }),
    "index.html": '<!doctype html><html><body>default port<script type="module" src="./main.js"></script></body></html>\n',
    "main.js": "document.body.dataset.ready = 'true';\n",
  });
  const reservation = net.createServer();
  try {
    await new Promise((resolve, reject) => {
      reservation.once("error", reject);
      reservation.listen(3000, "127.0.0.1", resolve);
    });
  } catch (error) {
    assert.equal(error.code, "EADDRINUSE");
    const conflict = await runProcess(knot, ["serve", "index.html"], { cwd: workspace });
    assert.equal(conflict.status, 1, conflict.stderr);
    assert.match(conflict.stderr, /port 3000 is already in use/);
    await removeWorkspace(workspace);
    return;
  }
  await new Promise((resolve, reject) => reservation.close((error) => error ? reject(error) : resolve()));
  let child;
  t.after(async () => {
    if (child) await stop(child);
    await removeWorkspace(workspace);
  });

  child = startServer(workspace);
  const page = await waitForPage(child, 3000);
  assert.equal(page.status, 200, child.stderrText);
  assert.match(await page.text(), /default port/);
  assert.match(child.stderrText, /http:\/\/127\.0\.0\.1:3000\//);
  assert.equal(await stop(child), 143);
});

test("serve builds and serves an HTML entry and its local artifacts", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "index.html": '<!doctype html><html><head><link rel="stylesheet" href="./style.css"></head><body><img src="./logo.svg"><img src="./assets/nested.svg"><output id="result">pending</output><script type="module" src="./main.ts"></script></body></html>\n',
    "main.ts": 'document.querySelector("#result").textContent = "served by Knot";\n',
    "style.css": "output { color: rgb(1, 2, 3); }\n",
    "logo.svg": '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"><path d="M0 0h1v1H0z"/></svg>\n',
    "assets/nested.svg": '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2 2"><circle cx="1" cy="1" r="1"/></svg>\n',
  });
  let child;
  t.after(async () => {
    if (child) await stop(child);
    await removeWorkspace(workspace);
  });

  const port = await unusedPort();
  child = startServer(workspace, port, ["--watch", "--minify", "--outdir", "preview/site"]);

  const page = await waitForPage(child, port);
  assert.equal(page.status, 200, child.stderrText);
  const html = await page.text();
  assert.match(child.stderrText, new RegExp(`http://127\\.0\\.0\\.1:${port}/`));
  assert.equal(child.stdoutText, "");
  assert.match(html, /main\.js/);
  assert.match(html, /src="nested\.svg"/);
  assert.equal((await request(`http://127.0.0.1:${port}/main.js`)).status, 200);
  assert.equal((await request(`http://127.0.0.1:${port}/style.css`)).status, 200);
  assert.equal((await request(`http://127.0.0.1:${port}/logo.svg`)).status, 200);
  assert.equal((await request(`http://127.0.0.1:${port}/nested.svg`)).status, 200);
  assert.equal((await request(`http://127.0.0.1:${port}/missing.js`)).status, 404);

  const interfaces = Object.values(os.networkInterfaces()).flatMap((items) => items ?? []);
  const nonLoopback = interfaces.find((item) => item.family === "IPv4" && !item.internal && !item.address.startsWith("169.254."));
  if (process.platform === "darwin") {
    const binding = await runProcess("lsof", ["-nP", "-a", "-p", String(child.pid), "-iTCP", "-sTCP:LISTEN"], { cwd: workspace });
    assert.equal(binding.status, 0, binding.stderr);
    assert.match(binding.stdout, new RegExp(`TCP 127\\.0\\.0\\.1:${port} \\(LISTEN\\)`));
    assert.doesNotMatch(binding.stdout, new RegExp(`(?:\\*|0\\.0\\.0\\.0):${port}`));
  } else {
    assert.ok(nonLoopback, "no non-loopback IPv4 address is available to verify the listener boundary");
  }
  if (nonLoopback) {
    let response;
    try {
      response = await fetch(`http://${nonLoopback.address}:${port}/`, { signal: AbortSignal.timeout(400) });
    } catch {
      // Refused connections are the expected result for a loopback-only listener.
    }
    assert.equal(response, undefined, `server unexpectedly accepted ${nonLoopback.address}`);
  }

  const active = JSON.parse(await readFile(path.join(workspace, "preview/site/active.json"), "utf8"));
  const generation = path.join(workspace, "preview/site/generations", active.generation);
  const secret = path.join(workspace, "secret.txt");
  await writeFile(secret, "outside output");
  await symlink(secret, path.join(generation, "outside.txt"));
  const escaped = await request(`http://127.0.0.1:${port}/outside.txt`);
  assert.notEqual(escaped.status, 200);
  assert.doesNotMatch(await escaped.text(), /outside output/);

  const traversal = await request(`http://127.0.0.1:${port}/%2e%2e%2fsecret.txt`);
  assert.notEqual(traversal.status, 200);
  assert.doesNotMatch(await traversal.text(), /outside output/);
});
test("serve maps --outfile to the served entry in a project subdirectory", async (t) => {
  const workspace = await makeWorkspace({
    "index.html": '<!doctype html><html><body>named output<script type="module" src="./main.js"></script></body></html>\n',
    "main.js": "document.body.dataset.ready = 'true';\n",
  });
  const port = await unusedPort();
  let child;
  t.after(async () => {
    if (child) await stop(child);
    await removeWorkspace(workspace);
  });

  child = startServer(workspace, port, ["--outfile", "preview/site.html"]);
  const page = await waitForPage(child, port);
  assert.equal(page.status, 200, child.stderrText);
  assert.match(await page.text(), /named output/);
  assert.equal((await request(`http://127.0.0.1:${port}/site.html`)).status, 200);
  assert.equal((await request(`http://127.0.0.1:${port}/index.html`)).status, 404);
});


test("serve validates its help, port, and host options before opening a listener", async (t) => {
  const workspace = await makeWorkspace({
    "index.html": "<!doctype html><html><body>entry</body></html>\n",
  });
  t.after(() => removeWorkspace(workspace));

  const help = await runProcess(knot, ["serve", "--help"], { cwd: workspace });
  assert.equal(help.status, 0, help.stderr);
  assert.match(help.stdout, /127\.0\.0\.1|loopback/);

  for (const port of ["0", "65536", "not-a-port", "3.5"]) {
    const result = await runProcess(knot, ["serve", "index.html", "--port", port], { cwd: workspace });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /invalid_option/);
  }
  const duplicate = await runProcess(knot, ["serve", "index.html", "--port", "4173", "--port", "4174"], { cwd: workspace });
  assert.equal(duplicate.status, 2, duplicate.stderr);
  assert.match(duplicate.stderr, /duplicate_option/);

  const projectRoot = await runProcess(knot, ["serve", "index.html", "--outdir", "."], { cwd: workspace });
  assert.equal(projectRoot.status, 2, projectRoot.stderr);
  assert.match(projectRoot.stderr, /safe project subdirectory/);

  const host = await runProcess(knot, ["serve", "index.html", "--host", "0.0.0.0"], { cwd: workspace });
  assert.equal(host.status, 2, host.stderr);
  assert.doesNotMatch(host.stderr, /127\.0\.0\.1:/);
  for (const options of [
    ["--write=false"],
    ["--show-config"],
    ["--manifest", "-"],
    ["--metafile", "-"],
  ]) {
    const result = await runProcess(knot, ["serve", "index.html", ...options], { cwd: workspace });
    assert.equal(result.status, 2, result.stderr);
  }
});
test("serve rejects non-browser targets and non-ESM formats before binding", async (t) => {
  const workspace = await makeWorkspace({
    "index.html": "<!doctype html><html><body>entry</body></html>\n",
  });
  t.after(() => removeWorkspace(workspace));

  const port = await unusedPort();
  const reservation = net.createServer();
  await new Promise((resolve, reject) => {
    reservation.once("error", reject);
    reservation.listen(port, "127.0.0.1", resolve);
  });
  try {
    for (const options of [
      ["--target", "node"],
      ["--format", "iife"],
    ]) {
      const result = await runProcess(knot, ["serve", "index.html", ...options, "--port", String(port)], { cwd: workspace });
      assert.equal(result.status, 2, result.stderr);
      assert.match(result.stderr, /browser ESM/);
    }
  } finally {
    await new Promise((resolve, reject) => reservation.close((error) => error ? reject(error) : resolve()));
  }
});

test("serve reports a fixed-port conflict without selecting another port", async (t) => {
  const workspace = await makeWorkspace({
    "index.html": "<!doctype html><html><body>entry</body></html>\n",
  });
  t.after(() => removeWorkspace(workspace));

  const port = await unusedPort();
  const occupied = net.createServer();
  await new Promise((resolve, reject) => {
    occupied.once("error", reject);
    occupied.listen(port, "127.0.0.1", resolve);
  });
  t.after(() => new Promise((resolve) => occupied.close(resolve)));

  const result = await runProcess(knot, ["serve", "index.html", "--port", String(port)], { cwd: workspace });
  assert.equal(result.status, 1, result.stderr);
  assert.match(result.stderr, new RegExp(`port ${port} is already in use`));
  assert.doesNotMatch(result.stderr, /127\.0\.0\.1:/);
});
