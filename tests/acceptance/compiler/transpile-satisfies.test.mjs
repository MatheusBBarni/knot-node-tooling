import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile erases satisfies and keeps the value", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": [
      "export const n = { a: 1 } satisfies { a: number };",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /\bsatisfies\b/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { n } from "./input.js"; console.log(n.a);`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "1\n");
});
