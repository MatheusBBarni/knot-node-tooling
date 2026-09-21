import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install writes the same knot.lock for reordered equivalent manifests", async (t) => {
  const registry = startRegistry({
    name: pkgName,
    version: "1.0.0",
    files: {
      "package.json": JSON.stringify({
        name: pkgName,
        version: "1.0.0",
        type: "module",
        exports: "./index.js",
      }),
      "index.js": "export function hello() { return \"hello from fixture\"; }\n",
    },
  });
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspaceA = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        [pkgName]: "1.0.0",
      },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspaceA));

  const workspaceB = await makeWorkspace({
    "package.json": `{
  "dependencies": {
    "${pkgName}": "1.0.0"
  },
  "type": "module",
  "name": "app"
}
`,
  });
  t.after(() => removeWorkspace(workspaceB));

  const installA = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspaceA,
    timeoutMs: 60_000,
  });
  assert.equal(installA.status, 0, installA.stderr);
  const installB = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspaceB,
    timeoutMs: 60_000,
  });
  assert.equal(installB.status, 0, installB.stderr);

  const lockA = await readFile(path.join(workspaceA, "knot.lock"), "utf8");
  const lockB = await readFile(path.join(workspaceB, "knot.lock"), "utf8");
  assert.equal(lockA, lockB);
  assert.match(lockA, new RegExp(`name ${pkgName}`));
  assert.match(lockA, /version 1\.0\.0/);
  assert.match(lockA, /integrity sha512-/);
});
