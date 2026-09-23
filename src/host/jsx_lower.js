function jsx_lower(source, mode, factory, fragment, import_source) {
  try {
    const { spawnSync } = require("child_process");
    const root = process.env.KNOT_ROOT;
    if (!root) return io_fail(22);
    const r = spawnSync(
      process.execPath,
      [
        `${root}/scripts/jsx-lower.mjs`,
        mode || "classic",
        factory || "React.createElement",
        fragment || "React.Fragment",
        import_source || "react",
      ],
      { input: source, encoding: "utf8" },
    );
    if (r.status !== 0) return io_fail(22);
    return io_done(r.stdout);
  } catch (e) {
    return io_fail(22);
  }
}
