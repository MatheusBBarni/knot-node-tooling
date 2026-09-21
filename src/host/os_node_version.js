function os_node_version() {
  const { execFileSync } = require("child_process");
  try {
    let s = execFileSync("node", ["-v"], { encoding: "utf8" }).trim();
    if (s.startsWith("v")) {
      s = s.slice(1);
    }
    return io_done(s);
  } catch (e) {
    return io_fail(1);
  }
}
