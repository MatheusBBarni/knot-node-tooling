import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile erases import type and keeps runtime imports", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "math.js": "export function mul(a, b) { return a * b; }\n",
    "input.ts": [
      "import type { Id } from \"./types.js\";",
      "import { mul } from \"./math.js\";",
      "export function double(x: Id): Id {",
      "  return mul(x, 2);",
      "}",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /types\.js/);
  assert.doesNotMatch(js, /import type/);
  assert.match(js, /math\.js/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { double } from "./input.js"; console.log(double(3));`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "6\n");
});
