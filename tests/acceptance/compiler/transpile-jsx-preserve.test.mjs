import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile --jsx-runtime preserve keeps JSX and strips types", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.tsx": "export const el = (name: string) => <div className=\"a\">{name}</div>;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["transpile", "--jsx-runtime", "preserve", "input.tsx"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.match(js, /<\s*div/);
  assert.match(js, /className/);
  assert.doesNotMatch(js, /:\s*string/);
  assert.doesNotMatch(js, /React\.createElement/);
  assert.doesNotMatch(js, /from\s+["']react\/jsx-runtime["']/);
});
