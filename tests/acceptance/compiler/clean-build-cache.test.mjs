import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("clean --build-cache removes compiler cache and leaves build output", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const build = await runProcess(knot, ["build", "--no-bundle", "input.ts"], { cwd: workspace });
  assert.equal(build.status, 0, build.stderr);
  await access(path.join(workspace, ".knot/build-cache/v1"));

  const jsBefore = await readFile(path.join(workspace, "input.js"), "utf8");

  const clean = await runProcess(knot, ["clean", "--build-cache"], { cwd: workspace });
  assert.equal(clean.status, 0, clean.stderr);
  await assert.rejects(() => access(path.join(workspace, ".knot/build-cache/v1")));

  const jsAfter = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.equal(jsAfter, jsBefore);
});
