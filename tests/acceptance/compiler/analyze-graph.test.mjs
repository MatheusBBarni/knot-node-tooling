import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("analyze walks a small relative import graph as JSON", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts":
      'import { add } from "./math.ts";\nimport { missing } from "./nope.ts";\nexport const n = add(1, 2);\n',
    "math.ts":
      "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["analyze", "entry.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const payload = JSON.parse(result.stdout);
  assert.deepEqual(payload.entries, ["entry.ts"]);
  assert.ok(Array.isArray(payload.modules));
  assert.ok(payload.modules.length >= 2);

  const byFile = Object.fromEntries(payload.modules.map((m) => [m.file, m]));
  assert.ok(byFile["entry.ts"]);
  assert.deepEqual(byFile["entry.ts"].imports, ["./math.ts", "./nope.ts"]);
  assert.deepEqual(byFile["entry.ts"].exports, ["n"]);
  assert.ok(byFile["math.ts"]);
  assert.deepEqual(byFile["math.ts"].exports, ["add"]);
  assert.ok(payload.missing.includes("./nope.ts"));
});
