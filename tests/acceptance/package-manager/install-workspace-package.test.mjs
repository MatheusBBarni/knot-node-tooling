import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("install links a workspace package so Node.js can import it", async (t) => {
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
      workspaces: ["packages/lib"],
      dependencies: {
        "knot-ws-lib": "1.0.0",
      },
    }, null, 2),
    "packages/lib/package.json": JSON.stringify({
      name: "knot-ws-lib",
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }, null, 2),
    "packages/lib/index.js": "export function hello() { return \"from-workspace\"; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { hello } from \"knot-ws-lib\"; console.log(hello());",
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "from-workspace\n");
});
