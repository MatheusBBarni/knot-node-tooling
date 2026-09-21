import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install fails once when the registry returns 401", async (t) => {
  let gets = 0;
  const server = http.createServer((_req, res) => {
    gets += 1;
    res.writeHead(401, { "www-authenticate": "Bearer" });
    res.end("unauthorized");
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
      dependencies: {
        [pkgName]: "1.0.0",
      },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.notEqual(install.status, 0);
  assert.match(install.stderr, /auth_failed/);
  assert.equal(gets, 1);
});
