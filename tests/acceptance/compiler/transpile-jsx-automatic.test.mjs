import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile lowers automatic JSX with runtime import", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.tsx": "export const el = <div className=\"a\">{x}</div>;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["transpile", "--jsx-runtime", "automatic", "input.tsx"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.match(js, /from\s+["']react\/jsx-runtime["']/);
  assert.match(js, /\bjsx(s)?\s*\(/);
  assert.match(js, /["']div["']/);
  assert.match(js, /className/);
  assert.doesNotMatch(js, /React\.createElement/);
  assert.doesNotMatch(js, /<\s*div/);
});
