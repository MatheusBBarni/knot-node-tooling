#!/usr/bin/env node
"use strict";

const { createRequire } = require("node:module");
const { spawn } = require("node:child_process");
const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const process = require("node:process");

const SCOPE = "@scope";
const MUSL_LOADER = /^ld-musl-.+\.so\.1$/;
const GLIBC_LOADER = /^ld-linux(?:-.+)?\.so(?:\.\d+)?$/;

function platformPackageName(platform, arch, libc) {
  const musl = platform === "linux" && libc === "musl";
  return `${SCOPE}/knot-${platform}-${arch}${musl ? "-musl" : ""}`;
}

function binaryName(platform) {
  return platform === "win32" ? "knot.exe" : "knot";
}

function sha256File(filePath) {
  const hash = crypto.createHash("sha256");
  hash.update(fs.readFileSync(filePath));
  return hash.digest("hex");
}

// Native main reads KNOT_ARG_1..n. bin/knot uses the same numbering.
function userArgEnv(argv) {
  const user = argv.slice(2);
  const env = { KNOT_ARGC: String(user.length) };
  for (let i = 0; i < user.length; i += 1) {
    env[`KNOT_ARG_${i + 1}`] = user[i];
  }
  return env;
}

function readLoaderNames(dir) {
  try {
    return fs.readdirSync(dir);
  } catch (error) {
    if (error && error.code === "ENOENT") {
      return [];
    }
    throw error;
  }
}

function classifyLoaders(dir, names) {
  const musl = [];
  const glibc = [];
  for (const name of names.slice().sort()) {
    if (MUSL_LOADER.test(name)) {
      musl.push(path.join(dir, name));
    } else if (GLIBC_LOADER.test(name)) {
      glibc.push(path.join(dir, name));
    }
  }
  return { musl, glibc };
}

function decideLibc(classified) {
  if (classified.musl.length > 0 && classified.glibc.length > 0) {
    return {
      conflict: true,
      paths: classified.musl.concat(classified.glibc),
    };
  }
  if (classified.musl.length > 0) {
    return { conflict: false, libc: "musl", paths: classified.musl };
  }
  return { conflict: false, libc: "glibc", paths: classified.glibc };
}

function hostSelection() {
  return {
    platform: process.env.KNOT_PLATFORM || process.platform,
    arch: process.env.KNOT_ARCH || process.arch,
    libDir: path.resolve(process.env.KNOT_LIB_DIR || "/lib"),
  };
}

function failMissing(packageName, platform, arch) {
  process.stderr.write(`knot: package not found: ${packageName} (${platform} ${arch})\n`);
  process.exit(127);
}

function wrapperBin(packageName) {
  const wrapperPath = path.join(path.dirname(__filename), "..", "package.json");
  const wrapper = JSON.parse(fs.readFileSync(wrapperPath, "utf8"));
  const bins = wrapper.knot && wrapper.knot.bins;
  const expected = bins && bins[packageName];
  return typeof expected === "string" ? expected : "";
}

function childEnvironment(argv) {
  const env = { ...process.env };
  for (const key of Object.keys(env)) {
    if (key === "KNOT_ARGC" || /^KNOT_ARG_\d+$/.test(key)) {
      delete env[key];
    }
  }
  return Object.assign(env, userArgEnv(argv));
}

function signalStatus(signal) {
  const number = os.constants.signals[signal];
  return number ? 128 + number : 1;
}

function main() {
  const { platform, arch, libDir } = hostSelection();
  let libc = null;
  if (platform === "linux") {
    const decision = decideLibc(classifyLoaders(libDir, readLoaderNames(libDir)));
    if (decision.conflict) {
      process.stderr.write(
        `knot: both musl and glibc loaders are present: ${decision.paths.join(" ")}\n`,
      );
      process.exit(1);
    }
    libc = decision.libc;
  }

  const packageName = platformPackageName(platform, arch, libc);
  const requireFromLauncher = createRequire(__filename);
  let manifestPath;
  try {
    manifestPath = requireFromLauncher.resolve(`${packageName}/package.json`);
  } catch {
    failMissing(packageName, platform, arch);
  }

  let expected;
  try {
    expected = wrapperBin(packageName);
  } catch {
    failMissing(packageName, platform, arch);
  }
  if (!expected) {
    failMissing(packageName, platform, arch);
  }

  const binaryPath = path.join(path.dirname(manifestPath), "bin", binaryName(platform));
  if (!fs.existsSync(binaryPath)) {
    failMissing(packageName, platform, arch);
  }

  let digest;
  try {
    digest = sha256File(binaryPath);
  } catch {
    process.stderr.write("knot: binary integrity check failed\n");
    process.exit(1);
  }
  if (digest !== expected.toLowerCase()) {
    process.stderr.write("knot: binary integrity check failed\n");
    process.exit(1);
  }

  let child;
  const forward = (signal) => {
    if (child && child.exitCode === null && child.signalCode === null) {
      child.kill(signal);
    }
  };
  process.on("SIGINT", () => forward("SIGINT"));
  process.on("SIGTERM", () => forward("SIGTERM"));
  process.on("SIGHUP", () => forward("SIGHUP"));

  child = spawn(binaryPath, [], {
    env: childEnvironment(process.argv),
    stdio: "inherit",
  });

  child.on("error", () => {
    failMissing(packageName, platform, arch);
  });
  child.on("exit", (code, signal) => {
    if (signal) {
      process.exit(signalStatus(signal));
    }
    process.exit(code === null ? 1 : code);
  });
}

if (require.main === module) {
  main();
}

module.exports = {
  SCOPE,
  platformPackageName,
  binaryName,
  sha256File,
  userArgEnv,
  readLoaderNames,
  classifyLoaders,
  decideLibc,
  signalStatus,
};
