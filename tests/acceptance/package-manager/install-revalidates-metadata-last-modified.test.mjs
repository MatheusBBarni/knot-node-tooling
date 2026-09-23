import assert from "node:assert/strict";
import { rm } from "node:fs/promises";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";
import { KnotTestHome } from "../../support/home.mjs";
import { KnotNodeDriver } from "../../support/node-driver.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";
const lastModified = "Wed, 21 Oct 2015 07:28:00 GMT";

test("install revalidates cached registry metadata with If-Modified-Since", async (t) => {
  const tar = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"hello from fixture\"; }\n",
  });
  const integrity = sriSha512(tar);
  const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;
  const ifModifiedSince = [];
  let tarGets = 0;

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const ims = req.headers["if-modified-since"];
      ifModifiedSince.push(ims);
      if (ims === lastModified) {
        res.writeHead(304, { "last-modified": lastModified });
        res.end();
        return;
      }
      const body = JSON.stringify({
        name: pkgName,
        "dist-tags": { latest: "1.0.0" },
        versions: {
          "1.0.0": {
            name: pkgName,
            version: "1.0.0",
            dist: {
              tarball: `http://127.0.0.1:${port}${tarballPath}`,
              integrity,
            },
          },
        },
      });
      res.writeHead(200, {
        "content-type": "application/vnd.npm.install-v1+json",
        "content-length": Buffer.byteLength(body),
        "last-modified": lastModified,
      });
      res.end(body);
      return;
    }
    if (req.method === "GET" && req.url === tarballPath) {
      tarGets += 1;
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

  const home = await KnotTestHome.create(t);
  const env = KnotTestHome.env(home);

  const first = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(first.status, 0, first.stderr);
  assert.deepEqual(ifModifiedSince, [undefined]);

  await rm(path.join(workspace, "knot.lock"), { force: true });
  const second = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(second.status, 0, second.stderr);
  assert.deepEqual(ifModifiedSince, [undefined, lastModified]);
  assert.equal(tarGets, 1);

  const imported = await runProcess(KnotNodeDriver.binary(), [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from fixture\n");
});
