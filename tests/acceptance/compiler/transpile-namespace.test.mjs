import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile lowers a value namespace to a runtime object", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": [
      "export namespace N { export const x = 1; export function f() { return x; } }",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /\bnamespace\b/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { N } from "./input.js"; console.log(N.f());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "1\n");
});
