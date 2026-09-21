import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { startRegistry } from "../../support/registry.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");
const pkgName = "knot-fixture-hello";

test("install materializes a workspace package dependency so Node.js can import it", async (t) => {
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
      workspaces: ["packages/lib"],
    }, null, 2),
    "packages/lib/package.json": JSON.stringify({
      name: "knot-ws-lib",
      version: "1.0.0",
      type: "module",
      dependencies: {
        [pkgName]: "1.0.0",
      },
    }, null, 2),
    "packages/lib/index.js": `import { hello } from "${pkgName}"; export function greet() { return hello(); }\n`,
  });
  t.after(() => removeWorkspace(workspace));

  const install = await runProcess(knot, ["install", "--registry", registryUrl], {
    cwd: workspace,
    timeoutMs: 60_000,
  });
  assert.equal(install.status, 0, install.stderr);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    "import { greet } from \"./index.js\"; console.log(greet());",
  ], { cwd: path.join(workspace, "packages", "lib") });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "hello from fixture\n");
});
