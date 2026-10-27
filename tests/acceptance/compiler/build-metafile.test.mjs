import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build writes a metafile with inputs and outputs", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": "export function used() { return 1; }\n",
    "main.ts": 'import { used } from "./lib.ts";\nconsole.log(used());\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json", "--sourcemap", "external"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const raw = await readFile(path.join(workspace, "meta.json"), "utf8");
  const meta = JSON.parse(raw);
  assert.ok(meta.inputs || meta.modules);
  const inputs = meta.inputs || meta.modules;
  const inputKeys = Object.keys(inputs);
  assert.ok(inputKeys.some((k) => k.includes("main.ts") || k.endsWith("main.ts")));
  assert.ok(meta.outputs);
  const outKeys = Object.keys(meta.outputs);
  assert.ok(outKeys.some((k) => k.includes("out.js") || k.endsWith("out.js")));
  const out = meta.outputs[outKeys.find((k) => k.includes("out.js"))];
  assert.equal(out.kind, "js");
  assert.equal(out.entry.endsWith("main.ts"), true);
  assert.deepEqual(out.imports, ["./lib.ts"]);
  assert.deepEqual(out.exports, []);
  assert.match(out.digest, /^[A-Za-z0-9+/]+=*$/);
  assert.equal(out.sourceMap, "out.js.map");
});

test("metafile records why an unused export was removed", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": [
      "export function used() { return 1; }",
      "export function unused() { return 2; }",
      "",
    ].join("\n"),
    "main.ts": 'import { used } from "./lib.ts";\nconsole.log(used());\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const meta = JSON.parse(await readFile(path.join(workspace, "meta.json"), "utf8"));
  const unused = meta.removed.find((item) => item.name === "unused");
  assert.equal(unused.reason, "unused-export");
  assert.equal(unused.file.endsWith("lib.ts"), true);
  assert.equal(meta.removed.some((item) => item.name === "used"), false);
});

test("metafile records the entry import source range", async (t) => {
  const source = 'import { used } from "./lib.ts";\nconsole.log(used());\n';
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": "export function used() { return 1; }\n",
    "main.ts": source,
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const meta = JSON.parse(await readFile(path.join(workspace, "meta.json"), "utf8"));
  const out = meta.outputs[Object.keys(meta.outputs).find((key) => key.endsWith("out.js"))];
  const record = out.importRecords.find((item) => item.specifier === "./lib.ts");
  const start = source.indexOf('"./lib.ts"');
  assert.equal(record.start, start);
  assert.equal(record.end, start + '"./lib.ts"'.length);
});

test("metafile records dependency export ranges and whether each export was kept", async (t) => {
  const lib = [
    "export function used() { return 1; }",
    "export function unused() { return 2; }",
    "",
  ].join("\n");
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "lib.ts": lib,
    "main.ts": 'import { used } from "./lib.ts";\nconsole.log(used());\n',
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const meta = JSON.parse(await readFile(path.join(workspace, "meta.json"), "utf8"));
  const used = meta.exports.find((item) => item.name === "used");
  const unused = meta.exports.find((item) => item.name === "unused");
  const usedAt = lib.indexOf("function used") + "function ".length;
  const unusedAt = lib.indexOf("function unused") + "function ".length;
  assert.equal(used.kept, true);
  assert.equal(unused.kept, false);
  assert.equal(used.file.endsWith("lib.ts"), true);
  assert.equal(unused.file.endsWith("lib.ts"), true);
  assert.equal(used.start, usedAt);
  assert.equal(used.end, usedAt + "used".length);
  assert.equal(unused.start, unusedAt);
  assert.equal(unused.end, unusedAt + "unused".length);
});

test("metafile records a CSS import association with its source range", async (t) => {
  const source = 'import "./style.css";\nconsole.log(1);\n';
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "style.css": "body { color: red; }\n",
    "main.ts": source,
  });
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(
    knot,
    ["build", "main.ts", "--outfile", "out.js", "--metafile", "meta.json"],
    { cwd: workspace },
  );
  assert.equal(result.status, 0, result.stderr);

  const meta = JSON.parse(await readFile(path.join(workspace, "meta.json"), "utf8"));
  const out = meta.outputs[Object.keys(meta.outputs).find((key) => key.endsWith("out.js"))];
  const record = out.cssRecords.find((item) => item.specifier === "./style.css");
  const start = source.indexOf('"./style.css"');
  assert.equal(record.start, start);
  assert.equal(record.end, start + '"./style.css"'.length);
});
