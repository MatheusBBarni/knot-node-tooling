import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("scan prints runtime import specifiers as JSON", async (t) => {
  const workspace = await makeWorkspace({
    "input.ts": "import { mul } from \"./math.js\";\nexport function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["scan", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.file, "input.ts");
  assert.deepEqual(payload.exports, ["add"]);
  assert.deepEqual(payload.imports, ["./math.js"]);
});
