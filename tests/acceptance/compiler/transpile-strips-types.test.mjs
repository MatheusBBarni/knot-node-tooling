import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile strips type annotations and runs in Node.js", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /:\s*number/);
  assert.match(js, /sourceMappingURL=input\.js\.map/);

  const map = JSON.parse(await readFile(path.join(workspace, "input.js.map"), "utf8"));
  assert.equal(map.version, 3);
  assert.equal(map.file, "input.js");
  assert.deepEqual(map.sources, ["input.ts"]);
  assert.equal(typeof map.mappings, "string");

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { add } from "./input.js"; console.log(add(2, 3));`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "5\n");
});
