import fs from "node:fs";

const modeArg = process.argv[2] === "automatic" ? "automatic" : "classic";
const source = fs.readFileSync(0, "utf8");
process.stdout.write(lower(source, modeArg === "automatic"));

function lower(src, automatic) {
  let i = 0;
  const n = src.length;
  let out = "";
  let usedJsx = false;
  let usedJsxs = false;
  let usedFrag = false;

  const peek = () => (i < n ? src[i] : "");
  const next = () => (i < n ? src[i++] : "");
  const startsIdent = (c) => /[A-Za-z_$]/.test(c);
  const isIdent = (c) => /[A-Za-z0-9_$]/.test(c);
  const skipSpace = () => {
    while (i < n && /\s/.test(src[i])) i++;
  };

  function readIdent() {
    let s = "";
    while (i < n && isIdent(src[i])) s += src[i++];
    return s;
  }

  function readStringRest(q) {
    let s = "";
    while (i < n) {
      const c = next();
      s += c;
      if (c === "\\" && i < n) s += next();
      else if (c === q) break;
    }
    return s;
  }

  function readBraceExpr() {
    let depth = 1;
    let s = "";
    while (i < n && depth > 0) {
      const c = next();
      if (c === "{") depth++;
      else if (c === "}") {
        depth--;
        if (depth === 0) break;
      } else if (c === "'" || c === '"' || c === "`") {
        s += c + readStringRest(c);
        continue;
      }
      if (depth > 0) s += c;
    }
    return s.trim();
  }

  function isJsxStart() {
    const rest = src.slice(i + 1);
    if (!/^\s*(\/|[A-Za-z_$]|>)/.test(rest)) return false;
    let j = out.length - 1;
    while (j >= 0 && /\s/.test(out[j])) j--;
    const before = out.slice(0, j + 1).trimEnd();
    if (/\b(return|throw|case|default|else|do|typeof|await|yield)$/.test(before)) return true;
    const prev = j >= 0 ? out[j] : "";
    if (/[(\[{=,?:;]/.test(prev)) return true;
    if (/[A-Za-z0-9_)$]/.test(prev)) return false;
    return true;
  }

  function tagExpr(name) {
    if (name === "") return automatic ? "Fragment" : "React.Fragment";
    if (/^[A-Z]/.test(name)) return name;
    return JSON.stringify(name);
  }

  function propsObject(props, kids) {
    const parts = props.slice();
    if (kids.length === 1) parts.push(`children: ${kids[0]}`);
    else if (kids.length > 1) parts.push(`children: [${kids.join(", ")}]`);
    if (parts.length === 0) return "null";
    return `{ ${parts.join(", ")} }`;
  }

  function emit(tag, props, kids) {
    if (automatic) {
      if (tag === "Fragment") usedFrag = true;
      const propObj = propsObject(props, kids);
      if (kids.length <= 1) {
        usedJsx = true;
        return `jsx(${tag}, ${propObj})`;
      }
      usedJsxs = true;
      return `jsxs(${tag}, ${propObj})`;
    }
    const p = props.length === 0 ? "null" : `{ ${props.join(", ")} }`;
    if (kids.length === 0) return `React.createElement(${tag}, ${p})`;
    return `React.createElement(${tag}, ${p}, ${kids.join(", ")})`;
  }

  function parseAttrs() {
    const props = [];
    while (true) {
      skipSpace();
      if (peek() === ">" || peek() === "/" || peek() === "") break;
      if (!startsIdent(peek())) break;
      const key = readIdent();
      skipSpace();
      if (peek() === "=") {
        next();
        skipSpace();
        let val;
        if (peek() === "{") {
          next();
          val = readBraceExpr();
        } else if (peek() === '"' || peek() === "'") {
          const q = next();
          val = q + readStringRest(q);
        } else {
          val = readIdent();
        }
        props.push(`${key}: ${val}`);
      } else {
        props.push(`${key}: true`);
      }
    }
    return props;
  }

  function parseKids(closeName) {
    const kids = [];
    while (i < n) {
      if (peek() === "<") {
        const save = i;
        next();
        skipSpace();
        if (peek() === "/") {
          next();
          skipSpace();
          const name = startsIdent(peek()) ? readIdent() : "";
          skipSpace();
          if (peek() === ">") next();
          if (name === closeName || (closeName === "" && name === "")) return kids;
          i = save;
          kids.push(JSON.stringify(next()));
          continue;
        }
        i = save;
        kids.push(parseElement());
        continue;
      }
      if (peek() === "{") {
        next();
        kids.push(readBraceExpr());
        continue;
      }
      let text = "";
      while (i < n && peek() !== "<" && peek() !== "{") text += next();
      const trimmed = text.replace(/^\s+|\s+$/g, " ").trim();
      if (trimmed.length > 0) kids.push(JSON.stringify(trimmed));
    }
    return kids;
  }

  function parseElement() {
    next(); // <
    skipSpace();
    if (peek() === ">") {
      next();
      if (automatic) usedFrag = true;
      return emit(tagExpr(""), [], parseKids(""));
    }
    const name = readIdent();
    const props = parseAttrs();
    skipSpace();
    if (peek() === "/") {
      next();
      skipSpace();
      if (peek() === ">") next();
      return emit(tagExpr(name), props, []);
    }
    if (peek() === ">") next();
    return emit(tagExpr(name), props, parseKids(name));
  }

  while (i < n) {
    const c = peek();
    if (c === "<" && isJsxStart()) {
      out += parseElement();
      continue;
    }
    if (c === "'" || c === '"' || c === "`") {
      out += next() + readStringRest(c);
      continue;
    }
    if (c === "/" && src[i + 1] === "/") {
      while (i < n && peek() !== "\n") out += next();
      continue;
    }
    if (c === "/" && src[i + 1] === "*") {
      out += next();
      out += next();
      while (i < n && !(peek() === "*" && src[i + 1] === "/")) out += next();
      if (i < n) {
        out += next();
        out += next();
      }
      continue;
    }
    out += next();
  }

  if (automatic && (usedJsx || usedJsxs || usedFrag)) {
    const names = [];
    if (usedJsx) names.push("jsx");
    if (usedJsxs) names.push("jsxs");
    if (usedFrag) names.push("Fragment");
    out = `import { ${names.join(", ")} } from "react/jsx-runtime";\n` + out;
  }
  return out;
}
