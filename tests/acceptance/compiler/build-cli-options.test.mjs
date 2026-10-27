import assert from "node:assert/strict";
import { access, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

const exists = async (file) => {
  try {
    await access(file);
    return true;
  } catch {
    return false;
  }
};

test("build applies target, naming, define, drop, and write options", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "if (DEBUG) { console.log(\"removed\"); }\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outdir",
    "dist",
    "--target",
    "browser",
    "--entry-naming",
    "[name]-bundle.[ext]",
    "--define",
    "DEBUG=false",
    "--drop",
    "console.log",
  ], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const output = path.join(workspace, "dist/entry-bundle.js");
  const js = await readFile(output, "utf8");
  assert.match(js, /false/);
  assert.doesNotMatch(js, /console\s*\.\s*log/);

  const noWrite = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outdir",
    "discarded",
    "--write=false",
  ], { cwd: workspace });
  assert.equal(noWrite.status, 0, noWrite.stderr);
  assert.equal(await exists(path.join(workspace, "discarded")), false);
});

test("build rejects an invalid write mode before publication", async (t) => {
  const workspace = await makeWorkspace({ "entry.ts": "export const value = 1;\n" });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--write=perhaps"], { cwd: workspace });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /invalid_option/);
  assert.equal(await exists(path.join(workspace, "dist")), false);
});

test("build applies a custom text loader", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import value from "./data.foo";\nconsole.log(value);\n',
    "data.foo": "hello from loader\n",
  });
  t.after(() => removeWorkspace(workspace));

  const args = ["build", "entry.ts", "--outdir", "dist", "--loader", ".foo=text"];
  const result = await runProcess(knot, args, { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const run = await runProcess(process.execPath, [path.join(workspace, "dist/entry.js")], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "hello from loader\n\n");
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  await writeFile(path.join(workspace, "data.foo"), Buffer.from([255]));
  const invalid = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(invalid.status, 0);
  assert.match(invalid.stderr, /invalid_encoding/);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
});

test("build applies a custom JSON loader", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import value from "./data.foo";\nimport { plusOne } from "./helper.ts";\nconsole.log(plusOne(value.answer));\n',
    "helper.ts": "export function plusOne(value) { return value + 1; }\n",
    "data.foo": "{\"answer\":7}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--loader", ".foo=json"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const run = await runProcess(process.execPath, [path.join(workspace, "dist/entry.js")], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "8\n");
});

test("build preserves an external import without duplicating same-line code", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import value from "pkg"; console.log(value);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "dist.js", "--external", "pkg"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist.js"), "utf8");
  assert.equal((js.match(/console\s*\.\s*log/g) ?? []).length, 1);
  assert.match(js, /import value from "pkg"/);
});

test("build externalizes bare imports with packages external", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": 'import value from "pkg";\nconsole.log(value);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "dist.js", "--packages", "external"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist.js"), "utf8");
  assert.match(js, /import value from "pkg"/);
});

test("build rejects unsupported targets explicitly", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js", "--target", "legacy"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /unsupported target/);
});

test("build rejects an unknown loader and accepts a custom YAML loader", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "import data from \"./data.foo\";\nconsole.log(data.answer);\n",
    "data.foo": "answer: 9\n",
  });
  t.after(() => removeWorkspace(workspace));

  const loader = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js", "--loader", ".foo=wasm"], { cwd: workspace });
  assert.notEqual(loader.status, 0);
  assert.match(loader.stderr, /unsupported loader/);

  const yaml = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js", "--loader", ".foo=yaml"], { cwd: workspace });
  assert.equal(yaml.status, 0, yaml.stderr);
  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "9\n");
});
