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

test("build --watch rebuilds a bundle when a dependency changes", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "dep.ts": "export function val() { return 1; }\n",
    "main.ts": "import { val } from \"./dep.ts\";\nconsole.log(val());\n",
  });
  t.after(() => removeWorkspace(workspace));

  const child = spawn(knot, ["build", "--watch", "main.ts", "--outfile", "out.js"], {
    cwd: workspace,
    stdio: ["ignore", "pipe", "pipe"],
  });
  t.after(() => child.kill("SIGKILL"));

  const outPath = path.join(workspace, "out.js");
  await waitFor(async () => {
    const js = await readFile(outPath, "utf8");
    assert.match(js, /\breturn 1\b/);
    return js;
  });

  await writeFile(path.join(workspace, "dep.ts"), "export function val() { return 9; }\n");

  await waitFor(async () => {
    const js = await readFile(outPath, "utf8");
    assert.match(js, /\breturn 9\b/);
    return js;
  });
});
