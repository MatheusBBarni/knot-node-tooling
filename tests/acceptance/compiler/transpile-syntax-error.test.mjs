import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile does not emit JavaScript when a module has a syntax error", async (t) => {
  const workspace = await makeWorkspace({
    "input.ts": "export function add() {\n  /* unterminated\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /syntax_error/);
  await assert.rejects(() => readFile(path.join(workspace, "input.js")));
});
