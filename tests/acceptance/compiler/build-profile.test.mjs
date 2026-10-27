import assert from "node:assert/strict";
import { createHash } from "node:crypto";
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
  assert.deepEqual((await readdir(path.join(workspace, "production"))).filter((name) => !["active.json", "previous.json", "generations", "leases", "gc.lock"].includes(name)), ["entry.cjs"]);
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

test("profile sourcemap and packages apply unless the CLI overrides them", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "import { missing } from \"left-pad\";\nexport const value = missing;\n",
    "knot.toml": "[build.production]\ntarget = \"browser\"\nformat = \"esm\"\noutdir = \"dist\"\nsourcemap = \"external\"\npackages = \"external\"\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--profile", "production"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  assert.match(js, /from "left-pad"/);
  assert.equal(JSON.parse(await readFile(path.join(workspace, "dist/entry.js.map"), "utf8")).version, 3);
  const overridden = await runProcess(knot, ["build", "entry.ts", "--profile", "production", "--packages", "bundle", "--sourcemap", "none", "--show-config"], { cwd: workspace });
  assert.equal(overridden.status, 0, overridden.stderr);
  const shown = JSON.parse(overridden.stdout);
  assert.equal(shown.config.packages, "bundle");
  assert.equal(shown.config.sourceMap, "none");
});

test("a nested profile library table supplies packageJson", async (t) => {
  const source = JSON.stringify({
    name: "lib",
    type: "module",
    exports: { ".": { import: "./dist/entry.mjs" } },
  });
  const workspace = await makeWorkspace({
    "package.json": source,
    "entry.ts": "export const value = 1;\n",
    "knot.toml": [
      "[build.production]",
      'target = "node"',
      'format = "esm"',
      'packages = "external"',
      'outdir = "dist"',
      "[build.production.library]",
      'packageJson = "package.json"',
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const shown = await runProcess(knot, ["build", "entry.ts", "--profile", "production", "--show-config"], { cwd: workspace });
  assert.equal(shown.status, 0, shown.stderr);
  const record = JSON.parse(shown.stdout);
  assert.equal(record.config.library.packageJson, "package.json");
  assert.equal(record.config.configInputs.libraryManifest, createHash("sha256").update(source).digest("base64"));

  const built = await runProcess(knot, ["build", "entry.ts", "--profile", "production"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  assert.notEqual(await readFile(path.join(workspace, "dist/entry.mjs"), "utf8"), "");
});

test("the CLI library export overrides the nested profile table", async (t) => {
  const source = JSON.stringify({
    name: "lib",
    type: "module",
    exports: { ".": { import: "./dist/entry.mjs" } },
  });
  const workspace = await makeWorkspace({
    "package.json": source,
    "missing.json": "{\"type\":\"module\",\"exports\":{\".\":{\"import\":\"./dist/missing.mjs\"}}}",
    "entry.ts": "export const value = 1;\n",
    "knot.toml": [
      "[build.production]",
      'target = "node"',
      'format = "esm"',
      'packages = "external"',
      'outdir = "dist"',
      "[build.production.library]",
      'packageJson = "missing.json"',
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const built = await runProcess(
    knot,
    ["build", "entry.ts", "--profile", "production", "--library-exports", "package.json"],
    { cwd: workspace },
  );
  assert.equal(built.status, 0, built.stderr);
  assert.notEqual(await readFile(path.join(workspace, "dist/entry.mjs"), "utf8"), "");
});

test("a profile enables splitting without a CLI flag", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lazy.ts": "export const value = 5;\n",
    "entry.ts": "const module = await import(\"./lazy.ts\");\nconsole.log(module.value);\n",
    "knot.toml": "[build.release]\nsplitting = true\noutdir = \"dist\"\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--profile", "release"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const js = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  const matched = js.match(/import\s*\(\s*["'](\.\/[^"']+)["']/);
  assert.ok(matched, js);
  assert.doesNotMatch(js, /export const value = 5/);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "5\n");
  const shown = await runProcess(knot, ["build", "entry.ts", "--profile", "release", "--show-config"], { cwd: workspace });
  assert.equal(JSON.parse(shown.stdout).config.splitting, true);
});
