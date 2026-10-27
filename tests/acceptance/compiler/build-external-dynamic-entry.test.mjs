import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("path-like external dynamic import links to an independently emitted entry", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "main.ts": 'export function load() { return import("./lazy.ts").then((module) => module.value); }\n',
    "lazy.ts": 'globalThis.lazyLoaded = true; export const value = 42;\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "lazy.ts", "--external", "./lazy.ts", "--outdir", "dist", "--splitting", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  const [edge] = manifest.outputs[manifest.entries["main.ts"]].dynamicImports;
  assert.equal(edge.targetKind, "external-entry");
  assert.equal(edge.lazy, true);
  assert.equal(manifest.entries[edge.resolved], edge.output);
  assert.equal(edge.output, manifest.entries["lazy.ts"]);
  assert.equal((await readdir(path.join(workspace, "dist"))).filter((file) => file.endsWith(".js")).length, 2);
  assert.match(await readFile(path.join(workspace, "dist/main.js"), "utf8"), /\bimport\s*\(\s*["']\.\/lazy\.js["']\s*\)/);

  const run = await runProcess(process.execPath, ["--input-type=module", "-e", 'const m = await import("./dist/main.js"); if (globalThis.lazyLoaded) throw Error("eager import"); console.log(await m.load(), globalThis.lazyLoaded);'], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "42 true\n");

  const prior = await readFile(path.join(workspace, "dist/main.js"), "utf8");
  const unlisted = await runProcess(knot, ["build", "main.ts", "--external", "./lazy.ts", "--outdir", "dist", "--splitting"], { cwd: workspace });
  assert.notEqual(unlisted.status, 0);
  assert.match(unlisted.stderr, /external_format/);
  assert.equal(await readFile(path.join(workspace, "dist/main.js"), "utf8"), prior);
});

test("JavaScript entry identities do not append another .js extension", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "main.js": 'export function load() { return import("./lazy.js").then((module) => module.value); }\n',
    "lazy.js": "export const value = 9;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "main.js", "lazy.js", "--external", "./lazy.js", "--outdir", "dist", "--splitting", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.equal(manifest.entries["main.js"], "dist/main.js");
  assert.equal(manifest.outputs[manifest.entries["main.js"]].dynamicImports[0].output, manifest.entries["lazy.js"]);
  const run = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log(await (await import("./dist/main.js")).load())'], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "9\n");
});

test("dynamic external paths follow explicitly named emitted entries", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "main.ts": 'export function load() { return import("./lazy.ts").then((module) => module.value); }\n',
    "lazy.ts": "export const value = 12;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "main.ts", "lazy.ts", "--external", "./lazy.ts", "--splitting", "--entry-names", "named/[name].js", "--outdir", "dist", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.equal(manifest.entries["lazy.ts"], "dist/named/lazy.js");
  assert.equal(manifest.outputs[manifest.entries["main.ts"]].dynamicImports[0].output, manifest.entries["lazy.ts"]);
  const run = await runProcess(process.execPath, ["--input-type=module", "-e", 'console.log(await (await import("./dist/named/main.js")).load())'], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "12\n");
});

test("a dynamic import edge records the specifier source range", async (t) => {
  const source = 'export function load() { return import("./lazy.ts"); }\n';
  const workspace = await makeWorkspace({
    "package.json": '{"type":"module"}',
    "main.ts": source,
    "lazy.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "lazy.ts", "--external", "./lazy.ts", "--outdir", "dist", "--splitting", "--manifest", "manifest.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  const edge = manifest.outputs[manifest.entries["main.ts"]].dynamicImports[0];
  const start = source.indexOf('"./lazy.ts"');
  assert.deepEqual(edge.range, [start, start + '"./lazy.ts"'.length]);
});
