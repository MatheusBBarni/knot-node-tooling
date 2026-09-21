import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import http from "node:http";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "@knot/hello";

test("install records the scoped registry origin in knot.lock", async (t) => {
  const scoped = startRegistry({
    name: pkgName,
    version: "1.0.0",
    files: {
      "package.json": JSON.stringify({
        name: pkgName,
        version: "1.0.0",
        type: "module",
        exports: "./index.js",
      }),
      "index.js": "export function hello() { return \"hello from scoped registry\"; }\n",
    },
  });
  t.after(() => scoped.close());
  const scopedUrl = await scoped.url();

  const fallback = http.createServer((_req, res) => {
    res.writeHead(404);
    res.end();
  });
  await new Promise((resolve) => {
    fallback.listen(0, "127.0.0.1", resolve);
  });
  t.after(() => new Promise((resolve, reject) => {
    fallback.close((error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  }));
  const defaultUrl = `http://127.0.0.1:${fallback.address().port}`;

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        [pkgName]: "1.0.0",
      },
    }, null, 2),
    "knot.toml": `@knot:registry=${scopedUrl}\n`,
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", defaultUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const lock = await readFile(path.join(workspace, "knot.lock"), "utf8");
  assert.equal(lock.includes(`name ${pkgName}`), true);
  assert.equal(lock.includes(`registry ${scopedUrl}`), true);
  assert.equal(lock.includes(`registry ${defaultUrl}`), false);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from scoped registry\n");
});
