import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("analyze reports dynamic import and require edge kinds", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": [
      'const lazy = import("./lazy.ts");',
      'const dependency = require("./dependency.ts");',
      "console.log(lazy, dependency);",
      "",
    ].join("\n"),
    "lazy.ts": "export const lazy = 1;\n",
    "dependency.ts": "module.exports = { dependency: 2 };\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["analyze", "entry.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const payload = JSON.parse(result.stdout);
  const entry = payload.modules.find((module) => module.file === "entry.ts");
  assert.deepEqual(entry.edges, [
    { kind: "dynamic-import", specifier: "./lazy.ts" },
    { kind: "require", specifier: "./dependency.ts" },
  ]);
  assert.ok(payload.modules.some((module) => module.file === "lazy.ts"));
  assert.ok(payload.modules.some((module) => module.file === "dependency.ts"));
});
