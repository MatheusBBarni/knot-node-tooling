import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { KnotTestHome } from "../../support/home.mjs";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const packageNames = Array.from({ length: 8 }, (_, index) => `knot-fixture-parallel-${index}`);

test("install fetches independent registry metadata concurrently", async (t) => {
  const packages = new Map(packageNames.map((name, index) => {
    const tarball = npmTarball({
      "package.json": JSON.stringify({
        name,
        version: "1.0.0",
        type: "module",
        exports: "./index.js",
      }),
      "index.js": `export default ${index};\n`,
    });
    return [name, { tarball, integrity: sriSha512(tarball) }];
  }));
  let metadataInFlight = 0;
  let maxMetadataInFlight = 0;

  const server = http.createServer((req, res) => {
    const name = req.url?.slice(1).split("/")[0];
    const pkg = packages.get(name);
    if (req.method === "GET" && pkg !== undefined && req.url === `/${name}`) {
      metadataInFlight += 1;
      maxMetadataInFlight = Math.max(maxMetadataInFlight, metadataInFlight);
      const tarballPath = `/${name}/-/${name}-1.0.0.tgz`;
      const body = JSON.stringify({
        name,
        "dist-tags": { latest: "1.0.0" },
        versions: {
          "1.0.0": {
            name,
            version: "1.0.0",
            dist: {
              tarball: `http://127.0.0.1:${port}${tarballPath}`,
              integrity: pkg.integrity,
            },
          },
        },
      });
      setTimeout(() => {
        metadataInFlight -= 1;
        res.writeHead(200, {
          "content-type": "application/vnd.npm.install-v1+json",
          "content-length": Buffer.byteLength(body),
        });
        res.end(body);
      }, 100);
      return;
    }
    if (req.method === "GET" && pkg !== undefined && req.url === `/${name}/-/${name}-1.0.0.tgz`) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": pkg.tarball.length,
      });
      res.end(pkg.tarball);
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
    server.close((error) => error ? reject(error) : resolve());
  }));

  const home = await KnotTestHome.create(t);
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: Object.fromEntries(packageNames.map((name) => [name, "1.0.0"])),
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", `http://127.0.0.1:${port}`], {
    cwd: workspace,
    env: KnotTestHome.env(home),
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);
  assert.ok(maxMetadataInFlight > 1, `expected concurrent metadata requests, observed ${maxMetadataInFlight}`);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `const values = await Promise.all(${JSON.stringify(packageNames)}.map((name) => import(name).then((mod) => mod.default))); console.log(values.join(","));`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "0,1,2,3,4,5,6,7\n");
});
