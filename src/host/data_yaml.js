// YAML 1.2 core data subset. Deliberately does not resolve references or tags.
function knot_data_yaml_json(text) {
  const MAX = 1000000, DEPTH = 128;
  let lineCount=1;
  for(let i=0;i<text.length;i++) if(text[i]==='\r'||text[i]==='\n'&&text[i-1]!=='\r') {
    if(++lineCount>MAX) return {status:'resource_limit',json:null};
  }
  const lines = text.replace(/\r\n?/g, '\n').split('\n');
  let at = 0, nodes = 0, error = 'syntax_error';
  const fail = (code = 'syntax_error') => { error = code; throw null; };
  const blank = s => /^\s*(?:#.*)?$/.test(s);
  const indent = s => { const n = /^ */.exec(s)[0].length; if (s[n] === '\t') fail(); return n; };
  const checkLine = s => {
    if (/^(?:---|\.\.\.)(?:\s|$)/.test(s) || /^%/.test(s)) fail();
  };
  const skip = () => { while (at < lines.length && blank(lines[at])) at++; if (at < lines.length) checkLine(lines[at]); };
  const count = depth => { if (depth > DEPTH || ++nodes > MAX) fail('resource_limit'); };
  const keySet = () => new Set();
  const putKey = (set, key) => { if (set.has(key)) fail('duplicate_key'); set.add(key); };
  const quoted = (s, state) => {
    const q = s[state.i++]; let out = '';
    const escapes = { '0':'\0', a:'\x07', b:'\b', t:'\t', n:'\n', v:'\v', f:'\f', r:'\r', e:'\x1b', ' ':' ', '"':'"', '/':'/', '\\':'\\', N:'\u0085', _: '\u00a0', L:'\u2028', P:'\u2029' };
    while (true) {
      if (state.i >= s.length) fail();
      let c = s[state.i++];
      if (c === q) { if (q === "'" && s[state.i] === "'") { state.i++; out += "'"; continue; } return out; }
      if (c === '\\' && q === '"') {
        if (state.i >= s.length) fail();
        c = s[state.i++];
        if (Object.prototype.hasOwnProperty.call(escapes, c)) out += escapes[c];
        else if (c === 'x' || c === 'u' || c === 'U') {
          const n = c === 'x' ? 2 : c === 'u' ? 4 : 8;
          const hex = s.slice(state.i, state.i+n);
          if (!new RegExp(`^[0-9a-fA-F]{${n}}$`).test(hex)) fail();
          const cp = parseInt(hex,16); if (cp > 0x10ffff || cp >= 0xd800 && cp <= 0xdfff) fail();
          out += String.fromCodePoint(cp); state.i += n;
        } else fail();
      } else { if (c === '\n' || c === '\r' || c < ' ' && c !== '\t') fail(); out += c; }
    }
  };
  const scalar = (raw, key = false) => {
    const s = raw.trim();
    if (!s) return key ? '' : null;
    if (s[0] === '&' || s[0] === '*' || s[0] === '!' || s === '<<') fail('data_schema');
    if (/^[+-]?\.(?:inf|nan)$/i.test(s)) fail('data_schema');
    if (/^\d{4}-\d\d-\d\d(?:$|[Tt ]\d)/.test(s)) fail('data_schema');
    if (key) return s;
    if (colon(s)>=0) fail();
    if (/^(?:null|Null|NULL|~)$/.test(s)) return null;
    if (/^(?:true|True|TRUE)$/.test(s)) return true;
    if (/^(?:false|False|FALSE)$/.test(s)) return false;
    if (/^(?:[+-]?(?:0|[1-9][0-9]*)|0x[0-9a-fA-F]+|0o[0-7]+)$/.test(s)) {
      let v;
      try { v = BigInt(s); } catch { fail('data_number'); }
      if (v > 9007199254740991n || v < -9007199254740991n) fail('data_number');
      return Number(v);
    }
    if (/^[+-]?(?:(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?)$/.test(s) && (s.includes('.') || /[eE]/.test(s))) {
      const v = Number(s);
      if (!Number.isFinite(v) || Number.isInteger(v) && !Number.isSafeInteger(v)) fail('data_number');
      return v;
    }
    if (/^[+-]?(?:[0-9][0-9_.eE+-]*|\.[0-9])/.test(s)) fail('data_number');
    if (/^[\[\]{},|>%@`]|^[:?](?:\s|$)|^[-](?:\s|$)/.test(s)) fail();
    return s;
  };
  // A colon is a mapping delimiter only when followed by separation (or a flow delimiter).
  const colon = (s, flow = false) => {
    let q = '', level = 0;
    for (let i=0;i<s.length;i++) {
      const c=s[i];
      if (q) { if (q === '"' && c === '\\') i++; else if (c === q) { if (q === "'" && s[i+1] === "'") i++; else q=''; } continue; }
      if (c === '"' || c === "'") { q=c; continue; }
      if (c === '[' || c === '{') level++;
      else if (c === ']' || c === '}') level--;
      if (!level && c === ':' && (i+1 === s.length || /[\s,\]}]/.test(s[i+1]) && (flow || /\s/.test(s[i+1])))) return i;
    }
    return -1;
  };
  const clean = s => { let q='', nesting=0; for(let i=0;i<s.length;i++) { const c=s[i]; if(q) { if(q==='"' && c==='\\') i++; else if(c===q) { if(q==="'" && s[i+1]==="'") i++; else q=''; } } else if(c==='"'||c==="'") q=c; else if(c==='['||c==='{') nesting++; else if(c===']'||c==='}') nesting--; else if(c==='#' && (i===0 || /\s/.test(s[i-1])) && !nesting) return s.slice(0,i).trimEnd(); } return s.trimEnd(); };
  const parseKey = raw => {
    const s=raw.trim(); if (!s || s[0]==='[' || s[0]==='{' || s[0]==='?' || s[0]==='&' || s[0]==='*' || s[0]==='!') fail('data_schema');
    if (s[0]==='"' || s[0]==="'") { const state={i:0}, v=quoted(s,state); if (s.slice(state.i).trim()) fail(); return v; }
    return scalar(s,true);
  };
  const flow = (input, depth) => {
    let i=0;
    const ws=()=> { while (i<input.length) { if (/\s/.test(input[i])) i++; else if (input[i]==='#' && (i===0 || /\s/.test(input[i-1]))) { while(i<input.length && input[i]!=='\n') i++; } else break; } };
    const value=d=> {
      ws(); count(d);
      if (input[i]==='[') {
        i++; const list=[]; ws(); if(input[i]===']') {i++;return list;}
        while(true) { list.push(value(d+1)); ws(); if(input[i]===']') {i++;return list;} if(input[i++]!==',') fail(); ws(); if(input[i]===']') {i++;return list;} }
      }
      if (input[i]==='{') {
        i++; const obj=Object.create(null), keys=keySet(); ws(); if(input[i]==='}') {i++;return obj;}
        while(true) {
          ws(); let k;
          if(input[i]==='"'||input[i]==="'") {const state={i};k=quoted(input,state);i=state.i;}
          else { const start=i; while(i<input.length && input[i]!==':' && input[i]!==',' && input[i]!=='}' && input[i]!=='\n') i++; k=parseKey(input.slice(start,i)); }
          ws(); if(input[i++]!==':') fail(); putKey(keys,k);
          ws(); obj[k] = input[i]===',' || input[i]==='}' ? (count(d+1), null) : value(d+1);
          ws(); if(input[i]==='}') {i++;return obj;} if(input[i++]!==',') fail(); ws(); if(input[i]==='}') {i++;return obj;}
        }
      }
      if(input[i]==='"'||input[i]==="'") {const state={i}; const v=quoted(input,state);i=state.i;return v;}
      const start=i;
      while(i<input.length && input[i]!==',' && input[i]!==']' && input[i]!=='}' && input[i]!=='\n') {
        if(input[i]==='#' && (i===start||/\s/.test(input[i-1]))) break;
        if(input[i]==='[' || input[i]==='{') fail();
        if(input[i]===':' && (i+1===input.length || /[\s,\]}]/.test(input[i+1]))) fail();
        i++;
      }
      if(i===start) fail(); return scalar(input.slice(start,i).replace(/\s+/g,' '));
    };
    const result=value(depth); ws(); if(i!==input.length) fail(); return result;
  };
  const blockScalar = (marker, parent) => {
    const m=/^([|>])([+-]?)([1-9]?)(?:\s*(?:#.*)?)?$/.exec(marker) || /^([|>])([1-9])([+-]?)(?:\s*(?:#.*)?)?$/.exec(marker);
    if(!m) fail();
    const style=m[1], chomp=/[+-]/.test(m[2])?m[2]:m[3], explicit=/[1-9]/.test(m[2])?+m[2]:/[1-9]/.test(m[3])?+m[3]:0;
    let base=explicit ? parent+explicit : 0, end=at;
    if(!base) { for(let j=at;j<lines.length;j++) { if(!lines[j].trim()) continue; const n=indent(lines[j]); if(n<=parent) break; base=n; break; } }
    if(!base) base=parent+1;
    const parts=[];
    for(;end<lines.length;end++) { const s=lines[end], n=indent(s); if(s.trim() && n<base) break; parts.push(s.trim() ? s.slice(base) : ''); }
    at=end;
    let result='';
    for(let j=0;j<parts.length;j++) {
      result+=parts[j];
      if(j<parts.length-1) result+=style==='>' && j>0 && !parts[j] && parts[j+1] && !/^\s/.test(parts[j+1]) ? '' : style==='|' || !parts[j] || !parts[j+1] || /^\s/.test(parts[j]) || /^\s/.test(parts[j+1]) ? '\n' : ' ';
    }
    if(parts.length) result+='\n';
    if(chomp==='-') result=result.replace(/\n+$/,'');
    else if(chomp!=='+') result=result.replace(/\n+$/,'\n');
    return result;
  };
  const inline = (raw, parent, depth, indentless=false) => {
    count(depth);
    const s=clean(raw).trim();
    if(!s) { skip(); if(at<lines.length && (indent(lines[at])>parent || indentless && indent(lines[at])===parent && /^-(?:\s|$)/.test(lines[at].slice(parent)))) {nodes--;return block(indent(lines[at]),depth,false);} return null; }
    if(s[0]==='|' || s[0]==='>') return blockScalar(s,parent);
    if(s[0]==='[' || s[0]==='{') {
      // Collect only through the balanced closing delimiter, respecting quotes/comments.
      const chunks=[], levelState={level:0,quote:'',comment:false}, endState={index:-1};
      let part=s, offset=0;
      for(;;) {
        chunks.push(part);
        for(let k=0;k<part.length;k++) {
          const c=part[k];
          if(levelState.comment) { if(c==='\n') levelState.comment=false; continue; }
          if(levelState.quote) {
            if(levelState.quote==='"' && c==='\\') k++;
            else if(c===levelState.quote) { if(c==="'" && part[k+1]==="'") k++; else levelState.quote=''; }
          } else if(c==='#' && (k===0 || /\s/.test(part[k-1]))) levelState.comment=true;
          else if(c==='"'||c==="'") levelState.quote=c;
          else if(c==='['||c==='{') levelState.level++;
          else if(c===']'||c==='}') { if(--levelState.level===0) {endState.index=offset+k;break;} }
        }
        if(endState.index>=0) break;
        if(levelState.quote || at>=lines.length || indent(lines[at])<=parent && !blank(lines[at])) fail();
        offset+=part.length;part='\n'+lines[at++];
      }
      const str=chunks.join(''), end=endState.index;
      if(str.slice(end+1).trim() && !/^\s+#/.test(str.slice(end+1))) fail();
      nodes--; return flow(str.slice(0,end+1),depth);
    }
    if(s[0]==='"'||s[0]==="'") {const state={i:0},v=quoted(s,state);if(s.slice(state.i).trim()) fail();return v;}
    return scalar(s);
  };
  const block = (column,depth,initial) => {
    if (!initial) { skip(); if(at>=lines.length || indent(lines[at])!==column) fail(); }
    let first=initial || lines[at].slice(column), sequence=/^-(?:\s|$)/.test(first), c=colon(clean(first));
    if(sequence) {
      count(depth); const list=[];
      while(at<lines.length) {
        skip(); if(at>=lines.length || indent(lines[at])!==column || !/^-(?:\s|$)/.test(lines[at].slice(column))) break;
        const line=clean(lines[at++].slice(column+1)); const content=line.trimStart(), childColumn=column+2;
        if(!content) list.push(inline('',column,depth+1));
        else if(colon(content)>=0) list.push(block(childColumn,depth+1,content));
        else list.push(inline(content,column,depth+1));
      }
      return list;
    }
    if(c>=0) {
      count(depth); const obj=Object.create(null), keys=keySet(); let pending=initial;
      while(true) {
        skip(); let line;
        if(pending!==false && pending!==undefined && pending!==null) {line=pending;pending=null;}
        else {if(at>=lines.length || indent(lines[at])!==column) break; line=lines[at++].slice(column);}
        const index=colon(clean(line)); if(index<0) fail();
        const key=parseKey(line.slice(0,index)); putKey(keys,key);
        obj[key]=inline(line.slice(index+1),column,depth+1,true);
      }
      return obj;
    }
    if(initial) fail();
    at++; return inline(first,column,depth);
  };
  try {
    skip(); if(at===lines.length) return {status:'syntax_error',json:null};
    const result=block(indent(lines[at]),0,false);
    skip(); if(at!==lines.length) fail();
    return {status:'ok',json:JSON.stringify(result)};
  } catch { return {status:error,json:null}; }
}

function data_yaml(text) {
  const parsed = knot_data_yaml_json(text);
  return io_done(parsed.status === "ok" ? parsed.json : "ERR:" + parsed.status);
}
