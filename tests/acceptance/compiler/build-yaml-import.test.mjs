import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("YAML core mappings, sequences, and scalars load as default module data", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./config.yaml";\nconsole.log(data.name, data.active, data.items[1].id, data.items[0].tags[1], Object.hasOwn(data, "__proto__"));\n',
    "config.yaml": 'name: knot\nactive: true\n__proto__: own\nitems:\n  - id: 1\n    tags: [red, blue]\n  - id: 2\n    tags: [green]\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "knot true 2 blue true\n");
});

test("YAML duplicate keys and forbidden schemas preserve the previous build", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./config.yml";\nconsole.log(data.answer);\n',
    "config.yml": "answer: 42\n",
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--outdir", "dist"];
  const initial = await runProcess(knot, args, { cwd: workspace });
  assert.equal(initial.status, 0, initial.stderr);
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  for (const [source, code] of [
    ["answer: 1\nanswer: 2\n", "duplicate_key"],
    ["answer: *copy\n", "data_schema"],
    ["answer: 2024-01-01\n", "data_schema"],
    ["answer: .inf\n", "data_schema"],
    ["answer: 9007199254740992\n", "data_number"],
  ]) {
    await writeFile(path.join(workspace, "config.yml"), source);
    const failed = await runProcess(knot, args, { cwd: workspace });
    assert.notEqual(failed.status, 0, `${source}: ${failed.stderr}`);
    assert.match(failed.stderr, new RegExp(code));
    assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
  }
});
