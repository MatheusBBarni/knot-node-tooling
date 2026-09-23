import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build selects package export conditions (import default and --conditions require)", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "node_modules/foo/package.json": JSON.stringify({
      name: "foo",
      type: "module",
      exports: {
        ".": {
          import: "./esm.js",
          require: "./cjs.js",
          default: "./esm.js",
        },
      },
    }),
    "node_modules/foo/esm.js": 'export function hello() { return "esm"; }\n',
    "node_modules/foo/cjs.js": 'export function hello() { return "cjs"; }\n',
    "main.ts": 'import { hello } from "foo";\nconsole.log(hello());\n',
  });
  t.after(() => removeWorkspace(workspace));

  const def = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(def.status, 0, def.stderr);
  const runDef = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(runDef.status, 0, runDef.stderr);
  assert.equal(runDef.stdout, "esm\n");

  const req = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out-req.js", "--conditions", "require"],
    { cwd: workspace },
  );
  assert.equal(req.status, 0, req.stderr);
  const runReq = await runProcess(process.execPath, ["out-req.js"], { cwd: workspace });
  assert.equal(runReq.status, 0, runReq.stderr);
  assert.equal(runReq.stdout, "cjs\n");
});
