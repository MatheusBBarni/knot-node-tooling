import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { runProcess } from "../../support/process.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const helloFixture = path.join(repoRoot, "tests/fixtures/bend/hello.bend");
const falseProofFixture = path.join(repoRoot, "tests/fixtures/bend/false-proof.bend");
const pinPath = path.join(repoRoot, "toolchain.json");
const ccWrapper = path.join(repoRoot, "scripts/cc");

test("pinned Bend toolchain checks a valid program, rejects a false proof, and runs a CPU binary", async (t) => {
  if (process.versions.bun) {
    assert.fail(
      `bun test is not the acceptance driver (Bun reports process.versions.node=${process.versions.node}); use Node.js 24 LTS with node --test`,
    );
  }
  const nodeMajor = Number(process.versions.node.split(".")[0]);
  assert.equal(nodeMajor, 24, `Node.js 24 LTS is the acceptance driver, found ${process.versions.node}`);

  const pin = JSON.parse(await readFile(pinPath, "utf8"));
  const env = {
    ...process.env,
    BEND_NO_TELEMETRY: "1",
    CC: ccWrapper,
    PATH: [
      path.join(os.homedir(), ".bend", "bin"),
      process.env.PATH ?? "",
    ].join(path.delimiter),
  };

  const version = await runProcess("bend", ["version"], { env, cwd: repoRoot });
  assert.equal(version.status, 0, version.stderr);
  assert.equal(version.stdout, `bend ${pin.bend.version}\n`);

  const hello = await runProcess("bend", [helloFixture], { env, cwd: repoRoot });
  assert.equal(hello.status, 0, hello.stderr);
  assert.equal(hello.stdout, "ok\n");

  const falseProof = await runProcess("bend", [falseProofFixture], { env, cwd: repoRoot });
  assert.notEqual(falseProof.status, 0);
  assert.match(falseProof.stderr, /Error:/);

  const work = await mkdtemp(path.join(os.tmpdir(), "knot-bend-gate-"));
  t.after(async () => {
    await rm(work, { recursive: true, force: true });
  });
  const binary = path.join(work, "hello");
  const build = await runProcess("bend", [helloFixture, "-o", binary], {
    env,
    cwd: repoRoot,
    timeoutMs: 60_000,
  });
  assert.equal(build.status, 0, build.stderr);
  const native = await runProcess(binary, [], { env, cwd: work });
  assert.equal(native.status, 0, native.stderr);
  assert.equal(native.stdout, "ok\n");
});
