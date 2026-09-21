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

function pkgFiles(version, greeting) {
  return {
    "package.json": JSON.stringify({
      name: pkgName,
      version,
      type: "module",
      exports: "./index.js",
    }),
    "index.js": `export function hello() { return "${greeting}"; }\n`,
  };
}

test("install selects the highest version that satisfies a greater-or-equal range", async (t) => {
  const registry = startRegistry({
    name: pkgName,
    versions: [
      { version: "1.0.0", files: pkgFiles("1.0.0", "v1.0.0") },
      { version: "1.5.0", files: pkgFiles("1.5.0", "v1.5.0") },
      { version: "2.0.0", files: pkgFiles("2.0.0", "v2.0.0") },
    ],
  });
  t.after(() => registry.close());
  const registryUrl = await registry.url();

  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "app",
      type: "module",
      dependencies: {
        [pkgName]: ">=1.2.0",
      },
    }, null, 2),
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const lock = await readFile(path.join(workspace, "knot.lock"), "utf8");
  assert.match(lock, /version 2\.0\.0/);
  assert.doesNotMatch(lock, /version 1\.0\.0/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "v2.0.0\n");
});
