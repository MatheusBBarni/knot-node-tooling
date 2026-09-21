function json_query(text, path, mode) {
  try {
    let cur = JSON.parse(text);
    if (path.length > 0) {
      for (const key of path.split("/")) {
        if (cur == null || typeof cur !== "object" || !(key in cur)) {
          return io_fail(2);
        }
        cur = cur[key];
      }
    }
    if (mode === "string") {
      if (typeof cur !== "string") {
        return io_fail(2);
      }
      return io_done(cur);
    }
    if (mode === "pairs") {
      if (cur == null || typeof cur !== "object") {
        return io_fail(2);
      }
      const lines = Object.entries(cur).map(([k, v]) => `${k}\t${v}`);
      return io_done(lines.join("\n"));
    }
    if (mode === "keys") {
      if (cur == null || typeof cur !== "object") {
        return io_fail(2);
      }
      return io_done(Object.keys(cur).join("\n"));
    }
    if (mode === "lines") {
      if (!Array.isArray(cur)) {
        return io_fail(2);
      }
      return io_done(cur.join("\n"));
    }
    return io_fail(22);

  } catch {
    return io_fail(22);
  }
}
