import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { spawn } from "node:child_process";
import test from "node:test";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

function runProtocol(cwd, input) {
  return new Promise((resolve, reject) => {
    const child = spawn(knot, ["protocol"], { cwd });
    let stdout = "";
    let stderr = "";
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      reject(new Error("protocol timed out"));
    }, 30_000);
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", (error) => {
      clearTimeout(timer);
      reject(error);
    });
    child.on("close", (status) => {
      clearTimeout(timer);
      resolve({ status, stdout, stderr });
    });
    child.stdin.end(`${input}\n`);
  });
}

test("native protocol builds from one JSON request and rejects a bad version", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 9;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const request = JSON.stringify({
    protocolVersion: 1,
    id: "t1",
    operation: "build",
    config: {
      entries: ["entry.ts"],
      output: { dir: "dist" },
      format: "esm",
      target: "browser",
    },
    returnArtifacts: false,
  });
  const built = await runProtocol(workspace, request);
  assert.equal(built.status, 0, built.stderr);
  const response = JSON.parse(built.stdout);
  assert.equal(response.protocolVersion, 1);
  assert.equal(response.id, "t1");
  assert.equal(response.status, "ok");
  assert.deepEqual(response.diagnostics, []);
  assert.equal(response.artifacts.length, 0);
  assert.match(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), /value = 9/);

  const rejected = await runProtocol(workspace, JSON.stringify({
    protocolVersion: 2,
    id: "t2",
    operation: "build",
    config: { entries: ["entry.ts"], output: { dir: "dist" }, format: "esm", target: "browser" },
    returnArtifacts: false,
  }));
  assert.equal(rejected.status, 0, rejected.stderr);
  const error = JSON.parse(rejected.stdout);
  assert.equal(error.id, "t2");
  assert.equal(error.status, "error");
  assert.equal(error.diagnostics[0].code, "unsupported_interface");
});
