import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build --show-config prints normalized defaults", async () => {
  const result = await runProcess(knot, ["build", "--show-config"]);
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), {
    target: "browser",
    format: "esm",
    splitting: false,
    minify: false,
    write: true,
    conditions: ["import", "module", "node", "default"],
  });
});
