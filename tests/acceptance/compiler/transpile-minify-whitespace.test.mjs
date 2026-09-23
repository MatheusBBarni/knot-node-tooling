import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile --minify-whitespace keeps runtime behavior and drops extra spaces", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "transpile",
    "--minify-whitespace",
    "input.ts",
    "--outfile",
    "out.js",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "out.js"), "utf8");
  assert.match(js, /a\+b/);
  assert.doesNotMatch(js, /a \+ b/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { add } from "./out.js"; console.log(add(2, 3));`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "5\n");
});
