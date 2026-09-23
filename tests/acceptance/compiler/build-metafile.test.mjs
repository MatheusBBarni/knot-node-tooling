import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build writes a metafile with inputs and outputs", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": "export function used() { return 1; }\n",
    "main.ts": 'import { used } from "./lib.ts";\nconsole.log(used());\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const raw = await readFile(path.join(workspace, "meta.json"), "utf8");
  const meta = JSON.parse(raw);
  assert.ok(meta.inputs || meta.modules);
  const inputs = meta.inputs || meta.modules;
  const inputKeys = Object.keys(inputs);
  assert.ok(inputKeys.some((k) => k.includes("main.ts") || k.endsWith("main.ts")));
  assert.ok(meta.outputs);
  const outKeys = Object.keys(meta.outputs);
  assert.ok(outKeys.some((k) => k.includes("out.js") || k.endsWith("out.js")));
  const out = meta.outputs[outKeys.find((k) => k.includes("out.js"))];
  assert.ok(typeof out.bytes === "number" || typeof out.size === "number");
});
