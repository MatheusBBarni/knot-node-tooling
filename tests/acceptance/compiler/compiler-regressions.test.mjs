import assert from "node:assert/strict";
import { chmod, readFile, unlink, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

async function runNode(file, cwd) {
  return runProcess(process.execPath, [file], { cwd });
}

test("transpile rejects malformed source without emitting output", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "const = ;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /syntax_error/);
  await assert.rejects(() => readFile(path.join(workspace, "input.js")));
}
);

test("build follows single-quoted imports", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "dep.ts": "export const value = 7;\n",
    "main.ts": "import { value } from './dep.ts';\nconsole.log(value);\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);
  const run = await runNode("out.js", workspace);
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "7\n");
});

test("tree shaking preserves local functions used by exported values", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "dep.ts": "function helper() { return 9; }\nexport const value = helper();\n",
    "main.ts": 'import { value } from "./dep.ts";\nconsole.log(value);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);
  const run = await runNode("out.js", workspace);
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "9\n");
});

test("failed builds do not activate partial outputs", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": 'console.log("before");\nimport("./missing.ts");\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
  });
  assert.notEqual(result.status, 0);
  await assert.rejects(() => readFile(path.join(workspace, "out.js")));
  await assert.rejects(() => readFile(path.join(workspace, "out.js.map")));
});

test("cache reuse recreates a missing output", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export const x: number = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const first = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(first.status, 0, first.stderr);
  await unlink(path.join(workspace, "input.js"));
  const second = await runProcess(knot, ["transpile", "input.ts"], { cwd: workspace });
  assert.equal(second.status, 0, second.stderr);
  assert.match(await readFile(path.join(workspace, "input.js"), "utf8"), /export const x/);
});

test("compiler transforms do not invoke Node.js internally", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export const x: number = 1;\n",
    "fake-bin/node": "#!/bin/sh\ntouch \"$KNOT_NODE_MARKER\"\nexit 127\n",
  });
  t.after(() => removeWorkspace(workspace));

  const marker = path.join(workspace, "node-invoked");
  await chmod(path.join(workspace, "fake-bin/node"), 0o755);
  const result = await runProcess(knot, ["transpile", "input.ts"], {
    cwd: workspace,
    env: {
      ...process.env,
      PATH: `${path.join(workspace, "fake-bin")}:/usr/bin:/bin`,
      KNOT_NODE_MARKER: marker,
    },
  });
  assert.equal(result.status, 0, result.stderr);
  await assert.rejects(() => readFile(marker));
});

 test("JSX options are passed as data, not shell source", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.tsx": "export const x = <div />;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const marker = path.join(workspace, "injected");
  const payload = `React.createElement'; touch '${marker}'; printf '`;
  const result = await runProcess(knot, ["transpile", "--jsx-factory", payload, "input.tsx"], {
    cwd: workspace,
  });
  assert.equal(result.status, 0, result.stderr);
  await assert.rejects(() => readFile(marker));
});
