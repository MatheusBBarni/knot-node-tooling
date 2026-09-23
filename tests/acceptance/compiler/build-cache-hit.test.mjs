import assert from "node:assert/strict";
import { stat } from "node:fs/promises";
import path from "node:path";
import { setTimeout as delay } from "node:timers/promises";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build --no-bundle reuses compiler cache when source is unchanged", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export function add(a: number, b: number) { return a + b; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const first = await runProcess(knot, ["build", "--no-bundle", "input.ts"], {
    cwd: workspace,
  });
  assert.equal(first.status, 0, first.stderr);

  const jsPath = path.join(workspace, "input.js");
  const before = await stat(jsPath);
  await delay(50);

  const second = await runProcess(knot, ["build", "--no-bundle", "input.ts"], {
    cwd: workspace,
  });
  assert.equal(second.status, 0, second.stderr);

  const after = await stat(jsPath);
  assert.equal(after.mtimeMs, before.mtimeMs);
});
