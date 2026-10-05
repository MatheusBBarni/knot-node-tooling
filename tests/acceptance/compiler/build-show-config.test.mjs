import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("show-config hashes semantic inputs independently of workspace and output location", async (t) => {
  const files = {
    "package.json": '{"type":"module"}',
    "entry.ts": "console.log(FEATURE);\n",
  };
  const firstRoot = await makeWorkspace(files);
  const secondRoot = await makeWorkspace(files);
  t.after(() => Promise.all([removeWorkspace(firstRoot), removeWorkspace(secondRoot)]));
  const show = async (cwd, flags) => {
    const result = await runProcess(knot, ["build", "entry.ts", "--show-config", ...flags], { cwd });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout.trimEnd().split("\n").length, 1);
    const record = JSON.parse(result.stdout);
    assert.match(record.configDigest, /^[A-Za-z0-9+/]{43}=$/);
    assert.equal(record.portable, true);
    assert.doesNotMatch(result.stdout, /SECRET_VALUE|knot-workspace-/);
    return record;
  };

  const base = await show(firstRoot, ["--outdir", "dist-a"]);
  assert.equal(base.config.sourcesContent, "exclude");
  assert.equal(base.config.write, true);
  const relocated = await show(secondRoot, ["--outdir", "dist-b", "--write=false"]);
  assert.equal(relocated.config.write, false);
  assert.equal(base.configDigest, relocated.configDigest);
  const defined = await show(firstRoot, ["--outdir", "dist-a", "--define", "FEATURE=SECRET_VALUE"]);
  assert.notEqual(defined.configDigest, base.configDigest);
  assert.equal(defined.config.transforms.define.FEATURE, "<redacted>");
  const oneCondition = await show(firstRoot, ["--conditions", "custom"]);
  const repeatedCondition = await show(firstRoot, ["--conditions", "custom", "--conditions", "custom"]);
  assert.deepEqual(repeatedCondition.config.conditions, ["custom"]);
  assert.equal(repeatedCondition.configDigest, oneCondition.configDigest);
});
