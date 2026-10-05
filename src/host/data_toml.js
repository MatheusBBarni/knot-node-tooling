/* TOML 1.0 to JSON. Parse into a tagged tree so table declarations cannot
 * accidentally reopen dotted keys, inline tables, or ordinary arrays. */
function knot_data_toml_json(text) {
  let i = 0, nodes = 0;
  const fail = (code = "syntax_error") => { throw new Error(code); };
  const make = (kind, depth, extra = {}) => {
    if (depth > 128 || ++nodes > 1000000) fail("resource_limit");
    return { kind, depth, ...extra };
  };
  const table = (depth, mode) => make("table", depth, { mode, entries: new Map() });
  const root = table(0, "root");
  const hspace = () => { while (text[i] === " " || text[i] === "\t") i++; };
  const newline = () => {
    if (text[i] === "\r") { if (text[i + 1] !== "\n") fail(); i += 2; return true; }
    if (text[i] === "\n") { i++; return true; }
    return false;
  };
  const comment = () => {
    if (text[i] !== "#") return;
    i++;
    while (i < text.length && text[i] !== "\r" && text[i] !== "\n") {
      const c = text.charCodeAt(i++);
      if (c < 32 && c !== 9 || c === 127) fail();
    }
  };
  const arraySpace = () => {
    while (i < text.length) {
      hspace();
      if (text[i] === "#") { comment(); continue; }
      if (newline()) continue;
      break;
    }
  };
  const codepoint = (digits) => {
    const piece = text.slice(i, i + digits);
    if (!new RegExp(`^[0-9a-fA-F]{${digits}}$`).test(piece)) fail();
    i += digits;
    const n = parseInt(piece, 16);
    if (n > 0x10ffff || n >= 0xd800 && n <= 0xdfff) fail();
    return String.fromCodePoint(n);
  };
  const string = () => {
    const quote = text[i++];
    const multi = text[i] === quote && text[i + 1] === quote;
    if (multi) i += 2;
    if (multi) newline();
    let result = "";
    while (i < text.length) {
      const ch = text[i++];
      if (ch === quote) {
        if (!multi) return result;
        if (text[i] === quote && text[i + 1] === quote) {
          i += 2;
          for (let n = 0; n < 2 && text[i] === quote; n++, i++) result += quote;
          if (text[i] === quote) fail();
          return result;
        }
        result += ch;
        continue;
      }
      const cp = ch.charCodeAt(0);
      if (cp === 127 || cp < 32 && cp !== 9 && !(multi && (cp === 10 || cp === 13))) fail();
      if (ch === "\r" && (!multi || text[i] !== "\n")) fail();
      if (ch === "\n" && !multi) fail();
      if (ch !== "\\" || quote === "'") { result += ch; continue; }
      const escaped = text[i++];
      const escapes = { b: "\b", t: "\t", n: "\n", f: "\f", r: "\r", '"': '"', "\\": "\\" };
      if (Object.hasOwn(escapes, escaped)) { result += escapes[escaped]; continue; }
      if (escaped === "u" || escaped === "U") { result += codepoint(escaped === "u" ? 4 : 8); continue; }
      if (multi && (escaped === " " || escaped === "\t" || escaped === "\r" || escaped === "\n")) {
        i--;
        while (text[i] === " " || text[i] === "\t") i++;
        if (!newline()) fail();
        while (text[i] === " " || text[i] === "\t" || text[i] === "\r" || text[i] === "\n") {
          if (text[i] === "\r" || text[i] === "\n") newline(); else i++;
        }
        continue;
      }
      fail();
    }
    fail();
  };
  const key = () => {
    hspace();
    if (text[i] === '"' || text[i] === "'") {
      if (text[i + 1] === text[i] && text[i + 2] === text[i]) fail();
      return string();
    }
    const start = i;
    while (i < text.length && /[A-Za-z0-9_-]/.test(text[i])) i++;
    if (start === i) fail();
    return text.slice(start, i);
  };
  const path = () => {
    const parts = [key()];
    hspace();
    while (text[i] === ".") { i++; parts.push(key()); hspace(); if (parts.length > 128) fail("resource_limit"); }
    return parts;
  };
  const descend = (parent, name, header) => {
    let child = parent.entries.get(name);
    if (!child) { child = table(parent.depth + 1, header ? "implicit" : "dotted"); parent.entries.set(name, child); }
    if (child.kind === "array" && child.aot && header) child = child.items[child.items.length - 1];
    if (child.kind !== "table" || child.mode === "inline") fail("duplicate_key");
    return child;
  };
  const days = (y, m) => m === 2 ? (y % 4 === 0 && (y % 100 !== 0 || y % 400 === 0) ? 29 : 28) : [4, 6, 9, 11].includes(m) ? 30 : 31;
  const date = (token) => {
    const match = /^(?:(\d{4})-(\d{2})-(\d{2}))?(?:([Tt ])?(\d{2}):(\d{2}):(\d{2})(\.\d+)?([Zz]|[+-]\d{2}:\d{2})?)?$/.exec(token);
    if (!match || !match[1] && !match[5] || !!match[1] !== !!match[4] && !!match[5] || match[4] && !match[5] || !match[1] && match[9]) return null;
    const [, year, month, day, separator, hour, minute, second, fraction, zone] = match;
    if (year && (+month < 1 || +month > 12 || +day < 1 || +day > days(+year, +month))) fail();
    if (hour && (+hour > 23 || +minute > 59 || +second > 59)) fail();
    if (zone && zone.length > 1 && (+zone.slice(1, 3) > 23 || +zone.slice(4) > 59)) fail();
    return (year ? `${year}-${month}-${day}` : "") + (separator ? "T" : "") +
      (hour ? `${hour}:${minute}:${second}${fraction || ""}` : "") + (zone ? zone.toUpperCase() : "");
  };
  const integerPattern = /^[+-]?(?:0|[1-9](?:_?[0-9])*)$/;
  const floatPattern = /^[+-]?(?:0|[1-9](?:_?[0-9])*)(?:\.[0-9](?:_?[0-9])*(?:[eE][+-]?[0-9](?:_?[0-9])*)?|[eE][+-]?[0-9](?:_?[0-9])*)$/;
  const digitsValue = (token, start, base) => {
    let value = 0;
    for (let j = start; j < token.length; j++) {
      if (token[j] === "_") continue;
      const digit = parseInt(token[j], base);
      if (value > (Number.MAX_SAFE_INTEGER - digit) / base) fail("data_number");
      value = value * base + digit;
    }
    return value;
  };
  const scalar = (token) => {
    if (token === "true" || token === "false") return token === "true";
    if (/^[+-]?(?:inf|nan)$/.test(token)) fail("data_number");
    if (/^(?:0x[0-9a-fA-F](?:_?[0-9a-fA-F])*|0o[0-7](?:_?[0-7])*|0b[01](?:_?[01])*)$/.test(token)) {
      const base = token[1] === "x" ? 16 : token[1] === "o" ? 8 : 2;
      return digitsValue(token, 2, base);
    }
    if (integerPattern.test(token)) {
      const start = token[0] === "+" || token[0] === "-" ? 1 : 0;
      const value = digitsValue(token, start, 10);
      return token[0] === "-" ? -value : value;
    }
    if (floatPattern.test(token)) {
      const value = Number(token.replaceAll("_", ""));
      if (!Number.isFinite(value)) fail("data_number");
      return value;
    }
    if (/^\d{4}-\d{2}-\d{2}(?:[Tt ]|$)|^\d{2}:\d{2}:\d{2}/.test(token)) {
      const normalized = date(token);
      if (normalized !== null) return normalized;
    }
    fail();
  };
  const value = (depth) => {
    if (depth > 128) fail("resource_limit");
    const ch = text[i];
    if (ch === '"' || ch === "'") return make("scalar", depth, { value: string() });
    if (ch === "[") {
      i++;
      const result = make("array", depth, { aot: false, items: [] });
      arraySpace();
      if (text[i] === "]") { i++; return result; }
      for (;;) {
        result.items.push(value(depth + 1));
        arraySpace();
        if (text[i] === "]") { i++; return result; }
        if (text[i++] !== ",") fail();
        arraySpace();
        if (text[i] === "]") { i++; return result; }
      }
    }
    if (ch === "{") {
      i++;
      const result = table(depth, "inline");
      hspace();
      if (text[i] === "}") { i++; return result; }
      for (;;) {
        const parts = path();
        if (text[i++] !== "=") fail();
        hspace();
        let parent = result;
        for (const part of parts.slice(0, -1)) parent = descend(parent, part, false);
        const leaf = parts[parts.length - 1];
        if (parent.entries.has(leaf)) fail("duplicate_key");
        parent.entries.set(leaf, value(parent.depth + 1));
        hspace();
        if (text[i] === "}") { i++; return result; }
        if (text[i++] !== ",") fail();
        hspace();
        if (text[i] === "}" || text[i] === "\r" || text[i] === "\n") fail();
      }
    }
    const start = i;
    // The sole value containing an unquoted space is a date followed by a time.
    if (/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d/.test(text.slice(i, i + 20))) i += 11;
    while (i < text.length && !/[ \t\r\n,#\]}]/.test(text[i])) i++;
    if (i === start) fail();
    return make("scalar", depth, { value: scalar(text.slice(start, i)) });
  };
  const serialize = (node) => {
    if (node.kind === "scalar") return Object.is(node.value, -0) ? "-0" : JSON.stringify(node.value);
    if (node.kind === "array") return `[${node.items.map(serialize).join(",")}]`;
    // Object.keys supplies JavaScript's integer-index enumeration order while
    // Object.fromEntries keeps "__proto__" an own data key.
    const keys = Object.keys(Object.fromEntries(node.entries));
    return `{${keys.map(key => `${JSON.stringify(key)}:${serialize(node.entries.get(key))}`).join(",")}}`;
  };
  try {
    let current = root;
    while (i < text.length) {
      hspace(); comment();
      if (newline()) continue;
      if (i === text.length) break;
      if (text[i] === "[") {
        i++;
        const aot = text[i] === "[";
        if (aot) i++;
        hspace();
        const parts = path();
        if (text[i++] !== "]" || aot && text[i++] !== "]") fail();
        let parent = root;
        for (const part of parts.slice(0, -1)) parent = descend(parent, part, true);
        const name = parts[parts.length - 1];
        let node = parent.entries.get(name);
        if (aot) {
          if (!node) { node = make("array", parent.depth + 1, { aot: true, items: [] }); parent.entries.set(name, node); }
          if (node.kind !== "array" || !node.aot) fail("duplicate_key");
          current = table(node.depth + 1, "explicit");
          node.items.push(current);
        } else {
          if (!node) { node = table(parent.depth + 1, "explicit"); parent.entries.set(name, node); }
          else if (node.kind !== "table" || node.mode !== "implicit") fail("duplicate_key");
          else node.mode = "explicit";
          current = node;
        }
      } else {
        const parts = path();
        if (text[i++] !== "=") fail();
        hspace();
        let parent = current;
        for (const part of parts.slice(0, -1)) parent = descend(parent, part, false);
        const name = parts[parts.length - 1];
        if (parent.entries.has(name)) fail("duplicate_key");
        parent.entries.set(name, value(parent.depth + 1));
      }
      hspace(); comment();
      if (i !== text.length && !newline()) fail();
    }
    return { status: "ok", json: serialize(root) };
  } catch (error) {
    const status = ["duplicate_key", "data_number", "data_schema", "resource_limit"].includes(error.message) ? error.message : "syntax_error";
    return { status, json: null };
  }
}

function data_toml(text) {
  const parsed = knot_data_toml_json(text);
  return io_done(parsed.status === "ok" ? parsed.json : "ERR:" + parsed.status);
}
