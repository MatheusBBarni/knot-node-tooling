import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile erases interfaces and keeps runtime exports", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": [
      "export interface Point { x: number; y: number }",
      "export function origin(): Point {",
      "  return { x: 0, y: 0 };",
      "}",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /\binterface\b/);
  assert.doesNotMatch(js, /:\s*Point/);
  assert.doesNotMatch(js, /:\s*number/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { origin } from "./input.js"; const p = origin(); console.log(p.x, p.y);`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "0 0\n");
});
