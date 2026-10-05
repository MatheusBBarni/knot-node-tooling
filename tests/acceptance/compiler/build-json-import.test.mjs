import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build loads JSON modules as default values", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "data.json": JSON.stringify({ answer: 42 }),
    "entry.ts": [
      'import data from "./data.json";',
      "console.log(data.answer);",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "entry.ts", "--outfile", "out.js"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const run = await runProcess(process.execPath, ["out.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "42\n");
});

test("malformed JSON cannot inject JavaScript or replace the last valid build", async (t) => {
  const workspace = await makeWorkspace({
    "data.json": '{"answer":42}',
    "entry.ts": 'import data from "./data.json";\nexport const answer = data.answer;\n',
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--outdir", "dist"];
  const first = await runProcess(knot, args, { cwd: workspace });
  assert.equal(first.status, 0, first.stderr);
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  await writeFile(path.join(workspace, "data.json"), '{"answer":42};globalThis.injected=true', "utf8");
  const rejected = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(rejected.status, 0);
  assert.match(rejected.stderr, /syntax_error/);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
});

test("JSON duplicate decoded keys and unsafe numbers fail before publication", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./data.json";\nconsole.log(data.answer);\n',
    "data.json": '{"answer":42}',
  });
  t.after(() => removeWorkspace(workspace));
  for (const [value, code] of [
    ['{"answer":42,"ans\\u0077er":43}', "duplicate_key"],
    ['{"answer":9007199254740992}', "data_number"],
    ['{"answer":1e999}', "data_number"],
    ['{"answer":"\\ud800"}', "syntax_error"],
  ]) {
    await writeFile(path.join(workspace, "data.json"), value, "utf8");
    const failed = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
    assert.notEqual(failed.status, 0, `${value}: ${failed.stderr}`);
    assert.match(failed.stderr, new RegExp(code));
    await assert.rejects(() => readFile(path.join(workspace, "dist/entry.js")));
  }
});

test("JSON __proto__ stays an own data property in generated JavaScript", async (t) => {
  const workspace = await makeWorkspace({
    "data.json": '{"__proto__":{"answer":42},"ordinary":true}',
    "entry.ts": 'import data from "./data.json";\nconsole.log(Object.hasOwn(data, "__proto__"), data.__proto__.answer, Object.getPrototypeOf(data) === Object.prototype);\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "true 42 true\n");
});

test("JSON keys containing escaped NUL remain distinct from empty keys", async (t) => {
  const workspace = await makeWorkspace({
    "data.json": '{"":1,"\\u0000":2}',
    "entry.ts": 'import data from "./data.json";\nconsole.log(data[""], data["\\0"]);\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "1 2\n");
});

test("an explicit text loader overrides the default .json loader", async (t) => {
  const workspace = await makeWorkspace({
    "data.json": "plain text\n",
    "entry.ts": 'import text from "./data.json";\nconsole.log(text.trim());\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist", "--loader", ".json=text"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "plain text\n");
});

test("JSON accepts valid Unicode but rejects malformed UTF-8 without replacing output", async (t) => {
  const workspace = await makeWorkspace({
    "data.json": '{"a":"café 🌍"}',
    "entry.ts": 'import data from "./data.json";\nconsole.log(data.a);\n',
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--outdir", "dist"];
  const initial = await runProcess(knot, args, { cwd: workspace });
  assert.equal(initial.status, 0, initial.stderr);
  const run = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "café 🌍\n");
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  await writeFile(path.join(workspace, "data.json"), Buffer.from([123, 34, 97, 34, 58, 34, 255, 34, 125]));
  const rejected = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(rejected.status, 0);
  assert.match(rejected.stderr, /invalid_encoding/);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
});
