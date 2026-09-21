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

test("install selects a matching version published after many older releases", async (t) => {
  const tar = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "2.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"from later release\"; }\n",
  });
  const integrity = sriSha512(tar);
  const tarballPath = `/${pkgName}/-/${pkgName}-2.0.0.tgz`;

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const versions = {};
      for (let i = 0; i < 80; i += 1) {
        versions[`0.0.${i}`] = {
          name: pkgName,
          version: `0.0.${i}`,
          dist: {
            tarball: `http://127.0.0.1:${port}/${pkgName}/-/${pkgName}-0.0.${i}.tgz`,
            integrity,
          },
        };
      }
      versions["2.0.0"] = {
        name: pkgName,
        version: "2.0.0",
        dist: {
          tarball: `http://127.0.0.1:${port}${tarballPath}`,
          integrity,
        },
      };
      const body = JSON.stringify({
        name: pkgName,
        "dist-tags": { latest: "2.0.0" },
        versions,
      });
      res.writeHead(200, {
        "content-type": "application/vnd.npm.install-v1+json",
        "content-length": Buffer.byteLength(body),
      });
      res.end(body);
      return;
    }
    if (req.method === "GET" && req.url === tarballPath) {
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
    server.close((err) => {
      if (err) {
        reject(err);
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
        [pkgName]: "2.0.0",
      },
    }, null, 2),
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
  assert.equal(imported.stdout, "from later release\n");
});
