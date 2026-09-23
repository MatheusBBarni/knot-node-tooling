import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build drops unused sideEffects:false modules and keeps side-effect modules", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "node_modules/pure/package.json": JSON.stringify({
      name: "pure",
      type: "module",
      sideEffects: false,
      exports: "./index.js",
    }),
    "node_modules/pure/index.js": [
      "globalThis.__pure_hit = 1;",
      "export function unused() { return 2; }",
      "",
    ].join("\n"),
    "node_modules/effect/package.json": JSON.stringify({
      name: "effect",
      type: "module",
      sideEffects: true,
      exports: "./index.js",
    }),
    "node_modules/effect/index.js": [
      "globalThis.__hit = 1;",
      "export function unused() { return 3; }",
      "",
    ].join("\n"),
    "main.ts": [
      'import { unused as a } from "pure";',
      'import { unused as b } from "effect";',
      "console.log(globalThis.__hit ? 1 : 0);",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "out.js"), "utf8");
  assert.doesNotMatch(js, /__pure_hit/);
  assert.match(js, /__hit/);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "1\n");
});
