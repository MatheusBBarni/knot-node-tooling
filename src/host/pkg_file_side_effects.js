function pkg_file_side_effects(path) {
  try {
    const { spawnSync } = require("child_process");
    const root = process.env.KNOT_ROOT;
    if (!root) return io_fail(22);
    const r = spawnSync(
      process.execPath,
      [`${root}/scripts/pkg-exports.mjs`, "fileSideEffects", path || "."],
      { encoding: "utf8" },
    );
    if (r.status !== 0) return io_fail(22);
    return io_done(r.stdout);
  } catch (e) {
    return io_fail(22);
  }
}
