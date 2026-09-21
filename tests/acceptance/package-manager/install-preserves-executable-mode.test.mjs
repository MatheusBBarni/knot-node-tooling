import assert from "node:assert/strict";
import { stat } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install preserves executable mode from a package tarball", async (t) => {
  const registry = startRegistry({
    name: pkgName,
    versions: [
      {
        version: "1.0.0",
        modes: { "cli.js": "0000755" },
        files: {
          "package.json": JSON.stringify({
            name: pkgName,
            version: "1.0.0",
            type: "module",
            exports: "./index.js",
          }),
          "index.js": "export function hello() { return \"hello from fixture\"; }\n",
          "cli.js": "#!/usr/bin/env node\nconsole.log(\"ok\");\n",
        },
      },
    ],
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

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const info = await stat(path.join(workspace, "node_modules", ".knot", pkgName, "cli.js"));
  assert.equal(info.mode & 0o111, 0o111);
});
