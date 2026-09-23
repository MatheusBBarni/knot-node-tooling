import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("scan omits type-only imports", async (t) => {
  const workspace = await makeWorkspace({
    "input.ts": [
      "import type { Id } from \"./types.js\";",
      "import { mul } from \"./math.js\";",
      "export function add(a: number, b: number): number {",
      "  return mul(a, b);",
      "}",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["scan", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.deepEqual(payload.imports, ["./math.js"]);
  assert.deepEqual(payload.exports, ["add"]);
});
