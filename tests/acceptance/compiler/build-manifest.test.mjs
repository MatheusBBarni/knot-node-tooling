import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build writes a stable artifact manifest", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import "./style.css";\nconsole.log(42);\n',
    "style.css": "body { color: red; }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outfile",
    "out.js",
    "--manifest",
    "manifest.json",
    "--sourcemap",
    "external",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.equal(manifest.version, 1);
  assert.equal(manifest.entries["entry.ts"], "out.js");
  assert.equal(manifest.outputs["out.js"].kind, "js");
  assert.equal(manifest.outputs["out.js"].entry.endsWith("entry.ts"), true);
  assert.equal(manifest.outputs["out.js"].bytes > 0, true);
  assert.match(manifest.outputs["out.js"].digest, /^[A-Za-z0-9+/]+=*$/);
  assert.equal(manifest.outputs["out.js"].sourceMap, "out.js.map");
  assert.equal(manifest.outputs["out.css"].kind, "css");
  assert.equal(manifest.outputs["out.css"].bytes > 0, true);
  assert.match(manifest.outputs["out.css"].digest, /^[A-Za-z0-9+/]+=*$/);
  assert.equal(manifest.outputs["out.css"].sourceMap, "out.css.map");
});
