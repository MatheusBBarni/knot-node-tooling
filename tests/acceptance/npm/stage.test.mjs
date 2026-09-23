import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { dispatchVersionLiteral, stageNpmRelease } from "../../../scripts/stage-npm.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const launcherSource = path.join(repoRoot, "packaging/npm/knot.cjs");

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

test("staging refuses a version that differs from dispatch_version", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "knot-ver-"));
  const out = path.join(root, "out");
  fs.mkdirSync(path.join(root, "src"));
  fs.writeFileSync(path.join(root, "package.json"), JSON.stringify({
    name: "knot",
    version: "9.9.9",
    private: true,
  }));
  fs.writeFileSync(path.join(root, "src/knot.bend"), `
def dispatch_version(+cmd: String, rest: List<&2, String>, is_version: Bool) -> IO(Unit):
  match is_version:
    case True{}:
      IO.print("0.0.0")
    case False{}:
      IO.pure(Unit, Unit{})

def dispatch_help() -> IO(Unit):
  IO.pure(Unit, Unit{})
`);
  assert.throws(
    () => stageNpmRelease({ rootDir: root, outDir: out }),
    /staged version 9\.9\.9 does not match dispatch_version 0\.0\.0/,
  );
  assert.equal(fs.existsSync(out), false);
});

test("npm pack of the staged wrapper and darwin-arm64 package lists only the release files", async () => {
  assert.equal(process.platform, "darwin");
  assert.equal(process.arch, "arm64");
  const rootPkgPath = path.join(repoRoot, "package.json");
  const beforeRoot = fs.readFileSync(rootPkgPath, "utf8");
  const bendSource = fs.readFileSync(path.join(repoRoot, "src/knot.bend"), "utf8");
  assert.equal(dispatchVersionLiteral(bendSource), "0.0.0");

  const stage = await runProcess(process.execPath, [path.join(repoRoot, "scripts/stage-npm.mjs")], {
    cwd: repoRoot,
  });
  assert.equal(stage.status, 0, stage.stderr);
  assert.equal(fs.readFileSync(rootPkgPath, "utf8"), beforeRoot);

  const rootPkg = JSON.parse(beforeRoot);
  assert.equal(rootPkg.name, "knot");
  assert.equal(rootPkg.version, "0.0.0");
  assert.equal(rootPkg.private, true);
  assert.equal(rootPkg.engines.node, "^24.0.0");
  assert.equal(fs.existsSync(path.join(repoRoot, "LICENSE")), false);

  const outDir = path.join(repoRoot, "release/npm");
  assert.deepEqual(fs.readdirSync(outDir).sort(), ["knot", "knot-darwin-arm64"]);

  const wrapperDir = path.join(outDir, "knot");
  const platformDir = path.join(outDir, "knot-darwin-arm64");
  const wrapper = readJson(path.join(wrapperDir, "package.json"));
  const platform = readJson(path.join(platformDir, "package.json"));
  const binary = path.join(platformDir, "bin/knot");
  const launcher = path.join(wrapperDir, "bin/knot.js");

  assert.equal(fs.readFileSync(launcher, "utf8"), fs.readFileSync(launcherSource, "utf8"));
  assert.equal(fs.readFileSync(launcher, "utf8").startsWith("#!/usr/bin/env node\n"), true);
  assert.equal(wrapper.name, "@scope/knot");
  assert.equal(wrapper.version, "0.0.0");
  assert.equal(platform.name, "@scope/knot-darwin-arm64");
  assert.equal(platform.version, "0.0.0");
  assert.equal(wrapper.description, "Native JavaScript toolchain");
  assert.deepEqual(wrapper.bin, { knot: "bin/knot.js" });
  assert.deepEqual(wrapper.engines, { node: ">=18" });
  assert.equal(wrapper.main, undefined);
  assert.equal(wrapper.exports, undefined);
  assert.equal(wrapper.scripts, undefined);
  assert.equal(wrapper.license, undefined);
  assert.equal(platform.scripts, undefined);
  assert.equal(platform.license, undefined);
  assert.deepEqual(wrapper.optionalDependencies, {
    "@scope/knot-darwin-arm64": "0.0.0",
  });
  assert.deepEqual(platform.os, ["darwin"]);
  assert.deepEqual(platform.cpu, ["arm64"]);
  assert.equal("libc" in platform, false);
  for (const token of platform.os.concat(platform.cpu)) {
    assert.equal(token.startsWith("!"), false);
  }
  assert.equal(fs.existsSync(path.join(wrapperDir, "binding.gyp")), false);
  assert.equal(fs.existsSync(path.join(platformDir, "binding.gyp")), false);
  assert.ok(fs.statSync(binary).mode & 0o111);
  assert.ok(fs.statSync(launcher).mode & 0o111);
  const digest = sha256(binary);
  assert.equal(wrapper.knot.bins["@scope/knot-darwin-arm64"], digest);
  assert.match(digest, /^[0-9a-f]{64}$/);

  const readme = fs.readFileSync(path.join(wrapperDir, "README.md"), "utf8");
  assert.match(readme, /Another global package can own the `knot` bin\./);
  assert.match(readme, /The last install or update wins\./);
  assert.match(readme, /curl/);
  assert.match(readme, /gzip/);
  assert.match(readme, /zlib/);

  const tracked = await runProcess("git", ["ls-files", "--", "release"], { cwd: repoRoot });
  assert.equal(tracked.status, 0, tracked.stderr);
  assert.equal(tracked.stdout, "");

  const wrapperPack = await runProcess("npm", ["pack", "--dry-run", "--json"], { cwd: wrapperDir });
  assert.equal(wrapperPack.status, 0, wrapperPack.stderr);
  const wrapperFiles = JSON.parse(wrapperPack.stdout)[0].files.map((file) => file.path);
  assert.ok(wrapperFiles.includes("package.json"));
  assert.ok(wrapperFiles.includes("bin/knot.js"));
  assert.ok(wrapperFiles.includes("README.md"));
  assertPackedFiles(wrapperFiles);

  const platformPack = await runProcess("npm", ["pack", "--dry-run", "--json"], { cwd: platformDir });
  assert.equal(platformPack.status, 0, platformPack.stderr);
  const packed = JSON.parse(platformPack.stdout)[0];
  const platformFiles = packed.files.map((file) => file.path);
  assert.deepEqual(platformFiles.slice().sort(), ["bin/knot", "package.json"]);
  const packedBin = packed.files.find((file) => file.path === "bin/knot");
  assert.ok(packedBin.mode & 0o111, JSON.stringify(packedBin));
  assertPackedFiles(platformFiles);
});

function assertPackedFiles(files) {
  for (const file of files) {
    assert.equal(file.endsWith(".bend"), false, file);
    assert.equal(file.includes("src/host"), false, file);
    assert.equal(file.split("/").includes("tests"), false, file);
    assert.equal(file.includes("bend"), false, file);
  }
}
