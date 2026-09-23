import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build fails a missing package without network and names knot install", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "import { hello } from \"left-pad\";\nconsole.log(hello());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /left-pad/);
  assert.match(result.stderr, /knot install/);
  assert.match(result.stderr, /missing_dependency/);
});
