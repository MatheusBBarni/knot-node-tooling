import Base

# A selected build table is interpreted declaratively; unsupported selected
# values fail explicitly rather than silently changing the build.
type Settings is Data:
  Settings{target: String, format: String, outdir: String, minify: Bool}

def default_settings() -> Settings:
  Settings{"browser", "esm", "", False{}}

def profile_char(+c: Char) -> Bool:
  Bool.or(Char.is_alpha(c), Bool.or(Char.is_digit(c), Bool.or(Char.is_eq(c, '-'), Char.is_eq(c, '_'))))

def profile_name(s: String) -> Bool:
  match s:
    case SNil{}:
      True{}
    case SCon{h, t}:
      Bool.and(profile_char(h), profile_name(t))

def path_char(+c: Char) -> Bool:
  Bool.or(profile_char(c), Bool.or(Char.is_eq(c, '.'), Char.is_eq(c, '/')))

def path_value(s: String) -> Bool:
  match s:
    case SNil{}:
      True{}
    case SCon{h, t}:
      Bool.and(path_char(h), path_value(t))

def quoted_inner(+inner: String, invalid: Bool) -> Result<&2, &2, String, String>:
  match invalid:
    case True{}:
      Fail{"knot: unsupported profile string escape (invalid_option)"}
    case False{}:
      Done{inner}

def quoted_kind(+v: String, valid: Bool) -> Result<&2, &2, String, String>:
  match valid:
    case False{}:
      Fail{"knot: profile value must be a TOML string (invalid_option)"}
    case True{}:
      +inner = String.take(String.drop(v, 1n), Nat.sub(String.length(v), 2n))
      quoted_inner(inner, Bool.or(String.contains(inner, "\""), Bool.or(String.contains(inner, "\\"), String.contains(inner, ";"))))

def quoted(+value: String) -> Result<&2, &2, String, String>:
  +v = String.trim(value)
  quoted_kind(v, Bool.and(String.starts_with(v, "\""), String.ends_with(v, "\"")))

def target_kind(+value: String, +format: String, +outdir: String, minify: Bool, valid: Bool) -> Result<&2, &2, String, Settings>:
  match valid:
    case True{}:
      Done{Settings{value, format, outdir, minify}}
    case False{}:
      Fail{"knot: invalid profile target (invalid_option)"}

def format_kind(+target: String, +value: String, +outdir: String, minify: Bool, valid: Bool) -> Result<&2, &2, String, Settings>:
  match valid:
    case True{}:
      Done{Settings{target, value, outdir, minify}}
    case False{}:
      Fail{"knot: invalid profile format (invalid_option)"}

def outdir_kind(+target: String, +format: String, +value: String, minify: Bool, valid: Bool) -> Result<&2, &2, String, Settings>:
  match valid:
    case True{}:
      Done{Settings{target, format, value, minify}}
    case False{}:
      Fail{"knot: invalid profile outdir (invalid_path)"}

def apply_value(current: Settings, +key: String, +value: String) -> Result<&2, &2, String, Settings>:
  match current:
    case Settings{+target, +format, +outdir, minify}:
      match key:
        case "target":
          target_kind(value, format, outdir, minify, Bool.or(String.eq(value, "browser"), String.eq(value, "node")))
        case "format":
          format_kind(target, value, outdir, minify, Bool.or(String.eq(value, "esm"), String.eq(value, "cjs")))
        case "outdir":
          outdir_kind(target, format, value, minify, Bool.and(Bool.not(String.is_empty(value)), Bool.and(path_value(value), Bool.not(String.contains(value, "..")))))
        case _:
          Fail{"knot: unknown build profile key " ++ key ++ " (invalid_option)"}

def apply_quoted(+key: String, selected: Result<&2, &2, String, String>, current: Settings) -> Result<&2, &2, String, Settings>:
  match selected:
    case Fail{message}:
      Fail{message}
    case Done{value}:
      apply_value(current, key, value)

def apply_minify_value(current: Settings, +value: String) -> Result<&2, &2, String, Settings>:
  match current:
    case Settings{target, format, outdir, _}:
      match value:
        case "true":
          Done{Settings{target, format, outdir, True{}}}
        case "false":
          Done{Settings{target, format, outdir, False{}}}
        case _:
          Fail{"knot: profile minify must be a TOML boolean (invalid_option)"}

def apply_assignment(+key: String, +value: String, current: Settings) -> Result<&2, &2, String, Settings>:
  match key:
    case "minify":
      apply_minify_value(current, String.trim(value))
    case _:
      apply_quoted(key, quoted(value), current)

def assignment_checked_result(+key: String, +seen: String, checked: Result<&2, &2, String, Settings>) -> Result<&2, &1, String, String & Settings>:
  match checked:
    case Fail{message}:
      Fail{message}
    case Done{settings}:
      Done{(seen ++ ";" ++ key ++ ";", settings)}

