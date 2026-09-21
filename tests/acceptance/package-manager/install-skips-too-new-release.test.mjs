import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install skips versions newer than knot.toml minimum-release-age-before", async (t) => {
  const oldTar = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "0.9.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"hello from 0.9.0\"; }\n",
  });
  const newTar = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"hello from 1.0.0\"; }\n",
  });
  const oldIntegrity = sriSha512(oldTar);
  const newIntegrity = sriSha512(newTar);
  const oldPath = `/${pkgName}/-/${pkgName}-0.9.0.tgz`;
  const newPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const body = JSON.stringify({
        name: pkgName,
        "dist-tags": { latest: "1.0.0" },
        time: {
          "0.9.0": "2018-01-01T00:00:00.000Z",
          "1.0.0": "2024-01-01T00:00:00.000Z",
        },
        versions: {
          "0.9.0": {
            name: pkgName,
            version: "0.9.0",
            dist: {
              tarball: `http://127.0.0.1:${port}${oldPath}`,
              integrity: oldIntegrity,
            },
          },
          "1.0.0": {
            name: pkgName,
            version: "1.0.0",
            dist: {
              tarball: `http://127.0.0.1:${port}${newPath}`,
              integrity: newIntegrity,
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
    if (req.method === "GET" && req.url === oldPath) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": oldTar.length,
      });
      res.end(oldTar);
      return;
    }
    if (req.method === "GET" && req.url === newPath) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": newTar.length,
      });
      res.end(newTar);
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
        [pkgName]: ">=0.9.0",
      },
    }, null, 2),
    "knot.toml": "minimum-release-age-before=2020-01-01T00:00:00.000Z\n",
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
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from 0.9.0\n");
});
