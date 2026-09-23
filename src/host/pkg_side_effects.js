function pkg_side_effects(text, rel) {
  try {
    const { spawnSync } = require("child_process");
    const root = process.env.KNOT_ROOT;
    if (!root) return io_fail(22);
    const r = spawnSync(
      process.execPath,
      [`${root}/scripts/pkg-exports.mjs`, "sideEffects", rel || "."],
      { input: text, encoding: "utf8" },
    );
    if (r.status !== 0) return io_fail(22);
    return io_done(r.stdout);
  } catch (e) {
    return io_fail(22);
  }
}
