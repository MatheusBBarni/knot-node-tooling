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

test("release assets match both packed first-release binaries", () => {
  assert.equal(process.platform, "darwin");
  assert.equal(process.arch, "arm64");
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-assets-"));
  const stageDir = path.join(root, "npm");
  const outDir = path.join(root, "assets");
  const binaryPath = path.join(repoRoot, "dist", "knot.bin");
  stageNpmRelease({
    rootDir: repoRoot,
    outDir: stageDir,
    targets: [
      { platform: "darwin", arch: "arm64", libc: null, binaryPath },
      { platform: "linux", arch: "x64", libc: "glibc", binaryPath },
    ],
  });
  writeReleaseAssets({ stageDir, outDir });

  const darwinPacked = fs.readFileSync(path.join(stageDir, "knot-darwin-arm64/bin/knot"));
  const linuxPacked = fs.readFileSync(path.join(stageDir, "knot-linux-x64/bin/knot"));
  const darwinAsset = path.join(outDir, "knot-darwin-arm64");
  const linuxAsset = path.join(outDir, "knot-linux-x64");
  assert.deepEqual(fs.readFileSync(darwinAsset), darwinPacked);
  assert.deepEqual(fs.readFileSync(linuxAsset), linuxPacked);
  assert.ok(fs.statSync(darwinAsset).mode & 0o111);
  assert.ok(fs.statSync(linuxAsset).mode & 0o111);
  const wrapper = JSON.parse(fs.readFileSync(path.join(stageDir, "knot/package.json"), "utf8"));
  const darwinDigest = wrapper.knot.bins["@matheusbbarni/knot-darwin-arm64"];
  const linuxDigest = wrapper.knot.bins["@matheusbbarni/knot-linux-x64"];
  assert.equal(darwinDigest, sha256(darwinAsset));
  assert.equal(linuxDigest, sha256(linuxAsset));
  assert.deepEqual(
    new Set(fs.readFileSync(path.join(outDir, "SHA256SUMS"), "utf8").trim().split("\n")),
    new Set([`${darwinDigest}  knot-darwin-arm64`, `${linuxDigest}  knot-linux-x64`]),
  );
  assert.equal(fs.readFileSync(path.join(outDir, "assets.txt"), "utf8"), "SHA256SUMS\nknot-darwin-arm64\nknot-linux-x64\n");
  const notes = fs.readFileSync(path.join(outDir, "NOTES.md"), "utf8");
  assert.match(notes, /Package version 0\.0\.1\./);
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
    name: "@matheusbbarni/knot-darwin-arm64",
  }));
  fs.writeFileSync(path.join(stageDir, "knot/package.json"), JSON.stringify({
    version: "0.0.0",
    knot: {
      bins: {
        "@matheusbbarni/knot-darwin-arm64": "ab".repeat(32),
      },
    },
  }));
  assert.throws(
    () => writeReleaseAssets({ stageDir, outDir: path.join(root, "out") }),
    /checksum mismatch for @matheusbbarni\/knot-darwin-arm64/,
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
    name: "@matheusbbarni/knot-win32-x64",
  }));
  fs.writeFileSync(path.join(stageDir, "knot/package.json"), JSON.stringify({
    version: "0.0.0",
  knot: { bins: { "@matheusbbarni/knot-win32-x64": digest } },
  }));
  const outDir = path.join(root, "assets");
  writeReleaseAssets({ stageDir, outDir });
  assert.equal(fs.readFileSync(path.join(outDir, "knot-win32-x64.exe"), "utf8"), "windows-binary");
  assert.match(fs.readFileSync(path.join(outDir, "SHA256SUMS"), "utf8"), new RegExp(`^${digest}  knot-win32-x64\\.exe\\n$`));
});
