import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build follows require and keeps CommonJS runtime exports", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app" }),
    "math.ts": "module.exports.add = function add(a, b) { return a + b; }\n",
    "main.ts": "const math = require(\"./math.ts\");\nconsole.log(math.add(2, 3));\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "5\n");
});
