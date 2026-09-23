import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const launcherSource = path.join(repoRoot, "packaging/npm/knot.cjs");

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function writeFile(file, body, mode = 0o644) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, body);
  fs.chmodSync(file, mode);
}

function launcherCopy(dir) {
  const dest = path.join(dir, "bin", "knot.js");
  writeFile(dest, fs.readFileSync(launcherSource), 0o755);
  assert.equal(fs.readFileSync(dest, "utf8"), fs.readFileSync(launcherSource, "utf8"));
  return dest;
}

function writeWrapper(dir, bins) {
  writeFile(path.join(dir, "package.json"), JSON.stringify({
    name: "@scope/knot",
    version: "0.0.0",
    bin: { knot: "bin/knot.js" },
    knot: { bins },
  }, null, 2));
}

function writePlatform(root, name, binaryBody) {
  const pkgDir = path.join(root, "node_modules", ...name.split("/"));
  writeFile(path.join(pkgDir, "package.json"), JSON.stringify({ name, version: "0.0.0" }));
  const binary = path.join(pkgDir, "bin", name.endsWith("win32-x64") ? "knot.exe" : "knot");
  writeFile(binary, binaryBody, 0o755);
  return binary;
}

const nodeStandin = `#!/usr/bin/env node
const fs = require("node:fs");
if (process.env.KNOT_START) {
  fs.writeFileSync(process.env.KNOT_START, "started");
}
const args = {};
for (let i = 0; i <= 8; i += 1) {
  const key = "KNOT_ARG_" + i;
  if (Object.prototype.hasOwnProperty.call(process.env, key)) {
    args[key] = process.env[key];
  }
}
let stdin = null;
if (process.env.KNOT_READ_STDIN === "1") {
  stdin = fs.readFileSync(0, "utf8");
}
if (process.env.KNOT_OBS) {
  fs.writeFileSync(process.env.KNOT_OBS, JSON.stringify({
    argc: process.env.KNOT_ARGC ?? null,
    args,
    argv: process.argv.slice(2),
    self: fs.realpathSync(process.argv[1]),
    stdin,
  }));
}
process.stdout.write("stdout-marker\\n");
process.stderr.write("stderr-marker\\n");
process.exit(Number(process.env.KNOT_CODE || "0"));
`;

function baseEnv(extra = {}) {
  const env = { ...process.env };
  delete env.KNOT_PLATFORM;
  delete env.KNOT_ARCH;
  delete env.KNOT_LIB_DIR;
  return { ...env, ...extra };
}

function runLauncher(launcher, args, env, options = {}) {
  const child = spawn(process.execPath, [launcher, ...args], {
    env,
    stdio: ["pipe", "pipe", "pipe"],
    detached: options.detached ?? false,
  });
  if (options.stdin !== undefined) {
    child.stdin.end(options.stdin);
  } else {
    child.stdin.end();
  }
  const result = new Promise((resolve, reject) => {
    let stdout = "";
    let stderr = "";
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (status, signal) => {
      resolve({ status, signal, stdout, stderr, pid: child.pid });
    });
  });
  return { child, result };
}

