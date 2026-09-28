function os_exec_many(cmd, args, cwd) {
  const { spawnSync } = require("child_process");
  try {
    const argv = args ? args.split("\n") : [];
    const r = spawnSync(cmd, argv, { cwd, encoding: "utf8" });
    if (r.status === 0) {
      return io_done("0");
    }
    return io_done(String(r.status == null ? 1 : r.status));
  } catch {
    return io_done("127");
  }
}
