import assert from "node:assert/strict";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { gzipSync } from "node:zlib";
import { sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

function tarHeader(name, size) {
  const buf = Buffer.alloc(512);
  buf.write(name);
  buf.write("0000644\0", 100);
  buf.write("0000000\0", 108);
  buf.write("0000000\0", 116);
  buf.write(`${size.toString(8).padStart(11, "0")}\0`, 124);
  buf.write("00000000000\0", 136);
  buf.write("        ", 148);
  buf.write("0", 156);
  buf.write("ustar\0", 257);
  buf.write("00", 263);
  let sum = 0;
  for (const byte of buf) {
    sum += byte;
  }
  buf.write(`${sum.toString(8).padStart(6, "0")}\0 `, 148);
  return buf;
}

function tarFile(name, content) {
  const data = Buffer.from(content);
  const pad = (512 - (data.length % 512)) % 512;
  const parts = [tarHeader(name, data.length), data];
  if (pad > 0) {
    parts.push(Buffer.alloc(pad));
  }
  return Buffer.concat(parts);
}

function duplicateTarball() {
  return gzipSync(Buffer.concat([
    tarFile("package/package.json", JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    })),
    tarFile("package/index.js", "export function hello() { return \"first\"; }\n"),
    tarFile("package/index.js", "export function hello() { return \"second\"; }\n"),
    Buffer.alloc(1024),
  ]));
}

test("install rejects a tarball with a duplicate archive path", async (t) => {
  const tarball = duplicateTarball();
  const integrity = sriSha512(tarball);
  const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
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
      });
      res.end(body);
      return;
    }
    if (req.method === "GET" && req.url === tarballPath) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": tarball.length,
      });
      res.end(tarball);
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
  assert.match(install.stderr, /duplicate_entry/);
});
