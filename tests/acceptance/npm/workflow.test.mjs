import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const workflowPath = path.join(repoRoot, ".github/workflows/publish.yml");

test("the publish workflow builds both first-release targets and creates a GitHub release", () => {
  const text = fs.readFileSync(workflowPath, "utf8");
  const workflows = fs.readdirSync(path.join(repoRoot, ".github/workflows"));
  assert.deepEqual(workflows, ["publish.yml"]);
  assert.match(text, /tags:\n\s+- "v\*"/);
  assert.doesNotMatch(text, /branches:/);
  assert.doesNotMatch(text, /workflow_dispatch:/);
  assert.doesNotMatch(text, /pull_request:/);
  assert.match(text, /build-binaries:/);
  assert.match(text, /target: darwin-arm64/);
  assert.match(text, /target: linux-x64/);
  assert.match(text, /runner: macos-14/);
  assert.match(text, /runner: ubuntu-24\.04/);
  assert.match(text, /knot-binary-\$\{\{ matrix\.target \}\}/);
  assert.match(text, /needs: build-binaries/);
  assert.match(text, /knot-binary-darwin-arm64\/knot\.bin/);
  assert.match(text, /knot-binary-linux-x64\/knot\.bin/);
  assert.match(text, /platform: "darwin"/);
  assert.match(text, /platform: "linux"/);
  assert.match(text, /libc: "glibc"/);
  assert.match(text, /node scripts\/release-assets\.mjs/);
  assert.match(text, /gh release create/);
  assert.match(text, /contents:\s*write/);
  assert.match(text, /actions:\s*read/);
  assert.equal(text.match(/environment:\s*npm-publish/g).length, 2);
  assert.equal(text.match(/NODE_AUTH_TOKEN:\s*\$\{\{ secrets\.NPM_TOKEN \}\}/g).length, 2);
  assert.match(text, /npm stage publish --access public/);
  assert.match(text, /npm publish --access public/);
  assert.match(text, /npm view "\$name" name/);
  const uses = [...text.matchAll(/^\s{8}uses:\s*(\S+)/gm)].map((match) => match[1]);
  assert.equal(uses.filter((use) => use.startsWith("actions/checkout@")).length, 2);
  assert.equal(uses.filter((use) => use.startsWith("actions/setup-node@")).length, 2);
  assert.equal(uses.filter((use) => use.startsWith("actions/upload-artifact@")).length, 2);
  assert.equal(uses.filter((use) => use.startsWith("actions/download-artifact@")).length, 2);
  for (const use of uses) {
    assert.match(use, /@[0-9a-f]{40}$/);
  }
});
