import fs from "node:fs";

class TsLower {
  static lower(src) {
    return new TsLower(src).run();
  }

  constructor(src) {
    this.src = src;
    this.i = 0;
    this.n = src.length;
    this.out = "";
  }

  peek(k = 0) {
    return this.i + k < this.n ? this.src[this.i + k] : "";
  }

  next() {
    return this.i < this.n ? this.src[this.i++] : "";
  }

  startsIdent(c) {
    return /[A-Za-z_$]/.test(c);
  }

  isIdent(c) {
    return /[A-Za-z0-9_$]/.test(c);
  }

  skipSpace() {
    while (this.i < this.n && /\s/.test(this.src[this.i])) this.i++;
  }

  readIdent() {
    let s = "";
    while (this.i < this.n && this.isIdent(this.src[this.i])) s += this.src[this.i++];
    return s;
  }

  matchIdent(name) {
    const start = this.i;
    if (!this.startsIdent(this.peek())) return false;
    const id = this.readIdent();
    if (id === name) return true;
    this.i = start;
    return false;
  }

  tryMatch(str) {
    if (this.src.startsWith(str, this.i)) {
      this.i += str.length;
      return true;
    }
    return false;
  }

  copyString(q) {
    let s = q;
    while (this.i < this.n) {
      const c = this.next();
      s += c;
      if (c === "\\" && this.i < this.n) s += this.next();
      else if (c === q) break;
    }
    return s;
  }

  copyTemplate() {
    let s = "`";
    while (this.i < this.n) {
      const c = this.next();
      s += c;
      if (c === "\\") {
        if (this.i < this.n) s += this.next();
        continue;
      }
      if (c === "`") break;
      if (c === "$" && this.peek() === "{") {
        s += this.next();
        s += this.copyBalanced("{", "}");
      }
    }
    return s;
  }

  copyBalanced(open, close) {
    let depth = 0;
    let s = "";
    while (this.i < this.n) {
      const c = this.peek();
      if (c === "'" || c === '"') {
        this.next();
        s += this.copyString(c);
        continue;
      }
      if (c === "`") {
        this.next();
        s += this.copyTemplate();
        continue;
      }
      if (c === "/" && this.peek(1) === "/") {
        while (this.i < this.n && this.peek() !== "\n") s += this.next();
        continue;
      }
      if (c === "/" && this.peek(1) === "*") {
        s += this.next();
        s += this.next();
        while (this.i < this.n && !(this.peek() === "*" && this.peek(1) === "/")) s += this.next();
        if (this.i < this.n) {
          s += this.next();
          s += this.next();
        }
        continue;
      }
      s += this.next();
      if (c === open) depth++;
      else if (c === close) {
        depth--;
        if (depth === 0) break;
      }
    }
    return s;
  }

  skipType() {
    this.skipSpace();
    if (this.tryMatch("{")) {
      this.i--;
      this.copyBalanced("{", "}");
      return;
    }
    if (this.tryMatch("(")) {
      this.i--;
      this.copyBalanced("(", ")");
      this.skipSpace();
      if (this.tryMatch("=>")) this.skipType();
      return;
    }
    if (this.tryMatch("[")) {
      this.i--;
      this.copyBalanced("[", "]");
      return;
    }
    // identifiers / qualified / generics / unions / intersections
    while (this.i < this.n) {
      this.skipSpace();
      const c = this.peek();
      if (this.startsIdent(c)) {
        this.readIdent();
        this.skipSpace();
        if (this.tryMatch(".")) continue;
        if (this.tryMatch("<")) {
          this.i--;
          this.copyBalanced("<", ">");
        }
        this.skipSpace();
        if (this.peek() === "[" ) {
          this.copyBalanced("[", "]");
          continue;
        }
        if (this.peek() === "|" || this.peek() === "&") {
          this.next();
          continue;
        }
        break;
      }
      if (c === "{" || c === "(" || c === "[") {
        this.skipType();
        this.skipSpace();
        if (this.peek() === "|" || this.peek() === "&") {
          this.next();
          continue;
        }
        break;
      }
      if (c === "'" || c === '"') {
        this.next();
        this.copyString(c);
        break;
      }
      break;
    }
  }

