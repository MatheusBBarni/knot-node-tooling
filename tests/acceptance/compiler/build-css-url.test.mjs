import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("build copies and rewrites a local CSS url asset", async (t) => {
  const workspace = await makeWorkspace({
    "package.json": JSON.stringify({ name: "app", type: "module" }),
    "reset.css": "html { color: black; }\n",
    "style.css": '@import "./reset.css";\nbody { background: url("./bg.png?v=1#hero"); }\n.card { background: url( ./bg.png?v=2#card ); }\n.icon { background: url(data:image/png;base64,abc); }\n.remote { background: url("https://cdn.example.test/bg.png"); }\n',
    "entry.ts": 'import "./style.css";\nconsole.log(42);\n',
  });
  await writeFile(path.join(workspace, "bg.png"), Buffer.from([1, 2, 3, 4]));
  t.after(() => removeWorkspace(workspace));
  const result = await runProcess(knot, ["build", "entry.ts", "--outdir", "dist"], { cwd: workspace });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(await readFile(path.join(workspace, "dist", "entry.css"), "utf8"), 'html { color: black; }\n\nbody { background: url("bg.png?v=1#hero"); }\n.card { background: url("bg.png?v=2#card"); }\n.icon { background: url(data:image/png;base64,abc); }\n.remote { background: url("https://cdn.example.test/bg.png"); }\n');
  assert.deepEqual([...await readFile(path.join(workspace, "dist", "bg.png"))], [1, 2, 3, 4]);
});