async function waitForFile(file) {
  const start = Date.now();
  while (Date.now() - start < 5000) {
    if (fs.existsSync(file)) {
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
  throw new Error(`timed out waiting for ${file}`);
}

test("launcher source starts with the node shebang and does not name a network client", () => {
  const source = fs.readFileSync(launcherSource, "utf8");
  assert.equal(source.startsWith("#!/usr/bin/env node\n"), true);
  const forbidden = [
    "node:http",
    "node:https",
    "node:net",
    "node:tls",
    "node:dns",
    "require(\"http\")",
    "require(\"https\")",
    "require(\"net\")",
    "undici",
    "fetch(",
    "registry.npmjs",
    "NPM_TOKEN",
    ".npmrc",
    "child_process.exec",
  ];
  for (const token of forbidden) {
    assert.equal(source.includes(token), false, token);
  }
});

test("linux loader sets choose musl, glibc, or both paths", async () => {
  const launcher = launcherSource;

  const muslDir = fs.mkdtempSync(path.join(os.tmpdir(), "knot-musl-"));
  writeFile(path.join(muslDir, "ld-musl-aarch64.so.1"), "");
  writeFile(path.join(muslDir, "libc.musl-aarch64.so.1"), "");
  const musl = await runLauncher(launcher, [], baseEnv({
    KNOT_PLATFORM: "linux",
    KNOT_ARCH: "arm64",
    KNOT_LIB_DIR: muslDir,
  })).result;
  assert.equal(musl.status, 127, musl.stderr);
  assert.match(musl.stderr, /@scope\/knot-linux-arm64-musl/);
  assert.match(musl.stderr, /linux/);
  assert.match(musl.stderr, /arm64/);
  assert.doesNotMatch(musl.stderr, /binary integrity check failed/);

  const glibcDir = fs.mkdtempSync(path.join(os.tmpdir(), "knot-glibc-"));
  writeFile(path.join(glibcDir, "ld-linux-aarch64.so.1"), "");
  writeFile(path.join(glibcDir, "libc.so.6"), "");
  const glibc = await runLauncher(launcher, [], baseEnv({
    KNOT_PLATFORM: "linux",
    KNOT_ARCH: "arm64",
    KNOT_LIB_DIR: glibcDir,
  })).result;
  assert.equal(glibc.status, 127, glibc.stderr);
  assert.match(glibc.stderr, /package not found: @scope\/knot-linux-arm64 \(/);
  assert.doesNotMatch(glibc.stderr, /knot-linux-arm64-musl/);

  const bothDir = fs.mkdtempSync(path.join(os.tmpdir(), "knot-both-"));
  const muslPath = path.join(bothDir, "ld-musl-aarch64.so.1");
  const glibcPath = path.join(bothDir, "ld-linux-aarch64.so.1");
  writeFile(muslPath, "");
  writeFile(glibcPath, "");
  const both = await runLauncher(launcher, [], baseEnv({
    KNOT_PLATFORM: "linux",
    KNOT_ARCH: "x64",
    KNOT_LIB_DIR: bothDir,
  })).result;
  assert.equal(both.status, 1, both.stderr);
  assert.match(both.stderr, /both musl and glibc loaders are present/);
  assert.ok(both.stderr.includes(muslPath), both.stderr);
  assert.ok(both.stderr.includes(glibcPath), both.stderr);

  const live = await runLauncher(launcher, [], baseEnv({
    KNOT_PLATFORM: "linux",
    KNOT_ARCH: process.arch,
  })).result;
  assert.equal(live.status, 127, live.stderr);
  assert.match(live.stderr, new RegExp(`package not found: @scope/knot-linux-${process.arch} \\(`));
  assert.doesNotMatch(live.stderr, /-musl/);
});

test("a launcher run does not open a registry connection", async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "knot-net-"));
  const log = path.join(dir, "net.log");
  fs.writeFileSync(log, "");
  const preload = path.join(dir, "preload.cjs");
  fs.writeFileSync(preload, `
const fs = require("node:fs");
const net = require("node:net");
const dns = require("node:dns");
const log = process.env.KNOT_NET_LOG;
function note(line) { fs.appendFileSync(log, line + "\\n"); }
const connect = net.Socket.prototype.connect;
net.Socket.prototype.connect = function (...args) {
  note("connect " + args.map((part) => String(part && part.href || part)).join(" "));
  return connect.apply(this, args);
};
for (const name of ["lookup", "resolve", "resolve4", "resolve6"]) {
  const orig = dns[name];
  if (typeof orig !== "function") continue;
  dns[name] = function (...args) {
    note("dns " + name + " " + String(args[0]));
    return orig.apply(this, args);
  };
}
`);
  const result = await runLauncher(launcherSource, ["--version"], baseEnv({
    KNOT_NET_LOG: log,
    NODE_OPTIONS: `--require ${preload}`,
  })).result;
  assert.equal(result.status, 127, result.stderr);
  assert.equal(fs.readFileSync(log, "utf8"), "");
});

test("resolves a hoisted platform package and forwards argv, status, and stdio", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-hoist-"));
  const wrapper = path.join(root, "node_modules/@scope/knot");
  const launcher = launcherCopy(wrapper);
  const binary = writePlatform(root, "@scope/knot-darwin-arm64", nodeStandin);
  writeWrapper(wrapper, { "@scope/knot-darwin-arm64": sha256(binary) });
  const obs = path.join(root, "obs.json");
  const result = await runLauncher(launcher, ["alpha", "beta"], baseEnv({
    KNOT_OBS: obs,
    KNOT_CODE: "9",
    KNOT_READ_STDIN: "1",
  }), { stdin: "hello-stdin\n" }).result;
  assert.equal(result.status, 9, result.stderr);
  assert.equal(result.stdout, "stdout-marker\n");
  assert.equal(result.stderr, "stderr-marker\n");
  const seen = JSON.parse(fs.readFileSync(obs, "utf8"));
  assert.equal(seen.argc, "2");
  assert.equal(seen.args.KNOT_ARG_1, "alpha");
  assert.equal(seen.args.KNOT_ARG_2, "beta");
  assert.equal(Object.hasOwn(seen.args, "KNOT_ARG_0"), false);
  assert.deepEqual(seen.argv, []);
  assert.equal(seen.stdin, "hello-stdin\n");
  assert.equal(seen.self, fs.realpathSync(binary));
});

