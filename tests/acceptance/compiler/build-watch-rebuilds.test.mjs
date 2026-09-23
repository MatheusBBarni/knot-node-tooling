import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { setTimeout as delay } from "node:timers/promises";
import test from "node:test";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

async function waitFor(fn, timeoutMs = 8_000) {
  const start = Date.now();
  let last;
  while (Date.now() - start < timeoutMs) {
    try {
      return await fn();
    } catch (error) {
      last = error;
      await delay(50);
    }
  }
  throw last ?? new Error("timed out");
}

test("build --watch rebuilds after a source change", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.ts": "export function add(a: number, b: number): number {\n  return a + b;\n}\n",
  });
  t.after(() => removeWorkspace(workspace));

  const child = spawn(knot, ["build", "--watch", "--no-bundle", "input.ts"], {
    cwd: workspace,
    stdio: ["ignore", "pipe", "pipe"],
  });
  t.after(() => child.kill("SIGKILL"));

  const jsPath = path.join(workspace, "input.js");
  await waitFor(async () => {
    const js = await readFile(jsPath, "utf8");
    assert.match(js, /\badd\b/);
    return js;
  });

  await writeFile(
    path.join(workspace, "input.ts"),
    "export function mul(a: number, b: number): number {\n  return a * b;\n}\n",
  );

  await waitFor(async () => {
    const js = await readFile(jsPath, "utf8");
    assert.match(js, /\bmul\b/);
    assert.doesNotMatch(js, /\badd\b/);
    return js;
  });
});