  lowerImportEquals() {
    // already consumed "import"
    const start = this.i;
    this.skipSpace();
    if (!this.startsIdent(this.peek())) {
      this.i = start;
      return null;
    }
    const name = this.readIdent();
    this.skipSpace();
    if (!this.tryMatch("=")) {
      this.i = start;
      return null;
    }
    this.skipSpace();
    if (!this.matchIdent("require")) {
      this.i = start;
      return null;
    }
    this.skipSpace();
    if (!this.tryMatch("(")) {
      this.i = start;
      return null;
    }
    this.skipSpace();
    const q = this.peek();
    if (q !== "'" && q !== '"') {
      this.i = start;
      return null;
    }
    this.next();
    let spec = "";
    while (this.i < this.n) {
      const c = this.next();
      if (c === "\\") {
        spec += c + this.next();
        continue;
      }
      if (c === q) break;
      spec += c;
    }
    this.skipSpace();
    this.tryMatch(")");
    this.skipSpace();
    this.tryMatch(";");
    return `import ${name} from ${JSON.stringify(spec)};`;
  }

  lowerExportEquals() {
    // already consumed "export"
    const start = this.i;
    this.skipSpace();
    if (!this.tryMatch("=")) {
      this.i = start;
      return null;
    }
    this.skipSpace();
    const exprStart = this.i;
    // read until semicolon or newline at depth 0
    let depth = 0;
    while (this.i < this.n) {
      const c = this.peek();
      if (c === "'" || c === '"') {
        this.next();
        this.copyString(c);
        continue;
      }
      if (c === "`") {
        this.next();
        this.copyTemplate();
        continue;
      }
      if (c === "(" || c === "{" || c === "[") {
        depth++;
        this.next();
        continue;
      }
      if (c === ")" || c === "}" || c === "]") {
        depth--;
        this.next();
        continue;
      }
      if (depth === 0 && (c === ";" || c === "\n")) break;
      this.next();
    }
    const expr = this.src.slice(exprStart, this.i).trim();
    this.tryMatch(";");
    return `module.exports = ${expr};`;
  }

  lowerNamespace(exported) {
    // already consumed optional "export" and "namespace"
    this.skipSpace();
    const name = this.readIdent();
    this.skipSpace();
    if (this.peek() !== "{") return null;
    const body = this.copyBalanced("{", "}");
    const inner = body.slice(1, -1);
    const lowered = this.lowerNamespaceBody(name, inner);
    const decl = `const ${name} = (function () {\n  const ${name} = {};\n${lowered}  return ${name};\n})();`;
    return exported ? `export ${decl}` : decl;
  }

