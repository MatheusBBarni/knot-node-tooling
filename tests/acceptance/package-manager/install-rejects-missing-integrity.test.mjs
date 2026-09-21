import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install rejects a registry package that has no integrity digest", async (t) => {
  const tar = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"hello from fixture\"; }\n",
  });

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;
      const body = JSON.stringify({
        name: pkgName,
        "dist-tags": { latest: "1.0.0" },
        versions: {
          "1.0.0": {
            name: pkgName,
            version: "1.0.0",
            dist: {
              tarball: `http://127.0.0.1:${port}${tarballPath}`,
            },
          },
        },
      });
      res.writeHead(200, {
        "content-type": "application/vnd.npm.install-v1+json",
        "content-length": Buffer.byteLength(body),
      });
      res.end(body);
      return;
    }
    if (req.method === "GET" && req.url === `/${pkgName}/-/${pkgName}-1.0.0.tgz`) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": tar.length,
      });
      res.end(tar);
      return;
    }
    res.writeHead(404);
    res.end();
  });

  let port = 0;
  await new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      port = server.address().port;
      resolve();
    });
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
  const registryUrl = `http://127.0.0.1:${port}`;

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
  assert.match(install.stderr, /integrity_missing/);
  assert.equal(existsSync(path.join(workspace, "knot.lock")), false);
  assert.equal(existsSync(path.join(workspace, "node_modules", pkgName)), false);
});
