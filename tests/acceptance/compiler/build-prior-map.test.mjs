import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build composes a prior loader source map into the bundle map", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": "export const value = 1;\n",
    "lib.ts.map": JSON.stringify({
      version: 3,
      file: "lib.ts",
      sources: ["lib.original.ts"],
      names: ["originalName", "secondName"],
      mappings: "",
    }),
    "main.ts": 'import { value } from "./lib.ts";\nconsole.log(value);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--sourcemap", "external"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const map = JSON.parse(await readFile(path.join(workspace, "out.js.map"), "utf8"));
  assert.ok(map.sources.includes("lib.original.ts"));
  assert.equal(map.sources.some((source) => source.endsWith("/lib.ts") || source === "lib.ts"), false);
  assert.ok(map.names.includes("originalName"));
  assert.ok(map.names.includes("secondName"));
});
