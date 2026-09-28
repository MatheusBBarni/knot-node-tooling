import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build extracts imported CSS beside the JavaScript artifact", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "style.css": "body { color: red; }\n",
    "entry.ts": [
      'import "./style.css";',
      "console.log(42);",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "42\n");
  assert.equal(await readFile(path.join(workspace, "out.css"), "utf8"), "body { color: red; }\n");
});
