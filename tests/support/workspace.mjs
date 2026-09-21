import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";

export async function makeWorkspace(files) {
  const dir = await mkdtemp(path.join(os.tmpdir(), "knot-ws-"));
  for (const [rel, content] of Object.entries(files)) {
    const dest = path.join(dir, rel);
    await mkdir(path.dirname(dest), { recursive: true });
    await writeFile(dest, content);
  }
  return dir;
}

export async function removeWorkspace(dir) {
  await rm(dir, { recursive: true, force: true });
}
