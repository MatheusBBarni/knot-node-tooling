import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { once } from "node:events";
import net from "node:net";
import path from "node:path";
import { setTimeout as delay } from "node:timers/promises";
import test from "node:test";
import { writeFile } from "node:fs/promises";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const watchPage = '<!doctype html><html><head><link rel="stylesheet" href="./style.css"></head><body><img id="asset" src="./pixel.svg"><output id="navigation"></output><output id="value"></output><script>const key="knot-serve-navigation";const n=Number(sessionStorage.getItem(key)||"0")+1;sessionStorage.setItem(key,String(n));document.querySelector("#navigation").textContent=String(n);</script><script type="module" src="./main.ts"></script></body></html>\n';
const unsupportedHtmlPage = '<!doctype html><html><body><output id="value"></output></body></html>\n';
const recoveredPage = '<!doctype html><html><body><output id="value"></output><script type="module" src="./main.ts"></script></body></html>\n';

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

function startServer(cwd, port) {
  const child = spawn(knot, ["serve", "index.html", "--port", String(port)], {
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

async function waitFor(fn, timeoutMs = 12_000) {
  const start = Date.now();
  let last;
  while (Date.now() - start < timeoutMs) {
    try {
      return await fn();
    } catch (error) {
      last = error;
      await delay(75);
    }
  }
  throw last ?? new Error("timed out");
}

async function waitForReady(child, port) {
  return waitFor(async () => {
    if (child.exitCode !== null) throw new Error(`knot serve exited ${child.exitCode}: ${child.stderrText}`);
    assert.match(child.stderrText, new RegExp(`http://127\\.0\\.0\\.1:${port}/`));
    return child.stderrText;
  });
}

async function waitForStatus(port, expected) {
  return waitFor(async () => {
    const response = await request(`http://127.0.0.1:${port}/`);
    assert.equal(response.status, expected);
    return response;
  });
}

async function runBrowser(args, cwd) {
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

function sessionArgs(session, ...args) {
  return ["--session", session, ...args];
}

async function stop(child, signal = "SIGTERM") {
  if (child.exitCode !== null) return child.exitCode;
  const closed = once(child, "close");
  const forceKill = setTimeout(() => child.kill("SIGKILL"), 5_000);
  child.kill(signal);
  try {
    const [status] = await closed;
    return status;
  } finally {
    clearTimeout(forceKill);
  }
}

test("serve reloads only after successful rebuilds and preserves the prior page on failure", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "serve-watch", type: "module" }),
    "index.html": watchPage,
    "main.ts": 'document.querySelector("#value").textContent = "value: one";\n',
    "style.css": "#value { color: rgb(1, 2, 3); }\n",
    "pixel.svg": '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"><path d="M0 0h1v1H0z"/></svg>\n',
  });
  let child;
  t.after(async () => {
    if (child) await stop(child, "SIGKILL");
    await removeWorkspace(workspace);
  });

  const port = await unusedPort();
  child = startServer(workspace, port);
  await waitForReady(child, port);
  await waitForStatus(port, 200);

  const session = `knot-serve-watch-${process.pid}`;
  const browser = async (...args) => {
    const result = await runBrowser(sessionArgs(session, ...args), workspace);
    assert.equal(result.status, 0, result.stderr);
    return result.stdout;
  };
  try {
    await browser("open", `http://127.0.0.1:${port}/`);
    await browser("wait", "--text", "value: one");
    const initial = JSON.parse(await browser("eval", '({ navigation: document.querySelector("#navigation").textContent, value: document.querySelector("#value").textContent, color: getComputedStyle(document.querySelector("#value")).color, asset: document.querySelector("#asset").complete && document.querySelector("#asset").naturalWidth > 0 })'));
    assert.deepEqual(initial, { navigation: "1", value: "value: one", color: "rgb(1, 2, 3)", asset: true });

    await Promise.all([
      writeFile(path.join(workspace, "index.html"), unsupportedHtmlPage),
      writeFile(path.join(workspace, "main.ts"), 'document.querySelector("#value").textContent = "value: two";\n'),
    ]);
    await waitFor(() => {
      assert.match(child.stderrText, /unsupported_html/);
      return child.stderrText;
    });
    const retained = await request(`http://127.0.0.1:${port}/main.js`);
    assert.equal(retained.status, 200);
    assert.match(await retained.text(), /value: one/);
    await delay(800);
    const afterFailure = JSON.parse(await browser("eval", '({ navigation: document.querySelector("#navigation").textContent, value: document.querySelector("#value").textContent, color: getComputedStyle(document.querySelector("#value")).color, asset: document.querySelector("#asset").complete && document.querySelector("#asset").naturalWidth > 0 })'));
    assert.deepEqual(afterFailure, { navigation: "1", value: "value: one", color: "rgb(1, 2, 3)", asset: true });

    await writeFile(path.join(workspace, "index.html"), watchPage);
    await browser("wait", "--text", "value: two");
    await waitFor(async () => {
      const observed = JSON.parse(await browser("eval", '({ navigation: document.querySelector("#navigation").textContent, value: document.querySelector("#value").textContent, color: getComputedStyle(document.querySelector("#value")).color, asset: document.querySelector("#asset").complete && document.querySelector("#asset").naturalWidth > 0 })'));
      assert.deepEqual(observed, { navigation: "2", value: "value: two", color: "rgb(1, 2, 3)", asset: true });
      return observed;
    });
    const rebuilt = await request(`http://127.0.0.1:${port}/main.js`);
    assert.equal(rebuilt.status, 200);
    assert.match(await rebuilt.text(), /value: two/);
    assert.equal(child.stdoutText, "");
  } finally {
    await runBrowser(sessionArgs(session, "close"), workspace);
  }

  assert.equal(await stop(child, "SIGINT"), 130);
});

test("serve exposes 503 after an initial build failure, recovers, and honors SIGTERM", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "serve-recovery", type: "module" }),
    "index.html": unsupportedHtmlPage,
    "main.ts": 'document.querySelector("#value").textContent = "recovered";\n',
  });
  let child;
  t.after(async () => {
    if (child) await stop(child, "SIGKILL");
    await removeWorkspace(workspace);
  });

  const port = await unusedPort();
  child = startServer(workspace, port);
  await waitForReady(child, port);
  await waitForStatus(port, 503);
  await waitFor(() => {
    assert.match(child.stderrText, /unsupported_html/);
    return child.stderrText;
  });

  await writeFile(path.join(workspace, "index.html"), recoveredPage);
  await waitForStatus(port, 200);
  const session = `knot-serve-recovery-${process.pid}`;
  try {
    const opened = await runBrowser(sessionArgs(session, "open", `http://127.0.0.1:${port}/`), workspace);
    assert.equal(opened.status, 0, opened.stderr);
    const visible = await runBrowser(sessionArgs(session, "wait", "--text", "recovered"), workspace);
    assert.equal(visible.status, 0, visible.stderr);
  } finally {
    await runBrowser(sessionArgs(session, "close"), workspace);
  }

  assert.equal(await stop(child, "SIGTERM"), 143);
});
