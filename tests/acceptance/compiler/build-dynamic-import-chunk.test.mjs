import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build emits a separate chunk for a dynamic import", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lazy.ts": "export function val() { return 7; }\n",
    "main.ts": "const m = await import(\"./lazy.ts\");\nconsole.log(m.val());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outdir", "dist", "--splitting"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "dist/main.js"), "utf8");
  const m = js.match(/import\s*\(\s*["'](\.\/[^"']+)["']/);
  assert.ok(m, js);
  assert.doesNotMatch(js, /function val/);

  const chunk = await readFile(path.join(workspace, "dist", m[1].slice(2)), "utf8");
  assert.match(chunk, /function val/);
  const run = await runProcess(process.execPath, ["dist/main.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "7\n");
});

test("a dependency dynamic import becomes its own chunk", async (t) => {
  const lib = 'export function load() { return import("./lazy.ts"); }\n';
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "import { load } from \"./lib.ts\";\nconst m = await load();\nconsole.log(m.value);\n",
    "lib.ts": lib,
    "lazy.ts": "export const value = 9;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--splitting", "--manifest", "manifest.json"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  const matched = js.match(/import\s*\(\s*["'](\.\/[^"']+)["']/);
  assert.ok(matched, js);
  assert.doesNotMatch(js, /export const value = 9/);

  const chunk = await readFile(path.join(workspace, "dist", matched[1].slice(2)), "utf8");
  assert.match(chunk, /value/);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "9\n");

  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  const edge = manifest.outputs[manifest.entries["entry.ts"]].dynamicImports.find((item) => item.source === "./lazy.ts");
  assert.equal(edge.importer, "lib.ts");
  const start = lib.indexOf('"./lazy.ts"');
  assert.deepEqual(edge.range, [start, start + '"./lazy.ts"'.length]);
});
