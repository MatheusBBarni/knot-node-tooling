import assert from "node:assert/strict";
import { access } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("browser CommonJS fails before reading entries or staging outputs in build and analyze", async (t) => {
  const workspace = await makeWorkspace({ "package.json": '{"type":"module"}' });
  t.after(() => removeWorkspace(workspace));
  for (const command of ["build", "analyze"]) {
    const args = [command, "missing.ts", "--target", "browser", "--format", "cjs"];
    const result = await runProcess(knot, command === "build" ? [...args, "--outdir", "dist"] : args, { cwd: workspace });
    assert.notEqual(result.status, 0, `${command} unexpectedly succeeded`);
    assert.match(result.stderr, /unsupported_format/, result.stderr);
    assert.doesNotMatch(result.stderr, /missing\.ts|missing_input|ENOENT/, result.stderr);
  }
  await assert.rejects(access(path.join(workspace, "dist")), { code: "ENOENT" });
});
