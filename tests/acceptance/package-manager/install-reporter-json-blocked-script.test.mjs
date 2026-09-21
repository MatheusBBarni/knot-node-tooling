import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install --reporter json emits blocked_script when a preinstall is denied", async (t) => {
  const registry = startRegistry({
    name: pkgName,
    version: "1.0.0",
    files: {
      "package.json": JSON.stringify({
        name: pkgName,
        version: "1.0.0",
        type: "module",
        exports: "./index.js",
        scripts: {
          preinstall: "node -e \"process.exit(0)\"",
        },
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

  const install = await runProcess(knot, [
    "install",
    "--reporter",
    "json",
    "--registry",
    registryUrl,
  ], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const text = `${install.stdout}\n${install.stderr}`;
  const events = text.split("\n").flatMap((line) => {
    const trimmed = line.trim();
    if (!trimmed.startsWith("{")) {
      return [];
    }
    try {
      return [JSON.parse(trimmed)];
    } catch {
      return [];
    }
  });
  assert.equal(events.some((event) => event.code === "blocked_script"), true);
});
