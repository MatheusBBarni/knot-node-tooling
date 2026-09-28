import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build emits an external CSS source map", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./style.css";\n',
    "style.css": "body { color: red; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--sourcemap", "external"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.match(css, /sourceMappingURL=entry\.css\.map/);
  const map = JSON.parse(await readFile(path.join(workspace, "dist/entry.css.map"), "utf8"));
  assert.equal(map.version, 3);
  assert.equal(map.file, "entry.css");
  assert.deepEqual(map.sources, ["style.css"]);
  assert.notEqual(map.mappings, "");
});

test("build embeds an inline CSS source map", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./style.css";\n',
    "style.css": "body { color: blue; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--sourcemap", "inline"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const css = await readFile(path.join(workspace, "dist/entry.css"), "utf8");
  assert.match(css, /sourceMappingURL=data:application\/json;base64,/);
  assert.equal(await access(path.join(workspace, "dist/entry.css.map")).then(() => true, () => false), false);
});

test("build composes mappings across CSS inputs", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./base.css";\nimport "./theme.css";\n',
    "base.css": "body {\n  margin: 0;\n}\n",
    "theme.css": ".theme {\n  color: blue;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--sourcemap", "external"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const map = JSON.parse(await readFile(path.join(workspace, "dist/entry.css.map"), "utf8"));
  assert.deepEqual(map.sources, ["base.css", "theme.css"]);
  assert.match(map.mappings, /;/);
});
