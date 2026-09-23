import Base

type Token is Data:
  Token{text: String, start: U32, end: U32, line: U32, col: U32}

type LexRes is Data:
  LexOk{tokens: List<&2, Token>}
  LexErr{msg: String, line: U32, col: U32}

type TRes is Data:
  TOk{js: String, map: String}
  TErr{msg: String, line: U32, col: U32}

type Lx is Data:
  Lx{
    rest: String,
    pos: U32,
    line: U32,
    col: U32,
    acc: List<&2, Token>,
    ch: Char,
    ident_acc: String,
    start: U32,
    sl: U32,
    sc: U32,
    b_space: Bool,
    b_nl: Bool,
    b_id: Bool,
    b_digit: Bool,
    b_slash: Bool,
    b_punct: Bool,
    b_idcont: Bool
  }

type Xs is Data:
  Xs{
    tokens: List<&2, Token>,
    acc: List<&2, Token>,
    depth: U32,
    text: String,
    rest: List<&2, Token>,
    tok: Token,
    flag: Bool
  }

type Sc is Data:
  Sc{tokens: List<&2, Token>, acc: List<&2, String>, text: String, flag: Bool}

type Ts is Data:
  Ts{tokens: List<&2, Token>, acc: List<&2, Token>, tok: Token, text: String, flag: Bool}



def is_id_start(+c: Char) -> Bool:
  Bool.or(Char.is_alpha(c), Bool.or(Char.is_eq(c, '$'), Char.is_eq(c, '_')))

def is_id_cont(+c: Char) -> Bool:
  Bool.or(is_id_start(c), Char.is_digit(c))

def is_punct(c: Char) -> Bool:
  match c:
    case Chr{+x}:
      Bool.or(
        Bool.and(U32.is_ge(x, 33), U32.is_le(x, 47)),
        Bool.or(
          Bool.and(U32.is_ge(x, 58), U32.is_le(x, 64)),
          Bool.or(
            Bool.and(U32.is_ge(x, 91), U32.is_le(x, 96)),
            Bool.and(U32.is_ge(x, 123), U32.is_le(x, 126))
          )
        )
      )

def is_ty_term(+text: String) -> Bool:
  Bool.or(
    String.eq(text, ","),
    Bool.or(
      String.eq(text, ")"),
      Bool.or(
        String.eq(text, "{"),
        Bool.or(String.eq(text, ";"), String.eq(text, "="))
      )
    )
  )

def is_ty_term_at(+text: String, depth: U32) -> Bool:
  Bool.and(U32.is_eq(depth, 0), is_ty_term(text))

def depth_open(+text: String) -> Bool:
  Bool.or(String.eq(text, "<"), Bool.or(String.eq(text, "("), String.eq(text, "[")))

def depth_close(+text: String) -> Bool:
  Bool.or(String.eq(text, ">"), Bool.or(String.eq(text, ")"), String.eq(text, "]")))

def depth_dec(depth: U32, z: Bool) -> U32:
  match z:
    case True{}:
      0
    case False{}:
      U32.sub(depth, 1)

def depth_next_close(+depth: U32, close: Bool) -> U32:
  match close:
    case True{}:
      depth_dec(depth, U32.is_eq(depth, 0))
    case False{}:
      depth

def depth_next_open(depth: U32, open: Bool, close: Bool) -> U32:
  match open:
    case True{}:
      U32.inc(depth)
    case False{}:
      depth_next_close(depth, close)

def depth_next(+text: String, depth: U32) -> U32:
  depth_next_open(depth, depth_open(text), depth_close(text))

def decl_open(+text: String) -> Bool:
  Bool.or(String.eq(text, "{"), depth_open(text))

def decl_close(+text: String) -> Bool:
  Bool.or(String.eq(text, "}"), depth_close(text))

def decl_depth(+text: String, depth: U32) -> U32:
  depth_next_open(depth, decl_open(text), decl_close(text))

