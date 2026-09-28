import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build rejects an output path that escapes the project", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "console.log(42);\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "../escape.js"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /unsafe_output/);
});
