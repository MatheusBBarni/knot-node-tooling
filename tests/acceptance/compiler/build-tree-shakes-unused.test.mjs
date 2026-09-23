import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build removes an unused exported function and keeps the used one", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": [
      "export function used() { return 1; }",
      "export function unused() { return 2; }",
      "",
    ].join("\n"),
    "main.ts": "import { used } from \"./lib.ts\";\nconsole.log(used());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "out.js"), "utf8");
  assert.doesNotMatch(js, /\bunused\b/);
  assert.match(js, /\bused\b/);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "1\n");
});
