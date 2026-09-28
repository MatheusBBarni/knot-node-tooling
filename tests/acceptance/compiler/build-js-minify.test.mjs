import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build minifies JavaScript when requested", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "const value = 1 + 2; console.log(value);\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "dist.js", "--minify"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist.js"), "utf8");
  assert.match(js, /console\.log\(value\)/);
  assert.doesNotMatch(js, /const value = 1 \+ 2/);
});

test("build minifies local identifiers when requested", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "function longLocalName() { const anotherLongName = 1; return anotherLongName; } export const result = longLocalName();\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "dist.js", "--minify-identifiers"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist.js"), "utf8");
  assert.doesNotMatch(js, /anotherLongName/);
  assert.match(js, /return\s+[a-z]\s*;/);
});