  lowerNamespaceBody(ns, body) {
    // Rewrite `export const/let/var x = ...` and `export function f` inside namespace.
    let i = 0;
    let out = "";
    const n = body.length;
    const startsIdent = (c) => /[A-Za-z_$]/.test(c);
    const isIdent = (c) => /[A-Za-z0-9_$]/.test(c);
    while (i < n) {
      // skip whitespace/comments quickly by copying until potential export
      if (body.startsWith("export", i) && (i === 0 || !isIdent(body[i - 1])) && !isIdent(body[i + 6] || "")) {
        i += 6;
        while (i < n && /\s/.test(body[i])) i++;
        if (body.startsWith("const", i) || body.startsWith("let", i) || body.startsWith("var", i)) {
          const kw = body.startsWith("const", i) ? "const" : body.startsWith("let", i) ? "let" : "var";
          i += kw.length;
          while (i < n && /\s/.test(body[i])) i++;
          let name = "";
          while (i < n && isIdent(body[i])) name += body[i++];
          while (i < n && /\s/.test(body[i])) i++;
          if (body[i] === "=") {
            i++;
            while (i < n && /\s/.test(body[i])) i++;
            const exprStart = i;
            let depth = 0;
            while (i < n) {
              const c = body[i];
              if (c === "'" || c === '"') {
                const q = c;
                i++;
                while (i < n) {
                  const d = body[i++];
                  if (d === "\\") i++;
                  else if (d === q) break;
                }
                continue;
              }
              if (c === "(" || c === "{" || c === "[") {
                depth++;
                i++;
                continue;
              }
              if (c === ")" || c === "}" || c === "]") {
                depth--;
                i++;
                continue;
              }
              if (depth === 0 && (c === ";" || c === "\n")) break;
              i++;
            }
            const expr = body.slice(exprStart, i).trim();
            if (body[i] === ";") i++;
            out += `  ${ns}.${name} = ${expr};\n`;
            continue;
          }
        }
        if (body.startsWith("function", i)) {
          i += 8;
          while (i < n && /\s/.test(body[i])) i++;
          let name = "";
          while (i < n && isIdent(body[i])) name += body[i++];
          while (i < n && /\s/.test(body[i])) i++;
          // params + body
          if (body[i] === "(") {
            let depth = 0;
            const start = i;
            while (i < n) {
              const c = body[i++];
              if (c === "(") depth++;
              else if (c === ")") {
                depth--;
                if (depth === 0) break;
              }
            }
            while (i < n && /\s/.test(body[i])) i++;
            if (body[i] === "{") {
              depth = 0;
              const bstart = i;
              while (i < n) {
                const c = body[i++];
                if (c === "{") depth++;
                else if (c === "}") {
                  depth--;
                  if (depth === 0) break;
                }
              }
              let fnBody = body.slice(bstart, i);
              // rewrite bare ns member refs: simple `return x` -> `return ns.x` for known pattern
              // Prefer rewriting identifier x that was exported as const onto ns.
              fnBody = fnBody.replace(/\breturn\s+([A-Za-z_$][\w$]*)\b/g, (m, id) => {
                if (id === ns) return m;
                return `return ${ns}.${id}`;
              });
              out += `  function ${name}${body.slice(start, bstart)}${fnBody}\n`;
              out += `  ${ns}.${name} = ${name};\n`;
              continue;
            }
          }
        }
        // fallback: keep rest including "export" dropped already - put back export-less
        out += "  " + body.slice(i) + "\n";
        break;
      }
      out += body[i++];
    }
    // Indent non-empty leftover lines
    return out
      .split("\n")
      .map((line) => {
        if (!line.trim()) return line;
        if (line.startsWith("  ")) return line;
        return "  " + line;
      })
      .join("\n");
  }

  lowerParamPropsInConstructor(header) {
    // header is full `constructor(...)` including parens content without body
    const open = header.indexOf("(");
    const close = header.lastIndexOf(")");
    if (open < 0 || close < 0) return { header, assigns: [] };
    const params = header.slice(open + 1, close);
    const assigns = [];
    const parts = [];
    let i = 0;
    const n = params.length;
    while (i < n) {
      while (i < n && /\s/.test(params[i])) i++;
      if (i >= n) break;
      let mod = "";
      const tryMod = (m) => {
        if (params.startsWith(m, i) && !/[A-Za-z0-9_$]/.test(params[i + m.length] || "")) {
          mod = m;
          i += m.length;
          while (i < n && /\s/.test(params[i])) i++;
          return true;
        }
        return false;
      };
      tryMod("public") || tryMod("private") || tryMod("protected") || tryMod("readonly");
      if (mod === "readonly") {
        // optional second mod already handled; readonly alone
      }
      // another mod after public?
      if (params.startsWith("readonly", i)) {
        i += 8;
        while (i < n && /\s/.test(params[i])) i++;
      }
      let name = "";
      while (i < n && /[A-Za-z0-9_$]/.test(params[i])) name += params[i++];
      // skip optional ? and type
      if (params[i] === "?") i++;
      if (params[i] === ":") {
        i++;
        let depth = 0;
        while (i < n) {
          const c = params[i];
          if (c === "(" || c === "{" || c === "[") depth++;
          if (c === ")" || c === "}" || c === "]") depth--;
          if (depth === 0 && (c === "," || c === "=")) break;
          i++;
        }
      }
      let def = "";
      if (params[i] === "=") {
        const start = i;
        i++;
        let depth = 0;
        while (i < n) {
          const c = params[i];
          if (c === "(" || c === "{" || c === "[") depth++;
          if (c === ")" || c === "}" || c === "]") depth--;
          if (depth === 0 && c === ",") break;
          i++;
        }
        def = params.slice(start, i);
      }
      if (mod === "public" || mod === "private" || mod === "protected") {
        assigns.push(`this.${name} = ${name};`);
      }
      parts.push(name + def);
      if (params[i] === ",") {
        i++;
        continue;
      }
      break;
    }
    return {
      header: header.slice(0, open + 1) + parts.join(", ") + header.slice(close),
      assigns,
    };
  }

