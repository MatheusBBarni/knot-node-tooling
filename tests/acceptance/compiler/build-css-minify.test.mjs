import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build minifies bundled CSS syntax and whitespace", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./style.css";\n',
    "style.css": "body { color: red; margin: 0  1px; }\n.card, .panel { padding: 2px; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--minify"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(await readFile(path.join(workspace, "dist/entry.css"), "utf8"), "body{color:red;margin:0 1px;}.card,.panel{padding:2px;} ".trimEnd());
});

test("build removes CSS comments and units from zero values", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./style.css";\n',
    "style.css": "/* generated */\nbody { margin: 0px; padding: 0em 0rem; width: 0%; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--minify"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.equal(css, "body{margin:0;padding:0 0;width:0;}");
});
