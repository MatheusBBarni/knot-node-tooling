import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile --outfile writes JavaScript to the named path", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "src/input.ts": "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "src/input.ts", "--outfile", "dist/out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  await assert.rejects(() => readFile(path.join(workspace, "src/input.js")));
  const js = await readFile(path.join(workspace, "dist/out.js"), "utf8");
  assert.doesNotMatch(js, /:\s*number/);
  assert.match(js, /sourceMappingURL=out\.js\.map/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { add } from "./dist/out.js"; console.log(add(1, 8));`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "9\n");
});
