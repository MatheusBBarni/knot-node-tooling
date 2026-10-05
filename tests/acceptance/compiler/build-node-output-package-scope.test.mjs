import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile, readdir, symlink, unlink, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("Node .js output scope tracks absent, present, and changed package manifests", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "export const value = 42;\n",
    "dist/.keep": "",
  });
  t.after(() => removeWorkspace(workspace));
  const manifest = path.join(workspace, "dist/package.json");
  const output = path.join(workspace, "dist/entry.js");
  const args = ["build", "entry.ts", "--target", "node", "--format", "cjs", "--outfile", "dist/entry.js"];
  const show = async () => {
    const result = await runProcess(knot, [...args, "--show-config"], { cwd: workspace });
    assert.equal(result.status, 0, result.stderr);
    return JSON.parse(result.stdout);
  };

  const absent = await show();
  assert.equal(absent.config.configInputs.outputPackages[0].state, "absent");
  assert.equal(absent.config.configInputs.outputPackages[0].checked[0], "dist/package.json");
  assert.equal((await runProcess(knot, args, { cwd: workspace })).status, 0);
  assert.equal((await runProcess(process.execPath, ["-e", 'console.log(require("./dist/entry.js").value)'], { cwd: workspace })).stdout, "42\n");
  const old = await readFile(output, "utf8");

  await writeFile(manifest, '{"type":"commonjs"}');
  const commonjs = await show();
  assert.equal(commonjs.config.configInputs.outputPackages[0].type, "commonjs");
  assert.equal(commonjs.config.configInputs.outputPackages[0].state, "present");
  assert.equal(commonjs.config.configInputs.outputPackages[0].path, "dist/package.json");
  assert.equal(commonjs.config.configInputs.outputPackages[0].digest, createHash("sha256").update('{"type":"commonjs"}').digest("base64"));
  assert.notEqual(commonjs.configDigest, absent.configDigest);

  await writeFile(manifest, '{"type":"module"}');
  const mismatch = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(mismatch.status, 0);
  assert.match(mismatch.stderr, /output_module_type/);
  assert.equal(await readFile(output, "utf8"), old);

  await writeFile(manifest, '{"type":8}');
  const invalidType = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(invalidType.status, 0);
  assert.match(invalidType.stderr, /output_module_type/);
  assert.equal(await readFile(output, "utf8"), old);

  await unlink(manifest);
  assert.equal((await show()).configDigest, absent.configDigest);
  const esmArgs = ["build", "entry.ts", "--target", "node", "--format", "esm", "--outfile", "dist/entry.js"];
  const missingType = await runProcess(knot, esmArgs, { cwd: workspace });
  assert.notEqual(missingType.status, 0);
  assert.match(missingType.stderr, /output_module_type/);
  await writeFile(manifest, '{"type":"module"}');
  const supported = await runProcess(knot, esmArgs, { cwd: workspace });
  assert.equal(supported.status, 0, supported.stderr);
  assert.equal((await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log((await import("./dist/entry.js")).value)'], { cwd: workspace })).stdout, "42\n");
});

test("nearest output package scope wins and negative candidates are recorded", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "entry.ts": "export const value = 11;\n",
    "dist/.keep": "",
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--target", "node", "--format", "esm", "--outfile", "dist/entry.js"];
  const show = async () => {
    const result = await runProcess(knot, [...args, "--show-config"], { cwd: workspace });
    assert.equal(result.status, 0, result.stderr);
    return JSON.parse(result.stdout);
  };
  const inherited = await show();
  assert.equal(inherited.portable, true);
  assert.deepEqual(inherited.config.configInputs.outputPackages[0].checked, ["dist/package.json"]);
  assert.equal(inherited.config.configInputs.outputPackages[0].path, "package.json");
  assert.equal((await runProcess(knot, args, { cwd: workspace })).status, 0);
  const output = path.join(workspace, "dist/entry.js");
  const previous = await readFile(output, "utf8");
  const nested = path.join(workspace, "dist/package.json");
  await writeFile(nested, '{"type":"commonjs"}');
  const failed = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(failed.status, 0);
  assert.match(failed.stderr, /output_module_type/);
  assert.equal(await readFile(output, "utf8"), previous);
  await unlink(nested);
  assert.equal((await show()).configDigest, inherited.configDigest);
});

