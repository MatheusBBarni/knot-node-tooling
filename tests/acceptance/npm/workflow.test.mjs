import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const workflowPath = path.join(repoRoot, ".github/workflows/publish.yml");

test("the publish workflow stages on v* tags and creates a GitHub release", () => {
  const text = fs.readFileSync(workflowPath, "utf8");
  const workflows = fs.readdirSync(path.join(repoRoot, ".github/workflows"));
  assert.deepEqual(workflows, ["publish.yml"]);
  assert.match(text, /tags:\n\s+- "v\*"/);
  assert.doesNotMatch(text, /branches:/);
  assert.doesNotMatch(text, /workflow_dispatch:/);
  assert.doesNotMatch(text, /pull_request:/);
  assert.match(text, /id-token:\s*write/);
  assert.match(text, /contents:\s*read/);
  assert.match(text, /contents:\s*write/);
  assert.match(text, /actions:\s*read/);
  assert.match(text, /package-manager-cache:\s*false/);
  assert.equal(text.match(/environment:\s*npm-publish/g).length, 2);
  assert.match(text, /npm stage publish --access public/);
  assert.match(text, /registry-url:\s*"https:\/\/registry\.npmjs\.org"/);
  assert.match(text, /node scripts\/release-assets\.mjs/);
  assert.match(text, /gh release create/);
  assert.match(text, /needs:\s*publish/);
  assert.doesNotMatch(text, /npm publish/);
  const publishJob = text.split(/^ {2}publish:\n/m)[1].split(/^ {2}release:\n/m)[0];
  assert.equal(publishJob.match(/NODE_AUTH_TOKEN:\s*\$\{\{ secrets\.NPM_TOKEN \}\}/g).length, 2);
  const releaseJob = text.split(/^ {2}release:\n/m)[1];
  assert.match(releaseJob, /contents:\s*write/);
  assert.match(releaseJob, /actions:\s*read/);
  assert.doesNotMatch(releaseJob, /id-token:/);
  assert.doesNotMatch(releaseJob, /NPM_TOKEN/);
  const uses = [...text.matchAll(/^ {8}uses:\s*(\S+)/gm)].map((match) => match[1]);
  assert.deepEqual(uses, [
    "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1",
    "actions/setup-node@820762786026740c76f36085b0efc47a31fe5020",
    "actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a",
    "actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c",
  ]);
  for (const use of uses) {
    assert.match(use, /@[0-9a-f]{40}$/);
  }
});
