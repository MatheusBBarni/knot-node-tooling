import assert from "node:assert/strict";
import { access } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build --outdir writes an executable entry artifact", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(7);\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outdir", "dist"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);
  await access(path.join(workspace, "dist", "main.js"));

  const run = await runProcess(process.execPath, ["dist/main.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "7\n");
});
