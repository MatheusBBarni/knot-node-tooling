import assert from "node:assert/strict";
import { access, mkdtemp, readFile, rm } from "node:fs/promises";
import { constants } from "node:fs";
import { tmpdir } from "node:os";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

async function exists(p) {
  try {
    await access(p, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

test("fetch populates the store from the lockfile without linking node_modules", async (t) => {
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
  let tarballGets = 0;

  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;
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
    if (req.method === "GET" && req.url === `/${pkgName}/-/${pkgName}-1.0.0.tgz`) {
      tarballGets += 1;
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

  const home = await mkdtemp(path.join(tmpdir(), "knot-home-"));
  t.after(() => removeWorkspace(home));
  const env = { ...process.env, HOME: home };

  const first = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(first.status, 0, first.stderr);
  const lock = await readFile(path.join(workspace, "knot.lock"), "utf8");
  await rm(path.join(workspace, "node_modules"), { recursive: true, force: true });
  await rm(path.join(home, ".knot"), { recursive: true, force: true });

  const fetched = await runProcess(knot, ["fetch", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(fetched.status, 0, fetched.stderr);
  assert.equal(await readFile(path.join(workspace, "knot.lock"), "utf8"), lock);
  assert.equal(await exists(path.join(workspace, "node_modules", pkgName)), false);

  const offline = await runProcess(knot, ["install", "--offline"], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(offline.status, 0, offline.stderr);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from fixture\n");
});
