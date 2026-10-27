import assert from "node:assert/strict";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("static preload emits the HTML entry chunk and skips dynamic chunks", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "import(\"./lazy.ts\").then((module) => console.log(module.value));\n",
    "lazy.ts": "export const value = 9;\n",
    "style.css": "body { color: red; }\n",
    "index.html": '<link rel="stylesheet" href="./style.css"><script type="module" crossorigin="anonymous" referrerpolicy="no-referrer" nonce="test-nonce" src="./main.ts"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));

  const plain = await runProcess(knot, ["build", "index.html", "--outdir", "plain", "--splitting"], { cwd: workspace });
  assert.equal(plain.status, 0, plain.stderr);
  assert.doesNotMatch(await readFile(path.join(workspace, "plain/index.html"), "utf8"), /modulepreload/);

  const built = await runProcess(knot, ["build", "index.html", "--outdir", "dist", "--splitting", "--preload", "static", "--sourcemap", "linked"], { cwd: workspace });
  assert.equal(built.status, 0, built.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /<link rel="modulepreload" href="main\.js" crossorigin="anonymous" referrerpolicy="no-referrer" nonce="test-nonce">/);
  assert.match(html, /referrerpolicy="no-referrer"/);
  assert.match(html, /nonce="test-nonce"/);
  assert.match(html, /src="main\.js"/);
  const files = await readdir(path.join(workspace, "dist"));
  const chunks = files.filter((name) => name.endsWith(".js") && name !== "main.js");
  assert.equal(chunks.length, 1);
  assert.doesNotMatch(html, new RegExp(`modulepreload[^>]*${chunks[0]}`));
  assert.match(await readFile(path.join(workspace, "dist/main.js"), "utf8"), /sourceMappingURL=main\.js\.map/);
  assert.equal(JSON.parse(await readFile(path.join(workspace, "dist/main.js.map"), "utf8")).version, 3);
  assert.match(await readFile(path.join(workspace, "dist/style.css"), "utf8"), /sourceMappingURL=style\.css\.map/);
  assert.equal(JSON.parse(await readFile(path.join(workspace, "dist/style.css.map"), "utf8")).version, 3);

  const shown = await runProcess(knot, ["build", "main.ts", "--preload", "static", "--show-config"], { cwd: workspace });
  assert.equal(shown.status, 0, shown.stderr);
  assert.equal(JSON.parse(shown.stdout).config.preload, "static");
});

test("an invalid preload mode fails before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<script type="module" src="./main.ts"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist", "--preload", "eager"], { cwd: workspace });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /invalid_option/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/index.html"), "utf8"));
});
