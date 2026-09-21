import assert from "node:assert/strict";
import { access, mkdir, writeFile } from "node:fs/promises";
import { constants } from "node:fs";
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

test("cache clean removes registry metadata without deleting verified store content", async (t) => {
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

  const home = path.join(workspace, "home");
  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
    env: {
      ...process.env,
      HOME: home,
    },
  });
  assert.equal(install.status, 0, install.stderr);

  const cacheDir = path.join(home, ".knot", "cache");
  const meta = path.join(cacheDir, "registry-meta.json");
  await mkdir(cacheDir, { recursive: true });
  await writeFile(meta, "{}");

  const cleaned = await runProcess(knot, ["cache", "clean"], {
    cwd: workspace,
    env: {
      ...process.env,
      HOME: home,
    },
  });
  assert.equal(cleaned.status, 0, cleaned.stderr);
  assert.match(`${cleaned.stderr}\n${cleaned.stdout}`, /cleared registry metadata/);
  assert.equal(await exists(meta), false);

  const casDir = path.join(home, ".knot", "cas");
  assert.equal(await exists(casDir), true);

  const offline = await runProcess(knot, ["install", "--offline"], {
    cwd: workspace,
    env: {
      ...process.env,
      HOME: home,
    },
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
