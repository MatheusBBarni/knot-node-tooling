import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("publication activates a generation pointer and retains the previous generation", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const first = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(first.status, 0, first.stderr);
  const active1 = JSON.parse(await readFile(path.join(workspace, "dist/active.json"), "utf8"));
  assert.equal(active1.version, 1);
  assert.equal(typeof active1.generation, "string");
  assert.equal(typeof active1.completeDigest, "string");
  const gen1 = path.join(workspace, "dist/generations", active1.generation);
  const oldJs = await readFile(path.join(gen1, "entry.js"), "utf8");
  assert.match(oldJs, /value = 1/);
  const complete = JSON.parse(await readFile(path.join(gen1, "complete.json"), "utf8"));
  assert.equal(complete.version, 1);
  assert.equal(complete.generation, active1.generation);
  assert.equal(complete.tombstone, false);
  assert.equal(complete.outputs.some((item) => item.path === "entry.js" && item.bytes === Buffer.byteLength(oldJs)), true);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), oldJs);

  await writeFile(path.join(workspace, "entry.ts"), "export const value = 2;\n");
  const second = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(second.status, 0, second.stderr);
  const active2 = JSON.parse(await readFile(path.join(workspace, "dist/active.json"), "utf8"));
  assert.notEqual(active2.generation, active1.generation);
  assert.equal(await readFile(path.join(gen1, "entry.js"), "utf8"), oldJs);
  assert.match(await readFile(path.join(workspace, "dist/generations", active2.generation, "entry.js"), "utf8"), /value = 2/);
  assert.match(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), /value = 2/);

  const crashed = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], {
    cwd: workspace,
    env: { ...process.env, KNOT_FAIL_PUBLISH: "before-activate" },
  });
  assert.notEqual(crashed.status, 0);
  assert.match(crashed.stderr, /publication_error/);
  assert.equal(JSON.parse(await readFile(path.join(workspace, "dist/active.json"), "utf8")).generation, active2.generation);
  assert.match(await readFile(path.join(workspace, "dist/entry.js"), "utf8"), /value = 2/);
});

test("snapshot exports the active generation without publication metadata", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 3;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const active = JSON.parse(await readFile(path.join(workspace, "dist/active.json"), "utf8"));
  const exported = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export"], { cwd: workspace });
  assert.equal(exported.status, 0, exported.stderr);
  const record = JSON.parse(exported.stdout);
  assert.equal(record.version, 1);
  assert.equal(record.generation, active.generation);
  assert.equal(record.completeDigest, active.completeDigest);
  const js = await readFile(path.join(workspace, "export/entry.js"), "utf8");
  assert.match(js, /value = 3/);
  await assert.rejects(() => readFile(path.join(workspace, "export/active.json"), "utf8"));
  await assert.rejects(() => readFile(path.join(workspace, "export/complete.json"), "utf8"));
  const again = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export"], { cwd: workspace });
  assert.notEqual(again.status, 0);
  assert.match(again.stderr, /publication_error/);
  assert.match(await readFile(path.join(workspace, "export/entry.js"), "utf8"), /value = 3/);
});

test("snapshot failure before rename publishes nothing and a corrupt pointer is recovery", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 4;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const built = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const active = await readFile(path.join(workspace, "dist/active.json"), "utf8");
  const crashed = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export"], {
    cwd: workspace,
    env: { ...process.env, KNOT_FAIL_SNAPSHOT: "before-rename" },
  });
  assert.notEqual(crashed.status, 0);
  assert.match(crashed.stderr, /publication_error/);
  await assert.rejects(() => readFile(path.join(workspace, "export/entry.js"), "utf8"));
  assert.equal(await readFile(path.join(workspace, "dist/active.json"), "utf8"), active);
  await writeFile(path.join(workspace, "dist/active.json"), "{not-json");
  const recovered = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export"], { cwd: workspace });
  assert.notEqual(recovered.status, 0);
  assert.match(recovered.stderr, /publication_recovery/);
  await assert.rejects(() => readFile(path.join(workspace, "export/entry.js"), "utf8"));
});

test("a corrupt active pointer recovers the previous generation", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "entry.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));
  const first = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(first.status, 0, first.stderr);
  await writeFile(path.join(workspace, "entry.ts"), "export const value = 2;\n");
  const second = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(second.status, 0, second.stderr);
  await writeFile(path.join(workspace, "dist/active.json"), "{not-json");
  const recovered = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export-old"], { cwd: workspace });
  assert.equal(recovered.status, 0, recovered.stderr);
  assert.match(await readFile(path.join(workspace, "export-old/entry.js"), "utf8"), /value = 1/);
  assert.doesNotMatch(await readFile(path.join(workspace, "export-old/entry.js"), "utf8"), /value = 2/);
  await writeFile(path.join(workspace, "dist/previous.json"), "{not-json");
  const both = await runProcess(knot, ["snapshot", "--outdir", "dist", "--to", "export-both"], { cwd: workspace });
  assert.notEqual(both.status, 0);
  assert.match(both.stderr, /publication_recovery/);
  await assert.rejects(() => readFile(path.join(workspace, "export-both/entry.js"), "utf8"));
});
