function os_exec(cmd, arg, cwd) {
  const { spawnSync } = require("child_process");
  try {
    const r = spawnSync(cmd, [arg], { cwd, encoding: "utf8" });
    if (r.status === 0) {
      return io_done({ $: "Unit" });
    }
    return io_fail(r.status == null ? 1 : r.status);
  } catch (e) {
    return io_fail(-e.errno);
  }
}
