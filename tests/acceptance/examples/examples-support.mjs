import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { runProcess } from "../../support/process.mjs";
import { makeWorkspace, removeWorkspace } from "../../support/workspace.mjs";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const examplesRoot = path.join(repoRoot, "examples");
const knot = process.env.KNOT ?? path.join(repoRoot, "bin/knot");

const SOURCE_EXTS = new Set([".ts", ".tsx"]);

export class ExampleFixture {
  static get repoRoot() {
    return repoRoot;
  }

  static get knot() {
    return knot;
  }

  static exampleDir(name) {
    return path.join(examplesRoot, name);
  }

  /** Copy .ts/.tsx (and package.json if present) from examples/<name> into a temp workspace. */
  static async stage(name) {
    const srcDir = ExampleFixture.exampleDir(name);
    const entries = await readdir(srcDir, { withFileTypes: true });
    const files = {
      "package.json": JSON.stringify({ name: `example-${name}`, type: "module" }),
    };

    for (const entry of entries) {
      if (!entry.isFile()) continue;
      const ext = path.extname(entry.name);
      if (SOURCE_EXTS.has(ext) || entry.name === "package.json") {
        files[entry.name] = await readFile(path.join(srcDir, entry.name), "utf8");
      }
    }

    return makeWorkspace(files);
  }

  static async remove(workspace) {
    await removeWorkspace(workspace);
  }

  static async transpile(workspace, entry, extraArgs = []) {
    return runProcess(knot, ["transpile", ...extraArgs, entry], { cwd: workspace });
  }

  static async analyze(workspace, entry) {
    return runProcess(knot, ["analyze", entry], { cwd: workspace });
  }

  static async readJs(workspace, entry) {
    const base = entry.replace(/\.(tsx?|jsx?)$/, "");
    return readFile(path.join(workspace, `${base}.js`), "utf8");
  }

  static async readMap(workspace, entry) {
    const base = entry.replace(/\.(tsx?|jsx?)$/, "");
    return readFile(path.join(workspace, `${base}.js.map`), "utf8");
  }

  static async runNode(workspace, scriptRel) {
    return runProcess(process.execPath, [scriptRel], { cwd: workspace });
  }
}
