import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build loads text modules as default strings", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "message.txt": "hello knot\n",
    "entry.ts": [
      'import message from "./message.txt";',
      "console.log(message.trim());",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "hello knot\n");
});
