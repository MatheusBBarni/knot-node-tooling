import assert from "node:assert/strict";
import https from "node:https";
import path from "node:path";
import test from "node:test";
import { KnotTestHome } from "../../support/home.mjs";
import { createTestCertificate } from "../../support/https.mjs";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-https-auth-failure";

test("install does not retry an HTTPS registry authentication failure", async (t) => {
  const { key, cert, certPath } = await createTestCertificate(t);
  let gets = 0;
  const server = https.createServer({ key, cert }, (_req, res) => {
    gets += 1;
    res.writeHead(401, { "www-authenticate": "Bearer" });
    res.end("unauthorized");
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
      dependencies: { [pkgName]: "1.0.0" },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", `https://127.0.0.1:${port}`], {
    cwd: workspace,
    env: KnotTestHome.env(home, {
      ...process.env,
      CURL_CA_BUNDLE: certPath,
      SSL_CERT_FILE: certPath,
      NODE_EXTRA_CA_CERTS: certPath,
    }),
    timeoutMs: 60_000,
  });

  assert.notEqual(install.status, 0);
  assert.equal(gets, 1);
});
