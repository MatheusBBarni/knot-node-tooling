import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

function pkgTar(name, deps) {
  return npmTarball({
    "package.json": JSON.stringify({
      name,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
      dependencies: deps,
    }),
    "index.js": `export function hello() { return "${name}"; }\n`,
  });
}

function startRegistry() {
  const pkgs = {};
  for (const [name, deps] of [
    ["knot-fixture-cycle-a", { "knot-fixture-cycle-b": "1.0.0" }],
    ["knot-fixture-cycle-b", { "knot-fixture-cycle-a": "1.0.0" }],
  ]) {
    const tarball = pkgTar(name, deps);
    pkgs[name] = {
      version: "1.0.0",
      tarball,
      integrity: sriSha512(tarball),
    };
  }

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
  const listening = new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      port = server.address().port;
      resolve();
    });
  });
  return {
    async url() {
      await listening;
      return `http://127.0.0.1:${port}`;
    },
    close() {
      return new Promise((resolve, reject) => {
        server.close((error) => {
          if (error) {
            reject(error);
            return;
          }
          resolve();
        });
      });
    },
  };
}

test("install finishes when two packages depend on each other", async (t) => {
  const registry = startRegistry();
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        "knot-fixture-cycle-a": "1.0.0",
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
    'import { hello } from "knot-fixture-cycle-a"; console.log(hello());',
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "knot-fixture-cycle-a\n");
});
