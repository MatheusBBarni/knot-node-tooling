import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("knot --help prints usage and listed commands", async () => {
  const result = await runProcess(knot, ["--help"], { cwd: repoRoot });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Usage:/);
  assert.match(result.stdout, /install/);
  assert.match(result.stdout, /cache clean/);
});

test("knot -h prints usage", async () => {
  const result = await runProcess(knot, ["-h"], { cwd: repoRoot });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Usage:/);
});

test("knot with no arguments prints usage", async () => {
  const result = await runProcess(knot, [], { cwd: repoRoot });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Usage:/);
});
