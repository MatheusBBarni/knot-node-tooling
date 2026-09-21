import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

function pkgTar(name, greeting) {
  return npmTarball({
    "package.json": JSON.stringify({
      name,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": `export function hello() { return "${greeting}"; }\n`,
  });
}

function startRegistry() {
  const aTar = pkgTar("knot-filter-a", "from-a");
  const bTar = pkgTar("knot-filter-b", "from-b");
  const pkgs = {
    "knot-filter-a": { version: "1.0.0", tarball: aTar, integrity: sriSha512(aTar) },
    "knot-filter-b": { version: "1.0.0", tarball: bTar, integrity: sriSha512(bTar) },
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

function wsPkg(name, dep) {
  return {
    [`packages/${name}/package.json`]: JSON.stringify({
      name: `knot-ws-${name}`,
      version: "1.0.0",
      type: "module",
      dependencies: {
        [dep]: "1.0.0",
      },
    }, null, 2),
    [`packages/${name}/index.js`]: `import { hello } from "${dep}"; export function greet() { return hello(); }\n`,
  };
}

test("install --filter materializes only the selected workspace dependencies", async (t) => {
  const registry = startRegistry();
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      workspaces: ["packages/a", "packages/b"],
    }, null, 2),
    ...wsPkg("a", "knot-filter-a"),
    ...wsPkg("b", "knot-filter-b"),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, [
    "install",
    "--filter",
    "packages/a",
    "--registry",
    registryUrl,
  ], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const fromA = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { greet } from \"./index.js\"; console.log(greet());",
  ], { cwd: path.join(workspace, "packages", "a") });
  assert.equal(fromA.status, 0, fromA.stderr);
  assert.equal(fromA.stdout, "from-a\n");

  const fromB = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { greet } from \"./index.js\"; console.log(greet());",
  ], { cwd: path.join(workspace, "packages", "b") });
  assert.notEqual(fromB.status, 0);
});
