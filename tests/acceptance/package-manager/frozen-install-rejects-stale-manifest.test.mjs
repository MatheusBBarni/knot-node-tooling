import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("frozen install rejects a manifest that differs from the lockfile", async (t) => {
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

  const first = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(first.status, 0, first.stderr);
  const lockPath = path.join(workspace, "knot.lock");
  const lockBefore = await readFile(lockPath, "utf8");

  await writeFile(path.join(workspace, "package.json"), JSON.stringify({
    name: "app",
    type: "module",
    dependencies: {
      [pkgName]: "2.0.0",
    },
  }, null, 2));

  const frozen = await runProcess(
    knot,
    ["install", "--frozen-lockfile", "--registry", registryUrl],
    { cwd: workspace, timeoutMs: 60_000 },
  );
  assert.notEqual(frozen.status, 0);
  assert.match(frozen.stderr, /frozen_lockfile/);
  const lockAfter = await readFile(lockPath, "utf8");
  assert.equal(lockAfter, lockBefore);
});