test("resolves a platform package nested under the wrapper", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-nest-"));
  const wrapper = path.join(root, "node_modules/@scope/knot");
  const launcher = launcherCopy(wrapper);
  const binary = writePlatform(wrapper, "@scope/knot-darwin-arm64", nodeStandin);
  writeWrapper(wrapper, { "@scope/knot-darwin-arm64": sha256(binary) });
  const obs = path.join(root, "obs.json");
  const result = await runLauncher(launcher, ["--version"], baseEnv({
    KNOT_OBS: obs,
  })).result;
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, "stdout-marker\n");
  const seen = JSON.parse(fs.readFileSync(obs, "utf8"));
  assert.equal(seen.argc, "1");
  assert.equal(seen.args.KNOT_ARG_1, "--version");
  assert.equal(seen.self, fs.realpathSync(binary));
  assert.equal(seen.self.includes(`${path.sep}knot${path.sep}node_modules${path.sep}`), true);
});

test("win32 selects bin/knot.exe", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-win-"));
  const wrapper = path.join(root, "node_modules/@scope/knot");
  const launcher = launcherCopy(wrapper);
  const binary = writePlatform(root, "@scope/knot-win32-x64", nodeStandin);
  assert.equal(path.basename(binary), "knot.exe");
  writeWrapper(wrapper, { "@scope/knot-win32-x64": sha256(binary) });
  const obs = path.join(root, "obs.json");
  const result = await runLauncher(launcher, [], baseEnv({
    KNOT_PLATFORM: "win32",
    KNOT_ARCH: "x64",
    KNOT_OBS: obs,
  })).result;
  assert.equal(result.status, 0, result.stderr);
  const seen = JSON.parse(fs.readFileSync(obs, "utf8"));
  assert.equal(seen.self, fs.realpathSync(binary));
  assert.equal(seen.argc, "0");
  assert.deepEqual(seen.args, {});
});

test("a byte mismatch exits 1 before the binary starts", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-hash-"));
  const wrapper = path.join(root, "node_modules/@scope/knot");
  const launcher = launcherCopy(wrapper);
  const start = path.join(root, "started");
  const binary = writePlatform(root, "@scope/knot-darwin-arm64", nodeStandin);
  writeWrapper(wrapper, { "@scope/knot-darwin-arm64": "0".repeat(64) });
  const result = await runLauncher(launcher, ["--version"], baseEnv({
    KNOT_START: start,
  })).result;
  assert.equal(result.status, 1);
  assert.equal(result.stderr, "knot: binary integrity check failed\n");
  assert.equal(result.stdout, "");
  assert.equal(fs.existsSync(start), false);
});

test("a missing platform package exits 127 and names the package and triple", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-miss-"));
  const wrapper = path.join(root, "node_modules/@scope/knot");
  const launcher = launcherCopy(wrapper);
  writeWrapper(wrapper, {});
  const result = await runLauncher(launcher, ["--version"], baseEnv()).result;
  assert.equal(result.status, 127);
  assert.match(result.stderr, /@scope\/knot-darwin-arm64/);
  assert.match(result.stderr, /darwin/);
  assert.match(result.stderr, /arm64/);
});

test("SIGINT, SIGTERM, and SIGHUP exit with 128 plus the signal number", async () => {
  const signals = ["SIGTERM", "SIGINT", "SIGHUP"];
  for (const signal of signals) {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-sig-"));
    const wrapper = path.join(root, "node_modules/@scope/knot");
    const launcher = launcherCopy(wrapper);
    const ready = path.join(root, "ready");
    const binary = writePlatform(root, "@scope/knot-darwin-arm64", `#!/bin/sh
printf 'ready\\n' > "$KNOT_READY"
exec /bin/sleep 30
`);
    writeWrapper(wrapper, { "@scope/knot-darwin-arm64": sha256(binary) });
    const { child, result } = runLauncher(launcher, [], baseEnv({
      KNOT_READY: ready,
    }), { detached: true });
    try {
      await waitForFile(ready);
      process.kill(child.pid, signal);
      const finished = await result;
      assert.equal(finished.status, 128 + os.constants.signals[signal], `${signal} ${finished.stderr}`);
      assert.equal(finished.signal, null);
    } finally {
      try {
        process.kill(-child.pid, "SIGKILL");
      } catch {
        // The launcher process group has already exited.
      }
    }
  }
});
