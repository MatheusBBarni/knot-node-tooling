import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build names a dynamic-import chunk from a content digest", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lazy.ts": "export function val() { return 7; }\n",
    "main.ts": "const m = await import(\"./lazy.ts\");\nconsole.log(m.val());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "out.js"), "utf8");
  const m = js.match(/import\s*\(\s*["'](\.\/[^"']+)["']/);
  assert.ok(m, js);
  assert.doesNotMatch(m[1], /lazy/);
  assert.match(m[1], /^\.\/[A-Za-z0-9]{8}\.js$/);

  const chunk = await readFile(path.join(workspace, m[1].slice(2)), "utf8");
  assert.match(chunk, /function val/);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "7\n");
});