test("Node defaults use executable .mjs and .cjs paths without package scopes", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'export function load() { return import("./lazy.ts").then((module) => module.value); }\n',
    "lazy.ts": "export const value = 42;\n",
    "common.ts": "export const value = 7;\n",
    "module.mts": "export const value = 3;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const esm = await runProcess(knot, ["build", "entry.ts", "lazy.ts", "--target", "node", "--format", "esm", "--splitting", "--external", "./lazy.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(esm.status, 0, esm.stderr);
  const execution = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log(await (await import("./dist/entry.mjs")).load())'], { cwd: workspace });
  assert.equal(execution.status, 0, execution.stderr);
  assert.equal(execution.stdout, "42\n");
  const named = await runProcess(knot, ["build", "entry.ts", "lazy.ts", "--target", "node", "--format", "esm", "--splitting", "--external", "./lazy.ts", "--entry-names", "named/[name].[ext]", "--outdir", "named-dist"], { cwd: workspace });
  assert.equal(named.status, 0, named.stderr);
  const namedExecution = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log(await (await import("./named-dist/named/entry.mjs")).load())'], { cwd: workspace });
  assert.equal(namedExecution.status, 0, namedExecution.stderr);
  assert.equal(namedExecution.stdout, "42\n");
  const mts = await runProcess(knot, ["build", "module.mts", "--target", "node", "--format", "esm", "--entry-names", "[name].[ext]", "--outdir", "mts-dist"], { cwd: workspace });
  assert.equal(mts.status, 0, mts.stderr);
  assert.deepEqual(await readdir(path.join(workspace, "mts-dist")), ["module.mjs"]);
  const importedMts = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log((await import("./mts-dist/module.mjs")).value)'], { cwd: workspace });
  assert.equal(importedMts.status, 0, importedMts.stderr);
  assert.equal(importedMts.stdout, "3\n");
  const cjs = await runProcess(knot, ["build", "common.ts", "--target", "node", "--format", "cjs", "--outdir", "common-dist"], { cwd: workspace });
  assert.equal(cjs.status, 0, cjs.stderr);
  const required = await runProcess(process.execPath, ["-e", 'console.log(require("./common-dist/common.cjs").value)'], { cwd: workspace });
  assert.equal(required.status, 0, required.stderr);
  assert.equal(required.stdout, "7\n");
});

test("Node ESM rejects a shared .js chunk in a CommonJS output scope before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"commonjs"}',
    "shared.ts": "export const value = 40;\n",
    "one.ts": 'import { value } from "./shared.ts";\nexport const answer = value + 2;\n',
    "two.ts": 'import { value } from "./shared.ts";\nexport const answer = value + 3;\n',
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "one.ts", "two.ts", "--target", "node", "--format", "esm", "--splitting", "--outdir", "dist"];
  const initial = await runProcess(knot, args, { cwd: workspace });
  assert.equal(initial.status, 0, initial.stderr);
  const before = await readdir(path.join(workspace, "dist"));
  const runtime = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log((await import("./dist/one.mjs")).answer)'], { cwd: workspace });
  assert.equal(runtime.status, 0, runtime.stderr);
  assert.equal(runtime.stdout, "42\n");

  const invalid = await runProcess(knot, [...args, "--chunk-naming", "shared.js"], { cwd: workspace });
  assert.notEqual(invalid.status, 0);
  assert.match(invalid.stderr, /output_module_type/);
  assert.deepEqual(await readdir(path.join(workspace, "dist")), before);
  const nonWriting = await runProcess(knot, [...args, "--chunk-naming", "shared.js", "--write=false"], { cwd: workspace });
  assert.notEqual(nonWriting.status, 0);
  assert.match(nonWriting.stderr, /output_module_type/);
  assert.deepEqual(await readdir(path.join(workspace, "dist")), before);
});

test("Node .js output rejects a symlinked package scope manifest", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "export const value = 42;\n",
    "real-package.json": '{"type":"commonjs"}',
  });
  t.after(() => removeWorkspace(workspace));
  await symlink("real-package.json", path.join(workspace, "package.json"));
  const built = await runProcess(knot, ["build", "entry.ts", "--target", "node", "--format", "cjs", "--outfile", "entry.js"], { cwd: workspace });
  assert.notEqual(built.status, 0);
  assert.match(built.stderr, /output_module_type/);
  await assert.rejects(() => readFile(path.join(workspace, "entry.js")));
});
