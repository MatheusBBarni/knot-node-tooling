import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("JSONC comments and trailing commas retain data-loader semantics", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./data.jsonc";\nconsole.log(data.answer, data.items[1], Object.hasOwn(data, "__proto__"), data.url);\n',
    "data.jsonc": '{\n// punctuation: { [ ;\n"answer": 42, /* comment */ "items": [1, 2,],\n"url": "https://example.test/a/*literal*/,}",\n"__proto__": {"value": 3,},\n}\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "42 2 true https://example.test/a/*literal*/,}\n");
});

test("JSONC syntax, duplicate keys, and unsafe numbers fail without replacing output", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./data.jsonc";\nconsole.log(data.answer);\n',
    "data.jsonc": '{"answer":42}',
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--outdir", "dist"];
  const initial = await runProcess(knot, args, { cwd: workspace });
  assert.equal(initial.status, 0, initial.stderr);
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  for (const [source, code] of [
    ['{"answer":42};globalThis.injected=true', "syntax_error"],
    ['{"answer":42,"ans\\u0077er":43}', "duplicate_key"],
    ['{"answer":9007199254740992}', "data_number"],
    ['{"answer":42, /* unfinished', "syntax_error"],
    ['{"answer":"\\ud800"}', "syntax_error"],
  ]) {
    await writeFile(path.join(workspace, "data.jsonc"), source);
    const result = await runProcess(knot, args, { cwd: workspace });
    assert.notEqual(result.status, 0, `${source}: ${result.stderr}`);
    assert.match(result.stderr, new RegExp(code));
    assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
  }
  await writeFile(path.join(workspace, "data.jsonc"), Buffer.from([0x7b, 0xc3, 0x28, 0x7d]));
  const invalidUtf8 = await runProcess(knot, args, { cwd: workspace });
  assert.notEqual(invalidUtf8.status, 0);
  assert.match(invalidUtf8.stderr, /invalid_encoding/);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
});

test("JSONC extension mappings override defaults only for matching files", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./data.foo";\nimport raw from "./note.jsonc";\nconsole.log(data.answer, typeof raw, raw.answer);\n',
    "data.foo": '{"answer":7,}',
    "note.jsonc": '{// note\n"answer":8,}',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--loader", ".foo=jsonc", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "7 object 8\n");
});

test("explicit text mapping overrides built-in JSONC mapping", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import raw from "./note.jsonc";\nconsole.log(typeof raw, raw.includes("// note"));\n',
    "note.jsonc": '{// note\n"answer":8,}',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--loader", ".jsonc=text", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "string true\n");
});
