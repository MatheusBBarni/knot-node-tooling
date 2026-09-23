import assert from "node:assert/strict";
import test from "node:test";
import { ExampleFixture } from "./examples-support.mjs";

test("examples/basic: strips types and prints hello knot", async (t) => {
  const workspace = await ExampleFixture.stage("basic");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "greet.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "greet.ts");
  assert.doesNotMatch(js, /\binterface\b/);
  assert.doesNotMatch(js, /\btype\s+Greeting\b/);
  assert.doesNotMatch(js, /:\s*string/);
  assert.doesNotMatch(js, /:\s*Person/);
  assert.doesNotMatch(js, /:\s*Greeting/);

  const run = await ExampleFixture.runNode(workspace, "greet.js");
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "hello knot\n");
});

test("examples/enum: lowers enum and prints members", async (t) => {
  const workspace = await ExampleFixture.stage("enum");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "color.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "color.ts");
  assert.doesNotMatch(js, /\benum\b/);

  const run = await ExampleFixture.runNode(workspace, "color.js");
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "1 2\n");
});

test("examples/namespace: lowers namespace and prints answer", async (t) => {
  const workspace = await ExampleFixture.stage("namespace");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "math-util.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "math-util.ts");
  assert.doesNotMatch(js, /\bnamespace\b/);

  const run = await ExampleFixture.runNode(workspace, "math-util.js");
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "42\n");
});

test("examples/param-props: assigns this.x/this.y and prints point", async (t) => {
  const workspace = await ExampleFixture.stage("param-props");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "point.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "point.ts");
  assert.match(js, /this\s*\.\s*x\s*=\s*x/);
  assert.match(js, /this\s*\.\s*y\s*=\s*y/);
  assert.doesNotMatch(js, /\bpublic\b/);

  const run = await ExampleFixture.runNode(workspace, "point.js");
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "3,4\n");
});

test("examples/satisfies: erases satisfies and prints port", async (t) => {
  const workspace = await ExampleFixture.stage("satisfies");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "config.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "config.ts");
  assert.doesNotMatch(js, /\bsatisfies\b/);

  const run = await ExampleFixture.runNode(workspace, "config.js");
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "3000\n");
});

test("examples/jsx-classic: emits React.createElement shape", async (t) => {
  const workspace = await ExampleFixture.stage("jsx-classic");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "app.tsx");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "app.tsx");
  assert.doesNotMatch(js, /:\s*string/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']div["']/);
  assert.match(js, /\bid\s*:\s*["']root["']/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']span["']/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']br["']/);
  assert.match(js, /React\s*\.\s*Fragment/);
  assert.match(js, /["']hi["']/);
  assert.doesNotMatch(js, /<\s*div/);
});

test("examples/jsx-automatic: jsx-runtime import and children", async (t) => {
  const workspace = await ExampleFixture.stage("jsx-automatic");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "app.tsx", [
    "--jsx-runtime",
    "automatic",
  ]);
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "app.tsx");
  assert.match(js, /from\s+["']react\/jsx-runtime["']/);
  assert.match(js, /\bjsx(s)?\s*\(/);
  assert.match(js, /children\s*:\s*label/);
  assert.doesNotMatch(js, /React\.createElement/);
  assert.doesNotMatch(js, /<\s*div/);
});

test("examples/jsx-preserve: keeps JSX tags, strips types", async (t) => {
  const workspace = await ExampleFixture.stage("jsx-preserve");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "app.tsx", [
    "--jsx-runtime",
    "preserve",
  ]);
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "app.tsx");
  assert.match(js, /<\s*div/);
  assert.match(js, /className/);
  assert.doesNotMatch(js, /:\s*string/);
  assert.doesNotMatch(js, /React\.createElement/);
  assert.doesNotMatch(js, /from\s+["']react\/jsx-runtime["']/);
});

test("examples/analyze-graph: JSON entries/modules/imports", async (t) => {
  const workspace = await ExampleFixture.stage("analyze-graph");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.analyze(workspace, "main.ts");
  assert.equal(result.status, 0, result.stderr);

  const payload = JSON.parse(result.stdout);
  assert.deepEqual(payload.entries, ["main.ts"]);
  assert.ok(Array.isArray(payload.modules));
  assert.ok(payload.modules.length >= 2);

  const byFile = Object.fromEntries(payload.modules.map((m) => [m.file, m]));
  assert.ok(byFile["main.ts"]);
  assert.deepEqual(byFile["main.ts"].imports, ["./util.ts"]);
  assert.ok(byFile["main.ts"].exports.includes("total"));
  assert.ok(byFile["util.ts"]);
  assert.deepEqual(byFile["util.ts"].exports, ["add"]);
});

test("examples/sourcemap: linked map with real mappings", async (t) => {
  const workspace = await ExampleFixture.stage("sourcemap");
  t.after(() => ExampleFixture.remove(workspace));

  const result = await ExampleFixture.transpile(workspace, "tiny.ts");
  assert.equal(result.status, 0, result.stderr);

  const js = await ExampleFixture.readJs(workspace, "tiny.ts");
  assert.match(js, /sourceMappingURL=tiny\.js\.map/);
  assert.doesNotMatch(js, /:\s*number/);

  const map = JSON.parse(await ExampleFixture.readMap(workspace, "tiny.ts"));
  assert.equal(map.version, 3);
  assert.equal(map.sources.length, 1);
  assert.notEqual(map.mappings, "AAAA");
  assert.ok(map.mappings.length > 4);
});
