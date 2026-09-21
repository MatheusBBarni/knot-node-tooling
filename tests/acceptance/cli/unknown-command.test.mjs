import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("knot unknown command exits with a stable diagnostic code", async () => {
  const result = await runProcess(knot, ["not-a-command"], { cwd: repoRoot });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /unknown_command/);
  assert.match(result.stderr, /not-a-command/);
});
