import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("knot run executes a package script with the package engine", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      name: "run-fixture",
      type: "module",
      engines: { node: ">=24" },
      scripts: { hello: "node hello.js" },
    }),
    "hello.js": "console.log('hello from run');\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["run", "hello"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, "hello from run\n");
});

test("knot run reports a missing package script", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ scripts: {} }),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["run", "missing"], { cwd: workspace });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /missing_script/);
});

test("knot run rejects a script when package engine is unsatisfied", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      engines: { node: "99.0.0" },
      scripts: { hello: "node hello.js" },
    }),
    "hello.js": "console.log('should not run');\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["run", "hello"], { cwd: workspace });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /engine_unsatisfied/);
  assert.equal(result.stdout, "");
});

test("knot run forwards direct script arguments without a shell", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({
      scripts: { args: "node hello.js first second" },
    }),
    "hello.js": "console.log(process.argv.slice(2).join(','));\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["run", "args"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, "first,second\n");
});

test("knot run returns a failing script status", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ scripts: { fail: "node fail.js" } }),
    "fail.js": "process.exit(7);\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["run", "fail"], { cwd: workspace });
  assert.equal(result.status, 7);
});
