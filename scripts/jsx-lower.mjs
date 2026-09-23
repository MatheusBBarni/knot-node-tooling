import fs from "node:fs";

class JsxLower {
  static defaults() {
    return {
      mode: "classic",
      factory: "React.createElement",
      fragment: "React.Fragment",
      importSource: "react",
    };
  }

  static parseArgs(argv) {
    const d = JsxLower.defaults();
    const mode = argv[2] === "automatic" || argv[2] === "classic" || argv[2] === "preserve"
      ? argv[2]
      : d.mode;
    return {
      mode,
      factory: argv[3] && argv[3].length > 0 ? argv[3] : d.factory,
      fragment: argv[4] && argv[4].length > 0 ? argv[4] : d.fragment,
      importSource: argv[5] && argv[5].length > 0 ? argv[5] : d.importSource,
    };
  }

  static lower(src, opts) {
    if (opts.mode === "preserve") return src;
    return new JsxLower(src, opts).run();
  }

  constructor(src, opts) {
    this.src = src;
    this.i = 0;
    this.n = src.length;
    this.out = "";
    this.automatic = opts.mode === "automatic";
    this.factory = opts.factory;
    this.fragment = opts.fragment;
    this.importSource = opts.importSource;
    this.usedJsx = false;
    this.usedJsxs = false;
    this.usedFrag = false;
  }

