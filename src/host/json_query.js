function validate_data_json(text) {
  let index = 0;
  let nodes = 0;
  const numberPattern = /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/y;
  const space = () => {
    while (index < text.length && /[ \t\r\n]/.test(text[index])) index++;
  };
  const string = () => {
    const start = index++;
    if (text[start] !== '"') throw new SyntaxError("JSON string expected");
    while (index < text.length) {
      const char = text[index++];
      if (char === '"') {
        const decoded = JSON.parse(text.slice(start, index));
        for (let at = 0; at < decoded.length; at++) {
          const code = decoded.charCodeAt(at);
          if (code >= 0xd800 && code <= 0xdbff) {
            if (++at >= decoded.length || decoded.charCodeAt(at) < 0xdc00 || decoded.charCodeAt(at) > 0xdfff) {
              throw new SyntaxError("Unpaired JSON surrogate");
            }
          } else if (code >= 0xdc00 && code <= 0xdfff) {
            throw new SyntaxError("Unpaired JSON surrogate");
          }
        }
        return decoded;
      }
      if (char === "\\") index++;
      if (index > text.length) throw new SyntaxError("Unterminated JSON string");
    }
    throw new SyntaxError("Unterminated JSON string");
  };
  const value = (depth) => {
    space();
    if (depth > 128 || ++nodes > 1000000) throw new RangeError("resource_limit");
    const char = text[index];
    if (char === "{") {
      index++;
      space();
      if (text[index] === "}") { index++; return; }
      const keys = new Set();
      for (;;) {
        const key = string();
        if (keys.has(key)) throw new Error("duplicate_key");
        keys.add(key);
        space();
        if (text[index++] !== ":") throw new SyntaxError("JSON colon expected");
        value(depth + 1);
        space();
        const delimiter = text[index++];
        if (delimiter === "}") return;
        if (delimiter !== ",") throw new SyntaxError("JSON object delimiter expected");
        space();
      }
    }
    if (char === "[") {
      index++;
      space();
      if (text[index] === "]") { index++; return; }
      for (;;) {
        value(depth + 1);
        space();
        const delimiter = text[index++];
        if (delimiter === "]") return;
        if (delimiter !== ",") throw new SyntaxError("JSON array delimiter expected");
      }
    }
    if (char === '"') { string(); return; }
    if (char === "t" && text.startsWith("true", index)) { index += 4; return; }
    if (char === "f" && text.startsWith("false", index)) { index += 5; return; }
    if (char === "n" && text.startsWith("null", index)) { index += 4; return; }
    numberPattern.lastIndex = index;
    const match = numberPattern.exec(text);
    if (!match) throw new SyntaxError("JSON value expected");
    index += match[0].length;
    if (!Number.isFinite(Number(match[0])) ||
        (!/[.eE]/.test(match[0]) && !Number.isSafeInteger(Number(match[0])))) {
      throw new RangeError("data_number");
    }
  };
  try {
    value(0);
    space();
    return index === text.length ? "ok" : "syntax_error";
  } catch (error) {
    return error.message === "duplicate_key" ? "duplicate_key" :
      error.message === "data_number" || error.message === "resource_limit" ? error.message : "syntax_error";
  }
}

function normalize_jsonc(text) {
  const out = text.split("");
  let quoted = false;
  for (let i = 0; i < out.length; i++) {
    const char = out[i];
    if (quoted) {
      if (char === "\\") i++;
      else if (char === '"') quoted = false;
      continue;
    }
    if (char === '"') { quoted = true; continue; }
    if (char === "/" && text[i + 1] === "/") {
      out[i++] = " "; out[i] = " ";
      while (i + 1 < out.length && text[i + 1] !== "\n" && text[i + 1] !== "\r") out[++i] = " ";
      continue;
    }
    if (char === "/" && text[i + 1] === "*") {
      out[i++] = " "; out[i] = " ";
      let closed = false;
      while (i + 1 < out.length) {
        if (text[i + 1] === "*" && text[i + 2] === "/") {
          out[++i] = " "; out[++i] = " "; closed = true; break;
        }
        i++;
        out[i] = text[i] === "\n" || text[i] === "\r" ? text[i] : " ";
      }
      if (!closed) return "ERR:syntax_error";
    }
  }
  quoted = false;
  for (let i = 0; i < out.length; i++) {
    if (quoted) {
      if (out[i] === "\\") i++;
      else if (out[i] === '"') quoted = false;
      continue;
    }
    if (out[i] === '"') { quoted = true; continue; }
    if (out[i] !== ",") continue;
    let next = i + 1;
    while (next < out.length && /[ \t\r\n]/.test(out[next])) next++;
    if (out[next] === "}" || out[next] === "]") out[i] = " ";
  }
  const result = out.join("");
  const status = validate_data_json(result);
  return status === "ok" ? "OK\n" + result : "ERR:" + status;
}

function json_query(text, path, mode) {
  try {
    if (mode === "validate") return io_done(validate_data_json(text));
    if (mode === "normalize_jsonc") return io_done(normalize_jsonc(text));
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
