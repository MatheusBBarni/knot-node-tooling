import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build resolves simple same-file CSS Module composition", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import styles from "./styles.module.css"; console.log(styles.button);\n',
    "styles.module.css": ".base { color: red; } .button { composes: base; color: blue; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "styles_button styles_base\n");
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.doesNotMatch(css, /composes:/);
  assert.match(css, /\.styles_base/);
  assert.match(css, /\.styles_button/);
});
test("build resolves cross-file CSS Module composition", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import styles from "./button.module.css"; console.log(styles.button);\n',
    "base.module.css": ".base { color: red; }\n",
    "button.module.css": '.button { composes: base from "./base.module.css"; color: blue; }\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "button_button base_base\n");
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.match(css, /\.base_base/);
  assert.match(css, /\.button_button/);
});

test("build rejects CSS Module composition cycles", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import styles from "./a.module.css"; console.log(styles.a);\n',
    "a.module.css": '.a { composes: b from "./b.module.css"; }\n',
    "b.module.css": '.b { composes: a from "./a.module.css"; }\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /css_module_cycle/);
});
