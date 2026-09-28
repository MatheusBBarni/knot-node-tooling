import assert from "node:assert/strict";
import { chmod, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

test("knot --upgrade updates the installed Knot package through npm", async (t) => {
  const workspace = await makeWorkspace({
    "fake-bin/npm": "#!/usr/bin/env node\nimport { writeFile } from \"node:fs/promises\";\nawait writeFile(process.env.KNOT_UPGRADE_LOG, JSON.stringify(process.argv.slice(2)));\n",
  });
  const fakeNpm = path.join(workspace, "fake-bin/npm");
  const log = path.join(workspace, "upgrade-args.json");
  await chmod(fakeNpm, 0o755);
  t.after(() => removeWorkspace(workspace));

  const result = await runProcess(knot, ["--upgrade"], {
    cwd: workspace,
    env: {
      ...process.env,
      KNOT_UPGRADE_LOG: log,
      PATH: `${path.dirname(fakeNpm)}${path.delimiter}${path.dirname(process.execPath)}${path.delimiter}${process.env.PATH ?? ""}`,
    },
  });

  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout, "knot: upgraded @matheusbbarni/knot\n");
  assert.deepEqual(JSON.parse(await readFile(log, "utf8")), ["install", "--global", "@matheusbbarni/knot@latest"]);
});
