import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const {
  SCOPE,
  platformPackageName,
  binaryName,
  sha256File,
  readLoaderNames,
  classifyLoaders,
  decideLibc,
} = require("../packaging/npm/knot.cjs");

const REPOSITORY = {
  type: "git",
  url: "git+https://github.com/MatheusBBarni/knot-node-tooling.git",
};

export function dispatchVersionLiteral(source) {
  const start = source.indexOf("def dispatch_version");
  if (start < 0) {
    throw new Error("dispatch_version not found");
  }
  const next = source.indexOf("\ndef ", start + 1);
  const body = source.slice(start, next === -1 ? source.length : next);
  const match = body.match(/IO\.print\("([^"]*)"\)/);
  if (!match) {
    throw new Error("dispatch_version literal not found");
  }
  return match[1];
}

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

function hostTarget(rootDir) {
  const platform = process.platform;
  const arch = process.arch;
  let libc = null;
  if (platform === "linux") {
    const libDir = "/lib";
    const decision = decideLibc(classifyLoaders(libDir, readLoaderNames(libDir)));
    if (decision.conflict) {
      throw new Error(`both musl and glibc loaders are present: ${decision.paths.join(" ")}`);
    }
    libc = decision.libc;
  }
  return {
    platform,
    arch,
    libc,
    binaryPath: path.join(rootDir, "dist", "knot.bin"),
  };
}

function platformFolder(name) {
  const slash = name.indexOf("/");
  return name.slice(slash + 1);
}

export function stageNpmRelease({ rootDir, outDir, targets } = {}) {
  const rootPkg = JSON.parse(fs.readFileSync(path.join(rootDir, "package.json"), "utf8"));
  const bendSource = fs.readFileSync(path.join(rootDir, "src", "knot.bend"), "utf8");
  const bendVersion = dispatchVersionLiteral(bendSource);
  if (rootPkg.version !== bendVersion) {
    throw new Error(
      `staged version ${rootPkg.version} does not match dispatch_version ${bendVersion}`,
    );
  }

  const version = rootPkg.version;
  const chosen = (targets ?? [hostTarget(rootDir)]).slice().sort((left, right) => {
    return platformPackageName(left.platform, left.arch, left.libc).localeCompare(
      platformPackageName(right.platform, right.arch, right.libc),
    );
  });

  for (const target of chosen) {
    if (!fs.existsSync(target.binaryPath)) {
      throw new Error(`native binary missing: ${target.binaryPath}`);
    }
    if (target.platform === "linux" && target.libc !== "glibc" && target.libc !== "musl") {
      throw new Error(`linux target ${target.arch} is missing libc`);
    }
  }

  fs.rmSync(outDir, { recursive: true, force: true });
  const wrapperDir = path.join(outDir, "knot");
  fs.mkdirSync(path.join(wrapperDir, "bin"), { recursive: true });
  const launcherDest = path.join(wrapperDir, "bin", "knot.js");
  fs.copyFileSync(path.join(rootDir, "packaging", "npm", "knot.cjs"), launcherDest);
  fs.chmodSync(launcherDest, 0o755);
  fs.copyFileSync(
    path.join(rootDir, "packaging", "npm", "README.md"),
    path.join(wrapperDir, "README.md"),
  );

  const optionalDependencies = {};
  const bins = {};
  for (const target of chosen) {
    const name = platformPackageName(target.platform, target.arch, target.libc);
    const platformDir = path.join(outDir, platformFolder(name));
    fs.mkdirSync(path.join(platformDir, "bin"), { recursive: true });
    const binaryDest = path.join(platformDir, "bin", binaryName(target.platform));
    fs.copyFileSync(target.binaryPath, binaryDest);
    fs.chmodSync(binaryDest, 0o755);
    const musl = target.platform === "linux" && target.libc === "musl";
    const triple = musl
      ? `${target.platform}-${target.arch}-musl`
      : `${target.platform}-${target.arch}`;
    const platformPkg = {
      name,
      version,
      description: `knot binary for ${triple}`,
      repository: REPOSITORY,
      os: [target.platform],
      cpu: [target.arch],
    };
    if (target.platform === "linux") {
      platformPkg.libc = [target.libc];
    }
    writeJson(path.join(platformDir, "package.json"), platformPkg);
    optionalDependencies[name] = version;
    bins[name] = sha256File(binaryDest);
  }

  writeJson(path.join(wrapperDir, "package.json"), {
    name: `${SCOPE}/knot`,
    version,
    description: "Native JavaScript toolchain",
    repository: REPOSITORY,
    bin: {
      knot: "bin/knot.js",
    },
    engines: {
      node: ">=18",
    },
    optionalDependencies,
    knot: {
      bins,
    },
  });
}

const invokedDirectly = process.argv[1]
  && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url));

if (invokedDirectly) {
  const here = path.dirname(fileURLToPath(import.meta.url));
  try {
    stageNpmRelease({
      rootDir: path.resolve(here, ".."),
      outDir: path.resolve(here, "../release/npm"),
    });
  } catch (error) {
    process.stderr.write(`knot: ${error.message}\n`);
    process.exit(1);
  }
}
