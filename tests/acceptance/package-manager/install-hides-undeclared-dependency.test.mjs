import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("install hides a transitive package from undeclared importers", async (t) => {

  const leafTar = npmTarball({
    "package.json": JSON.stringify({
      name: "knot-fixture-leaf",
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function ping() { return \"leaf\"; }\n",
  });
  const midTar = npmTarball({
    "package.json": JSON.stringify({
      name: "knot-fixture-mid",
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
      dependencies: {
        "knot-fixture-leaf": "1.0.0",
      },
    }),
    "index.js": "import { ping } from \"knot-fixture-leaf\"; export function hello() { return ping(); }\n",
  });
  const pkgs = {
    "knot-fixture-leaf": { version: "1.0.0", tarball: leafTar, integrity: sriSha512(leafTar) },
    "knot-fixture-mid": { version: "1.0.0", tarball: midTar, integrity: sriSha512(midTar) },
  };
  const server = http.createServer((req, res) => {
    const name = req.url && req.url.startsWith("/") ? req.url.slice(1).split("/")[0] : "";
    const pkg = pkgs[name];
    if (req.method === "GET" && pkg !== undefined && req.url === `/${name}`) {
      const tarballPath = `/${name}/-/${name}-${pkg.version}.tgz`;
      const body = JSON.stringify({
        name,
        "dist-tags": { latest: pkg.version },
        versions: {
          [pkg.version]: {
            name,
            version: pkg.version,
            dist: {
              tarball: `http://127.0.0.1:${port}${tarballPath}`,
              integrity: pkg.integrity,
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
    for (const [n, p] of Object.entries(pkgs)) {
      const tarballPath = `/${n}/-/${n}-${p.version}.tgz`;
      if (req.method === "GET" && req.url === tarballPath) {
        res.writeHead(200, {
          "content-type": "application/octet-stream",
          "content-length": p.tarball.length,
        });
        res.end(p.tarball);
        return;
      }
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
        "knot-fixture-mid": "1.0.0",
      },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const declared = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { hello } from \"knot-fixture-mid\"; console.log(hello());",
  ], { cwd: workspace });
  assert.equal(declared.status, 0, declared.stderr);
  assert.equal(declared.stdout, "leaf\n");

  const phantom = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { ping } from \"knot-fixture-leaf\"; console.log(ping());",
  ], { cwd: workspace });
  assert.notEqual(phantom.status, 0);
});
