import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const scopedName = "@knot/plugin";
const hostName = "knot-fixture-host";

function startNestedRegistry() {
  const hostTar = npmTarball({
    "package.json": JSON.stringify({
      name: hostName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hostName() { return \"host-1\"; }\n",
  });
  const pluginTar = npmTarball({
    "package.json": JSON.stringify({
      name: scopedName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
      dependencies: {
        [hostName]: "1.0.0",
      },
    }),
    "index.js": "import { hostName } from \"knot-fixture-host\"; export function hello() { return hostName(); }\n",
  });
  const pkgs = {
    [hostName]: { version: "1.0.0", tarball: hostTar, integrity: sriSha512(hostTar) },
    [scopedName]: { version: "1.0.0", tarball: pluginTar, integrity: sriSha512(pluginTar) },
  };

  const server = http.createServer((req, res) => {
    const url = req.url ?? "";
    const name = decodeURIComponent(url.startsWith("/") ? url.slice(1) : url);
    const pkg = pkgs[name];
    if (req.method === "GET" && pkg !== undefined) {
      const tarballPath = `/${encodeURIComponent(name)}/-/${name.replace("/", "-")}-${pkg.version}.tgz`;
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
    for (const [pkgName, pkg] of Object.entries(pkgs)) {
      const tarballPath = `/${encodeURIComponent(pkgName)}/-/${pkgName.replace("/", "-")}-${pkg.version}.tgz`;
      if (req.method === "GET" && url === tarballPath) {
        res.writeHead(200, {
          "content-type": "application/octet-stream",
          "content-length": pkg.tarball.length,
        });
        res.end(pkg.tarball);
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
        server.close((err) => {
          if (err) {
            reject(err);
            return;
          }
          resolve();
        });
      });
    },
  };
}

test("install links a nested dependency of a scoped package so Node.js can import it", async (t) => {
  const registry = startNestedRegistry();
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        [scopedName]: "1.0.0",
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
    `import { hello } from "${scopedName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "host-1\n");
});
