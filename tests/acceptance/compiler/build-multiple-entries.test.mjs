import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build emits one output for each entrypoint", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "one.ts": 'console.log("one");\n',
    "two.ts": 'console.log("two");\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "one.ts", "two.ts", "--outdir", "dist", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal((await runProcess(process.execPath, ["dist/one.js"], { cwd: workspace })).stdout, "one\n");
  assert.equal((await runProcess(process.execPath, ["dist/two.js"], { cwd: workspace })).stdout, "two\n");
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.deepEqual(manifest.entries, { "one.ts": "dist/one.js", "two.ts": "dist/two.js" });
  assert.equal(manifest.outputs["dist/one.js"].bytes > 0, true);
  assert.equal(manifest.outputs["dist/two.js"].bytes > 0, true);
});

test("build places modules shared by entries in one static chunk", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "shared.ts": "export const shared = 7;\n",
    "one.ts": 'import { shared } from "./shared.ts"; console.log(shared + 1);\n',
    "two.ts": 'import { shared } from "./shared.ts"; console.log(shared + 2);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "one.ts", "two.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const files = await readdir(path.join(workspace, "dist"));
  assert.deepEqual(files.filter((file) => file.endsWith(".js") && !file.endsWith(".map")).sort(), ["knot-shared.js", "one.js", "two.js"]);
  assert.equal((await runProcess(process.execPath, ["dist/one.js"], { cwd: workspace })).stdout, "8\n");
  assert.equal((await runProcess(process.execPath, ["dist/two.js"], { cwd: workspace })).stdout, "9\n");
});

test("build applies a chunk naming template", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "shared.ts": "export const shared = 7;\n",
    "one.ts": 'import { shared } from "./shared.ts"; console.log(shared + 1);\n',
    "two.ts": 'import { shared } from "./shared.ts"; console.log(shared + 2);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "one.ts", "two.ts", "--outdir", "dist", "--chunk-naming", "[name]-chunk.[ext]"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const files = await readdir(path.join(workspace, "dist"));
  assert.equal(files.includes("shared-chunk.js"), true);
  assert.equal(files.includes("knot-shared.js"), false);
});

test("multi-entry manifests include shared chunks after atomic publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "shared.ts": "export const shared = 7;\n",
    "one.ts": 'import { shared } from "./shared.ts"; console.log(shared + 1);\n',
    "two.ts": 'import { shared } from "./shared.ts"; console.log(shared + 2);\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "one.ts", "two.ts", "--outdir", "dist", "--manifest", "manifest.json"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const manifest = JSON.parse(await readFile(path.join(workspace, "manifest.json"), "utf8"));
  assert.deepEqual(manifest.entries, { "one.ts": "dist/one.js", "two.ts": "dist/two.js" });
  assert.equal(manifest.outputs["dist/knot-shared.js"].kind, "chunk");
  assert.match(manifest.outputs["dist/knot-shared.js"].digest, /^[A-Za-z0-9+/]+=*$/);
  assert.equal(Object.keys(manifest.outputs).some((file) => file.includes(".knot-stage")), false);
});
