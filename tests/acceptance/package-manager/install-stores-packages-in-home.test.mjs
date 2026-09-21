import assert from "node:assert/strict";
import { mkdtemp, readdir } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install stores tarballs and unpacked packages under HOME/.knot", async (t) => {
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

  const home = await mkdtemp(path.join(tmpdir(), "knot-home-"));
  t.after(() => removeWorkspace(home));

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

  const env = { ...process.env, HOME: home };
  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env,
  });
  assert.equal(install.status, 0, install.stderr);

  const cas = await readdir(path.join(home, ".knot", "cas"));
  assert.ok(cas.some((name) => name.startsWith("sha512-")));
  const unpacked = await readdir(path.join(home, ".knot", "unpacked"));
  assert.ok(unpacked.some((name) => name.startsWith("sha512-")));

  let projectKnot = [];
  try {
    projectKnot = await readdir(path.join(workspace, ".knot"));
  } catch {
    projectKnot = [];
  }
  assert.equal(projectKnot.length, 0);

  const listed = await runProcess(knot, ["store", "path"], { cwd: workspace, env });
  assert.equal(listed.status, 0, listed.stderr);
  assert.equal(listed.stdout, path.join(home, ".knot", "cas") + "\n");

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from fixture\n");
});
