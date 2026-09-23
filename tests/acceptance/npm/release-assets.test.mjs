import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { stageNpmRelease } from "../../../scripts/stage-npm.mjs";
import { writeReleaseAssets } from "../../../scripts/release-assets.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

test("release assets match the packed darwin-arm64 binary", () => {
  assert.equal(process.platform, "darwin");
  assert.equal(process.arch, "arm64");
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-assets-"));
  const stageDir = path.join(root, "npm");
  const outDir = path.join(root, "assets");
  stageNpmRelease({ rootDir: repoRoot, outDir: stageDir });
  writeReleaseAssets({ stageDir, outDir });

  const packed = fs.readFileSync(path.join(stageDir, "knot-darwin-arm64/bin/knot"));
  const assetPath = path.join(outDir, "knot-darwin-arm64");
  assert.deepEqual(fs.readFileSync(assetPath), packed);
  assert.ok(fs.statSync(assetPath).mode & 0o111);
  const wrapper = JSON.parse(fs.readFileSync(path.join(stageDir, "knot/package.json"), "utf8"));
  const digest = wrapper.knot.bins["@scope/knot-darwin-arm64"];
  assert.equal(digest, sha256(assetPath));
  assert.equal(fs.readFileSync(path.join(outDir, "SHA256SUMS"), "utf8"), `${digest}  knot-darwin-arm64\n`);
  assert.equal(fs.readFileSync(path.join(outDir, "assets.txt"), "utf8"), "SHA256SUMS\nknot-darwin-arm64\n");
  const notes = fs.readFileSync(path.join(outDir, "NOTES.md"), "utf8");
  assert.match(notes, /Package version 0\.0\.0\./);
  assert.match(notes, /npm stage approve/);
  assert.equal(fs.existsSync(path.join(outDir, "NOTES.md")), true);
  assert.equal(fs.readFileSync(path.join(outDir, "assets.txt"), "utf8").includes("NOTES.md"), false);
});

test("release assets refuse a binary that does not match knot.bins", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-assets-bad-"));
  const stageDir = path.join(root, "npm");
  fs.mkdirSync(path.join(stageDir, "knot-darwin-arm64/bin"), { recursive: true });
  fs.mkdirSync(path.join(stageDir, "knot"), { recursive: true });
  fs.writeFileSync(path.join(stageDir, "knot-darwin-arm64/bin/knot"), "not-the-binary\n");
  fs.writeFileSync(path.join(stageDir, "knot-darwin-arm64/package.json"), JSON.stringify({
    name: "@scope/knot-darwin-arm64",
  }));
  fs.writeFileSync(path.join(stageDir, "knot/package.json"), JSON.stringify({
    version: "0.0.0",
    knot: {
      bins: {
        "@scope/knot-darwin-arm64": "ab".repeat(32),
      },
    },
  }));
  assert.throws(
    () => writeReleaseAssets({ stageDir, outDir: path.join(root, "out") }),
    /checksum mismatch for @scope\/knot-darwin-arm64/,
  );
});

test("windows release assets keep the exe name", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-assets-win-"));
  const stageDir = path.join(root, "npm");
  const binary = path.join(stageDir, "knot-win32-x64/bin/knot.exe");
  fs.mkdirSync(path.dirname(binary), { recursive: true });
  fs.mkdirSync(path.join(stageDir, "knot"), { recursive: true });
  fs.writeFileSync(binary, "windows-binary");
  const digest = sha256(binary);
  fs.writeFileSync(path.join(stageDir, "knot-win32-x64/package.json"), JSON.stringify({
    name: "@scope/knot-win32-x64",
  }));
  fs.writeFileSync(path.join(stageDir, "knot/package.json"), JSON.stringify({
    version: "0.0.0",
    knot: { bins: { "@scope/knot-win32-x64": digest } },
  }));
  const outDir = path.join(root, "assets");
  writeReleaseAssets({ stageDir, outDir });
  assert.equal(fs.readFileSync(path.join(outDir, "knot-win32-x64.exe"), "utf8"), "windows-binary");
  assert.match(fs.readFileSync(path.join(outDir, "SHA256SUMS"), "utf8"), new RegExp(`^${digest}  knot-win32-x64\\.exe\\n$`));
});
