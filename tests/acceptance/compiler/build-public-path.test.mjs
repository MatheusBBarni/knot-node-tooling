import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build rewrites generated asset references with the public path", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import logo from "./logo.png"; import "./style.css"; console.log(logo);\n',
    "logo.png": "logo-bytes",
    "style.css": "body { background: url(./logo.png); }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outdir",
    "dist",
    "--asset-naming",
    "[name]-[hash:8].[ext]",
    "--public-path",
    "https://cdn.example.test/assets",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const assets = (await readdir(path.join(workspace, "dist"))).filter((file) => file.endsWith(".png"));
  assert.equal(assets.length, 1);
  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  assert.match(js, new RegExp(`https://cdn\\.example\\.test/assets/${assets[0]}`));
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.match(css, new RegExp(`https://cdn\\.example\\.test/assets/${assets[0]}`));
});
