import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

function manifest(target) {
  return JSON.stringify({
    name: "lib",
    type: "module",
    exports: { ".": { import: target } },
  });
}

test("library exports are modeled and must match the planned output", async (t) => {
  const source = manifest("./dist/entry.js");
  const workspace = await makeWorkspace({
    "package.json": source,
    "entry.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const shown = await runProcess(
    knot,
    [
      "build",
      "entry.ts",
      "--outfile",
      "dist/entry.js",
      "--target",
      "node",
      "--format",
      "esm",
      "--packages",
      "external",
      "--library-exports",
      "package.json",
      "--show-config",
    ],
    { cwd: workspace },
  );
  assert.equal(shown.status, 0, shown.stderr);
  const record = JSON.parse(shown.stdout);
  const digest = createHash("sha256").update(source).digest("base64");
  assert.equal(record.config.library.packageJson, "package.json");
  assert.equal(record.config.configInputs.libraryManifest, digest);

  const built = await runProcess(
    knot,
    [
      "build",
      "entry.ts",
      "--outfile",
      "dist/entry.js",
      "--target",
      "node",
      "--format",
      "esm",
      "--packages",
      "external",
      "--library-exports",
      "package.json",
    ],
    { cwd: workspace },
  );
  assert.equal(built.status, 0, built.stderr);
  assert.equal(await readFile(path.join(workspace, "package.json"), "utf8"), source);
  assert.equal(await readFile(path.join(workspace, "dist/entry.js"), "utf8") !== "", true);
});

test("a library export mismatch fails before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": manifest("./dist/other.js"),
    "entry.ts": "export const value = 1;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    [
      "build",
      "entry.ts",
      "--outfile",
      "dist/entry.js",
      "--target",
      "node",
      "--format",
      "esm",
      "--packages",
      "external",
      "--library-exports",
      "package.json",
    ],
    { cwd: workspace },
  );
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /library_exports/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/entry.js"), "utf8"));
});
