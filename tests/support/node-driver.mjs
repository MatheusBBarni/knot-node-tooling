/**
 * Acceptance tests must drive nested Node.js (`node --test`, `--input-type=module`).
 * Under `bun test`, `process.execPath` is Bun and `bun --test` is not Node's runner.
 */
export class KnotNodeDriver {
  static binary() {
    if (process.env.KNOT_NODE) {
      return process.env.KNOT_NODE;
    }
    if (process.versions.bun) {
      return "node";
    }
    return process.execPath;
  }
}
