import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("ignoring dependency sideEffects annotations retains an unused module and changes the semantic digest", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "node_modules/pure/package.json": '{"name":"pure","type":"module","sideEffects":false,"exports":"./index.js"}',
    "node_modules/pure/index.js": 'globalThis.effect = true; export const unused = 1;\n',
    "main.ts": 'import { unused } from "pure"; console.log(globalThis.effect === true);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const base = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.equal(base.status, 0, base.stderr);
  assert.equal((await runProcess(process.execPath, ["out.js"], { cwd: workspace })).stdout, "false\n");

  const ignored = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js", "--ignore-side-effects-annotations"], { cwd: workspace });
  assert.equal(ignored.status, 0, ignored.stderr);
  assert.equal((await runProcess(process.execPath, ["out.js"], { cwd: workspace })).stdout, "true\n");
  assert.match(await readFile(path.join(workspace, "out.js"), "utf8"), /effect/);

  const common = ["build", "main.ts", "--outfile", "out.js", "--show-config"];
  const first = await runProcess(knot, common, { cwd: workspace });
  const second = await runProcess(knot, [...common, "--ignore-side-effects-annotations"], { cwd: workspace });
  assert.equal(first.status, 0, first.stderr);
  assert.equal(second.status, 0, second.stderr);
  assert.notEqual(JSON.parse(first.stdout).configDigest, JSON.parse(second.stdout).configDigest);
});
