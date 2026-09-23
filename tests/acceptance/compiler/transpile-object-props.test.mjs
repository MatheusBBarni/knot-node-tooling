import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile keeps object property values after type stripping", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts":
      "type Id = string;\nexport const o = { a: 1, b: name };\nexport function f(x: Id): Id { return x; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.match(js, /b\s*:\s*name/);
  assert.match(js, /a\s*:\s*1/);
  assert.doesNotMatch(js, /:\s*Id/);
  assert.doesNotMatch(js, /\btype\s+Id\b/);
});