  peek() {
    return this.i < this.n ? this.src[this.i] : "";
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

  readStringRest(q) {
    let s = "";
    while (this.i < this.n) {
      const c = this.next();
      s += c;
      if (c === "\\" && this.i < this.n) s += this.next();
      else if (c === q) break;
    }
    return s;
  }

  readBraceExpr() {
    let depth = 1;
    let s = "";
    while (this.i < this.n && depth > 0) {
      const c = this.next();
      if (c === "{") depth++;
      else if (c === "}") {
        depth--;
        if (depth === 0) break;
      } else if (c === "'" || c === '"' || c === "`") {
        s += c + this.readStringRest(c);
        continue;
      }
      if (depth > 0) s += c;
    }
    return s.trim();
  }

  isJsxStart() {
    const rest = this.src.slice(this.i + 1);
    if (!/^\s*(\/|[A-Za-z_$]|>)/.test(rest)) return false;
    let j = this.out.length - 1;
    while (j >= 0 && /\s/.test(this.out[j])) j--;
    const before = this.out.slice(0, j + 1).trimEnd();
    if (/\b(return|throw|case|default|else|do|typeof|await|yield)$/.test(before)) return true;
    const prev = j >= 0 ? this.out[j] : "";
    if (/[(\[{=,?:;]/.test(prev)) return true;
    if (/[A-Za-z0-9_)$]/.test(prev)) return false;
    return true;
  }

  tagExpr(name) {
    if (name === "") return this.automatic ? "Fragment" : this.fragment;
    if (/^[A-Z]/.test(name)) return name;
    return JSON.stringify(name);
  }

  propsObject(props, kids) {
    const parts = props.slice();
    if (kids.length === 1) parts.push(`children: ${kids[0]}`);
    else if (kids.length > 1) parts.push(`children: [${kids.join(", ")}]`);
    if (parts.length === 0) return "null";
    return `{ ${parts.join(", ")} }`;
  }

  emit(tag, props, kids) {
    if (this.automatic) {
      if (tag === "Fragment") this.usedFrag = true;
      const propObj = this.propsObject(props, kids);
      if (kids.length <= 1) {
        this.usedJsx = true;
        return `jsx(${tag}, ${propObj})`;
      }
      this.usedJsxs = true;
      return `jsxs(${tag}, ${propObj})`;
    }
    const p = props.length === 0 ? "null" : `{ ${props.join(", ")} }`;
    if (kids.length === 0) return `${this.factory}(${tag}, ${p})`;
    return `${this.factory}(${tag}, ${p}, ${kids.join(", ")})`;
  }

  parseAttrs() {
    const props = [];
    while (true) {
      this.skipSpace();
      if (this.peek() === ">" || this.peek() === "/" || this.peek() === "") break;
      if (!this.startsIdent(this.peek())) break;
      const key = this.readIdent();
      this.skipSpace();
      if (this.peek() === "=") {
        this.next();
        this.skipSpace();
        let val;
        if (this.peek() === "{") {
          this.next();
          val = this.readBraceExpr();
        } else if (this.peek() === '"' || this.peek() === "'") {
          const q = this.next();
          val = q + this.readStringRest(q);
        } else {
          val = this.readIdent();
        }
        props.push(`${key}: ${val}`);
      } else {
        props.push(`${key}: true`);
      }
    }
    return props;
  }

  parseKids(closeName) {
    const kids = [];
    while (this.i < this.n) {
      if (this.peek() === "<") {
        const save = this.i;
        this.next();
        this.skipSpace();
        if (this.peek() === "/") {
          this.next();
          this.skipSpace();
          const name = this.startsIdent(this.peek()) ? this.readIdent() : "";
          this.skipSpace();
          if (this.peek() === ">") this.next();
          if (name === closeName || (closeName === "" && name === "")) return kids;
          this.i = save;
          kids.push(JSON.stringify(this.next()));
          continue;
        }
        this.i = save;
        kids.push(this.parseElement());
        continue;
      }
      if (this.peek() === "{") {
        this.next();
        kids.push(this.readBraceExpr());
        continue;
      }
      let text = "";
      while (this.i < this.n && this.peek() !== "<" && this.peek() !== "{") text += this.next();
      const trimmed = text.replace(/^\s+|\s+$/g, " ").trim();
      if (trimmed.length > 0) kids.push(JSON.stringify(trimmed));
    }
    return kids;
  }

  parseElement() {
    this.next();
    this.skipSpace();
    if (this.peek() === ">") {
      this.next();
      if (this.automatic) this.usedFrag = true;
      return this.emit(this.tagExpr(""), [], this.parseKids(""));
    }
    const name = this.readIdent();
    const props = this.parseAttrs();
    this.skipSpace();
    if (this.peek() === "/") {
      this.next();
      this.skipSpace();
      if (this.peek() === ">") this.next();
      return this.emit(this.tagExpr(name), props, []);
    }
    if (this.peek() === ">") this.next();
    return this.emit(this.tagExpr(name), props, this.parseKids(name));
  }

  run() {
    while (this.i < this.n) {
      const c = this.peek();
      if (c === "<" && this.isJsxStart()) {
        this.out += this.parseElement();
        continue;
      }
      if (c === "'" || c === '"' || c === "`") {
        this.out += this.next() + this.readStringRest(c);
        continue;
      }
      if (c === "/" && this.src[this.i + 1] === "/") {
        while (this.i < this.n && this.peek() !== "\n") this.out += this.next();
        continue;
      }
      if (c === "/" && this.src[this.i + 1] === "*") {
        this.out += this.next();
        this.out += this.next();
        while (this.i < this.n && !(this.peek() === "*" && this.src[this.i + 1] === "/")) {
          this.out += this.next();
        }
        if (this.i < this.n) {
          this.out += this.next();
          this.out += this.next();
        }
        continue;
      }
      this.out += this.next();
    }

    if (this.automatic && (this.usedJsx || this.usedJsxs || this.usedFrag)) {
      const names = [];
      if (this.usedJsx) names.push("jsx");
      if (this.usedJsxs) names.push("jsxs");
      if (this.usedFrag) names.push("Fragment");
      const spec = `${this.importSource}/jsx-runtime`;
      this.out = `import { ${names.join(", ")} } from ${JSON.stringify(spec)};\n` + this.out;
    }
    return this.out;
  }
}

const opts = JsxLower.parseArgs(process.argv);
const source = fs.readFileSync(0, "utf8");
process.stdout.write(JsxLower.lower(source, opts));