  tryLowerClassConstructor() {
    // Look ahead from current position for constructor with param props inside a class.
    // Called when we see "constructor" as ident.
    const saved = this.i;
    // i is at start of "constructor"
    this.readIdent();
    this.skipSpace();
    if (this.peek() !== "(") {
      this.i = saved;
      return null;
    }
    const paramsTok = this.copyBalanced("(", ")");
    const header = "constructor" + paramsTok;
    if (!/\b(public|private|protected)\b/.test(paramsTok)) {
      this.i = saved;
      return null;
    }
    const { header: newHeader, assigns } = this.lowerParamPropsInConstructor(header);
    this.skipSpace();
    if (this.peek() !== "{") {
      this.i = saved;
      return null;
    }
    const body = this.copyBalanced("{", "}");
    const inner = body.slice(1, -1);
    const inject = assigns.map((a) => " " + a).join("");
    return `${newHeader} {${inject}${inner}}`;
  }

  run() {
    while (this.i < this.n) {
      const c = this.peek();

      // comments
      if (c === "/" && this.peek(1) === "/") {
        while (this.i < this.n && this.peek() !== "\n") this.out += this.next();
        continue;
      }
      if (c === "/" && this.peek(1) === "*") {
        this.out += this.next();
        this.out += this.next();
        while (this.i < this.n && !(this.peek() === "*" && this.peek(1) === "/")) this.out += this.next();
        if (this.i < this.n) {
          this.out += this.next();
          this.out += this.next();
        }
        continue;
      }

      // strings
      if (c === "'" || c === '"') {
        this.next();
        this.out += this.copyString(c);
        continue;
      }
      if (c === "`") {
        this.next();
        this.out += this.copyTemplate();
        continue;
      }

      if (this.startsIdent(c)) {
        const start = this.i;
        const id = this.readIdent();

        if (id === "import") {
          const lowered = this.lowerImportEquals();
          if (lowered != null) {
            this.out += lowered;
            continue;
          }
          this.out += "import";
          continue;
        }

        if (id === "export") {
          this.skipSpace();
          if (this.matchIdent("namespace")) {
            const lowered = this.lowerNamespace(true);
            if (lowered != null) {
              this.out += lowered;
              continue;
            }
          }
          // reset after failed namespace: we consumed "export" and maybe tried namespace
          // Re-parse export =
          this.i = start + 6; // after export
          const eq = this.lowerExportEquals();
          if (eq != null) {
            this.out += eq;
            continue;
          }
          this.i = start + 6;
          this.out += "export";
          continue;
        }

        if (id === "namespace") {
          const lowered = this.lowerNamespace(false);
          if (lowered != null) {
            this.out += lowered;
            continue;
          }
          this.out += "namespace";
          continue;
        }

        if (id === "constructor") {
          this.i = start;
          const lowered = this.tryLowerClassConstructor();
          if (lowered != null) {
            this.out += lowered;
            continue;
          }
          this.i = start;
          this.out += this.readIdent();
          continue;
        }

        if (id === "satisfies") {
          // erase satisfies and following type
          this.skipType();
          continue;
        }

        this.out += id;
        continue;
      }

      this.out += this.next();
    }
    return this.out;
  }
}

const source = fs.readFileSync(0, "utf8");
process.stdout.write(TsLower.lower(source));
