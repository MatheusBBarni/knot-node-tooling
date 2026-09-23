import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";
import { stageNpmRelease } from "../../../scripts/stage-npm.mjs";
import { KnotNodeDriver } from "../../support/node-driver.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");

async function packTarball(dir, dest) {
  const result = await runProcess("npm", ["pack", "--json", "--pack-destination", dest], {
    cwd: dir,
  });
  assert.equal(result.status, 0, result.stderr);
  const info = JSON.parse(result.stdout)[0];
  return path.join(dest, info.filename);
}

function replaceByte(file) {
  const bytes = fs.readFileSync(file);
  const flipped = Buffer.from(bytes);
  flipped[0] ^= 0xff;
  const stat = fs.lstatSync(file);
  if (stat.nlink > 1) {
    fs.rmSync(file);
    fs.writeFileSync(file, flipped, { mode: 0o755 });
  } else {
    fs.chmodSync(file, 0o644);
    fs.writeFileSync(file, flipped);
    fs.chmodSync(file, 0o755);
  }
}

test("npm install of the staged tarballs runs the packed knot binary", { timeout: 180_000 }, async () => {
  assert.equal(process.platform, "darwin");
  assert.equal(process.arch, "arm64");
  const rootPkg = JSON.parse(fs.readFileSync(path.join(repoRoot, "package.json"), "utf8"));
  assert.equal(rootPkg.version, "0.0.0");

  const out = fs.mkdtempSync(path.join(os.tmpdir(), "knot-stage-"));
  const packs = fs.mkdtempSync(path.join(os.tmpdir(), "knot-pack-"));
  const project = fs.mkdtempSync(path.join(os.tmpdir(), "knot-inst-"));
  stageNpmRelease({ rootDir: repoRoot, outDir: out });
  const wrapperTgz = await packTarball(path.join(out, "knot"), packs);
  const platformTgz = await packTarball(path.join(out, "knot-darwin-arm64"), packs);

  const install = await runProcess("npm", [
    "install",
    "--ignore-scripts",
    "--no-audit",
    "--no-fund",
    "--no-package-lock",
    wrapperTgz,
    platformTgz,
  ], { cwd: project, timeoutMs: 120_000 });
  assert.equal(install.status, 0, `${install.stdout}\n${install.stderr}`);

  const knot = path.join(project, "node_modules/.bin/knot");
  const first = await runProcess(knot, ["--version"], { cwd: project });
  const second = await runProcess(knot, ["--version"], { cwd: project });
  assert.equal(first.status, 0, first.stderr);
  assert.equal(first.stdout, "0.0.0\n");
  assert.equal(second.status, 0, second.stderr);
  assert.equal(second.stdout, first.stdout);
  assert.equal(second.stderr, first.stderr);

  const onePackage = await runProcess(KnotNodeDriver.binary(), [
    "--test",
    path.join(repoRoot, "tests/acceptance/package-manager/install-one-package.test.mjs"),
  ], {
    cwd: repoRoot,
    env: { ...process.env, KNOT: knot },
    timeoutMs: 120_000,
  });
  assert.equal(onePackage.status, 0, `${onePackage.stdout}\n${onePackage.stderr}`);

  const binary = path.join(project, "node_modules/@scope/knot-darwin-arm64/bin/knot");
  replaceByte(binary);
  const tampered = await runProcess(knot, ["--version"], { cwd: project });
  assert.equal(tampered.status, 1);
  assert.equal(tampered.stderr, "knot: binary integrity check failed\n");
  assert.equal(tampered.stdout, "");

  fs.rmSync(path.join(project, "node_modules/@scope/knot-darwin-arm64"), {
    recursive: true,
    force: true,
  });
  const missing = await runProcess(knot, ["--version"], { cwd: project });
  assert.equal(missing.status, 127);
  assert.match(missing.stderr, /@scope\/knot-darwin-arm64/);
  assert.match(missing.stderr, /darwin/);
  assert.match(missing.stderr, /arm64/);
});
