import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtemp, readFile } from "node:fs/promises";
import https from "node:https";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";
import { npmTarball, sriSha512 } from "../../support/registry.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install downloads one package from an HTTPS registry and lets Node.js import it", async (t) => {
  const certDir = await mkdtemp(path.join(tmpdir(), "knot-https-"));
  const keyPath = path.join(certDir, "key.pem");
  const certPath = path.join(certDir, "cert.pem");
  execFileSync("openssl", [
    "req",
    "-x509",
    "-newkey",
    "rsa:2048",
    "-keyout",
    keyPath,
    "-out",
    certPath,
    "-days",
    "1",
    "-nodes",
    "-subj",
    "/CN=localhost",
    "-addext",
    "subjectAltName=DNS:localhost,IP:127.0.0.1",
  ], { stdio: "ignore" });

  const key = await readFile(keyPath);
  const cert = await readFile(certPath);
  const tarball = npmTarball({
    "package.json": JSON.stringify({
      name: pkgName,
      version: "1.0.0",
      type: "module",
      exports: "./index.js",
    }),
    "index.js": "export function hello() { return \"hello from https\"; }\n",
  });
  const integrity = sriSha512(tarball);
  const tarballPath = `/${pkgName}/-/${pkgName}-1.0.0.tgz`;

  const tlsServer = https.createServer({ key, cert }, (req, res) => {
    if (req.method === "GET" && req.url === `/${pkgName}`) {
      const body = JSON.stringify({
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
    tlsServer.listen(0, "127.0.0.1", () => {
      port = tlsServer.address().port;
      resolve();
    });
  });
  t.after(() => new Promise((resolve, reject) => {
    tlsServer.close((error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  }));
  const registryUrl = `https://127.0.0.1:${port}`;

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
    env: {
      ...process.env,
      CURL_CA_BUNDLE: certPath,
      SSL_CERT_FILE: certPath,
      NODE_EXTRA_CA_CERTS: certPath,
    },
  });
  assert.equal(install.status, 0, install.stderr);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from https\n");
});
