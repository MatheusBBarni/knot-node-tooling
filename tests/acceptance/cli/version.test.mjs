import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("knot --version prints the project version", async () => {
  const pkg = JSON.parse(await readFile(path.join(repoRoot, "package.json"), "utf8"));
  const result = await runProcess(knot, ["--version"], { cwd: repoRoot });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, `${pkg.version}\n`);
});