def assignment_checked(+key: String, +value: String, +seen: String, current: Settings, duplicate: Bool) -> Result<&2, &1, String, String & Settings>:
  match duplicate:
    case True{}:
      Fail{"knot: duplicate profile key " ++ key ++ " (duplicate_option)"}
    case False{}:
      assignment_checked_result(key, seen, apply_assignment(key, value, current))

def assignment(parts: List<&2, String>, +seen: String, current: Settings) -> Result<&2, &1, String, String & Settings>:
  match parts:
    case Con{+key0, Con{+value, Nil{}}}:
      +key = String.trim(key0)
      assignment_checked(key, value, seen, current, String.contains(seen, ";" ++ key ++ ";"))
    case _:
      Fail{"knot: invalid build profile assignment (invalid_option)"}

def selected_missing(found: Bool, wanted: String, settings: Settings) -> Result<&2, &2, String, Settings>:
  match found:
    case True{}:
      Done{settings}
    case False{}:
      match wanted:
        case "default":
          Done{settings}
        case _:
          Fail{"knot: unknown build profile " ++ wanted ++ " (invalid_option)"}

def comment_quoted_kind(+quoted: Bool, toggle: Bool) -> Bool:
  match toggle:
    case True{}:
      Bool.not(quoted)
    case False{}:
      quoted

def comment_quoted(+char: Char, +quoted: Bool, +escaped: Bool) -> Bool:
  comment_quoted_kind(quoted, Bool.and(Char.is_eq(char, '"'), Bool.not(escaped)))

def comment_escaped(+char: Char, +quoted: Bool, +escaped: Bool) -> Bool:
  Bool.and(quoted, Bool.and(Bool.not(escaped), Char.is_eq(char, '\\')))

@unsafe def strip_comment(sel: Nat, line: String, +quoted: Bool, +escaped: Bool, +char: Char, rest: String, comment: Bool) -> String:
  match sel:
    case 0n:
      match line:
        case SNil{}:
          SNil{}
        case SCon{+head, tail}:
          strip_comment(1n, SNil{}, quoted, escaped, head, tail, Bool.and(Char.is_eq(head, '#'), Bool.not(quoted)))
    case _:
      match comment:
        case True{}:
          SNil{}
        case False{}:
          SCon{char, strip_comment(0n, rest, comment_quoted(char, quoted, escaped), comment_escaped(char, quoted, escaped), 'a', SNil{}, False{})}

# One selector keeps Bend's recursive call within a single definition.
@unsafe def select_lines(sel: Nat, lines: List<&2, String>, +wanted: String, +active: Bool, +found: Bool, +seen: String, +settings: Settings, +line: String, decision: Bool, pair: Result<&2, &1, String, String & Settings>) -> Result<&2, &2, String, Settings>:
  match sel:
    case 0n:
      match lines:
        case Nil{}:
          selected_missing(found, wanted, settings)
        case Con{+raw, rest}:
          +text = String.trim(strip_comment(0n, raw, False{}, False{}, 'a', SNil{}, False{}))
          select_lines(1n, rest, wanted, active, found, seen, settings, text, Bool.or(String.is_empty(text), String.starts_with(text, "#")), pair)
    case 1n:
      match decision:
        case True{}:
          select_lines(0n, lines, wanted, active, found, seen, settings, "", False{}, pair)
        case False{}:
          select_lines(2n, lines, wanted, active, found, seen, settings, line, String.starts_with(line, "["), pair)
    case 2n:
      match decision:
        case True{}:
          +selected = String.eq(line, "[build." ++ wanted ++ "]")
          select_lines(0n, lines, wanted, selected, Bool.or(found, selected), "", settings, "", False{}, pair)
        case False{}:
          select_lines(3n, lines, wanted, active, found, seen, settings, line, active, pair)
    case 3n:
      match decision:
        case True{}:
          select_lines(4n, lines, wanted, active, found, seen, settings, "", False{}, assignment(String.split(line, '='), seen, settings))
        case False{}:
          select_lines(0n, lines, wanted, active, found, seen, settings, "", False{}, pair)
    case _:
      match pair:
        case Fail{message}:
          Fail{message}
        case Done{entry}:
          (next_seen, next_settings) = entry
          select_lines(0n, lines, wanted, active, found, next_seen, next_settings, "", False{}, Done{("", default_settings())})

def select_kind(+text: String, +name: String, valid: Bool) -> Result<&2, &2, String, Settings>:
  match valid:
    case False{}:
      Fail{"knot: invalid build profile name (invalid_option)"}
    case True{}:
      select_lines(0n, String.lines(text), name, False{}, False{}, "", default_settings(), "", False{}, Done{("", default_settings())})

def select(+text: String, +name: String) -> Result<&2, &2, String, Settings>:
  select_kind(text, name, Bool.and(Bool.not(String.is_empty(name)), profile_name(name)))