def tok_is_ident(s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{+h, t}:
      is_id_start(h)

def colon_is_type(+next: String) -> Bool:
  Bool.or(tok_is_ident(next), Bool.or(String.eq(next, "{"), Bool.or(String.eq(next, "("), String.eq(next, "<"))))

@unsafe def colon_keep(sel: Nat, xs: List<&2, Token>, +p: U32, +b: U32, z: Bool, is_bc: Bool, is_bo: Bool, is_pc: Bool, is_po: Bool, is_q: Bool) -> Bool:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          False{}
        case Con{Token{+text, start, end, line, col}, rest}:
          colon_keep(5n, rest, p, b, False{}, String.eq(text, "}"), String.eq(text, "{"), String.eq(text, ")"), String.eq(text, "("), String.eq(text, "?"))
    case 1n:
      match z:
        case True{}:
          True{}
        case False{}:
          colon_keep(0n, xs, p, U32.sub(b, 1), False{}, False{}, False{}, False{}, False{}, False{})
    case 2n:
      match z:
        case True{}:
          False{}
        case False{}:
          colon_keep(0n, xs, U32.sub(p, 1), b, False{}, False{}, False{}, False{}, False{}, False{})
    case 3n:
      match z:
        case True{}:
          colon_keep(4n, xs, p, b, U32.is_eq(b, 0), False{}, False{}, False{}, False{}, False{})
        case False{}:
          colon_keep(0n, xs, p, b, False{}, False{}, False{}, False{}, False{}, False{})
    case 4n:
      match z:
        case True{}:
          True{}
        case False{}:
          colon_keep(0n, xs, p, b, False{}, False{}, False{}, False{}, False{}, False{})
    case _:
      match is_bc:
        case True{}:
          colon_keep(0n, xs, p, U32.inc(b), False{}, False{}, False{}, False{}, False{}, False{})
        case False{}:
          match is_bo:
            case True{}:
              colon_keep(1n, xs, p, b, U32.is_eq(b, 0), False{}, False{}, False{}, False{}, False{})
            case False{}:
              match is_pc:
                case True{}:
                  colon_keep(0n, xs, U32.inc(p), b, False{}, False{}, False{}, False{}, False{}, False{})
                case False{}:
                  match is_po:
                    case True{}:
                      colon_keep(2n, xs, p, b, U32.is_eq(p, 0), False{}, False{}, False{}, False{}, False{})
                    case False{}:
                      match is_q:
                        case True{}:
                          colon_keep(3n, xs, p, b, U32.is_eq(p, 0), False{}, False{}, False{}, False{}, False{})
                        case False{}:
                          colon_keep(0n, xs, p, b, False{}, False{}, False{}, False{}, False{}, False{})

def colon_keep_go(xs: List<&2, Token>, p: U32, b: U32) -> Bool:
  colon_keep(0n, xs, p, b, False{}, False{}, False{}, False{}, False{}, False{})

def colon_keep_ctx(acc: List<&2, Token>) -> Bool:
  colon_keep_go(acc, 0, 0)

def colon_is_type_at_go(keep: Bool, +next: String) -> Bool:
  match keep:
    case True{}:
      False{}
    case False{}:
      colon_is_type(next)

def colon_is_type_at(+acc: List<&2, Token>, +next: String) -> Bool:
  colon_is_type_at_go(colon_keep_ctx(acc), next)

def decl_stop(+text: String, +depth: U32, new_d: U32) -> Bool:
  Bool.or(Bool.and(String.eq(text, ";"), U32.is_eq(depth, 0)), Bool.and(String.eq(text, "}"), U32.is_eq(new_d, 0)))

def is_type_kw(+text: String) -> Bool:
  Bool.or(String.eq(text, "interface"), String.eq(text, "type"))



def json_esc(s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{'"', t}:
      "\\\"" ++ json_esc(t)
    case SCon{'\\', t}:
      "\\\\" ++ json_esc(t)
    case SCon{'\n', t}:
      "\\n" ++ json_esc(t)
    case SCon{'\r', t}:
      "\\r" ++ json_esc(t)
    case SCon{h, t}:
      SCon{h, json_esc(t)}

def json_str(+s: String) -> String:
  "\"" ++ json_esc(s) ++ "\""

def json_list_go(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      json_str(h)
    case Con{h, t}:
      json_str(h) ++ "," ++ json_list_go(t)

def json_list(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      "[]"
    case _:
      "[" ++ json_list_go(xs) ++ "]"


def nat_sub(a: Nat, b: Nat) -> Nat:
  match a b:
    case n 0n:
      n
    case 0n _:
      0n
    case 1n+p 1n+q:
      nat_sub(p, q)

def js_path_if(+file: String, ts: Bool) -> String:
  match ts:
    case True{}:
      String.append(String.take(file, nat_sub(String.length(file), 2n)), "js")
    case False{}:
      file ++ ".js"

def js_path_tsx(+file: String) -> String:
  String.append(String.take(file, nat_sub(String.length(file), 3n)), "js")

def js_path_go(+file: String, tsx: Bool, jsx: Bool) -> String:
  match tsx:
    case True{}:
      js_path_tsx(file)
    case False{}:
      match jsx:
        case True{}:
          js_path_tsx(file)
        case False{}:
          js_path_if(file, String.ends_with(file, ".ts"))

def js_path(+file: String) -> String:
  js_path_go(file, String.ends_with(file, ".tsx"), String.ends_with(file, ".jsx"))

def basename_go(parts: List<&2, String>) -> String:
  match parts:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      h
    case Con{_, t}:
      basename_go(t)

def basename(s: String) -> String:
  basename_go(String.split(s, '/'))

def drop_last(parts: List<&2, String>) -> List<&2, String>:
  match parts:
    case Nil{}:
      Nil{}
    case Con{_, Nil{}}:
      Nil{}
    case Con{h, t}:
      Con{h, drop_last(t)}

def join_slash(parts: List<&2, String>) -> String:
  match parts:
    case Nil{}:
      "."
    case Con{h, Nil{}}:
      h
    case Con{h, t}:
      h ++ "/" ++ join_slash(t)

def dirname(s: String) -> String:
  join_slash(drop_last(String.split(s, '/')))


def tok_lit(+text: String) -> Token:
  Token{text, 0, 0, 0, 0}

def tok_texts(xs: List<&2, Token>) -> List<&2, String>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{Token{+text, start, end, line, col}, t}:
      Con{text, tok_texts(t)}

def str_len_u32(s: String) -> U32:
  match s:
    case SNil{}:
      0
    case SCon{_, t}:
      U32.inc(str_len_u32(t))

@unsafe def nat_of_u32_k(sel: Nat, +x: U32, z: Bool) -> Nat:
  match sel:
    case 0n:
      nat_of_u32_k(1n, x, U32.is_eq(x, 0))
    case _:
      match z:
        case True{}:
          0n
        case False{}:
          1n+nat_of_u32_k(0n, U32.sub(x, 1), False{})

def nat_of_u32(+x: U32) -> Nat:
  nat_of_u32_k(0n, x, False{})

@unsafe def u32_div_go_k(sel: Nat, +n: U32, +d: U32, q: U32, ge: Bool) -> U32:
  match sel:
    case 0n:
      u32_div_go_k(1n, n, d, q, U32.is_ge(n, d))
    case _:
      match ge:
        case True{}:
          u32_div_go_k(0n, U32.sub(n, d), d, U32.inc(q), False{})
        case False{}:
          q

def u32_div_go(+n: U32, +d: U32, q: U32) -> U32:
  u32_div_go_k(0n, n, d, q, False{})

@unsafe def u32_mod_go_k(sel: Nat, +n: U32, +d: U32, ge: Bool) -> U32:
  match sel:
    case 0n:
      u32_mod_go_k(1n, n, d, U32.is_ge(n, d))
    case _:
      match ge:
        case True{}:
          u32_mod_go_k(0n, U32.sub(n, d), d, False{})
        case False{}:
          n

def u32_mod_go(+n: U32, +d: U32) -> U32:
  u32_mod_go_k(0n, n, d, False{})

def b64_digit(+d: U32) -> String:
  String.take(String.drop("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", nat_of_u32(d)), 1n)

def vlq_signed(+abs_n: U32, neg: Bool) -> U32:
  match neg:
    case True{}:
      U32.inc(U32.add(abs_n, abs_n))
    case False{}:
      U32.add(abs_n, abs_n)

@unsafe def vlq_encode_k(sel: Nat, +n: U32, +digit: U32, +rest: U32, z: Bool) -> String:
  match sel:
    case 0n:
      vlq_encode_k(1n, 0, u32_mod_go(n, 32), u32_div_go(n, 32, 0), False{})
    case 1n:
      vlq_encode_k(2n, 0, digit, rest, U32.is_eq(rest, 0))
    case _:
      match z:
        case True{}:
          b64_digit(digit)
        case False{}:
          b64_digit(U32.add(digit, 32)) ++ vlq_encode_k(0n, rest, 0, 0, False{})

def vlq_encode_go(n: U32) -> String:
  vlq_encode_k(0n, n, 0, 0, False{})

def vlq_encode_rest(+digit: U32, +rest: U32) -> String:
  vlq_encode_k(1n, 0, digit, rest, False{})

def vlq_encode(+abs_n: U32, neg: Bool) -> String:
  vlq_encode_go(vlq_signed(abs_n, neg))

def vlq_delta_ge(ge: Bool, +prev: U32, +cur: U32) -> String:
  match ge:
    case True{}:
      vlq_encode(U32.sub(cur, prev), False{})
    case False{}:
      vlq_encode(U32.sub(prev, cur), True{})

def vlq_delta(+prev: U32, +cur: U32) -> String:
  vlq_delta_ge(U32.is_ge(cur, prev), prev, cur)

def map_seg(+gen_col: U32, +prev_gc: U32, +src_line: U32, +prev_sl: U32, +src_col: U32, +prev_sc: U32) -> String:
  vlq_delta(prev_gc, gen_col) ++ vlq_encode(0, False{}) ++ vlq_delta(prev_sl, src_line) ++ vlq_delta(prev_sc, src_col)

def map_segs_emit(first: Bool, +seg: String) -> String:
  match first:
    case True{}:
      seg
    case False{}:
      "," ++ seg

# sel: 0=scan xs, 1=empty?, 2=emit+join
@unsafe def map_segs_k(sel: Nat, xs: List<&2, Token>, +gen_col: U32, +prev_gc: U32, +prev_sl: U32, +prev_sc: U32, +first: Bool, +empty: Bool, +text: String, +line: U32, +col: U32, +prefix: String, +next_col: U32) -> String:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          ""
        case Con{Token{+text2, start, end, +line2, +col2}, rest}:
          map_segs_k(1n, rest, gen_col, prev_gc, prev_sl, prev_sc, first, String.is_empty(text2), text2, line2, col2, "", 0)
    case 1n:
      match empty:
        case True{}:
          map_segs_k(0n, xs, gen_col, prev_gc, prev_sl, prev_sc, first, False{}, "", 0, 0, "", 0)
        case False{}:
          map_segs_k(2n, xs, gen_col, prev_gc, prev_sl, prev_sc, first, False{}, text, line, col, map_segs_emit(first, map_seg(gen_col, prev_gc, line, prev_sl, col, prev_sc)), U32.add(U32.add(gen_col, str_len_u32(text)), 1))
    case _:
      prefix ++ map_segs_k(0n, xs, next_col, gen_col, line, col, False{}, False{}, "", 0, 0, "", 0)

def map_segs(xs: List<&2, Token>, gen_col: U32, prev_gc: U32, prev_sl: U32, prev_sc: U32, first: Bool) -> String:
  map_segs_k(0n, xs, gen_col, prev_gc, prev_sl, prev_sc, first, False{}, "", 0, 0, "", 0)

def map_mappings(toks: List<&2, Token>) -> String:
  map_segs(toks, 0, 0, 0, 0, True{})

def make_map(+file: String, toks: List<&2, Token>) -> String:
  "{\"version\":3,\"file\":" ++ json_str(basename(js_path(file))) ++ ",\"sources\":[" ++ json_str(file) ++ "],\"names\":[],\"mappings\":" ++ json_str(map_mappings(toks)) ++ "}"

def tok_rev(xs: List<&2, Token>, acc: List<&2, Token>) -> List<&2, Token>:
  match xs:
    case Nil{}:
      acc
    case Con{h, t}:
      tok_rev(t, Con{h, acc})

def str_rev(xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      acc
    case Con{h, t}:
      str_rev(t, Con{h, acc})

def tok_is_num(s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{+h, t}:
      Char.is_digit(h)

def needs_space_side(+s: String) -> Bool:
  Bool.or(tok_is_ident(s), tok_is_num(s))

def needs_space(+a: String, +b: String) -> Bool:
  Bool.and(needs_space_side(a), needs_space_side(b))

# Pretty join: space beside ident/num, but keep multi-char punct ops glued (||, =>, ..., ??).
def needs_pretty_space(+a: String, +b: String) -> Bool:
  Bool.or(needs_space_side(a), needs_space_side(b))

@unsafe def join_sp_go(sel: Nat, +prev: String, xs: List<&2, String>, +h: String, gap: Bool) -> String:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          ""
        case Con{+n, t}:
          join_sp_go(1n, prev, t, n, needs_pretty_space(prev, n))
    case _:
      match gap:
        case True{}:
          " " ++ h ++ join_sp_go(0n, h, xs, "", False{})
        case False{}:
          h ++ join_sp_go(0n, h, xs, "", False{})

def join_sp(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{+h, t}:
      h ++ join_sp_go(0n, h, t, "", False{})

@unsafe def join_min_go(sel: Nat, +prev: String, xs: List<&2, String>, +h: String, gap: Bool) -> String:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          ""
        case Con{+n, t}:
          join_min_go(1n, prev, t, n, needs_space(prev, n))
    case _:
      match gap:
        case True{}:
          " " ++ h ++ join_min_go(0n, h, xs, "", False{})
        case False{}:
          h ++ join_min_go(0n, h, xs, "", False{})

def join_min(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{+h, t}:
      h ++ join_min_go(0n, h, t, "", False{})

def rewrite_ext_if(+s: String, ts: Bool) -> String:
  match ts:
    case True{}:
      String.take(s, nat_sub(String.length(s), 3n)) ++ "js\""
    case False{}:
      s

def rewrite_ext(+s: String) -> String:
  rewrite_ext_if(s, String.ends_with(s, ".ts\""))

def rewrite_texts(xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{+h, t}:
      Con{rewrite_ext(h), rewrite_texts(t)}

def rewrite_tok(+t: Token) -> Token:
  match t:
    case Token{+text, +start, +end, +line, +col}:
      Token{rewrite_ext(text), start, end, line, col}

def rewrite_toks(xs: List<&2, Token>) -> List<&2, Token>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{+h, t}:
      Con{rewrite_tok(h), rewrite_toks(t)}

def toks_retext(toks: List<&2, Token>, texts: List<&2, String>) -> List<&2, Token>:
  match toks texts:
    case Nil{} Nil{}:
      Nil{}
    case Con{Token{_, +start, +end, +line, +col}, t1} Con{+h, t2}:
      Con{Token{h, start, end, line, col}, toks_retext(t1, t2)}
    case _ _:
      Nil{}


def toks_fork_go(xs: List<&2, Token>, acc_txt: List<&2, String>, acc_tok: List<&2, Token>) -> List<&2, String> & List<&2, Token>:
  match xs:
    case Nil{}:
      (str_rev(acc_txt, Nil{}), tok_rev(acc_tok, Nil{}))
    case Con{Token{+text, +start, +end, +line, +col}, t}:
      toks_fork_go(t, Con{text, acc_txt}, Con{Token{text, start, end, line, col}, acc_tok})

def toks_fork(xs: List<&2, Token>) -> List<&2, String> & List<&2, Token>:
  toks_fork_go(xs, Nil{}, Nil{})


def transpile_pick_min(+file: String, pair: List<&2, String> & List<&2, Token>) -> TRes:
  (texts, toks) = pair
  TOk{join_min(texts), make_map(file, toks)}

def transpile_pick_full(+file: String, pair: List<&2, String> & List<&2, Token>) -> TRes:
  (texts, toks) = pair
  TOk{join_sp(texts), make_map(file, toks)}

def transpile_pick_pair(+file: String, minify: Bool, pair: List<&2, String> & List<&2, Token>) -> TRes:
  match minify:
    case True{}:
      transpile_pick_min(file, pair)
    case False{}:
      transpile_pick_full(file, pair)

def transpile_pick(+file: String, toks: List<&2, Token>, minify: Bool) -> TRes:
  transpile_pick_pair(file, minify, toks_fork(rewrite_toks(toks)))



def f_bool() -> Bool:
  False{}

def dummy_tok() -> Token:
  Token{"", 0, 0, 0, 0}

@unsafe def lex_go(sel: Nat, st: Lx) -> LexRes:
  match sel:
    case 0n:
      match st:
        case Lx{+rest, +pos, +line, +col, +acc, ch, ident_acc, start, sl, sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
          match rest:
            case SNil{}:
              LexOk{tok_rev(acc, Nil{})}
            case SCon{+h, t}:
              lex_go(1n, Lx{t, pos, line, col, acc, h, SNil{}, pos, line, col, Char.is_space(h), Char.is_eq(h, '\n'), is_id_start(h), Char.is_digit(h), Char.is_eq(h, '/'), is_punct(h), is_id_cont(h)})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Lx{+rest, +pos, +line, +col, +acc, +ch, ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
              match ch:
                case ' ':
                  lex_go(0n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case '\t':
                  lex_go(0n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case '\r':
                  lex_go(0n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case '\n':
                  lex_go(0n, Lx{rest, U32.inc(pos), U32.inc(line), 0, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case '/':
                  lex_go(6n, Lx{rest, pos, line, col, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case '"':
                  lex_go(15n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{'"', SNil{}}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                case _:
                  lex_go(12n, Lx{rest, pos, line, col, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), is_id_start(ch), Char.is_digit(ch), f_bool(), is_punct(ch), is_id_cont(ch)})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Lx{+rest, +pos, +line, +col, +acc, ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                  match rest:
                    case SNil{}:
                      lex_go(0n, Lx{SNil{}, pos, line, col, Con{Token{String.reverse(ident_acc), start, pos, sl, sc}, acc}, ch, SNil{}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                    case SCon{+h, t}:
                      lex_go(3n, Lx{t, pos, line, col, acc, h, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), is_id_cont(h)})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Lx{+rest, +pos, +line, +col, +acc, +ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, +b_idcont}:
                      match b_idcont:
                        case True{}:
                          lex_go(2n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{ch, ident_acc}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                        case False{}:
                          lex_go(1n, Lx{rest, pos, line, col, Con{Token{String.reverse(ident_acc), start, pos, sl, sc}, acc}, ch, SNil{}, pos, line, col, Char.is_space(ch), Char.is_eq(ch, '\n'), is_id_start(ch), Char.is_digit(ch), Char.is_eq(ch, '/'), is_punct(ch), is_id_cont(ch)})
                case 1n+s4:
                  match s4:
                    case 0n:
                      match st:
                        case Lx{+rest, +pos, +line, +col, +acc, ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                          match rest:
                            case SNil{}:
                              lex_go(0n, Lx{SNil{}, pos, line, col, Con{Token{String.reverse(ident_acc), start, pos, sl, sc}, acc}, ch, SNil{}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                            case SCon{+h, t}:
                              lex_go(5n, Lx{t, pos, line, col, acc, h, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), Char.is_digit(h), f_bool(), f_bool(), f_bool()})
                    case 1n+s5:
                      match s5:
                        case 0n:
                          match st:
                            case Lx{+rest, +pos, +line, +col, +acc, +ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, +b_digit, b_slash, b_punct, b_idcont}:
                              match b_digit:
                                case True{}:
                                  lex_go(4n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{ch, ident_acc}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                case False{}:
                                  lex_go(1n, Lx{rest, pos, line, col, Con{Token{String.reverse(ident_acc), start, pos, sl, sc}, acc}, ch, SNil{}, pos, line, col, Char.is_space(ch), Char.is_eq(ch, '\n'), is_id_start(ch), Char.is_digit(ch), Char.is_eq(ch, '/'), is_punct(ch), is_id_cont(ch)})
                        case 1n+s6:
                          match s6:
                            case 0n:
                              match st:
                                case Lx{+rest, pos, +line, col, +acc, ch, ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                  match rest:
                                    case SNil{}:
                                      lex_go(0n, Lx{SNil{}, U32.inc(start), line, U32.inc(sc), Con{Token{"/", start, U32.inc(start), sl, sc}, acc}, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                    case SCon{'/', t}:
                                      lex_go(7n, Lx{t, U32.add(start, 2), line, U32.add(sc, 2), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                    case SCon{'*', t}:
                                      lex_go(8n, Lx{t, U32.add(start, 2), line, U32.add(sc, 2), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                    case SCon{+h, t}:
                                      lex_go(1n, Lx{t, U32.inc(start), line, U32.inc(sc), Con{Token{"/", start, U32.inc(start), sl, sc}, acc}, h, SNil{}, U32.inc(start), line, U32.inc(sc), Char.is_space(h), Char.is_eq(h, '\n'), is_id_start(h), Char.is_digit(h), Char.is_eq(h, '/'), is_punct(h), is_id_cont(h)})
                            case 1n+s7:
                              match s7:
                                case 0n:
                                  match st:
                                    case Lx{+rest, +pos, +line, +col, +acc, ch, ident_acc, start, sl, sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                      match rest:
                                        case SNil{}:
                                          lex_go(0n, Lx{SNil{}, pos, line, col, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                        case SCon{'\n', t}:
                                          lex_go(0n, Lx{t, U32.inc(pos), U32.inc(line), 0, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                        case SCon{_, t}:
                                          lex_go(7n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                case 1n+s8:
                                  match s8:
                                    case 0n:
                                      match st:
                                        case Lx{+rest, +pos, +line, +col, +acc, ch, ident_acc, start, sl, sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                          match rest:
                                            case SNil{}:
                                              LexErr{"unterminated comment", line, col}
                                            case SCon{'*', t}:
                                              lex_go(9n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                            case SCon{'\n', t}:
                                              lex_go(8n, Lx{t, U32.inc(pos), U32.inc(line), 0, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                            case SCon{_, t}:
                                              lex_go(8n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                    case 1n+s9:
                                      match s9:
                                        case 0n:
                                          match st:
                                            case Lx{+rest, +pos, +line, +col, +acc, ch, ident_acc, start, sl, sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                              match rest:
                                                case SNil{}:
                                                  LexErr{"unterminated comment", line, col}
                                                case SCon{'/', t}:
                                                  lex_go(0n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                case SCon{'*', t}:
                                                  lex_go(9n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                case SCon{'\n', t}:
                                                  lex_go(8n, Lx{t, U32.inc(pos), U32.inc(line), 0, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                case SCon{_, t}:
                                                  lex_go(8n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                        case 1n+s10:
                                          match s10:
                                            case 0n:
                                              LexErr{"unexpected character", 0, 0}
                                            case 1n+s11:
                                              match s11:
                                                case 0n:
                                                  LexErr{"unexpected character", 0, 0}
                                                case 1n+s12:
                                                  match s12:
                                                    case 0n:
                                                      match st:
                                                        case Lx{+rest, +pos, +line, +col, +acc, +ch, ident_acc, +start, +sl, +sc, b_space, b_nl, +b_id, +b_digit, b_slash, +b_punct, b_idcont}:
                                                          match b_id:
                                                            case True{}:
                                                              lex_go(2n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{ch, SNil{}}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                            case False{}:
                                                              lex_go(13n, Lx{rest, pos, line, col, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), b_id, b_digit, f_bool(), b_punct, f_bool()})
                                                    case 1n+s13:
                                                      match s13:
                                                        case 0n:
                                                          match st:
                                                            case Lx{+rest, +pos, +line, +col, +acc, +ch, ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, +b_digit, b_slash, +b_punct, b_idcont}:
                                                              match b_digit:
                                                                case True{}:
                                                                  lex_go(4n, Lx{rest, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{ch, SNil{}}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                                case False{}:
                                                                  lex_go(14n, Lx{rest, pos, line, col, acc, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), b_digit, f_bool(), b_punct, f_bool()})
                                                        case 1n+s14:
                                                          match s14:
                                                            case 0n:
                                                              match st:
                                                                case Lx{+rest, +pos, +line, +col, +acc, +ch, ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, +b_punct, b_idcont}:
                                                                  match b_punct:
                                                                    case True{}:
                                                                      lex_go(0n, Lx{rest, U32.inc(pos), line, U32.inc(col), Con{Token{SCon{ch, SNil{}}, start, U32.inc(start), sl, sc}, acc}, ch, ident_acc, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                                    case False{}:
                                                                      LexErr{"unexpected character " ++ Char.show(ch), sl, sc}
                                                            case 1n+s15:
                                                              match s15:
                                                                case 0n:
                                                                  match st:
                                                                    case Lx{+rest, +pos, +line, +col, +acc, ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                                                      match rest:
                                                                        case SNil{}:
                                                                          LexErr{"unterminated string", line, col}
                                                                        case SCon{'"', t}:
                                                                          lex_go(0n, Lx{t, U32.inc(pos), line, U32.inc(col), Con{Token{String.reverse(SCon{'"', ident_acc}), start, U32.inc(pos), sl, sc}, acc}, ch, SNil{}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                                        case SCon{'\\', t}:
                                                                          lex_go(16n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{'\\', ident_acc}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                                        case SCon{'\n', t}:
                                                                          LexErr{"unterminated string", line, col}
                                                                        case SCon{+h, t}:
                                                                          lex_go(15n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{h, ident_acc}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})
                                                                case _:
                                                                  match st:
                                                                    case Lx{+rest, +pos, +line, +col, +acc, ch, +ident_acc, +start, +sl, +sc, b_space, b_nl, b_id, b_digit, b_slash, b_punct, b_idcont}:
                                                                      match rest:
                                                                        case SNil{}:
                                                                          LexErr{"unterminated string", line, col}
                                                                        case SCon{+h, t}:
                                                                          lex_go(15n, Lx{t, U32.inc(pos), line, U32.inc(col), acc, ch, SCon{h, ident_acc}, start, sl, sc, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})


def lex(src: String) -> LexRes:
  lex_go(0n, Lx{src, 0, 0, 0, Nil{}, ' ', SNil{}, 0, 0, 0, f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool(), f_bool()})

@unsafe def xform(sel: Nat, st: Xs) -> List<&2, Token>:
  match sel:
    case 0n:
      match st:
        case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
          match tokens:
            case Nil{}:
              tok_rev(acc, Nil{})
            case Con{Token{+text2, +start, +end, +line, +col}, rest2}:
              xform(1n, Xs{tokens, acc, 0, text2, rest2, Token{text2, start, end, line, col}, String.eq(text2, ":")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
              match flag:
                case True{}:
                  xform(9n, Xs{rest, acc, 0, ":", rest, dummy_tok(), f_bool()})
                case False{}:
                  xform(18n, Xs{tokens, acc, 0, text, rest, tok, String.eq(text, "enum")})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Xs{+tokens, +acc, +depth, text, rest, tok, flag}:
                  match tokens:
                    case Nil{}:
                      tok_rev(acc, Nil{})
                    case Con{Token{+text2, +start, +end, +line, +col}, rest2}:
                      xform(3n, Xs{tokens, acc, depth, text2, rest2, Token{text2, start, end, line, col}, is_ty_term_at(text2, depth)})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Xs{tokens, +acc, +depth, +text, +rest, +tok, +flag}:
                      match flag:
                        case True{}:
                          xform(0n, Xs{Con{tok, rest}, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                        case False{}:
                          xform(2n, Xs{rest, acc, depth_next(text, depth), "", Nil{}, dummy_tok(), f_bool()})
                case 1n+s4:
                  match s4:
                    case 0n:
                      match st:
                        case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
                          match flag:
                            case True{}:
                              xform(14n, Xs{rest, acc, 0, "import", rest, dummy_tok(), f_bool()})
                            case False{}:
                              xform(12n, Xs{tokens, acc, 0, text, rest, tok, is_type_kw(text)})
                    case 1n+s5:
                      match s5:
                        case 0n:
                          match st:
                            case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
                              match flag:
                                case True{}:
                                  xform(6n, Xs{rest, acc, 0, "export", rest, dummy_tok(), f_bool()})
                                case False{}:
                                  xform(0n, Xs{rest, Con{tok, acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                        case 1n+s6:
                          match s6:
                            case 0n:
                              match st:
                                case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                  match tokens:
                                    case Nil{}:
                                      xform(0n, Xs{Nil{}, Con{tok_lit("export"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                    case Con{Token{+text2, start, end, line, col}, rest2}:
                                      xform(11n, Xs{tokens, acc, 0, text2, rest2, dummy_tok(), is_type_kw(text2)})
                            case 1n+s7:
                              match s7:
                                case 0n:
                                  match st:
                                    case Xs{+tokens, +acc, +depth, text, rest, tok, flag}:
                                      match tokens:
                                        case Nil{}:
                                          tok_rev(acc, Nil{})
                                        case Con{Token{+text2, start, end, line, col}, +rest2}:
                                          xform(8n, Xs{rest2, acc, depth, text2, rest2, dummy_tok(), decl_stop(text2, depth, decl_depth(text2, depth))})
                                case 1n+s8:
                                  match s8:
                                    case 0n:
                                      match st:
                                        case Xs{tokens, +acc, +depth, +text, +rest, tok, +flag}:
                                          match flag:
                                            case True{}:
                                              xform(0n, Xs{rest, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                            case False{}:
                                              xform(7n, Xs{rest, acc, decl_depth(text, depth), "", Nil{}, dummy_tok(), f_bool()})
                                    case 1n+s9:
                                      match s9:
                                        case 0n:
                                          match st:
                                            case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                              match tokens:
                                                case Nil{}:
                                                  xform(0n, Xs{Nil{}, Con{tok_lit(":"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                case Con{Token{+text2, start, end, line, col}, rest2}:
                                                  xform(10n, Xs{tokens, acc, 0, text2, rest2, dummy_tok(), colon_is_type_at(acc, text2)})
                                        case 1n+s10:
                                          match s10:
                                            case 0n:
                                              match st:
                                                case Xs{+tokens, +acc, depth, text, rest, tok, +flag}:
                                                  match flag:
                                                    case True{}:
                                                      xform(2n, Xs{tokens, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                    case False{}:
                                                      xform(0n, Xs{tokens, Con{tok_lit(":"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                            case 1n+s11:
                                              match s11:
                                                case 0n:
                                                  match st:
                                                    case Xs{+tokens, +acc, depth, text, rest, tok, +flag}:
                                                      match flag:
                                                        case True{}:
                                                          xform(0n, Xs{tokens, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                        case False{}:
                                                          xform(0n, Xs{tokens, Con{tok_lit("export"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                case 1n+s12:
                                                  match s12:
                                                    case 0n:
                                                      match st:
                                                        case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
                                                          match flag:
                                                            case True{}:
                                                              xform(7n, Xs{rest, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                            case False{}:
                                                              xform(13n, Xs{tokens, acc, 0, text, rest, tok, Bool.or(String.eq(text, "as"), String.eq(text, "satisfies"))})
                                                    case 1n+s13:
                                                      match s13:
                                                        case 0n:
                                                          match st:
                                                            case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
                                                              match flag:
                                                                case True{}:
                                                                  xform(2n, Xs{rest, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                case False{}:
                                                                  xform(5n, Xs{tokens, acc, 0, text, rest, tok, String.eq(text, "export")})
                                                        case 1n+s14:
                                                          match s14:
                                                            case 0n:
                                                              match st:
                                                                case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                                                  match tokens:
                                                                    case Nil{}:
                                                                      xform(0n, Xs{Nil{}, Con{tok_lit("import"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                    case Con{Token{+text2, start, end, line, col}, rest2}:
                                                                      xform(15n, Xs{tokens, acc, 0, text2, rest2, dummy_tok(), String.eq(text2, "type")})
                                                            case 1n+s15:
                                                              match s15:
                                                                case 0n:
                                                                  match st:
                                                                    case Xs{+tokens, +acc, depth, text, rest, tok, +flag}:
                                                                      match flag:
                                                                        case True{}:
                                                                          xform(16n, Xs{tokens, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                        case False{}:
                                                                          xform(0n, Xs{tokens, Con{tok_lit("import"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                case 1n+s16:
                                                                  match s16:
                                                                    case 0n:
                                                                      match st:
                                                                        case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                                                          match tokens:
                                                                            case Nil{}:
                                                                              tok_rev(acc, Nil{})
                                                                            case Con{Token{+text2, start, end, line, col}, +rest2}:
                                                                              xform(17n, Xs{rest2, acc, 0, text2, rest2, dummy_tok(), String.eq(text2, ";")})
                                                                    case 1n+s17:
                                                                      match s17:
                                                                        case 0n:
                                                                          match st:
                                                                            case Xs{tokens, +acc, depth, text, +rest, tok, +flag}:
                                                                              match flag:
                                                                                case True{}:
                                                                                  xform(0n, Xs{rest, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                                case False{}:
                                                                                  xform(16n, Xs{rest, acc, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                        case 1n+s18:
                                                                          match s18:
                                                                            case 0n:
                                                                              match st:
                                                                                case Xs{tokens, +acc, depth, +text, +rest, +tok, +flag}:
                                                                                  match flag:
                                                                                    case True{}:
                                                                                      xform(19n, Xs{rest, Con{tok_lit("const"), acc}, 0, "", rest, dummy_tok(), f_bool()})
                                                                                    case False{}:
                                                                                      xform(4n, Xs{tokens, acc, 0, text, rest, tok, String.eq(text, "import")})
                                                                            case 1n+s19:
                                                                              match s19:
                                                                                case 0n:
                                                                                  match st:
                                                                                    case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                                                                      match tokens:
                                                                                        case Nil{}:
                                                                                          tok_rev(acc, Nil{})
                                                                                        case Con{Token{+text2, start, end, line, col}, rest2}:
                                                                                          xform(20n, Xs{rest2, Con{tok_lit("="), Con{Token{text2, start, end, line, col}, acc}}, 0, "", rest2, dummy_tok(), f_bool()})
                                                                                case 1n+s20:
                                                                                  match s20:
                                                                                    case 0n:
                                                                                      match st:
                                                                                        case Xs{+tokens, +acc, depth, text, rest, tok, flag}:
                                                                                          match tokens:
                                                                                            case Nil{}:
                                                                                              tok_rev(acc, Nil{})
                                                                                            case Con{Token{+text2, start, end, line, col}, +rest2}:
                                                                                              xform(21n, Xs{rest2, acc, 0, text2, rest2, dummy_tok(), String.eq(text2, "=")})
                                                                                    case 1n+s21:
                                                                                      match s21:
                                                                                        case 0n:
                                                                                          match st:
                                                                                            case Xs{tokens, +acc, depth, +text, +rest, tok, +flag}:
                                                                                              match flag:
                                                                                                case True{}:
                                                                                                  xform(20n, Xs{rest, Con{tok_lit(":"), acc}, 0, "", rest, dummy_tok(), f_bool()})
                                                                                                case False{}:
                                                                                                  xform(22n, Xs{rest, Con{tok_lit(text), acc}, 0, text, rest, dummy_tok(), String.eq(text, "}")})
                                                                                        case _:
                                                                                          match st:
                                                                                            case Xs{tokens, +acc, depth, text, +rest, tok, +flag}:
                                                                                              match flag:
                                                                                                case True{}:
                                                                                                  xform(0n, Xs{rest, Con{tok_lit(";"), acc}, 0, "", Nil{}, dummy_tok(), f_bool()})
                                                                                                case False{}:
                                                                                                  xform(20n, Xs{rest, acc, 0, "", rest, dummy_tok(), f_bool()})


def transpile_emit(+file: String, toks: List<&2, Token>) -> TRes:
  transpile_pick_full(file, toks_fork(rewrite_toks(toks)))

def transpile_lex(+file: String, lr: LexRes) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{tokens}:
      transpile_emit(file, xform(0n, Xs{tokens, Nil{}, 0, "", Nil{}, dummy_tok(), f_bool()}))

def transpile(+file: String, source: String) -> TRes:
  transpile_lex(file, lex(source))

def transpile_lex_min(+file: String, lr: LexRes, minify: Bool) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{tokens}:
      transpile_pick(file, xform(0n, Xs{tokens, Nil{}, 0, "", Nil{}, dummy_tok(), f_bool()}), minify)

def transpile_min(+file: String, source: String, minify: Bool) -> TRes:
  transpile_lex_min(file, lex(source), minify)


def export_kw(+t: String) -> Bool:
  Bool.or(String.eq(t, "function"), Bool.or(String.eq(t, "const"), Bool.or(String.eq(t, "let"), Bool.or(String.eq(t, "var"), String.eq(t, "class")))))

@unsafe def scan_go(sel: Nat, st: Sc) -> List<&2, String>:
  match sel:
    case 0n:
      match st:
        case Sc{+tokens, +acc, text, flag}:
          match tokens:
            case Nil{}:
              str_rev(acc, Nil{})
            case Con{Token{+text2, start, end, line, col}, rest2}:
              scan_go(1n, Sc{rest2, acc, text2, String.eq(text2, "export")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Sc{+tokens, +acc, text, +flag}:
              match flag:
                case True{}:
                  scan_go(2n, Sc{tokens, acc, "", f_bool()})
                case False{}:
                  scan_go(0n, Sc{tokens, acc, "", f_bool()})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Sc{+tokens, +acc, text, flag}:
                  match tokens:
                    case Nil{}:
                      str_rev(acc, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      scan_go(3n, Sc{rest2, acc, text2, export_kw(text2)})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Sc{+tokens, +acc, text, +flag}:
                      match flag:
                        case True{}:
                          scan_go(4n, Sc{tokens, acc, "", f_bool()})
                        case False{}:
                          scan_go(0n, Sc{tokens, acc, "", f_bool()})
                case _:
                  match st:
                    case Sc{+tokens, +acc, text, flag}:
                      match tokens:
                        case Nil{}:
                          str_rev(acc, Nil{})
                        case Con{Token{+text2, start, end, line, col}, rest2}:
                          scan_go(0n, Sc{rest2, Con{text2, acc}, "", f_bool()})


def unquote_tail(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'"', SNil{}}:
      ""
    case SCon{h, t}:
      SCon{h, unquote_tail(t)}

def unquote(s: String) -> String:
  match s:
    case SCon{'"', t}:
      unquote_tail(t)
    case _:
      s

def is_string_tok(s: String) -> Bool:
  match s:
    case SCon{'"', t}:
      True{}
    case _:
      False{}

def import_acc_if(acc: List<&2, String>, text: String, ok: Bool) -> List<&2, String>:
  match ok:
    case True{}:
      Con{unquote(text), acc}
    case False{}:
      acc

def import_acc(acc: List<&2, String>, +text: String) -> List<&2, String>:
  import_acc_if(acc, text, is_string_tok(text))

@unsafe def scan_imp(sel: Nat, st: Sc) -> List<&2, String>:
  match sel:
    case 0n:
      match st:
        case Sc{+tokens, +acc, text, flag}:
          match tokens:
            case Nil{}:
              str_rev(acc, Nil{})
            case Con{Token{+text2, start, end, line, col}, rest2}:
              scan_imp(1n, Sc{rest2, acc, text2, String.eq(text2, "import")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Sc{+tokens, +acc, +text, +flag}:
              match flag:
                case True{}:
                  scan_imp(2n, Sc{tokens, acc, "", f_bool()})
                case False{}:
                  scan_imp(5n, Sc{tokens, acc, text, String.eq(text, "from")})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Sc{+tokens, +acc, text, flag}:
                  match tokens:
                    case Nil{}:
                      str_rev(acc, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      scan_imp(3n, Sc{rest2, acc, text2, String.eq(text2, "type")})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Sc{+tokens, +acc, text, +flag}:
                      match flag:
                        case True{}:
                          scan_imp(4n, Sc{tokens, acc, "", f_bool()})
                        case False{}:
                          scan_imp(0n, Sc{tokens, acc, "", f_bool()})
                case 1n+s4:
                  match s4:
                    case 0n:
                      match st:
                        case Sc{+tokens, +acc, text, flag}:
                          match tokens:
                            case Nil{}:
                              str_rev(acc, Nil{})
                            case Con{Token{+text2, start, end, line, col}, rest2}:
                              scan_imp(6n, Sc{rest2, acc, text2, String.eq(text2, ";")})
                    case 1n+s5:
                      match s5:
                        case 0n:
                          match st:
                            case Sc{+tokens, +acc, text, +flag}:
                              match flag:
                                case True{}:
                                  scan_imp(7n, Sc{tokens, acc, "", f_bool()})
                                case False{}:
                                  scan_imp(0n, Sc{tokens, acc, "", f_bool()})
                        case 1n+s6:
                          match s6:
                            case 0n:
                              match st:
                                case Sc{+tokens, +acc, text, +flag}:
                                  match flag:
                                    case True{}:
                                      scan_imp(0n, Sc{tokens, acc, "", f_bool()})
                                    case False{}:
                                      scan_imp(4n, Sc{tokens, acc, "", f_bool()})
                            case _:
                              match st:
                                case Sc{+tokens, +acc, text, flag}:
                                  match tokens:
                                    case Nil{}:
                                      str_rev(acc, Nil{})
                                    case Con{Token{+text2, start, end, line, col}, rest2}:
                                      scan_imp(0n, Sc{rest2, import_acc(acc, text2), "", f_bool()})

def scan_json(+file: String, exports: List<&2, String>, imports: List<&2, String>) -> String:
  "{\"file\":" ++ json_str(file) ++ ",\"exports\":" ++ json_list(exports) ++ ",\"imports\":" ++ json_list(imports) ++ "}"

def scan_lex(+file: String, lr: LexRes) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{+tokens}:
      TOk{scan_json(file, scan_go(0n, Sc{tokens, Nil{}, "", f_bool()}), scan_imp(0n, Sc{tokens, Nil{}, "", f_bool()})), ""}

def scan(+file: String, source: String) -> TRes:
  scan_lex(file, lex(source))

def join_rel_dot(+dir: String, +rel: String, dot: Bool) -> String:
  match dot:
    case True{}:
      rel
    case False{}:
      dir ++ "/" ++ rel

def join_rel(+dir: String, +rel: String) -> String:
  join_rel_dot(dir, rel, String.eq(dir, "."))

def resolve_rel_if(+importer: String, +spec: String, rel: Bool) -> String:
  match rel:
    case True{}:
      join_rel(dirname(importer), String.drop(spec, 2n))
    case False{}:
      spec

def resolve_rel(+importer: String, +spec: String) -> String:
  resolve_rel_if(importer, spec, String.starts_with(spec, "./"))

def is_rel(+spec: String) -> Bool:
  String.starts_with(spec, "./")

def pkg_index_js(+spec: String) -> String:
  "node_modules/" ++ spec ++ "/index.js"

def pkg_index_ts(+spec: String) -> String:
  "node_modules/" ++ spec ++ "/index.ts"

def pkg_json(+spec: String) -> String:
  "node_modules/" ++ spec ++ "/package.json"

def strip_dot_if(+s: String, d: Bool) -> String:
  match d:
    case True{}:
      String.drop(s, 2n)
    case False{}:
      s

@unsafe def scan_dyn(sel: Nat, st: Sc) -> List<&2, String>:
  match sel:
    case 0n:
      match st:
        case Sc{+tokens, +acc, text, flag}:
          match tokens:
            case Nil{}:
              str_rev(acc, Nil{})
            case Con{Token{+text2, start, end, line, col}, rest2}:
              scan_dyn(1n, Sc{rest2, acc, text2, String.eq(text2, "import")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Sc{+tokens, +acc, text, +flag}:
              match flag:
                case True{}:
                  scan_dyn(2n, Sc{tokens, acc, "", f_bool()})
                case False{}:
                  scan_dyn(0n, Sc{tokens, acc, "", f_bool()})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Sc{+tokens, +acc, text, flag}:
                  match tokens:
                    case Nil{}:
                      str_rev(acc, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      scan_dyn(3n, Sc{rest2, acc, text2, String.eq(text2, "(")})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Sc{+tokens, +acc, text, +flag}:
                      match flag:
                        case True{}:
                          scan_dyn(4n, Sc{tokens, acc, "", f_bool()})
                        case False{}:
                          scan_dyn(0n, Sc{tokens, acc, "", f_bool()})
                case _:
                  match st:
                    case Sc{+tokens, +acc, text, flag}:
                      match tokens:
                        case Nil{}:
                          str_rev(acc, Nil{})
                        case Con{Token{+text2, start, end, line, col}, rest2}:
                          scan_dyn(0n, Sc{rest2, import_acc(acc, text2), "", f_bool()})

def dyn_imports_lex(lr: LexRes) -> List<&2, String>:
  match lr:
    case LexErr{msg, line, col}:
      Nil{}
    case LexOk{tokens}:
      scan_dyn(0n, Sc{tokens, Nil{}, "", f_bool()})

def dyn_imports_of(source: String) -> List<&2, String>:
  dyn_imports_lex(lex(source))

@unsafe def scan_req(sel: Nat, st: Sc) -> List<&2, String>:
  match sel:
    case 0n:
      match st:
        case Sc{+tokens, +acc, text, flag}:
          match tokens:
            case Nil{}:
              str_rev(acc, Nil{})
            case Con{Token{+text2, start, end, line, col}, rest2}:
              scan_req(1n, Sc{rest2, acc, text2, String.eq(text2, "require")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Sc{+tokens, +acc, text, +flag}:
              match flag:
                case True{}:
                  scan_req(2n, Sc{tokens, acc, "", f_bool()})
                case False{}:
                  scan_req(0n, Sc{tokens, acc, "", f_bool()})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Sc{+tokens, +acc, text, flag}:
                  match tokens:
                    case Nil{}:
                      str_rev(acc, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      scan_req(3n, Sc{rest2, acc, text2, String.eq(text2, "(")})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Sc{+tokens, +acc, text, +flag}:
                      match flag:
                        case True{}:
                          scan_req(4n, Sc{tokens, acc, "", f_bool()})
                        case False{}:
                          scan_req(0n, Sc{tokens, acc, "", f_bool()})
                case _:
                  match st:
                    case Sc{+tokens, +acc, text, flag}:
                      match tokens:
                        case Nil{}:
                          str_rev(acc, Nil{})
                        case Con{Token{+text2, start, end, line, col}, rest2}:
                          scan_req(0n, Sc{rest2, import_acc(acc, text2), "", f_bool()})

def requires_lex(lr: LexRes) -> List<&2, String>:
  match lr:
    case LexErr{msg, line, col}:
      Nil{}
    case LexOk{tokens}:
      scan_req(0n, Sc{tokens, Nil{}, "", f_bool()})

def requires_of(source: String) -> List<&2, String>:
  requires_lex(lex(source))



def strip_dot(+s: String) -> String:
  strip_dot_if(s, String.starts_with(s, "./"))

def pkg_join(+spec: String, +main: String) -> String:
  "node_modules/" ++ spec ++ "/" ++ strip_dot(main)



def imports_lex(lr: LexRes) -> List<&2, String>:
  match lr:
    case LexErr{msg, line, col}:
      Nil{}
    case LexOk{tokens}:
      scan_imp(0n, Sc{tokens, Nil{}, "", f_bool()})

def imports_of(source: String) -> List<&2, String>:
  imports_lex(lex(source))

def exports_lex(lr: LexRes) -> List<&2, String>:
  match lr:
    case LexErr{msg, line, col}:
      Nil{}
    case LexOk{tokens}:
      scan_go(0n, Sc{tokens, Nil{}, "", f_bool()})

def exports_of(source: String) -> List<&2, String>:
  exports_lex(lex(source))

@unsafe def strip_ie(sel: Nat, st: Ts) -> List<&2, Token>:
  match sel:
    case 0n:
      match st:
        case Ts{+tokens, +acc, tok, text, flag}:
          match tokens:
            case Nil{}:
              tok_rev(acc, Nil{})
            case Con{+tok2, rest2}:
              Token{+text2, start, end, line, col} = tok2
              strip_ie(1n, Ts{rest2, acc, tok2, text2, String.eq(text2, "import")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Ts{+tokens, +acc, +tok, +text, +flag}:
              match flag:
                case True{}:
                  strip_ie(5n, Ts{tokens, acc, tok, text, f_bool()})
                case False{}:
                  strip_ie(2n, Ts{tokens, acc, tok, text, String.eq(text, "export")})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Ts{+tokens, +acc, +tok, text, +flag}:
                  match flag:
                    case True{}:
                      strip_ie(0n, Ts{tokens, acc, dummy_tok(), "", f_bool()})
                    case False{}:
                      strip_ie(0n, Ts{tokens, Con{tok, acc}, dummy_tok(), "", f_bool()})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Ts{+tokens, +acc, tok, text, flag}:
                      match tokens:
                        case Nil{}:
                          tok_rev(acc, Nil{})
                        case Con{Token{+text2, start, end, line, col}, rest2}:
                          strip_ie(4n, Ts{rest2, acc, dummy_tok(), text2, String.eq(text2, ";")})
                case 1n+s4:
                  match s4:
                    case 0n:
                      match st:
                        case Ts{+tokens, +acc, tok, text, +flag}:
                          match flag:
                            case True{}:
                              strip_ie(0n, Ts{tokens, acc, dummy_tok(), "", f_bool()})
                            case False{}:
                              strip_ie(3n, Ts{tokens, acc, dummy_tok(), "", f_bool()})
                    case 1n+s5:
                      match s5:
                        case 0n:
                          match st:
                            case Ts{+tokens, +acc, +tok, text, flag}:
                              match tokens:
                                case Nil{}:
                                  strip_ie(0n, Ts{Nil{}, Con{tok, acc}, dummy_tok(), "", f_bool()})
                                case Con{Token{+text2, start, end, line, col}, rest2}:
                                  strip_ie(6n, Ts{rest2, acc, tok, text2, String.eq(text2, "(")})
                        case _:
                          match st:
                            case Ts{+tokens, +acc, +tok, +text, +flag}:
                              match flag:
                                case True{}:
                                  strip_ie(0n, Ts{Con{Token{"(", 0, 0, 0, 0}, tokens}, Con{tok, acc}, dummy_tok(), "", f_bool()})
                                case False{}:
                                  strip_ie(3n, Ts{Con{Token{text, 0, 0, 0, 0}, tokens}, acc, dummy_tok(), "", f_bool()})

def transpile_bundle_lex(+file: String, lr: LexRes) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{tokens}:
      transpile_emit(file, xform(0n, Xs{strip_ie(0n, Ts{tokens, Nil{}, dummy_tok(), "", f_bool()}), Nil{}, 0, "", Nil{}, dummy_tok(), f_bool()}))

def transpile_bundle(+file: String, source: String) -> TRes:
  transpile_bundle_lex(file, lex(source))

@unsafe def has_name(sel: Nat, xs: List<&2, String>, +f: String, eq: Bool) -> Bool:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          False{}
        case Con{+h, t}:
          has_name(1n, t, f, String.eq(h, f))
    case _:
      match eq:
        case True{}:
          True{}
        case False{}:
          has_name(0n, xs, f, False{})

@unsafe def scan_nm(sel: Nat, st: Sc) -> List<&2, String>:
  match sel:
    case 0n:
      match st:
        case Sc{+tokens, +acc, text, flag}:
          match tokens:
            case Nil{}:
              str_rev(acc, Nil{})
            case Con{Token{+text2, start, end, line, col}, rest2}:
              scan_nm(1n, Sc{rest2, acc, text2, String.eq(text2, "import")})
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Sc{+tokens, +acc, text, +flag}:
              match flag:
                case True{}:
                  scan_nm(2n, Sc{tokens, acc, "", f_bool()})
                case False{}:
                  scan_nm(0n, Sc{tokens, acc, "", f_bool()})
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Sc{+tokens, +acc, text, flag}:
                  match tokens:
                    case Nil{}:
                      str_rev(acc, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      scan_nm(3n, Sc{rest2, acc, text2, String.eq(text2, "from")})
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Sc{+tokens, +acc, +text, +flag}:
                      match flag:
                        case True{}:
                          scan_nm(0n, Sc{tokens, acc, "", f_bool()})
                        case False{}:
                          scan_nm(4n, Sc{tokens, acc, text, tok_is_ident(text)})
                case _:
                  match st:
                    case Sc{+tokens, +acc, +text, +flag}:
                      match flag:
                        case True{}:
                          scan_nm(2n, Sc{tokens, Con{text, acc}, "", f_bool()})
                        case False{}:
                          scan_nm(2n, Sc{tokens, acc, "", f_bool()})

def import_names_lex(lr: LexRes) -> List<&2, String>:
  match lr:
    case LexErr{msg, line, col}:
      Nil{}
    case LexOk{tokens}:
      scan_nm(0n, Sc{tokens, Nil{}, "", f_bool()})

def import_names_of(source: String) -> List<&2, String>:
  import_names_lex(lex(source))

@unsafe def shake_go(sel: Nat, st: Ts, +keep: List<&2, String>, +depth: U32) -> List<&2, Token>:
  match sel:
    case 0n:
      match st:
        case Ts{+tokens, +acc, tok, text, flag}:
          match tokens:
            case Nil{}:
              tok_rev(acc, Nil{})
            case Con{+tok2, rest2}:
              Token{+text2, start, end, line, col} = tok2
              shake_go(1n, Ts{rest2, acc, tok2, text2, String.eq(text2, "function")}, keep, 0)
    case 1n+s1:
      match s1:
        case 0n:
          match st:
            case Ts{+tokens, +acc, +tok, text, +flag}:
              match flag:
                case True{}:
                  shake_go(2n, Ts{tokens, acc, tok, "", f_bool()}, keep, 0)
                case False{}:
                  shake_go(0n, Ts{tokens, Con{tok, acc}, dummy_tok(), "", f_bool()}, keep, 0)
        case 1n+s2:
          match s2:
            case 0n:
              match st:
                case Ts{+tokens, +acc, +tok, text, flag}:
                  match tokens:
                    case Nil{}:
                      tok_rev(Con{tok, acc}, Nil{})
                    case Con{Token{+text2, start, end, line, col}, rest2}:
                      shake_go(3n, Ts{rest2, acc, tok, text2, has_name(0n, keep, text2, False{})}, keep, 0)
            case 1n+s3:
              match s3:
                case 0n:
                  match st:
                    case Ts{+tokens, +acc, +tok, +text, +flag}:
                      match flag:
                        case True{}:
                          shake_go(0n, Ts{tokens, Con{Token{text, 0, 0, 0, 0}, Con{tok, acc}}, dummy_tok(), "", f_bool()}, keep, 0)
                        case False{}:
                          shake_go(4n, Ts{tokens, acc, dummy_tok(), "", f_bool()}, keep, 0)
                case 1n+s4:
                  match s4:
                    case 0n:
                      match st:
                        case Ts{+tokens, +acc, tok, text, flag}:
                          match tokens:
                            case Nil{}:
                              tok_rev(acc, Nil{})
                            case Con{Token{+text2, start, end, line, col}, rest2}:
                              shake_go(5n, Ts{rest2, acc, dummy_tok(), text2, String.eq(text2, "{")}, keep, depth)
                    case 1n+s5:
                      match s5:
                        case 0n:
                          match st:
                            case Ts{+tokens, +acc, tok, +text, +flag}:
                              match flag:
                                case True{}:
                                  shake_go(4n, Ts{tokens, acc, dummy_tok(), "", f_bool()}, keep, U32.inc(depth))
                                case False{}:
                                  shake_go(6n, Ts{tokens, acc, dummy_tok(), text, String.eq(text, "}")}, keep, depth)
                        case 1n+s6:
                          match s6:
                            case 0n:
                              match st:
                                case Ts{+tokens, +acc, tok, text, +flag}:
                                  match flag:
                                    case True{}:
                                      shake_go(7n, Ts{tokens, acc, dummy_tok(), "", U32.is_eq(depth, 1)}, keep, depth)
                                    case False{}:
                                      shake_go(4n, Ts{tokens, acc, dummy_tok(), "", f_bool()}, keep, depth)
                            case _:
                              match st:
                                case Ts{+tokens, +acc, tok, text, +flag}:
                                  match flag:
                                    case True{}:
                                      shake_go(0n, Ts{tokens, acc, dummy_tok(), "", f_bool()}, keep, 0)
                                    case False{}:
                                      shake_go(4n, Ts{tokens, acc, dummy_tok(), "", f_bool()}, keep, depth_dec(depth, U32.is_eq(depth, 0)))

def shake_if(tokens: List<&2, Token>, keep: List<&2, String>, shake: Bool) -> List<&2, Token>:
  match shake:
    case True{}:
      shake_go(0n, Ts{tokens, Nil{}, dummy_tok(), "", f_bool()}, keep, 0)
    case False{}:
      tokens

def transpile_bundle_lex_keep(+file: String, lr: LexRes, keep: List<&2, String>, shake: Bool) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{tokens}:
      transpile_emit(file, xform(0n, Xs{shake_if(strip_ie(0n, Ts{tokens, Nil{}, dummy_tok(), "", f_bool()}), keep, shake), Nil{}, 0, "", Nil{}, dummy_tok(), f_bool()}))

def transpile_bundle_keep(+file: String, source: String, keep: List<&2, String>, shake: Bool) -> TRes:
  transpile_bundle_lex_keep(file, lex(source), keep, shake)

def after_tab(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'\t', t}:
      t
    case SCon{h, t}:
      after_tab(t)

def is_kw(+s: String) -> Bool:
  Bool.or(String.eq(s, "export"), Bool.or(String.eq(s, "function"), Bool.or(String.eq(s, "return"), Bool.or(String.eq(s, "const"), Bool.or(String.eq(s, "let"), Bool.or(String.eq(s, "var"), Bool.or(String.eq(s, "if"), String.eq(s, "else"))))))))

def letter(n: Nat) -> String:
  match n:
    case 0n:
      "a"
    case 1n:
      "b"
    case 2n:
      "c"
    case 3n:
      "d"
    case 4n:
      "e"
    case 5n:
      "f"
    case _:
      "g"

def min_keep(+s: String, fns: List<&2, String>) -> Bool:
  Bool.or(is_kw(s), Bool.or(has_name(0n, fns, s, False{}), Bool.not(tok_is_ident(s))))

@unsafe def collect_fn(sel: Nat, xs: List<&2, String>, prev_fn: Bool, acc: List<&2, String>, +h: String) -> List<&2, String>:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          str_rev(acc, Nil{})
        case Con{+n, t}:
          collect_fn(1n, t, prev_fn, acc, n)
    case _:
      match prev_fn:
        case True{}:
          collect_fn(0n, xs, String.eq(h, "function"), Con{h, acc}, "")
        case False{}:
          collect_fn(0n, xs, String.eq(h, "function"), acc, "")

@unsafe def map_lookup(sel: Nat, m: List<&2, String>, +name: String, +pair: String, hit: Bool) -> String:
  match sel:
    case 0n:
      match m:
        case Nil{}:
          ""
        case Con{+p, t}:
          map_lookup(1n, t, name, p, String.starts_with(p, name ++ "\t"))
    case _:
      match hit:
        case True{}:
          after_tab(pair)
        case False{}:
          map_lookup(0n, m, name, "", False{})

@unsafe def rename_go(sel: Nat, xs: List<&2, String>, acc: List<&2, String>, +map: List<&2, String>, +n: Nat, +fns: List<&2, String>, +h: String, keep: Bool, +found: String, empty: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          str_rev(acc, Nil{})
        case Con{+t, rest}:
          rename_go(1n, rest, acc, map, n, fns, t, min_keep(t, fns), "", True{})
    case 1n:
      match keep:
        case True{}:
          rename_go(0n, xs, Con{h, acc}, map, n, fns, "", False{}, "", True{})
        case False{}:
          +got : String = map_lookup(0n, map, h, "", False{})
          rename_go(2n, xs, acc, map, n, fns, h, False{}, got, String.is_empty(got))
    case _:
      match empty:
        case False{}:
          rename_go(0n, xs, Con{found, acc}, map, n, fns, "", False{}, "", True{})
        case True{}:
          +sh : String = letter(n)
          rename_go(0n, xs, Con{sh, acc}, Con{h ++ "\t" ++ sh, map}, 1n+n, fns, "", False{}, "", True{})

def min_ids(+xs: List<&2, String>) -> List<&2, String>:
  rename_go(0n, xs, Nil{}, Nil{}, 0n, collect_fn(0n, xs, False{}, Nil{}, ""), "", False{}, "", True{})

def min_ids_if(xs: List<&2, String>, ids: Bool) -> List<&2, String>:
  match ids:
    case True{}:
      min_ids(xs)
    case False{}:
      xs

def min_ids_toks_fork(pair: List<&2, String> & List<&2, Token>) -> List<&2, Token>:
  (texts, toks) = pair
  toks_retext(toks, min_ids(texts))

def min_ids_toks(toks: List<&2, Token>) -> List<&2, Token>:
  min_ids_toks_fork(toks_fork(toks))

def min_ids_toks_if(toks: List<&2, Token>, ids: Bool) -> List<&2, Token>:
  match ids:
    case True{}:
      min_ids_toks(toks)
    case False{}:
      toks

def transpile_lex_opt(+file: String, lr: LexRes, minify: Bool, ids: Bool) -> TRes:
  match lr:
    case LexErr{msg, line, col}:
      TErr{msg, line, col}
    case LexOk{tokens}:
      transpile_pick(file, min_ids_toks_if(xform(0n, Xs{tokens, Nil{}, 0, "", Nil{}, dummy_tok(), f_bool()}), ids), minify)

def transpile_opt(+file: String, source: String, minify: Bool, ids: Bool) -> TRes:
  transpile_lex_opt(file, lex(source), minify, ids)




