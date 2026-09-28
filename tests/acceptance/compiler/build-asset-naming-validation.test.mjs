import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build rejects unknown and escaping asset naming templates", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "logo.png": "asset",
    "main.ts": "import logo from './logo.png'; console.log(logo);\n",
  });
  t.after(() => removeWorkspace(workspace));

  for (const template of ["[unknown].[ext]", "../[name].[ext]"]) {
    const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js", "--asset-naming", template], { cwd: workspace });
    assert.notEqual(result.status, 0, template);
    assert.match(result.stderr, /invalid asset naming template/);
  }
});
