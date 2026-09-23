import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

// Default transpile emits ESM; import= require() lowers to default import
// (avoid `import * as`, because the type-eraser strips the `as` keyword).
test("transpile lowers import-equals require to ESM namespace import", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": [
      'import fs = require("node:fs");',
      "export function kind() {",
      "  return typeof fs.readFileSync;",
      "}",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /import\s+\w+\s*=\s*require/);
  assert.match(js, /import\s+fs\s+from\s+["']node:fs["']/);

  const imported = await runProcess(process.execPath, [
    "--input-type=module",
    "-e",
    `import { kind } from "./input.js"; console.log(kind());`,
  ], { cwd: workspace });
  assert.equal(imported.status, 0, imported.stderr);
  assert.equal(imported.stdout, "function\n");
});
