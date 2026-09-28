import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build --format cjs emits executable CommonJS with named exports", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": [
      'function announce() { console.log("entry side effect"); }',
      'console.log("default value");',
      "announce();",
      "export const answer: number = 42;",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "build",
    "entry.ts",
    "--format",
    "cjs",
    "--outfile",
    "out.cjs",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, [
    "-e",
    'const entry = require("./out.cjs"); process.stdout.write(JSON.stringify({ answer: entry.answer }) + "\\n");',
  ], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, 'default value\nentry side effect\n{"answer":42}\n');
});
