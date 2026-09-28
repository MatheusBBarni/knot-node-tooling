import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("manifest lists dynamic chunk outputs", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import("./lazy.ts").then((module) => console.log(module.value));\n',
    "lazy.ts": "export const value = 42;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outdir",
    "dist",
    "--manifest",
    "manifest.json",
    "--splitting",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  const dynamic = Object.entries(manifest.outputs).filter(([, output]) => output.kind === "dynamic");
  assert.equal(dynamic.length, 1);
  assert.equal(dynamic[0][1].bytes > 0, true);
});
