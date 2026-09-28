import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build copies a static asset and exposes its output name", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import logo from "./logo.png";\nconsole.log(logo);\n',
  });
  await writeFile(path.join(workspace, "logo.png"), Buffer.from([137, 80, 78, 71, 13, 10]));
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, "");
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "logo.png\n");
  assert.deepEqual([...await readFile(path.join(workspace, "dist/logo.png"))], [137, 80, 78, 71, 13, 10]);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.equal(manifest.outputs["logo.png"].kind, "asset");
  assert.equal(manifest.outputs["logo.png"].digest, "gjzrmfzvUlIzPt4bIgI0HDsoe21HVxlj5rDd85OiT4I=");
});
