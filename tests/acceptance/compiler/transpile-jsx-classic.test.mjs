import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("transpile lowers classic JSX in a .tsx file", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "input.tsx": [
      "export function App(name: string) {",
      "  return (",
      "    <div id=\"root\">",
      "      <span>{name}</span>",
      "      <br />",
      "      <>hi</>",
      "    </div>",
      "  );",
      "}",
      "",
    ].join("\n"),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["transpile", "input.tsx"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);

  const js = await readFile(path.join(workspace, "input.js"), "utf8");
  assert.doesNotMatch(js, /:\s*string/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']div["']/);
  assert.match(js, /\bid\s*:\s*["']root["']/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']span["']/);
  assert.match(js, /React\s*\.\s*createElement\s*\(\s*["']br["']/);
  assert.match(js, /React\s*\.\s*Fragment/);
  assert.match(js, /["']hi["']/);
  assert.doesNotMatch(js, /<\s*div/);
});
