import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build prefers package exports over main", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "node_modules/foo/package.json": JSON.stringify({
      name: "foo",
      type: "module",
      main: "legacy.js",
      exports: { ".": "./lib/hello.js" },
    }),
    "node_modules/foo/legacy.js": "export function hello() { return \"legacy\"; }\n",
    "node_modules/foo/lib/hello.js": "export function hello() { return \"exports\"; }\n",
    "main.ts": "import { hello } from \"foo\";\nconsole.log(hello());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "exports\n");
});
