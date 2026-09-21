import assert from "node:assert/strict";
import { access, mkdir, mkdtemp, writeFile } from "node:fs/promises";
import { constants } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
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

test("store prune deletes CAS files that the lockfile does not reference", async (t) => {
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
  const env = { ...process.env, HOME: home };

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
    env,
  });
  assert.equal(install.status, 0, install.stderr);

  const casDir = path.join(home, ".knot", "cas");
  const junk = path.join(casDir, "unreferenced-blob");
  await mkdir(casDir, { recursive: true });
  await writeFile(junk, "junk");

  const pruned = await runProcess(knot, ["store", "prune"], { cwd: workspace, env });
  assert.equal(pruned.status, 0, pruned.stderr);
  assert.equal(await exists(junk), false);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { hello } from "${pkgName}"; console.log(hello());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from fixture\n");
});
