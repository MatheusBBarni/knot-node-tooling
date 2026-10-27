import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("structured data diagnostics include a source range and honor data limits", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "import data from \"./data.json\";\nconsole.log(data.answer);\n",
    "data.json": "{\"answer\":",
  });
  t.after(() => removeWorkspace(workspace));

  const malformed = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.notEqual(malformed.status, 0);
  assert.match(malformed.stderr, /data\.json:1:\d+:/);
  assert.match(malformed.stderr, /syntax_error/);

  const limited = await runProcess(knot, [
    "build",
    "entry.ts",
    "--outfile",
    "out.js",
    "--data-depth",
    "1",
    "--show-config",
  ], { cwd: workspace });
  assert.equal(limited.status, 0, limited.stderr);
  const shown = JSON.parse(limited.stdout);
  assert.equal(shown.config.limits.dataDepth, 1);
  assert.equal(shown.config.limits.dataNodes, 1000000);
  const baseline = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js", "--show-config"], { cwd: workspace });
  assert.equal(baseline.status, 0, baseline.stderr);
  assert.equal(JSON.parse(baseline.stdout).configDigest, shown.configDigest);

  await writeNested(workspace);
  const rejected = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js", "--data-depth", "1"], { cwd: workspace });
  assert.notEqual(rejected.status, 0);
  assert.match(rejected.stderr, /resource_limit/);
  assert.match(rejected.stderr, /data\.json:1:\d+:/);
});

async function writeNested(workspace) {
  const { writeFile } = await import("node:fs/promises");
  await writeFile(path.join(workspace, "data.json"), "{\"answer\":{\"nested\":1}}\n");
}

test("show-config records previously rejected controls without changing the semantic digest", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 1;\n",
    "style.css": "body { color: red; }\n",
  });
  t.after(() => removeWorkspace(workspace));
  const base = await runProcess(knot, ["build", "entry.ts", "--show-config"], { cwd: workspace });
  assert.equal(base.status, 0, base.stderr);
  const baseRecord = JSON.parse(base.stdout);
  const flagged = await runProcess(knot, [
    "build",
    "entry.ts",
    "--show-config",
    "--css-naming",
    "styled-[name].css",
    "--root",
    "src",
    "--min-chunk-size",
    "32",
    "--sources-content",
    "include",
    "--log-level",
    "silent",
    "--diagnostics",
    "json",
    "--clear-on-error",
    "--gpu",
    "--tsconfig",
    "tsconfig.json",
  ], { cwd: workspace });
  assert.equal(flagged.status, 0, flagged.stderr);
  const record = JSON.parse(flagged.stdout);
  assert.equal(record.config.naming.css, "styled-[name].css");
  assert.equal(record.config.chunkMergeOverhead.minChunkBytes, 32);
  assert.equal(record.config.sourcesContent, "include");
  assert.equal(record.config.logLevel, "silent");
  assert.equal(record.config.diagnostics, "json");
  assert.equal(record.config.clearOnError, true);
  assert.equal(record.config.requestedBackend, "gpu");
  assert.equal(record.configDigest === baseRecord.configDigest, false);
  assert.equal(JSON.parse((await runProcess(knot, ["build", "entry.ts", "--show-config", "--gpu"], { cwd: workspace })).stdout).configDigest, baseRecord.configDigest);
});

test("css naming, root-relative directories, and included source content are emitted", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "nested/entry.ts": "import \"./style.css\";\nexport const value = 7;\n",
    "nested/style.css": "body { color: red; }\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, [
    "build",
    "nested/entry.ts",
    "--outdir",
    "dist",
    "--entry-names",
    "[dir][name]",
    "--css-naming",
    "styled-[name].css",
    "--sourcemap",
    "external",
    "--sources-content",
    "include",
  ], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const js = await readFile(path.join(workspace, "dist/nested/entry.js"), "utf8");
  assert.match(js, /value/);
  const css = await readFile(path.join(workspace, "dist/nested/styled-entry.css"), "utf8");
  assert.match(css, /color:\s*red/);
  const map = JSON.parse(await readFile(path.join(workspace, "dist/nested/entry.js.map"), "utf8"));
  assert.equal(map.version, 3);
  assert.ok(Array.isArray(map.sourcesContent));
  assert.match(map.sourcesContent.join("\n"), /export const value/);
  assert.ok(map.names.includes("value"));
});

test("identical entry output paths fail before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "a/entry.ts": "export const value = 1;\n",
    "b/entry.ts": "export const value = 2;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "a/entry.ts", "b/entry.ts", "--outdir", "dist", "--entry-names", "[name]"], { cwd: workspace });
  assert.notEqual(built.status, 0);
  assert.match(built.stderr, /output_collision/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/entry.js"), "utf8"));
});
