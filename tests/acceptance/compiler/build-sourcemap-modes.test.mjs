import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

async function exists(file) {
  try {
    await access(file);
    return true;
  } catch {
    return false;
  }
}

test("bundle source map mode defaults to none and supports external maps", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "export const value: number = 7;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const plain = await runProcess(knot, ["build", "main.ts", "--outfile", "plain.js"], { cwd: workspace });
  assert.equal(plain.status, 0, plain.stderr);
  const plainJs = await readFile(path.join(workspace, "plain.js"), "utf8");
  assert.doesNotMatch(plainJs, /sourceMappingURL/);
  assert.equal(await exists(path.join(workspace, "plain.js.map")), false);

  const external = await runProcess(knot, ["build", "main.ts", "--outfile", "external.js", "--sourcemap", "external"], { cwd: workspace });
  assert.equal(external.status, 0, external.stderr);
  const externalJs = await readFile(path.join(workspace, "external.js"), "utf8");
  assert.doesNotMatch(externalJs, /sourceMappingURL/);
  assert.equal(await exists(path.join(workspace, "external.js.map")), true);
});

test("build emits inline source maps", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "export const value: number = 7;\n",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "main.ts", "--outfile", "out.js", "--sourcemap", "inline"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const js = await readFile(path.join(workspace, "out.js"), "utf8");
  const match = js.match(/sourceMappingURL=data:application\/json;base64,([A-Za-z0-9+/=]+)/);
  assert.ok(match, js);
  assert.equal(JSON.parse(Buffer.from(match[1], "base64").toString("utf8")).version, 3);
  assert.equal(await exists(path.join(workspace, "out.js.map")), false);
});
