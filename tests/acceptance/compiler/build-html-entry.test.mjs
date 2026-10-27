import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build bundles a module script referenced by an HTML entry", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(42);\n",
    "index.html": '<!doctype html><link rel="stylesheet" href="./style.css"><img src="./logo.png"><script type="module" src="./main.ts"></script>\n',
    "style.css": "body { color: red; }\n",
    "logo.png": Buffer.from([137, 80, 78, 71]),
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /href="style\.css"/);
  assert.match(html, /src="logo\.png"/);
  assert.match(html, /src="main\.js"/);
  assert.equal(await readFile(path.join(workspace, "dist/style.css"), "utf8"), "body { color: red; }\n");
  assert.deepEqual([...await readFile(path.join(workspace, "dist/logo.png"))], [137, 80, 78, 71]);
  const run = await runProcess(process.execPath, ["dist/main.js"], { cwd: workspace });
  assert.equal(run.status, 0, run.stderr);
  assert.equal(run.stdout, "42\n");
});

test("build rewrites every local HTML href and src reference", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<link rel="stylesheet" href="./a.css"><link rel="stylesheet" href="./b.css"><img src="./one.png"><img src="./two.png"><script type="module" src="./main.ts"></script>\n',
    "a.css": "a {}\n",
    "b.css": "b {}\n",
    "one.png": "one",
    "two.png": "two",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /href="a\.css"/);
  assert.match(html, /href="b\.css"/);
  assert.match(html, /src="one\.png"/);
  assert.match(html, /src="two\.png"/);
  assert.match(html, /src="main\.js"/);
  assert.equal(await readFile(path.join(workspace, "dist/a.css"), "utf8"), "a {}\n");
  assert.equal(await readFile(path.join(workspace, "dist/b.css"), "utf8"), "b {}\n");
  assert.equal(await readFile(path.join(workspace, "dist/one.png"), "utf8"), "one");
  assert.equal(await readFile(path.join(workspace, "dist/two.png"), "utf8"), "two");
});

test("build rewrites local HTML srcset candidates", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<img srcset="./small.png 1x, ./large.png 2x"><script type="module" src="./main.ts"></script>\n',
    "small.png": "small",
    "large.png": "large",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /srcset="small\.png 1x,\s*large\.png 2x"/);
  assert.equal(await readFile(path.join(workspace, "dist/small.png"), "utf8"), "small");
  assert.equal(await readFile(path.join(workspace, "dist/large.png"), "utf8"), "large");
});

test("build bundles CSS dependencies referenced by HTML", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<link rel="stylesheet" href="./style.css"><script type="module" src="./main.ts"></script>\n',
    "style.css": '@import "./reset.css";\nbody { background: url("./bg.png"); }\n',
    "reset.css": "html { color: black; }\n",
    "bg.png": "bg",
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const css = await readFile(path.join(workspace, "dist/style.css"), "utf8");
  assert.match(css, /html \{ color: black; \}/);
  assert.match(css, /background: url\(["']?bg\.png/);
  assert.equal(await readFile(path.join(workspace, "dist/bg.png"), "utf8"), "bg");
});

test("build preserves external HTML references", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<link rel="stylesheet" href="https://cdn.example.test/site.css"><img src="/images/logo.png"><script type="module" src="./main.ts"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /href="https:\/\/cdn\.example\.test\/site\.css"/);
  assert.match(html, /src="\/images\/logo\.png"/);
});

test("build rewrites only attributes in parsed HTML tags", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "real.png": "real",
    "fake.png": "fake",
    "index.html": '<!-- <img src="./fake.png"> --><script type="module" src="./main.ts">const x = \'src="./fake.png"\';</script><img src="./real.png">\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  const html = await readFile(path.join(workspace, "dist/index.html"), "utf8");
  assert.match(html, /fake\.png/);
  assert.match(html, /real\.png/);
  assert.equal(await readFile(path.join(workspace, "dist/real.png"), "utf8"), "real");
  await assert.rejects(() => readFile(path.join(workspace, "dist/fake.png")));
});

test("local references inside an HTML template fail before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "real.png": "real",
    "fake.png": "fake",
    "index.html": "<script type=\"module\" src=\"./main.ts\"></script><template><img src=\"./fake.png\"></template><img src=\"./real.png\">\n",
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /html_template_reference/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/fake.png"), "utf8"));
  await assert.rejects(() => readFile(path.join(workspace, "dist/real.png"), "utf8"));
});

test("a javascript URL in an HTML attribute fails before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<img src="javascript:alert(1)"><script type="module" src="./main.ts"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /html_url_scheme/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/index.html"), "utf8"));
});

test("an executable blob or data URL fails before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "index.html": '<script type="module" src="./main.ts"></script><script src="blob:https://example.test/id"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));
  const blob = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(blob.status, 0);
  assert.match(blob.stderr, /html_url_scheme/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/index.html"), "utf8"));
  await writeFile(path.join(workspace, "index.html"), '<script type="module" src="./main.ts"></script><script src="data:text/javascript,alert(1)"></script>\n');
  const data = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(data.status, 0);
  assert.match(data.stderr, /html_url_scheme/);
  await writeFile(path.join(workspace, "index.html"), '<script type="module" src="./main.ts"></script><img src="data:image/png;base64,abc">\n');
  const image = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.equal(image.status, 0, image.stderr);
  assert.match(await readFile(path.join(workspace, "dist/index.html"), "utf8"), /data:image\/png;base64,abc/);
});

test("a malformed web app manifest fails before publication", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "main.ts": "console.log(1);\n",
    "app.webmanifest": "{",
    "index.html": '<link rel="manifest" href="./app.webmanifest"><script type="module" src="./main.ts"></script>\n',
  });
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "index.html", "--outdir", "dist"], { cwd: workspace });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /html_manifest/);
  await assert.rejects(() => readFile(path.join(workspace, "dist/index.html"), "utf8"));
  await assert.rejects(() => readFile(path.join(workspace, "dist/app.webmanifest"), "utf8"));
});
