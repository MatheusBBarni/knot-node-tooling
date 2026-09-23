import fs from "node:fs";

class LiveImports {
  static of(src) {
    const imports = LiveImports.parseImports(src);
    const used = LiveImports.bodyIdents(src);
    const live = new Set();
    for (const im of imports) {
      if (used.has(im.local)) live.add(im.imported);
    }
    return [...live].join("\n");
  }

  static parseImports(src) {
    const out = [];
    const re = /\bimport\s*(?:([^'"\n]+?)\s*from\s*)?["']([^"']+)["']/g;
    let m;
    while ((m = re.exec(src))) {
      const clause = (m[1] || "").trim();
      if (!clause) continue; // side-effect import
      if (clause.startsWith("type ") || clause === "type") continue;
      if (clause[0] === "{") {
        const inner = clause.replace(/^\{|\}$/g, "");
        for (const part of inner.split(",")) {
          const p = part.trim();
          if (!p || p.startsWith("type ")) continue;
          const mm = p.match(/^(?:type\s+)?([A-Za-z_$][\w$]*)(?:\s+as\s+([A-Za-z_$][\w$]*))?$/);
          if (!mm) continue;
          out.push({ imported: mm[1], local: mm[2] || mm[1] });
        }
      } else if (clause.startsWith("*")) {
        const mm = clause.match(/^\*\s+as\s+([A-Za-z_$][\w$]*)$/);
        if (mm) out.push({ imported: "*", local: mm[1] });
      } else {
        const mm = clause.match(/^([A-Za-z_$][\w$]*)$/);
        if (mm) out.push({ imported: "default", local: mm[1] });
      }
    }
    return out;
  }

  static bodyIdents(src) {
    // Strip import declarations roughly, then collect idents
    const stripped = src.replace(/\bimport\s[\s\S]*?["'][^"']+["']\s*;?/g, "\n");
    const used = new Set();
    const re = /[A-Za-z_$][\w$]*/g;
    let m;
    while ((m = re.exec(stripped))) {
      const id = m[0];
      if (LiveImports.KEYWORDS.has(id)) continue;
      used.add(id);
    }
    return used;
  }
}

LiveImports.KEYWORDS = new Set([
  "break","case","catch","class","const","continue","debugger","default","delete",
  "do","else","enum","export","extends","false","finally","for","function","if",
  "implements","in","instanceof","interface","let","new","null","package","private",
  "protected","public","return","super","switch","static","this","throw","true","try",
  "typeof","var","void","while","with","yield","await","async","from","as","of",
  "undefined","NaN","Infinity",
]);

process.stdout.write(LiveImports.of(fs.readFileSync(0, "utf8")));
