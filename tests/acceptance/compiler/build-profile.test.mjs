import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("selected declarative profile builds with CLI precedence", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "export const value = 42;\n",
    "knot.toml": '[build.default]\ntarget = "browser"\n\n[build.production]\ntarget = "node"\nformat = "cjs"\noutdir = "production"\n',
  });
  t.after(() => removeWorkspace(workspace));

  const profile = await runProcess(knot, ["build", "entry.ts", "--profile", "production"], { cwd: workspace });
  assert.equal(profile.status, 0, profile.stderr);
  assert.deepEqual(await readdir(path.join(workspace, "production")), ["entry.cjs"]);
  const executed = await runProcess(process.execPath, ["-e", 'console.log(require("./production/entry.cjs").value)'], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "42\n");

  const override = await runProcess(knot, ["build", "entry.ts", "--profile", "production", "--target", "browser", "--format", "esm", "--outdir", "browser"], { cwd: workspace });
  assert.equal(override.status, 0, override.stderr);
  assert.match(await readFile(path.join(workspace, "browser/entry.js"), "utf8"), /value/);
});

test("conflicting profile flags fail before writing either output", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "export const value = 42;\n",
    "knot.toml": '[build.production]\noutdir = "production"\n[build.staging]\noutdir = "staging"\n',
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "entry.ts", "--profile", "production", "--profile", "staging"], { cwd: workspace });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /duplicate_option/);
  await assert.rejects(() => readdir(path.join(workspace, "production")));
  await assert.rejects(() => readdir(path.join(workspace, "staging")));
});

test("a TOML profile accepts comments after a table and assigned value", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "export const value = 42;\n",
    "knot.toml": '[build.production] # release = node\ntarget = "node" # runtime = node\nformat = "cjs"\noutdir = "dist"\n',
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "entry.ts", "--profile", "production"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const executed = await runProcess(process.execPath, ["-e", 'console.log(require("./dist/entry.cjs").value)'], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "42\n");
});

test("selected profile enables JavaScript minification without a CLI flag", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "const value = 1 + 2; console.log(value);\n",
    "knot.toml": "[build.compact]\nminify = true\noutdir = \"dist\"\n",
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "entry.ts", "--profile", "compact"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  assert.match(js, /console\.log\(value\)/);
  assert.doesNotMatch(js, /const value = 1 \+ 2/);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "3\n");
});

test("profile minify is typed and an explicit CLI flag takes precedence", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "const value = 1 + 2; console.log(value);\n",
    "knot.toml": "[build.compact]\nminify = false\noutdir = \"dist\"\n",
  });
  t.after(() => removeWorkspace(workspace));
  const unminified = await runProcess(knot, ["build", "entry.ts", "--profile", "compact"], { cwd: workspace });
  assert.equal(unminified.status, 0, unminified.stderr);
  assert.match(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), /const value = 1 \+ 2/);
  const overridden = await runProcess(knot, ["build", "entry.ts", "--profile", "compact", "--minify"], { cwd: workspace });
  assert.equal(overridden.status, 0, overridden.stderr);
  assert.doesNotMatch(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), /const value = 1 \+ 2/);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "3\n");
});

test("profile rejects a string in place of a TOML boolean before publication", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "console.log(3);\n",
    "knot.toml": "[build.compact]\nminify = \"true\"\noutdir = \"dist\"\n",
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "entry.ts", "--profile", "compact"], { cwd: workspace });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /invalid_option/);
  await assert.rejects(() => readdir(path.join(workspace, "dist")));
});

test("equivalent profile and CLI minification share a semantic digest", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": "console.log(3);\n",
    "knot.toml": "[build.compact]\nminify = true\n",
  });
  t.after(() => removeWorkspace(workspace));
  const profile = await runProcess(knot, ["build", "entry.ts", "--profile", "compact", "--show-config"], { cwd: workspace });
  const cli = await runProcess(knot, ["build", "entry.ts", "--minify", "--show-config"], { cwd: workspace });
  assert.equal(profile.status, 0, profile.stderr);
  assert.equal(cli.status, 0, cli.stderr);
  assert.equal(JSON.parse(profile.stdout).configDigest, JSON.parse(cli.stdout).configDigest);
});
