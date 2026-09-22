import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const { sha256File } = require("../packaging/npm/knot.cjs");

function packageFolder(name) {
  const slash = name.indexOf("/");
  return name.slice(slash + 1);
}

export function writeReleaseAssets({ stageDir, outDir }) {
  const wrapper = JSON.parse(fs.readFileSync(path.join(stageDir, "knot", "package.json"), "utf8"));
  const bins = wrapper.knot && wrapper.knot.bins;
  if (!bins || Object.keys(bins).length === 0) {
    throw new Error("knot.bins is empty");
  }

  fs.rmSync(outDir, { recursive: true, force: true });
  fs.mkdirSync(outDir, { recursive: true });

  const lines = [];
  const assets = [];
  for (const packageName of Object.keys(bins).sort()) {
    const folder = packageFolder(packageName);
    const pkg = JSON.parse(fs.readFileSync(path.join(stageDir, folder, "package.json"), "utf8"));
    if (pkg.name !== packageName) {
      throw new Error(`staged package ${pkg.name} does not match ${packageName}`);
    }
    const exe = path.join(stageDir, folder, "bin", "knot.exe");
    const unix = path.join(stageDir, folder, "bin", "knot");
    const source = fs.existsSync(exe) ? exe : unix;
    if (!fs.existsSync(source)) {
      throw new Error(`packed binary missing for ${packageName}`);
    }
    const digest = sha256File(source);
    if (digest !== String(bins[packageName]).toLowerCase()) {
      throw new Error(`checksum mismatch for ${packageName}`);
    }
    const assetName = path.basename(source) === "knot.exe" ? `${folder}.exe` : folder;
    const dest = path.join(outDir, assetName);
    fs.copyFileSync(source, dest);
    fs.chmodSync(dest, 0o755);
    lines.push(`${digest}  ${assetName}`);
    assets.push(assetName);
  }

  assets.push("SHA256SUMS");
  assets.sort();
  lines.sort();
  fs.writeFileSync(path.join(outDir, "SHA256SUMS"), `${lines.join("\n")}\n`);
  fs.writeFileSync(path.join(outDir, "assets.txt"), `${assets.join("\n")}\n`);
  fs.writeFileSync(path.join(outDir, "NOTES.md"), [
    `Package version ${wrapper.version}.`,
    "npm packages for this tag are staged.",
    "A maintainer publishes them with `npm stage approve`.",
    "",
    "The binary assets are the files packed into the platform tarballs.",
    "SHA256SUMS is the SHA-256 of those files.",
    "",
  ].join("\n"));
}

const invokedDirectly = process.argv[1]
  && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url));

if (invokedDirectly) {
  const here = path.dirname(fileURLToPath(import.meta.url));
  try {
    writeReleaseAssets({
      stageDir: path.resolve(here, "../release/npm"),
      outDir: path.resolve(here, "../release/assets"),
    });
  } catch (error) {
    process.stderr.write(`knot: ${error.message}\n`);
    process.exit(1);
  }
}
