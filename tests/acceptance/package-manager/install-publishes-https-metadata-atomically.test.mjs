import assert from "node:assert/strict";
import https from "node:https";
import path from "node:path";
import test from "node:test";
import { KnotTestHome } from "../../support/home.mjs";
import { createTestCertificate } from "../../support/https.mjs";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-atomic-metadata";

test("concurrent installs never observe partial HTTPS metadata", async (t) => {
  const { key, cert, certPath } = await createTestCertificate(t);
  const tarball = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export default 'atomic metadata';\n",
  });
  const integrity = sriSha512(tarball);
  const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;
  let port = 0;
  let metadataGets = 0;
  let releaseFirstResponse;
  let signalFirstResponse;
  const firstResponseStarted = new Promise((resolve) => {
    signalFirstResponse = resolve;
  });
  const firstResponseRelease = new Promise((resolve) => {
    releaseFirstResponse = resolve;
  });

  const metadataBody = () => Buffer.from(JSON.stringify({
    name: pkgName,
    "dist-tags": { latest: "1.0.0" },
    versions: {
      "1.0.0": {
        name: pkgName,
        version: "1.0.0",
        dist: {
          tarball: `https://127.0.0.1:${port}${tarballPath}`,
          integrity,
        },
      },
    },
  }));

  const tlsServer = https.createServer({ key, cert }, async (req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      metadataGets += 1;
      const body = metadataBody();
      res.writeHead(200, {
        "content-type": "application/vnd.npm.install-v1+json",
        "content-length": body.length,
      });
      if (metadataGets === 1) {
        res.write(body.subarray(0, 20));
        signalFirstResponse();
        await firstResponseRelease;
        res.end(body.subarray(20));
      } else {
        res.end(body);
      }
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
  await new Promise((resolve) => {
    tlsServer.listen(0, "127.0.0.1", () => {
      port = tlsServer.address().port;
      resolve();
    });
  });
  t.after(() => new Promise((resolve, reject) => {
    tlsServer.close((error) => error ? reject(error) : resolve());
  }));

  const home = await KnotTestHome.create(t);
  const registryUrl = `https://127.0.0.1:${port}`;
  const env = KnotTestHome.env(home, {
    ...process.env,
    CURL_CA_BUNDLE: certPath,
    SSL_CERT_FILE: certPath,
    NODE_EXTRA_CA_CERTS: certPath,
  });
  const manifest = JSON.stringify({
    name: "app",
    type: "module",
    dependencies: { [pkgName]: "1.0.0" },
  }, null, 2);
  const firstWorkspace = await makeWorkspace({ "package.json": manifest });
  const secondWorkspace = await makeWorkspace({ "package.json": manifest });
  t.after(() => removeWorkspace(firstWorkspace));
  t.after(() => removeWorkspace(secondWorkspace));

  const firstInstallPromise = runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: firstWorkspace,
    env,
    timeoutMs: 60_000,
  });
  await firstResponseStarted;
  await new Promise((resolve) => setTimeout(resolve, 100));

  let secondInstall;
  try {
    secondInstall = await runProcess(knot, ["install", "--registry", registryUrl], {
      cwd: secondWorkspace,
      env,
      timeoutMs: 60_000,
    });
  } finally {
    releaseFirstResponse();
  }
  const firstInstall = await firstInstallPromise;

  assert.equal(secondInstall.status, 0, secondInstall.stderr);
  assert.equal(firstInstall.status, 0, firstInstall.stderr);
  assert.equal(metadataGets, 2);
});
