import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("install rejects two workspaces that share a package name", async (t) => {
  const server = http.createServer((_req, res) => {
    res.writeHead(404);
    res.end();
  });
  await new Promise((resolve) => {
    server.listen(0, "127.0.0.1", resolve);
  });
  t.after(() => new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  }));
  const registryUrl = `http://127.0.0.1:${server.address().port}`;

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      workspaces: ["packages/a", "packages/b"],
    }, null, 2),
    "packages/a/package.json": JSON.stringify({
      name: "knot-ws-dup",
      version: "1.0.0",
      type: "module",
    }, null, 2),
    "packages/b/package.json": JSON.stringify({
      name: "knot-ws-dup",
      version: "1.0.1",
      type: "module",
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.notEqual(install.status, 0);
  assert.match(install.stderr, /duplicate_workspace/);
  assert.match(install.stderr, /knot-ws-dup/);
});
