import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build emits stable CSS Module exports and renamed selectors", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "styles.module.css": ".button { color: red; }\n.title:hover { color: blue; }\n",
    "entry.ts": 'import styles from "./styles.module.css"; console.log(styles.button, styles.title);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.match(css, /\.styles_button/);
  assert.match(css, /\.styles_title/);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "styles_button styles_title\n");
});
