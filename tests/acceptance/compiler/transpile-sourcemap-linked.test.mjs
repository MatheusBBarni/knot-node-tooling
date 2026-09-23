import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile writes linked source map with real mappings", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export const n: number = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.match(js, /sourceMappingURL=input\.js\.map/);

  const map = JSON.parse(await readFile(path.join(workspace, "input.js.map"), "utf8"));
  assert.equal(map.version, 3);
  assert.equal(map.sources.length, 1);
  assert.notEqual(map.mappings, "AAAA");
  assert.ok(map.mappings.length > 4);
});
