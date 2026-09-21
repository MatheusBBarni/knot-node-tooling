import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const runtimeName = "knot-fixture-runtime";
const devName = "knot-fixture-dev";

function startProdRegistry() {
  const runtimeTar = npmTarball({
    "package.json": JSON.stringify({
      name: runtimeName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"runtime\"; }\n",
  });
  const devTar = npmTarball({
    "package.json": JSON.stringify({
      name: devName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"dev\"; }\n",
  });
  const pkgs = {
    [runtimeName]: { version: "1.0.0", tarball: runtimeTar, integrity: sriSha512(runtimeTar) },
    [devName]: { version: "1.0.0", tarball: devTar, integrity: sriSha512(devTar) },
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

test("install --production skips a devDependency so Node.js cannot import it", async (t) => {
  const registry = startProdRegistry();
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        [runtimeName]: "1.0.0",
      },
      devDependencies: {
        [devName]: "1.0.0",
      },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--production", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const runtime = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${runtimeName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(runtime.status, 0, runtime.stderr);
  assert.equal(runtime.stdout, "runtime\n");

  const dev = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${devName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.notEqual(dev.status, 0);
});
