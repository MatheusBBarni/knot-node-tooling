import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build prefixes dynamic chunk imports with the public path", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lazy.ts": "export function val() { return 7; }\n",
    "main.ts": "const m = await import(\"./lazy.ts\"); console.log(m.val());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outdir", "dist", "--public-path", "/static", "--splitting"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist/main.js"), "utf8");
  assert.match(js, /import\s*\(\s*["']\/static\/[A-Za-z0-9_-]{8}\.js["']\s*\)/);
});
