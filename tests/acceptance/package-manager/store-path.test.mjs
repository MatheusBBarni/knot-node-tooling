import assert from "node:assert/strict";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("store path prints the content-addressed store directory", async (t) => {
  const home = await mkdtemp(path.join(tmpdir(), "knot-home-"));
  t.after(() => removeWorkspace(home));
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app" }),
  });
  t.after(() => removeWorkspace(workspace));

  const listed = await runProcess(knot, ["store", "path"], {
    cwd: workspace,
    env: { ...process.env, HOME: home },
  });
  assert.equal(listed.status, 0, listed.stderr);
  assert.equal(listed.stdout, path.join(home, ".knot", "cas") + "\n");
});
