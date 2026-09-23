import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { removeWorkspace } from "./workspace.mjs";

/**
 * Isolates knot's global store (~/.knot) for acceptance tests that assert
 * download / cache behavior. Without this, a warm developer HOME makes the
 * first install skip tarball fetches and fail those assertions.
 */
export class KnotTestHome {
  static async create(t) {
    const home = await mkdtemp(path.join(tmpdir(), "knot-home-"));
    t.after(() => removeWorkspace(home));
    return home;
  }

  static env(home, base = process.env) {
    return { ...base, HOME: home };
  }
}
