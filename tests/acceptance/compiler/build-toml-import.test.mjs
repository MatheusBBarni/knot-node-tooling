import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("TOML tables, arrays of tables, and dates load as default module data", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./config.toml";\nconsole.log(data.package.name, data.items[1].id, data.items[1].when, Object.hasOwn(data, "__proto__"));\n',
    "config.toml": '"__proto__" = "own"\n[package]\nname = "knot"\n[[items]]\nid = 1\n[[items]]\nid = 2\nwhen = 1979-05-27T07:32:00Z\n',
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const executed = await runProcess(process.execPath, ["dist/entry.js"], { cwd: workspace });
  assert.equal(executed.status, 0, executed.stderr);
  assert.equal(executed.stdout, "knot 2 1979-05-27T07:32:00Z true\n");
});

test("TOML duplicate definitions and unsafe numbers preserve the prior build", async (t) => {
  const workspace = await makeWorkspace({
    "entry.ts": 'import data from "./config.toml";\nconsole.log(data.answer);\n',
    "config.toml": "answer = 42\n",
  });
  t.after(() => removeWorkspace(workspace));
  const args = ["build", "entry.ts", "--outdir", "dist"];
  const initial = await runProcess(knot, args, { cwd: workspace });
  assert.equal(initial.status, 0, initial.stderr);
  const before = await readFile(path.join(workspace, "dist/entry.js"), "utf8");
  for (const [source, code] of [
    ["answer = 1\nanswer = 2\n", "duplicate_key"],
    ["answer = 9007199254740992\n", "data_number"],
    ["answer = inf\n", "data_number"],
    ["answer = (1 + 2)\n", "syntax_error"],
  ]) {
    await writeFile(path.join(workspace, "config.toml"), source);
    const failed = await runProcess(knot, args, { cwd: workspace });
    assert.notEqual(failed.status, 0, `${source}: ${failed.stderr}`);
    assert.match(failed.stderr, new RegExp(code));
    assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), before);
  }
});
