import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const workflowPath = path.join(repoRoot, ".github/workflows/publish.yml");

test("the publish workflow stages on v* tags and does not publish directly", () => {
  const text = fs.readFileSync(workflowPath, "utf8");
  const workflows = fs.readdirSync(path.join(repoRoot, ".github/workflows"));
  assert.deepEqual(workflows, ["publish.yml"]);
  assert.match(text, /tags:\n\s+- "v\*"/);
  assert.doesNotMatch(text, /branches:/);
  assert.doesNotMatch(text, /workflow_dispatch:/);
  assert.doesNotMatch(text, /pull_request:/);
  assert.match(text, /id-token:\s*write/);
  assert.match(text, /contents:\s*read/);
  assert.match(text, /package-manager-cache:\s*false/);
  assert.match(text, /environment:\s*npm-publish/);
  assert.match(text, /npm stage publish/);
  assert.doesNotMatch(text, /npm publish/);
  assert.doesNotMatch(text, /NPM_TOKEN/);
  const uses = [...text.matchAll(/^ {8}uses:\s*(\S+)/gm)].map((match) => match[1]);
  assert.equal(uses.length, 2);
  for (const use of uses) {
    assert.match(use, /@[0-9a-f]{40}$/);
    assert.doesNotMatch(use, /@v\d/);
  }
});
