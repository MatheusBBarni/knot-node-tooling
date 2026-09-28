import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build uses content-hashed names for imported assets", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "logo.png": "logo-bytes",
    "entry.ts": 'import logo from "./logo.png"; console.log(logo);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--asset-naming", "[name]-[hash:8].[ext]"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const files = (await readdir(path.join(workspace, "dist"))).filter((file) => file.endsWith(".png"));
  assert.equal(files.length, 1);
  assert.equal(files[0], "logo-bKbitYjm.png");
  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  assert.match(js, new RegExp(files[0].replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
});
