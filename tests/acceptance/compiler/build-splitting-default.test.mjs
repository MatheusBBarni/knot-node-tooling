import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("dynamic imports require explicit splitting", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lazy.ts": "export const value = 42;\n",
    "main.ts": 'import("./lazy.ts").then((module) => console.log(module.value));\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /dynamic imports require --splitting/);
  assert.equal(result.stdout, "");
});
