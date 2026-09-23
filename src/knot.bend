import Base
import ./sri.bend as Sri
import ./http.bend as Fetch
import ./semver.bend as Semver
import ./compiler.bend as Compiler


def Fs.mkdir_p(path: String) -> IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_mkdir_p.c"
  import "./host/fs_mkdir_p.js"


def Fs.symlink(target: String, path: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_symlink.c"
  import "./host/fs_symlink.js"

def Fs.copy(src: String, dst: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_copy.c"
  import "./host/fs_copy.js"

def Fs.clone_dir(src: String, dst: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_clone_dir.c"
  import "./host/fs_clone_dir.js"

def Fs.layout_pkg(dest: String, name: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_layout_pkg.c"
  import "./host/fs_layout_pkg.js"

def Fs.offline_lock() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_offline_lock.c"
  import "./host/fs_offline_lock.js"

def Fs.unlink(path: String) -> IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_unlink.c"
  import "./host/fs_unlink.js"

def Fs.read_dir(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_read_dir.c"
  import "./host/fs_read_dir.js"




def Os.platform() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/os_platform.c"
  import "./host/os_platform.js"

def Os.arch() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/os_arch.c"
  import "./host/os_arch.js"


def Os.node_version() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/os_node_version.c"
  import "./host/os_node_version.js"


def Os.exec(cmd: String, arg: String, cwd: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/os_exec.c"
  import "./host/os_exec.js"



def Http.get_file(url: String, dest: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/http_get_file.c"
  import "./host/http_get_file.js"

def Gzip.inflate_file(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/gzip_inflate.c"
  import "./host/gzip_inflate.js"


def Hash.sha512_b64(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/hash_sha512_b64.c"
  import "./host/hash_sha512_b64.js"

def Tar.extract(archive: String, dest: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/tar_extract.c"
  import "./host/tar_extract.js"

def Json.query(text: String, path: String, mode: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/json_query.c"
  import "./host/json_query.js"

def Jsx.lower(source: String, mode: String, factory: String, fragment: String, import_source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/jsx_lower.c"
  import "./host/jsx_lower.js"

def Ts.lower(source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/ts_lower.c"
  import "./host/ts_lower.js"

def Pkg.exports(text: String, subpath: String, conditions: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/pkg_exports.c"
  import "./host/pkg_exports.js"

def Pkg.side_effects(text: String, rel: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/pkg_side_effects.c"
  import "./host/pkg_side_effects.js"

def Live.imports(source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/live_imports.c"
  import "./host/live_imports.js"

def Pkg.file_side_effects(path: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/pkg_file_side_effects.c"
  import "./host/pkg_file_side_effects.js"

def read_open(path: String, r: Result<&1, &1, U32 & String, File>) -> IO(File):
  match r:
    case Fail{_}:
      IO.die(File, 2, "knot: cannot read " ++ path)
    case Done{f}:
      IO.pure(File, f)

def read_text_fin(pair: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  (file2, body) = pair
  do IO<String>:
    File.close(file2)
    text : String <- IO.pass(String, body)
    return text

def read_text(+path: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    file : File <- read_open(path, r)
    pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, 4194304)
    read_text_fin(pair)

def read_pkg(+path: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    file : File <- read_open(path, r)
    pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, 262144)
    read_text_fin(pair)

def write_text_fin(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (file2, body) = pair
  do IO<Unit>:
    File.close(file2)
    IO.pass(Unit, body)

def write_text(path: String, text: String) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "w"))
    pair : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, text)
    write_text_fin(pair)

def lock_le(a: String, b: String) -> Bool:
  String.is_le(a, b)

def lock_record(
  +name: String, +spec: String, +registry: String, +tarball: String, +integrity: String
) -> String:
  "name " ++ name ++ "\nversion " ++ spec ++ "\nregistry " ++ registry ++ "\ntarball " ++ tarball ++ "\nintegrity " ++ integrity ++ "\n"

def render_lock_go(lines: List<&2, String>) -> String:
  match lines:
    case Nil{}:
      ""
    case Con{h, t}:
      h ++ render_lock_go(t)

def render_lock(lines: List<&2, String>) -> String:
  "lockfileVersion 1\n" ++ render_lock_go(lines)

def load_args(left: Nat, +i: Nat) -> IO(List<&2, String>):
  match left:
    case 0n:
      IO.pure(List<&2, String>, Nil{})
    case 1n+p:
      do IO<List<&2, String>>:
        arg : String <- IO.try(String, IO.get_env("KNOT_ARG_" ++ Nat.show(i)))
        rest : List<&2, String> <- load_args(p, 1n+i)
        return arg <> rest

def need_arg(args: List<&2, String>) -> IO(String & List<&2, String>):
  match args:
    case Nil{}:
      IO.die(String & List<&2, String>, 2, "knot: unknown command  (unknown_command)")
    case Con{head, tail}:
      IO.pure(String & List<&2, String>, (head, tail))

def parse_registry_url(rest: List<&2, String>) -> IO(String):
  match rest:
    case Con{url, Nil{}}:
      IO.pure(String, url)
    case _:
      IO.die(String, 2, "knot: unknown command install (unknown_command)")

def parse_registry_eq(+flag: String, rest: List<&2, String>, ok: Bool) -> IO(String):
  match ok:
    case False{}:
      IO.die(String, 2, "knot: unknown command " ++ flag ++ " (unknown_command)")
    case True{}:
      parse_registry_url(rest)

def parse_registry_flag(+flag: String, rest: List<&2, String>) -> IO(String):
  parse_registry_eq(flag, rest, String.eq(flag, "--registry"))

def parse_registry_pair(pair: String & List<&2, String>) -> IO(String):
  (flag, rest) = pair
  parse_registry_flag(flag, rest)

def parse_registry(args: List<&2, String>) -> IO(String):
  do IO<String>:
    pair : String & List<&2, String> <- need_arg(args)
    parse_registry_pair(pair)

def sri_ok(got: String, integrity: String) -> Bool:
  Sri.sri_ok(got, integrity)

def extract_fail_dup(dup: Bool, +msg: String) -> IO(Unit):
  match dup:
    case True{}:
      IO.die(Unit, 1, "knot: duplicate archive entry (duplicate_entry)")
    case False{}:
      IO.die(Unit, 1, msg)

def extract_pkg_fail(+msg: String) -> IO(Unit):
  extract_fail_dup(String.contains(msg, "File exists"), msg)

def extract_pkg_r(r: Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  match r:
    case Done{_}:
      IO.pure(Unit, Unit{})
    case Fail{pair}:
      match pair:
        case (_, msg):
          extract_pkg_fail(msg)

def extract_pkg(+tar: String, +dest: String) -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, Unit> <- Tar.extract(tar, dest)
    extract_pkg_r(r)

def die_integrity_json(json: Bool) -> IO(Unit):
  match json:
    case True{}:
      IO.die(Unit, 1, "{\"code\":\"integrity_mismatch\"}")
    case False{}:
      IO.die(Unit, 1, "knot: integrity mismatch (integrity_mismatch)")

def die_integrity_body(file2: File, body: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match body:
    case Fail{_}:
      do IO<Unit>:
        File.close(file2)
        IO.die(Unit, 1, "knot: integrity mismatch (integrity_mismatch)")
    case Done{mode}:
      do IO<Unit>:
        File.close(file2)
        die_integrity_json(String.eq(mode, "json"))

def die_integrity_read(pair: File & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (file2, body) = pair
  die_integrity_body(file2, body)

def die_integrity_open(r: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.die(Unit, 1, "knot: integrity mismatch (integrity_mismatch)")
    case Done{file}:
      do IO<Unit>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, 256)
        die_integrity_read(pair)

def die_integrity() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, File> <- File.open(".knot/reporter", "r")
    die_integrity_open(r)

def install_verified_if(tar_path: String, dest: String, ok: Bool) -> IO(Unit):
  match ok:
    case False{}:
      die_integrity()
    case True{}:
      extract_pkg(tar_path, dest)

def install_verified(tar_path: String, dest: String, got: String, integrity: String) ->
  IO(Unit):
  install_verified_if(tar_path, dest, sri_ok(got, integrity))

def json_optional_pairs_fin(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.pure(String, "")
    case Done{v}:
      IO.pure(String, v)

def json_optional_pairs(text: String, key: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(text, key, "pairs")
    json_optional_pairs_fin(r)

def json_optional_lines(text: String, key: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(text, key, "lines")
    json_optional_pairs_fin(r)

def json_optional_string(text: String, key: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(text, key, "string")
    json_optional_pairs_fin(r)

def json_optional_query(+text: String, +path: String, +mode: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(text, path, mode)
    json_optional_pairs_fin(r)

def need_json(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.die(String, 1, "knot: invalid registry metadata")
    case Done{s}:
      IO.pure(String, s)


def os_allowed(+os_field: String, +plat: String) -> Bool:
  match os_field:
    case SNil{}:
      True{}
    case _:
      String.contains(os_field, plat)

def check_engine_ok(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 1, "knot: engines.node is not satisfied (engine_unsatisfied)")

def check_engine(eng: String) -> IO(Unit):
  match eng:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case _:
      do IO<Unit>:
        ver : String <- IO.try(String, Os.node_version())
        check_engine_ok(Semver.satisfies(eng, ver))


def join_pair_lines(+a: String, +b: String) -> String:
  match a:
    case SNil{}:
      b
    case SCon{_, _}:
      match b:
        case SNil{}:
          a
        case SCon{_, _}:
          a ++ "\n" ++ b

def join_nested_deps(+text: String) -> IO(String):
  do IO<String>:
    deps : String <- json_optional_pairs(text, "dependencies")
    peers : String <- json_optional_pairs(text, "peerDependencies")
    return join_pair_lines(deps, peers)


def need_version(m: Maybe<&2, String>) -> IO(String):
  match m:
    case None{}:
      IO.die(String, 1, "knot: no version satisfies the range")
    case Some{v}:
      IO.pure(String, v)

def need_integrity(s: String) -> IO(String):
  match s:
    case SNil{}:
      IO.die(String, 1, "knot: missing integrity (integrity_missing)")
    case _:
      IO.pure(String, s)


def pick_version_tag(+tag: String, +spec: String, +keys: String) -> IO(String):
  match tag:
    case SNil{}:
      need_version(Semver.select_version(spec, String.lines(keys)))
    case _:
      IO.pure(String, tag)






def slash_count(s: String) -> Nat:
  match s:
    case SNil{}:
      0n
    case SCon{'/', t}:
      Nat.add(1n, slash_count(t))
    case SCon{_, t}:
      slash_count(t)

def rel_ups(n: Nat) -> String:
  match n:
    case 0n:
      "."
    case 1n:
      ".."
    case 1n+p:
      "../" ++ rel_ups(p)

def nested_rel(+dest: String, +name: String) -> String:
  rel_ups(Nat.add(slash_count(dest), slash_count(name))) ++ "/" ++ name

def link_child_parts(+dest: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{SNil{}, _}:
      IO.pure(Unit, Unit{})
    case Con{+name, _}:
      do IO<Unit>:
        u0 : Unit <- IO.try(Unit, Fs.mkdir_p(dest ++ "/node_modules"))
        u1 : Unit <- IO.try(Unit, Fs.symlink(nested_rel(dest, name), dest ++ "/node_modules/" ++ name))
        return Unit{}

def link_child(+dest: String, line: String) -> IO(Unit):
  link_child_parts(dest, String.split(line, '\t'))


def mark_nested_lines(lines: List<&2, String>) -> List<&2, String>:
  match lines:
    case Nil{}:
      Nil{}
    case Con{SNil{}, rest}:
      mark_nested_lines(rest)
    case Con{line, rest}:
      Con{line ++ "\t0", mark_nested_lines(rest)}


def mark_optional_lines(lines: List<&2, String>) -> List<&2, String>:
  match lines:
    case Nil{}:
      Nil{}
    case Con{SNil{}, rest}:
      mark_optional_lines(rest)
    case Con{line, rest}:
      Con{line ++ "\topt", mark_optional_lines(rest)}

def is_optional_parts(tail: List<&2, String>) -> Bool:
  match tail:
    case Con{tag, _}:
      String.eq(tag, "opt")
    case _:
      False{}


def is_root_parts(tail: List<&2, String>) -> Bool:
  match tail:
    case Nil{}:
      True{}
    case _:
      False{}

def link_children(+dest: String, lines: List<&2, String>) -> IO(Unit):
  match lines:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{line, rest}:
      do IO<Unit>:
        link_child(dest, line)
        link_children(dest, rest)

def link_root_target(+name: String, scoped: Bool) -> String:
  match scoped:
    case True{}:
      "../.knot/" ++ name
    case False{}:
      ".knot/" ++ name

def link_root_if(+name: String, root: Bool) -> IO(Unit):
  match root:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      do IO<Unit>:
        u0 : Unit <- IO.try(Unit, Fs.mkdir_p("node_modules"))
        u1 : Unit <- IO.try(Unit, Fs.symlink(link_root_target(name, String.contains(name, "/")), "node_modules/" ++ name))
        return Unit{}


def bin_rel(rel: String) -> String:
  match rel:
    case SCon{'.', SCon{'/', t}}:
      t
    case _:
      rel

def link_bin_one(+name: String, +cmd: String, +rel: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- IO.try(Unit, Fs.mkdir_p("node_modules/.bin"))
    u1 : Unit <- IO.try(Unit, Fs.symlink("../.knot/" ++ name ++ "/" ++ bin_rel(rel), "node_modules/.bin/" ++ cmd))
    return Unit{}

def link_bin_parts(+name: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+cmd, Con{+rel, Nil{}}}:
      link_bin_one(name, cmd, rel)
    case _:
      IO.pure(Unit, Unit{})

def link_bin_line(+name: String, line: String) -> IO(Unit):
  link_bin_parts(name, String.split(line, '\t'))

def link_bin_lines(fuel: Nat, +name: String, lines: List<&2, String>) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      match lines:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{SNil{}, rest}:
          link_bin_lines(p, name, rest)
        case Con{line, rest}:
          do IO<Unit>:
            link_bin_line(name, line)
            link_bin_lines(p, name, rest)

def link_bins_got(+name: String, r: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{pairs}:
      link_bin_lines(8n, name, String.lines(pairs))

def link_bins(+name: String, +pkg: String) -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(pkg, "bin", "pairs")
    link_bins_got(name, r)

def link_bins_if(+name: String, +pkg: String, root: Bool) -> IO(Unit):
  match root:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      link_bins(name, pkg)


def sri_key(s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{'/', t}:
      SCon{'_', sri_key(t)}
    case SCon{h, t}:
      SCon{h, sri_key(t)}

def file_is_open(r: Result<&1, &1, U32 & String, File>) -> IO(Bool):
  match r:
    case Fail{_}:
      IO.pure(Bool, False{})
    case Done{f}:
      do IO<Bool>:
        File.close(f)
        return True{}

def file_exists(path: String) -> IO(Bool):
  do IO<Bool>:
    r : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    file_is_open(r)

def progress_if(quiet: Bool, +msg: String) -> IO(Unit):
  match quiet:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.print_err(msg)

def progress(msg: String) -> IO(Unit):
  do IO<Unit>:
    quiet : Bool <- file_exists(".knot/silent")
    progress_if(quiet, msg)

def format_elapsed_long(+ms: Nat) -> String:
  Nat.show(Nat.div(ms, 1000n)) ++ "." ++ Nat.show(Nat.div(Nat.mod(ms, 1000n), 100n)) ++ "s"

def format_elapsed_ms(under: Bool, +ms: Nat) -> String:
  match under:
    case True{}:
      Nat.show(ms) ++ "ms"
    case False{}:
      format_elapsed_long(ms)

def format_elapsed(+ms: Nat) -> String:
  format_elapsed_ms(Nat.is_lt(ms, 1000n), ms)

def home_dir(r: Result<&1, &1, U32 & String, String>) -> String:
  match r:
    case Fail{_}:
      "."
    case Done{h}:
      h

def knot_home() -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("HOME")
    return home_dir(r) ++ "/.knot"

def unpacked_path(+integrity: String) -> IO(String):
  do IO<String>:
    root : String <- knot_home()
    return root ++ "/unpacked/" ++ sri_key(integrity)

def ensure_unpacked(has: Bool, +tar: String, +unpacked: String) -> IO(Unit):
  match has:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      extract_pkg(tar, unpacked)

def place_pkg(+tar: String, +dest: String, +integrity: String) -> IO(Unit):
  do IO<Unit>:
    +unp : String <- unpacked_path(integrity)
    has : Bool <- file_exists(unp ++ "/package.json")
    ensure_unpacked(has, tar, unp)
    IO.try(Unit, Fs.clone_dir(unp, dest))

def materialize_verified(ok: Bool, +tar: String, +dest: String, +integrity: String) -> IO(Unit):
  match ok:
    case False{}:
      die_integrity()
    case True{}:
      place_pkg(tar, dest, integrity)

def fetch_tar(+url: String, +tmp: String, +cas: String, exists: Bool) -> IO(String):
  match exists:
    case True{}:
      IO.pure(String, cas)
    case False{}:
      do IO<String>:
        u : Unit <- IO.try(Unit, Http.get_file(url, tmp))
        return tmp

def commit_cas(+tmp: String, +cas: String, exists: Bool) -> IO(Unit):
  match exists:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        u : Unit <- IO.try(Unit, Fs.copy(tmp, cas))
        return Unit{}

def cas_root_ex(ex: Bool) -> IO(String):
  match ex:
    case False{}:
      do IO<String>:
        root : String <- knot_home()
        return root ++ "/cas"
    case True{}:
      read_text(".knot/store-dir")

def cas_root() -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists(".knot/store-dir")
    cas_root_ex(ex)

def cas_file(+integrity: String) -> IO(String):
  do IO<String>:
    +root : String <- cas_root()

    u : Unit <- IO.try(Unit, Fs.mkdir_p(root))
    return root ++ "/" ++ sri_key(integrity)


def os_meta_or_skip(+meta: String, allowed: Bool) -> Maybe<&2, String>:
  match allowed:
    case True{}:
      Some{meta}
    case False{}:
      Some{SNil{}}

def trusted_name(+name: String, +toml: String) -> Bool:
  String.contains(toml, "\"" ++ name ++ "\"")

def take_until_slash(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'/', _}:
      acc
    case SCon{h, t}:
      take_until_slash(t, acc ++ SCon{h, SNil{}})

def drop_prefix(s: String, pre: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{h, st}:
      match pre:
        case SNil{}:
          SCon{h, st}
        case SCon{_, pt}:
          drop_prefix(st, pt)

def drop_until_key_go(+s: String, ok: Bool, +key: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{_, t}:
      match ok:
        case True{}:
          drop_prefix(s, key)
        case False{}:
          drop_until_key_go(t, String.starts_with(t, key), key)

def drop_until_key(+s: String, +key: String) -> String:
  drop_until_key_go(s, String.starts_with(s, key), key)

def take_line(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'\n', _}:
      acc
    case SCon{h, t}:
      take_line(t, acc ++ SCon{h, SNil{}})

def age_ok(+cutoff: String, +time: String) -> Bool:
  match cutoff:
    case SNil{}:
      True{}
    case _:
      match time:
        case SNil{}:
          True{}
        case _:
          String.is_le(time, cutoff)

def age_line(ok: Bool, +ver: String) -> String:
  match ok:
    case False{}:
      ""
    case True{}:
      ver ++ "\n"

def filter_age_one(+cutoff: String, +meta: String, +ver: String) -> IO(String):
  match ver:
    case SNil{}:
      IO.pure(String, "")
    case _:
      do IO<String>:
        t : String <- json_optional_string(meta, "time/" ++ ver)
        return age_line(age_ok(cutoff, t), ver)

def filter_age_keys(fuel: Nat, keys: List<&2, String>, +cutoff: String, +meta: String) -> IO(String):
  match fuel:
    case 0n:
      IO.pure(String, "")
    case 1n+p:
      match keys:
        case Nil{}:
          IO.pure(String, "")
        case Con{+ver, rest}:
          do IO<String>:
            one : String <- filter_age_one(cutoff, meta, ver)
            more : String <- filter_age_keys(p, rest, cutoff, meta)
            return one ++ more

def filter_age_go(+cutoff: String, +keys: String, key_list: List<&2, String>, +meta: String) -> IO(String):
  match cutoff:
    case SNil{}:
      IO.pure(String, keys)
    case _:
      filter_age_keys(4096n, key_list, cutoff, meta)

def read_age_cutoff(ex: Bool) -> IO(String):
  match ex:
    case False{}:
      IO.pure(String, "")
    case True{}:
      do IO<String>:
        toml : String <- read_text("knot.toml")
        return take_line(drop_until_key(toml, "minimum-release-age-before="), "")


def pick_keys(+preferred: String, +fallback: String) -> String:
  match preferred:
    case SNil{}:
      fallback
    case _:
      preferred

def pick_version(+spec: String, +keys: String, +meta: String) -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists("knot.toml")
    cutoff : String <- read_age_cutoff(ex)
    undep : String <- json_optional_query(meta, "versions", "undep_keys")
    +pool : String = pick_keys(undep, keys)
    +filtered : String <- filter_age_go(cutoff, pool, String.lines(pool), meta)
    tag : String <- json_optional_string(meta, "dist-tags/" ++ spec)
    pick_version_tag(tag, spec, filtered)


def take_cr_line(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'\n', _}:
      acc
    case SCon{'\r', _}:
      acc
    case SCon{h, t}:
      take_cr_line(t, acc ++ SCon{h, SNil{}})

def header_line(+resp: String, +key: String) -> String:
  take_cr_line(drop_until_key(resp, key), "")

def mapped_registry(+toml: String, +name: String) -> String:
  take_line(drop_until_key(toml, take_until_slash(name, "") ++ ":registry="), "")

def pick_mapped(+cli: String, +mapped: String) -> String:
  match mapped:
    case SNil{}:
      cli
    case _:
      mapped

def registry_for_ex(ex: Bool, +cli: String, +name: String) -> IO(String):
  match ex:
    case False{}:
      IO.pure(String, cli)
    case True{}:
      do IO<String>:
        toml : String <- read_text("knot.toml")
        return pick_mapped(cli, mapped_registry(toml, name))

def registry_for(+cli: String, +name: String) -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists("knot.toml")
    registry_for_ex(ex, cli, name)

def trust_file(ex: Bool, +name: String) -> IO(Bool):
  match ex:
    case False{}:
      IO.pure(Bool, False{})
    case True{}:
      do IO<Bool>:
        toml : String <- read_text("knot.toml")
        return trusted_name(name, toml)

def is_trusted(+name: String) -> IO(Bool):
  do IO<Bool>:
    ex : Bool <- file_exists("knot.toml")
    trust_file(ex, name)

def run_pre_parts(+dest: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+cmd, Con{+arg, Nil{}}}:
      do IO<Unit>:
        u : Unit <- IO.try(Unit, Os.exec(cmd, arg, dest))
        return Unit{}
    case _:
      IO.die(Unit, 1, "knot: invalid lifecycle script")

def run_pre_ok(+dest: String, script: String) -> IO(Unit):
  run_pre_parts(dest, String.split(script, ' '))


def run_pre_got(+dest: String, r: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{script}:
      run_pre_ok(dest, script)

def emit_blocked_json(json: Bool) -> IO(Unit):
  match json:
    case True{}:
      IO.print("{\"code\":\"blocked_script\"}")
    case False{}:
      IO.pure(Unit, Unit{})

def emit_blocked_ex(ex: Bool) -> IO(Unit):
  match ex:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      do IO<Unit>:
        mode : String <- read_text(".knot/reporter")
        emit_blocked_json(String.eq(mode, "json"))

def emit_blocked() -> IO(Unit):
  do IO<Unit>:
    ex : Bool <- file_exists(".knot/reporter")
    emit_blocked_ex(ex)

def emit_blocked_got(r: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{_}:
      emit_blocked()

def emit_blocked_if_has_script(+pkg: String) -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(pkg, "scripts/preinstall", "string")
    emit_blocked_got(r)

def run_pre_if(ok: Bool, +dest: String, +pkg: String) -> IO(Unit):
  match ok:
    case False{}:
      emit_blocked_if_has_script(pkg)
    case True{}:
      do IO<Unit>:
        r : Result<&1, &1, U32 & String, String> <- Json.query(pkg, "scripts/preinstall", "string")
        run_pre_got(dest, r)

def run_pre_unless_ignored(skipped: Bool, +name: String, +dest: String, +pkg: String) -> IO(Unit):
  match skipped:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        ok : Bool <- is_trusted(name)
        run_pre_if(ok, dest, pkg)

def run_approved_scripts(+name: String, +dest: String, +pkg: String) -> IO(Unit):
  do IO<Unit>:
    skipped : Bool <- file_exists(".knot/ignore-scripts")
    run_pre_unless_ignored(skipped, name, dest, pkg)




def cache_root() -> IO(String):
  do IO<String>:
    root : String <- knot_home()
    return root ++ "/cache"

def cache_path(+registry: String, +name: String) -> IO(String):
  do IO<String>:
    root : String <- cache_root()
    return root ++ "/" ++ sri_key(registry ++ "/" ++ name)

def save_meta_txt(+path: String, +txt: String) -> IO(Unit):
  match txt:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case SCon{_, _}:
      do IO<Unit>:
        root : String <- cache_root()
        u : Unit <- IO.try(Unit, Fs.mkdir_p(root))
        write_text(path, txt)

def save_etag(+path: String, +etag: String) -> IO(Unit):
  match etag:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case _:
      write_text(path ++ ".etag", etag)

def save_lm(+path: String, +lm: String) -> IO(Unit):
  match lm:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case _:
      write_text(path ++ ".lm", lm)

def inm_line(+etag: String) -> String:
  match etag:
    case SNil{}:
      ""
    case _:
      "If-None-Match: " ++ etag ++ "\r\n"

def ims_line(+lm: String) -> String:
  match lm:
    case SNil{}:
      ""
    case _:
      "If-Modified-Since: " ++ lm ++ "\r\n"

def cond_headers(+etag: String, +lm: String) -> String:
  inm_line(etag) ++ ims_line(lm)

def read_if(has: Bool, +path: String) -> IO(String):
  match has:
    case False{}:
      IO.pure(String, "")
    case True{}:
      read_text(path)

def http_is_200(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 200"), String.starts_with(resp, "HTTP/1.0 200"))

def save_meta_resp(+path: String, +resp: String) -> IO(Maybe<&2, String>):
  do IO<Maybe<&2, String>>:
    +body : String <- Fetch.http_decode_body(resp)
    u : Unit <- save_meta_txt(path, body)
    e : Unit <- save_etag(path, pick_mapped(header_line(resp, "ETag: "), header_line(resp, "etag: ")))
    m : Unit <- save_lm(path, pick_mapped(header_line(resp, "Last-Modified: "), header_line(resp, "last-modified: ")))
    return Some{body}

def meta_from_resp(ok: Bool, +path: String, +resp: String) -> IO(Maybe<&2, String>):
  match ok:
    case False{}:
      IO.pure(Maybe<&2, String>, Some{SNil{}})
    case True{}:
      save_meta_resp(path, resp)

def save_gzip_meta(+path: String, +url: String, +resp: String) -> IO(Maybe<&2, String>):
  do IO<Maybe<&2, String>>:
    u : Unit <- IO.try(Unit, Http.get_file(url, path ++ ".gz"))
    +body : String <- IO.try(String, Gzip.inflate_file(path ++ ".gz"))
    s : Unit <- save_meta_txt(path, body)
    e : Unit <- save_etag(path, pick_mapped(header_line(resp, "ETag: "), header_line(resp, "etag: ")))
    m : Unit <- save_lm(path, pick_mapped(header_line(resp, "Last-Modified: "), header_line(resp, "last-modified: ")))
    return Some{body}

def meta_from_gz(gz: Bool, ok: Bool, +path: String, +url: String, +resp: String) -> IO(Maybe<&2, String>):
  match gz:
    case False{}:
      meta_from_resp(ok, path, resp)
    case True{}:
      match ok:
        case False{}:
          IO.pure(Maybe<&2, String>, Some{SNil{}})
        case True{}:
          save_gzip_meta(path, url, resp)

def drop_url_https(https: Bool, +url: String) -> String:
  match https:
    case True{}:
      String.drop(url, 8n)
    case False{}:
      url

def drop_url_scheme(http: Bool, +url: String) -> String:
  match http:
    case True{}:
      String.drop(url, 7n)
    case False{}:
      drop_url_https(String.starts_with(url, "https://"), url)


def origin_key(+url: String) -> String:
  take_until_slash(drop_url_scheme(String.starts_with(url, "http://"), url), "")

def follow_loc_auth(keep: Bool, +loc: String) -> IO(String):
  match keep:
    case True{}:
      Fetch.http_get_resp(loc, "")
    case False{}:
      Fetch.http_get_resp_anon(loc)

def follow_loc(+from_url: String, +loc: String) -> IO(String):
  follow_loc_auth(String.eq(origin_key(from_url), origin_key(loc)), loc)

def follow_meta(redir: Bool, +resp: String, +from_url: String) -> IO(String):
  match redir:
    case False{}:
      IO.pure(String, resp)
    case True{}:
      follow_loc(from_url, pick_mapped(header_line(resp, "Location: "), header_line(resp, "location: ")))

def load_meta_fresh(+path: String, +url: String) -> IO(Maybe<&2, String>):
  do IO<Maybe<&2, String>>:
    +resp : String <- Fetch.http_get_resp(url, "")
    +resp2 : String <- follow_meta(Fetch.http_is_redirect(resp), resp, url)
    meta_from_gz(Fetch.http_is_gzip(resp2), http_is_200(resp2), path, url, resp2)

def load_meta_reval(not_mod: Bool, +path: String, +resp: String) -> IO(Maybe<&2, String>):
  match not_mod:
    case True{}:
      do IO<Maybe<&2, String>>:
        txt : String <- read_text(path)
        return Some{txt}
    case False{}:
      meta_from_resp(http_is_200(resp), path, resp)

def load_meta_cond(+path: String, +url: String) -> IO(Maybe<&2, String>):
  do IO<Maybe<&2, String>>:
    has_etag : Bool <- file_exists(path ++ ".etag")
    etag : String <- read_if(has_etag, path ++ ".etag")
    has_lm : Bool <- file_exists(path ++ ".lm")
    lm : String <- read_if(has_lm, path ++ ".lm")
    +resp : String <- Fetch.http_get_resp(url, cond_headers(etag, lm))
    load_meta_reval(Fetch.http_is_304(resp), path, resp)

def load_meta_cached(has_cond: Bool, +path: String, +url: String) -> IO(Maybe<&2, String>):
  match has_cond:
    case False{}:
      do IO<Maybe<&2, String>>:
        txt : String <- read_text(path)
        return Some{txt}
    case True{}:
      load_meta_cond(path, url)

def load_meta(hit: Bool, +path: String, +url: String) -> IO(Maybe<&2, String>):
  match hit:
    case True{}:
      do IO<Maybe<&2, String>>:
        has_etag : Bool <- file_exists(path ++ ".etag")
        has_lm : Bool <- file_exists(path ++ ".lm")
        load_meta_cached(Bool.or(has_etag, has_lm), path, url)
    case False{}:
      load_meta_fresh(path, url)

def materialize_pkg(
  exists: Bool,
  +tarball: String,
  +tar_path: String,
  +cas: String,
  +dest: String,
  +integrity: String
) -> IO(Unit):
  match exists:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        +ex : Bool <- file_exists(cas)
        +tar_use : String <- fetch_tar(tarball, tar_path, cas, ex)
        got : String <- IO.try(String, Hash.sha512_b64(tar_use))
        materialize_verified(sri_ok(got, integrity), tar_use, dest, integrity)
        commit_cas(tar_use, cas, ex)


def already(+seen: String, +name: String) -> Bool:
  String.contains(seen, "\n" ++ name ++ "\n")

def parts_hit(+seen: String, parts: List<&2, String>) -> Bool:
  match parts:
    case Con{+name, _}:
      already(seen, name)
    case _:
      False{}



def install_job(
  fuel: Nat,
  parts: List<&2, String>,
  queue: List<&2, String>,
  +registry: String,
  meta_m: Maybe<&2, String>,
  +optional: Bool,
  +os_checked: Bool,
  +seen: String,
  +hit: Bool
) -> IO(List<&2, String>):
  match fuel:
    case 0n:
      IO.die(List<&2, String>, 1, "knot: dependency graph too deep")
    case 1n+p:
      match parts:
        case Nil{}:
          match queue:
            case Nil{}:
              IO.pure(List<&2, String>, Nil{})
            case Con{SNil{}, rest}:
              install_job(p, Nil{}, rest, registry, None{}, False{}, False{}, seen, False{})
            case Con{+line, rest}:
              install_job(p, String.split(line, '\t'), rest, registry, None{}, String.contains(line, "\topt"), False{}, seen, parts_hit(seen, String.split(line, '\t')))
        case Con{+name, Con{+spec, +tail}}:
          match meta_m:
            case None{}:
              match hit:
                case True{}:
                  do IO<List<&2, String>>:
                    link_root_if(name, is_root_parts(tail))
                    install_job(p, Nil{}, queue, registry, None{}, False{}, False{}, seen, False{})
                case False{}:
                  do IO<List<&2, String>>:
                    +reg : String <- registry_for(registry, name)
                    +path : String <- cache_path(reg, name)
                    ex : Bool <- file_exists(path)
                    got : Maybe<&2, String> <- load_meta(ex, path, reg ++ "/" ++ name)
                    install_job(p, Con{name, Con{spec, tail}}, queue, registry, got, optional, False{}, seen ++ name ++ "\n", False{})
            case Some{SNil{}}:
              match optional:
                case True{}:
                  install_job(p, Nil{}, queue, registry, None{}, False{}, False{}, seen, False{})
                case False{}:
                  IO.die(List<&2, String>, 1, "knot: registry HTTP error")
            case Some{+meta}:
              match os_checked:
                case False{}:
                  do IO<List<&2, String>>:
                    keys_r : Result<&1, &1, U32 & String, String> <- Json.query(meta, "versions", "keys")
                    keys : String <- need_json(keys_r)
                    +picked : String <- pick_version(spec, keys, meta)

                    osf : String <- json_optional_lines(meta, "versions/" ++ picked ++ "/os")
                    plat : String <- IO.try(String, Os.platform())
                    cpf : String <- json_optional_lines(meta, "versions/" ++ picked ++ "/cpu")
                    arch : String <- IO.try(String, Os.arch())
                    eng : String <- json_optional_string(meta, "versions/" ++ picked ++ "/engines/node")
                    check_engine(eng)
                    install_job(p, Con{name, Con{spec, tail}}, queue, registry, os_meta_or_skip(meta, Bool.and(os_allowed(osf, plat), os_allowed(cpf, arch))), optional, True{}, seen, False{})

                case True{}:
                  do IO<List<&2, String>>:
                    +tar_path : String = "node_modules/.knot-tmp/" ++ name ++ ".tgz"
                    +dest : String = "node_modules/.knot/" ++ name
                    u0 : Unit <- IO.try(Unit, Fs.mkdir_p("node_modules/.knot-tmp"))
                    keys_r : Result<&1, &1, U32 & String, String> <- Json.query(meta, "versions", "keys")
                    keys : String <- need_json(keys_r)
                    +picked : String <- pick_version(spec, keys, meta)

                    tar_r : Result<&1, &1, U32 & String, String> <- Json.query(meta, "versions/" ++ picked ++ "/dist/tarball", "string")
                    +tarball : String <- need_json(tar_r)
                    raw_int : String <- json_optional_string(meta, "versions/" ++ picked ++ "/dist/integrity")
                    +integrity : String <- need_integrity(raw_int)
                    +cas : String <- cas_file(integrity)
                    +ex_pkg : Bool <- file_exists(dest ++ "/package.json")
                    u_m : Unit <- materialize_pkg(ex_pkg, tarball, tar_path, cas, dest, integrity)
                    u_log : Unit <- progress("+ " ++ name ++ "@" ++ picked)
                    +nested_txt : String <- read_text(dest ++ "/package.json")
                    run_approved_scripts(name, dest, nested_txt)

                    +req : String <- join_nested_deps(nested_txt)
                    +opt : String <- json_optional_pairs(nested_txt, "optionalDependencies")
                    more : List<&2, String> <- install_job(p, Nil{}, List.append(&2, String, mark_nested_lines(String.lines(req)), List.append(&2, String, mark_optional_lines(String.lines(opt)), queue)), registry, None{}, False{}, False{}, seen, False{})
                    link_children(dest, String.lines(req))
                    link_children(dest, String.lines(opt))
                    link_root_if(name, is_root_parts(tail))
                    link_bins_if(name, nested_txt, is_root_parts(tail))
                    +reg : String <- registry_for(registry, name)
                    return lock_record(name, picked, reg, tarball, integrity) <> more
        case _:
          IO.die(List<&2, String>, 1, "knot: invalid dependency entry")








def offline_materialize(has: Bool, +cas: String, +dest: String, +got: String, +integrity: String) -> IO(Unit):
  match has:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      install_verified(cas, dest, got, integrity)

def offline_finish(+name: String, +dest: String) -> IO(Unit):
  IO.try(Unit, Fs.layout_pkg(dest, name))

def offline_from_cas(+name: String, +cas: String, +dest: String, +integrity: String) -> IO(Unit):
  do IO<Unit>:
    place_pkg(cas, dest, integrity)
    offline_finish(name, dest)

def offline_from_url(+name: String, +cas: String, +dest: String, +integrity: String, +tarball: String) -> IO(Unit):
  match tarball:
    case SNil{}:
      IO.die(Unit, 1, "knot: missing store entry (offline)")
    case _:
      do IO<Unit>:
        u0 : Unit <- IO.try(Unit, Fs.mkdir_p("node_modules/.knot-tmp"))
        +tmp : String = "node_modules/.knot-tmp/offline.tgz"
        +tar_use : String <- fetch_tar(tarball, tmp, cas, False{})
        got : String <- IO.try(String, Hash.sha512_b64(tar_use))
        materialize_verified(sri_ok(got, integrity), tar_use, dest, integrity)
        commit_cas(tar_use, cas, False{})
        offline_finish(name, dest)

def offline_need_cas(cas_ex: Bool, +name: String, +cas: String, +dest: String, +integrity: String, +tarball: String) -> IO(Unit):
  match cas_ex:
    case True{}:
      offline_from_cas(name, cas, dest, integrity)
    case False{}:
      offline_from_url(name, cas, dest, integrity, tarball)

def offline_clone(+name: String, +dest: String, +unp: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- IO.try(Unit, Fs.clone_dir(unp, dest))
    offline_finish(name, dest)

def offline_unp(has_unp: Bool, +name: String, +dest: String, +integrity: String, +tarball: String, +unp: String) -> IO(Unit):
  match has_unp:
    case True{}:
      offline_clone(name, dest, unp)
    case False{}:
      do IO<Unit>:
        +cas : String <- cas_file(integrity)
        ex : Bool <- file_exists(cas)
        offline_need_cas(ex, name, cas, dest, integrity, tarball)

def offline_one_have(has: Bool, +name: String, +dest: String, +integrity: String, +tarball: String, +ver: String) -> IO(Unit):
  match has:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        u_log : Unit <- IO.print_err("+ " ++ name ++ "@" ++ ver)
        +unp : String <- unpacked_path(integrity)
        has_unp : Bool <- file_exists(unp ++ "/package.json")
        offline_unp(has_unp, name, dest, integrity, tarball, unp)

def offline_one(+name: String, +integrity: String, +tarball: String, +ver: String) -> IO(Unit):
  do IO<Unit>:
    +dest : String = "node_modules/.knot/" ++ name
    has : Bool <- file_exists(dest ++ "/package.json")
    offline_one_have(has, name, dest, integrity, tarball, ver)

def offline_job(
  fuel: Nat,
  parts: List<&2, String>,
  lines: List<&2, String>,
  +name: String,
  +tarball: String,
  +ver: String
) -> IO(Unit):
  match fuel:
    case 0n:
      IO.die(Unit, 1, "knot: lockfile too large")
    case 1n+p:
      match parts:
        case Nil{}:
          match lines:
            case Nil{}:
              IO.pure(Unit, Unit{})
            case Con{SNil{}, rest}:
              offline_job(p, Nil{}, rest, name, tarball, ver)
            case Con{line, rest}:
              offline_job(p, String.split(line, ' '), rest, name, tarball, ver)
        case Con{SCon{'n', SCon{'a', SCon{'m', SCon{'e', SNil{}}}}}, Con{+n, Nil{}}}:
          offline_job(p, Nil{}, lines, n, tarball, ver)
        case Con{SCon{'v', SCon{'e', SCon{'r', SCon{'s', SCon{'i', SCon{'o', SCon{'n', SNil{}}}}}}}}, Con{+v, Nil{}}}:
          offline_job(p, Nil{}, lines, name, tarball, v)
        case Con{SCon{'t', SCon{'a', SCon{'r', SCon{'b', SCon{'a', SCon{'l', SCon{'l', SNil{}}}}}}}}, Con{+url, Nil{}}}:
          offline_job(p, Nil{}, lines, name, url, ver)
        case Con{SCon{'i', SCon{'n', SCon{'t', SCon{'e', SCon{'g', SCon{'r', SCon{'i', SCon{'t', SCon{'y', SNil{}}}}}}}}}}, Con{+i, Nil{}}}:
          do IO<Unit>:
            offline_one(name, i, tarball, ver)
            offline_job(p, Nil{}, lines, "", "", "")
        case _:
          offline_job(p, Nil{}, lines, name, tarball, ver)

def run_offline() -> IO(Unit):
  do IO<Unit>:
    lock : String <- read_text("knot.lock")
    offline_job(4096n, Nil{}, String.lines(lock), "", "", "")


def list_link(ex: Bool, +name: String, +ver: String) -> IO(Unit):
  match ex:
    case False{}:
      IO.die(Unit, 1, "knot: missing link " ++ name ++ " (missing_link)")
    case True{}:
      IO.print(name ++ "@" ++ ver)

def list_job(
  fuel: Nat,
  parts: List<&2, String>,
  lines: List<&2, String>,
  +name: String
) -> IO(Unit):
  match fuel:
    case 0n:
      IO.die(Unit, 1, "knot: lockfile too large")
    case 1n+p:
      match parts:
        case Nil{}:
          match lines:
            case Nil{}:
              IO.pure(Unit, Unit{})
            case Con{SNil{}, rest}:
              list_job(p, Nil{}, rest, name)
            case Con{line, rest}:
              list_job(p, String.split(line, ' '), rest, name)
        case Con{SCon{'n', SCon{'a', SCon{'m', SCon{'e', SNil{}}}}}, Con{+n, Nil{}}}:
          list_job(p, Nil{}, lines, n)
        case Con{SCon{'v', SCon{'e', SCon{'r', SCon{'s', SCon{'i', SCon{'o', SCon{'n', SNil{}}}}}}}}, Con{+ver, Nil{}}}:
          do IO<Unit>:
            +n : String = name
            ex : Bool <- file_exists("node_modules/" ++ n)
            list_link(ex, n, ver)
            list_job(p, Nil{}, lines, "")
        case _:
          list_job(p, Nil{}, lines, name)

def run_list(args: List<&2, String>) -> IO(Unit):
  match args:
    case _:
      do IO<Unit>:
        lock : String <- read_text("knot.lock")
        list_job(64n, Nil{}, String.lines(lock), "")

def status_one_ex(ex: Bool) -> IO(Unit):
  match ex:
    case False{}:
      IO.die(Unit, 1, "knot: missing store entry")
    case True{}:
      IO.pure(Unit, Unit{})

def status_one(+integrity: String) -> IO(Unit):
  do IO<Unit>:
    cas : String <- cas_file(integrity)

    ex : Bool <- file_exists(cas)
    status_one_ex(ex)

def status_job(
  fuel: Nat,
  parts: List<&2, String>,
  lines: List<&2, String>
) -> IO(Unit):
  match fuel:
    case 0n:
      IO.die(Unit, 1, "knot: lockfile too large")
    case 1n+p:
      match parts:
        case Nil{}:
          match lines:
            case Nil{}:
              IO.pure(Unit, Unit{})
            case Con{SNil{}, rest}:
              status_job(p, Nil{}, rest)
            case Con{line, rest}:
              status_job(p, String.split(line, ' '), rest)
        case Con{SCon{'i', SCon{'n', SCon{'t', SCon{'e', SCon{'g', SCon{'r', SCon{'i', SCon{'t', SCon{'y', SNil{}}}}}}}}}}, Con{+i, Nil{}}}:
          do IO<Unit>:
            status_one(i)
            status_job(p, Nil{}, lines)
        case _:
          status_job(p, Nil{}, lines)

def run_store_status() -> IO(Unit):
  do IO<Unit>:
    lock : String <- read_text("knot.lock")
    status_job(64n, Nil{}, String.lines(lock))

def keep_keys(
  fuel: Nat,
  parts: List<&2, String>,
  lines: List<&2, String>,
  +acc: String
) -> String:
  match fuel:
    case 0n:
      acc
    case 1n+p:
      match parts:
        case Nil{}:
          match lines:
            case Nil{}:
              acc
            case Con{SNil{}, rest}:
              keep_keys(p, Nil{}, rest, acc)
            case Con{line, rest}:
              keep_keys(p, String.split(line, ' '), rest, acc)
        case Con{SCon{'i', SCon{'n', SCon{'t', SCon{'e', SCon{'g', SCon{'r', SCon{'i', SCon{'t', SCon{'y', SNil{}}}}}}}}}}, Con{+i, Nil{}}}:
          keep_keys(p, Nil{}, lines, acc ++ sri_key(i) ++ "\n")
        case _:
          keep_keys(p, Nil{}, lines, acc)

def prune_one_eq(+name: String, keep: Bool) -> IO(Unit):
  match keep:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        root : String <- cas_root()
        u : Unit <- IO.try(Unit, Fs.unlink(root ++ "/" ++ name))

        return Unit{}

def prune_one(+name: String, +keys: String) -> IO(Unit):
  prune_one_eq(name, String.contains(keys, name))

def prune_names(fuel: Nat, names: List<&2, String>, +keys: String) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      match names:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{SNil{}, rest}:
          prune_names(p, rest, keys)
        case Con{name, rest}:
          do IO<Unit>:
            prune_one(name, keys)
            prune_names(p, rest, keys)

def run_store_prune() -> IO(Unit):
  do IO<Unit>:
    lock : String <- read_text("knot.lock")
    root : String <- cas_root()
    listed : String <- IO.try(String, Fs.read_dir(root))

    prune_names(64n, String.lines(listed), keep_keys(64n, Nil{}, String.lines(lock), ""))

def run_store_prune_eq(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      run_store_prune()
    case False{}:
      IO.die(Unit, 2, "knot: unknown command store (unknown_command)")

def run_store_status_or(+sub: String, status_ok: Bool) -> IO(Unit):
  match status_ok:
    case True{}:
      run_store_status()
    case False{}:
      run_store_prune_eq(String.eq(sub, "prune"))

def run_store_status_eq(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      run_store_status()
    case False{}:
      IO.die(Unit, 2, "knot: unknown command store (unknown_command)")

def run_store_path_or(+sub: String, path_ok: Bool) -> IO(Unit):
  match path_ok:
    case True{}:
      do IO<Unit>:
        root : String <- cas_root()
        IO.print(root)

    case False{}:
      run_store_status_or(sub, String.eq(sub, "status"))

def run_store(args: List<&2, String>) -> IO(Unit):
  match args:
    case Con{+sub, _}:
      run_store_path_or(sub, String.eq(sub, "path"))
    case Nil{}:
      IO.die(Unit, 2, "knot: unknown command store (unknown_command)")



def why_if(ok: Bool, +dir: String, +pkg: String) -> IO(Unit):
  match ok:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      IO.print(dir ++ " > " ++ pkg)

def why_one_ex(ex: Bool, +dir: String, +pkg: String) -> IO(Unit):
  match ex:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      do IO<Unit>:
        txt : String <- read_text("node_modules/.knot/" ++ dir ++ "/package.json")
        deps : String <- json_optional_pairs(txt, "dependencies")
        why_if(String.contains(deps, pkg ++ "\t"), dir, pkg)

def why_one_dir_eq(same: Bool, +dir: String, +pkg: String) -> IO(Unit):
  match same:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        ex : Bool <- file_exists("node_modules/.knot/" ++ dir ++ "/package.json")
        why_one_ex(ex, dir, pkg)

def why_one_dir(+dir: String, +pkg: String) -> IO(Unit):
  why_one_dir_eq(String.eq(dir, pkg), dir, pkg)
def why_dirs(fuel: Nat, names: List<&2, String>, +pkg: String) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      match names:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{SNil{}, rest}:
          why_dirs(p, rest, pkg)
        case Con{+dir, rest}:
          do IO<Unit>:
            why_one_dir(dir, pkg)
            why_dirs(p, rest, pkg)

def run_why(args: List<&2, String>) -> IO(Unit):
  match args:
    case Con{+pkg, _}:
      do IO<Unit>:
        text : String <- read_text("package.json")
        app : String <- IO.try(String, Json.query(text, "name", "string"))
        IO.print(app ++ " > " ++ pkg)
        listed : String <- IO.try(String, Fs.read_dir("node_modules/.knot"))
        why_dirs(64n, String.lines(listed), pkg)
    case Nil{}:
      IO.die(Unit, 2, "knot: unknown command why (unknown_command)")





def fetch_commit_ok(+tmp: String, +cas: String, ex: Bool, ok: Bool) -> IO(Unit):
  match ok:
    case False{}:
      die_integrity()
    case True{}:
      commit_cas(tmp, cas, ex)

def fetch_one(+url: String, +integrity: String) -> IO(Unit):
  do IO<Unit>:
    +cas : String <- cas_file(integrity)


    +ex : Bool <- file_exists(cas)
    +tmp : String = ".knot/tmp.tgz"
    +tar_use : String <- fetch_tar(url, tmp, cas, ex)
    got : String <- IO.try(String, Hash.sha512_b64(tar_use))
    fetch_commit_ok(tar_use, cas, ex, sri_ok(got, integrity))

def fetch_job(
  fuel: Nat,
  parts: List<&2, String>,
  lines: List<&2, String>,
  +tarball: String
) -> IO(Unit):
  match fuel:
    case 0n:
      IO.die(Unit, 1, "knot: lockfile too large")
    case 1n+p:
      match parts:
        case Nil{}:
          match lines:
            case Nil{}:
              IO.pure(Unit, Unit{})
            case Con{SNil{}, rest}:
              fetch_job(p, Nil{}, rest, tarball)
            case Con{line, rest}:
              fetch_job(p, String.split(line, ' '), rest, tarball)
        case Con{SCon{'t', SCon{'a', SCon{'r', SCon{'b', SCon{'a', SCon{'l', SCon{'l', SNil{}}}}}}}}, Con{+url, Nil{}}}:
          fetch_job(p, Nil{}, lines, url)
        case Con{SCon{'i', SCon{'n', SCon{'t', SCon{'e', SCon{'g', SCon{'r', SCon{'i', SCon{'t', SCon{'y', SNil{}}}}}}}}}}, Con{+i, Nil{}}}:
          do IO<Unit>:
            fetch_one(tarball, i)
            fetch_job(p, Nil{}, lines, "")
        case _:
          fetch_job(p, Nil{}, lines, tarball)

def run_fetch(args: List<&2, String>) -> IO(Unit):
  match args:
    case _:
      do IO<Unit>:
        lock : String <- read_text("knot.lock")
        fetch_job(64n, Nil{}, String.lines(lock), "")



def note_flag(+path: String, on: Bool) -> IO(Unit):
  match on:
    case False{}:
      do IO<Unit>:
        u : Unit <- IO.try(Unit, Fs.unlink(path))
        return Unit{}
    case True{}:
      do IO<Unit>:
        u0 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
        write_text(path, "1")

def note_ignore(ignore: Bool) -> IO(Unit):
  note_flag(".knot/ignore-scripts", ignore)

def flag_offline_eq(ok: Bool, +flag: String) -> Bool:
  match ok:
    case True{}:
      True{}
    case False{}:
      String.eq(flag, "--prefer-offline")

def flag_offline(+flag: String) -> Bool:
  flag_offline_eq(String.eq(flag, "--offline"), flag)

def note_silent(silent: Bool) -> IO(Unit):
  note_flag(".knot/silent", silent)

def note_reporter(+mode: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
    write_text(".knot/reporter", mode)
    note_silent(String.eq(mode, "silent"))


def note_production(prod: Bool) -> IO(Unit):
  note_flag(".knot/production", prod)


def note_dry(dry: Bool) -> IO(Unit):
  note_flag(".knot/dry-run", dry)

def note_backend_ok(ok: Bool, +mode: String) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: unknown backend " ++ mode ++ " (unknown_backend)")

def note_backend(+mode: String) -> IO(Unit):
  note_backend_ok(Bool.or(String.eq(mode, "copy"), Bool.or(String.eq(mode, "auto"), Bool.or(String.eq(mode, "hardlink"), String.eq(mode, "clone")))), mode)

def parse_install_finish(registry: Maybe<&2, String>, offline: Bool, frozen: Bool) ->
  IO(String & Bool & Bool):
  match registry:
    case None{}:
      match offline:
        case True{}:
          IO.pure(String & Bool & Bool, ("", frozen, True{}))
        case False{}:
          IO.pure(String & Bool & Bool, ("https://registry.npmjs.org", frozen, False{}))

    case Some{url}:
      match offline:
        case True{}:
          IO.pure(String & Bool & Bool, (url, frozen, True{}))
        case False{}:
          IO.pure(String & Bool & Bool, (url, frozen, False{}))

def parse_install_done(registry: Maybe<&2, String>, offline: Bool, frozen: Bool, ignore: Bool, prod: Bool, dry: Bool) ->
  IO(String & Bool & Bool):
  do IO<String & Bool & Bool>:
    note_ignore(ignore)
    note_production(prod)
    note_dry(dry)
    parse_install_finish(registry, offline, frozen)

def parse_install(
  fuel: Nat,
  phase: Nat,
  args: List<&2, String>,
  registry: Maybe<&2, String>,
  frozen: Bool,
  +offline: Bool,
  +ignore: Bool,
  +prod: Bool,
  +dry: Bool,
  +flag: String,
  is_b: Bool
) -> IO(String & Bool & Bool):
  match fuel:
    case 0n:
      parse_install_done(registry, offline, frozen, ignore, prod, dry)
    case 1n+p:
      match phase:
        case 0n:
          match args:
            case Nil{}:
              parse_install_done(registry, offline, frozen, ignore, prod, dry)
            case Con{+f, rest}:
              parse_install(p, 9n, rest, registry, frozen, offline, ignore, prod, dry, f, String.eq(f, "--cpu"))


        case 1n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, True{}, offline, ignore, prod, dry, "", False{})
            case False{}:
              parse_install(p, 2n, args, registry, frozen, offline, ignore, prod, dry, flag, flag_offline(flag))
        case 2n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, frozen, True{}, ignore, prod, dry, "", False{})
            case False{}:
              parse_install(p, 3n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--ignore-scripts"))
        case 3n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, frozen, offline, True{}, prod, dry, "", False{})
            case False{}:
              parse_install(p, 4n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--production"))
        case 4n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, frozen, offline, ignore, True{}, dry, "", False{})
            case False{}:
              parse_install(p, 5n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--dry-run"))
        case 5n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, frozen, offline, ignore, prod, True{}, "", False{})
            case False{}:
              parse_install(p, 6n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--registry"))
        case 6n:
          match is_b:
            case False{}:
              parse_install(p, 10n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--store-dir"))

            case True{}:
              parse_install(p, 7n, args, registry, frozen, offline, ignore, prod, dry, flag, False{})
        case 9n:
          match is_b:
            case True{}:
              parse_install(p, 0n, args, registry, frozen, offline, ignore, prod, dry, "", False{})
            case False{}:
              parse_install(p, 8n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--gpu"))
        case 8n:
          match is_b:
            case True{}:
              IO.die(String & Bool & Bool, 2, "knot: no supported GPU backend (gpu_unavailable)")
            case False{}:
              parse_install(p, 1n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--frozen-lockfile"))

        case 10n:
          match is_b:
            case True{}:
              parse_install(p, 11n, args, registry, frozen, offline, ignore, prod, dry, flag, False{})
            case False{}:
              parse_install(p, 12n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--reporter"))
        case 11n:
          match args:
            case Con{+dir, more}:
              do IO<String & Bool & Bool>:
                u0 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
                write_text(".knot/store-dir", dir)
                parse_install(p, 0n, more, registry, frozen, offline, ignore, prod, dry, "", False{})
            case Nil{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command install (unknown_command)")

        case 12n:
          match is_b:
            case True{}:
              parse_install(p, 13n, args, registry, frozen, offline, ignore, prod, dry, flag, False{})
            case False{}:
              parse_install(p, 14n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--filter"))
        case 13n:
          match args:
            case Con{+mode, more}:
              do IO<String & Bool & Bool>:
                u0 : Unit <- note_reporter(mode)
                parse_install(p, 0n, more, registry, frozen, offline, ignore, prod, dry, "", False{})
            case Nil{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command install (unknown_command)")
        case 14n:
          match is_b:
            case True{}:
              parse_install(p, 15n, args, registry, frozen, offline, ignore, prod, dry, flag, False{})
            case False{}:
              parse_install(p, 16n, args, registry, frozen, offline, ignore, prod, dry, flag, String.eq(flag, "--backend"))
        case 15n:
          match args:
            case Con{+sel, more}:
              do IO<String & Bool & Bool>:
                u0 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
                write_text(".knot/filter", sel)
                parse_install(p, 0n, more, registry, frozen, offline, ignore, prod, dry, "", False{})
            case Nil{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command install (unknown_command)")
        case 16n:
          match is_b:
            case True{}:
              parse_install(p, 17n, args, registry, frozen, offline, ignore, prod, dry, flag, False{})
            case False{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command " ++ flag ++ " (unknown_command)")
        case 17n:
          match args:
            case Con{+mode, more}:
              do IO<String & Bool & Bool>:
                u0 : Unit <- note_backend(mode)
                parse_install(p, 0n, more, registry, frozen, offline, ignore, prod, dry, "", False{})
            case Nil{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command install (unknown_command)")
        case _:
          match args:
            case Con{url, more}:
              parse_install(p, 0n, more, Some{url}, frozen, offline, ignore, prod, dry, "", False{})
            case Nil{}:
              IO.die(String & Bool & Bool, 2, "knot: unknown command install (unknown_command)")


def parse_install_args(+args: List<&2, String>) -> IO(String & Bool & Bool):
  do IO<String & Bool & Bool>:
    u : Unit <- note_silent(False{})
    u2 : Unit <- IO.try(Unit, Fs.unlink(".knot/filter"))
    u3 : Unit <- IO.try(Unit, Fs.unlink(".knot/reporter"))
    parse_install(Nat.add(16n, Nat.mul(8n, List.length(&2, String, args))), 0n, args, None{}, False{}, False{}, False{}, False{}, False{}, "", False{})





def check_frozen_ok(+lock: String, +name: String, +spec: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 1, "knot: lockfile is stale (frozen_lockfile)")

def check_frozen_spec(+name: String, +spec: String, +lock: String) -> IO(Unit):
  check_frozen_ok(
    lock,
    name,
    spec,
    Bool.and(String.contains(lock, "name " ++ name), String.contains(lock, "version " ++ spec))
  )

def check_frozen_parts(parts: List<&2, String>, lock: String) -> IO(Unit):
  match parts:
    case Con{name, Con{spec, Nil{}}}:
      check_frozen_spec(name, spec, lock)
    case _:
      IO.die(Unit, 1, "knot: invalid dependency entry")

def check_frozen_line(line: String, lock: String) -> IO(Unit):
  check_frozen_parts(String.split(line, '\t'), lock)

def check_frozen(+lock: String, lines: List<&2, String>) -> IO(Unit):
  match lines:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{line, rest}:
      do IO<Unit>:
        check_frozen_line(line, lock)
        check_frozen(lock, rest)

def run_frozen(pairs: String) -> IO(Unit):
  do IO<Unit>:
    lock : String <- read_text("knot.lock")
    check_frozen(lock, String.lines(pairs))

def drop_dep_eq(+pairs: String, hit: Bool) -> String:
  match hit:
    case True{}:
      ""
    case False{}:
      pairs

def drop_dep_line(+pairs: String, +name: String) -> String:
  drop_dep_eq(pairs, String.contains(pairs, name ++ "\t"))

def workspace_name(dir: String) -> IO(String):
  do IO<String>:
    txt : String <- read_text(dir ++ "/package.json")
    IO.try(String, Json.query(txt, "name", "string"))

def check_dup_workspace(ok: Bool, +name: String) -> IO(Unit):
  match ok:
    case True{}:
      IO.die(Unit, 1, "knot: duplicate workspace name " ++ name ++ " (duplicate_workspace)")
    case False{}:
      IO.pure(Unit, Unit{})

def filter_keeps(ex: Bool, +dir: String) -> IO(Bool):
  match ex:
    case False{}:
      IO.pure(Bool, True{})
    case True{}:
      do IO<Bool>:
        sel : String <- read_text(".knot/filter")
        return String.eq(sel, dir)

def link_keep(+dir: String) -> IO(Bool):
  do IO<Bool>:
    ex : Bool <- file_exists(".knot/filter")
    filter_keeps(ex, dir)

def link_one_kept(keep: Bool, +dir: String, pairs: String) -> IO(String):
  match keep:
    case False{}:
      IO.pure(String, pairs)
    case True{}:
      do IO<String>:
        +name : String <- workspace_name(dir)
        ex : Bool <- file_exists("node_modules/" ++ name)
        u_dup : Unit <- check_dup_workspace(ex, name)
        u0 : Unit <- IO.try(Unit, Fs.mkdir_p("node_modules"))
        u1 : Unit <- IO.try(Unit, Fs.symlink("../" ++ dir, "node_modules/" ++ name))
        txt : String <- read_text(dir ++ "/package.json")
        deps : String <- json_optional_pairs(txt, "dependencies")
        return join_pair_lines(drop_dep_line(pairs, name), deps)

def link_one_workspace(+dir: String, pairs: String) -> IO(String):
  do IO<String>:
    keep : Bool <- link_keep(dir)
    link_one_kept(keep, dir, pairs)

def link_workspaces(fuel: Nat, paths: List<&2, String>, pairs: String) -> IO(String):
  match fuel:
    case 0n:
      IO.pure(String, pairs)
    case 1n+p:
      match paths:
        case Nil{}:
          IO.pure(String, pairs)
        case Con{SNil{}, rest}:
          link_workspaces(p, rest, pairs)
        case Con{dir, rest}:
          do IO<String>:
            pairs2 : String <- link_one_workspace(dir, pairs)
            link_workspaces(p, rest, pairs2)




def parts_in_lock(+lock: String, parts: List<&2, String>) -> Bool:
  match parts:
    case Con{+name, _}:
      String.contains(lock, "name " ++ name ++ "\n")
    case _:
      True{}

def line_in_lock(+lock: String, line: String) -> Bool:
  parts_in_lock(lock, String.split(line, '\t'))

def pairs_locked(+lock: String, lines: List<&2, String>) -> Bool:
  match lines:
    case Nil{}:
      True{}
    case Con{SNil{}, rest}:
      pairs_locked(lock, rest)
    case Con{line, rest}:
      Bool.and(line_in_lock(lock, line), pairs_locked(lock, rest))

def pairs_has_name(lines: List<&2, String>) -> Bool:
  match lines:
    case Nil{}:
      False{}
    case Con{SNil{}, rest}:
      pairs_has_name(rest)
    case Con{_, rest}:
      True{}

def count_name_inc(ok: Bool, +acc: Nat) -> Nat:
  match ok:
    case True{}:
      Nat.add(1n, acc)
    case False{}:
      acc

def count_name_lines(fuel: Nat, lines: List<&2, String>, acc: Nat) -> Nat:
  match fuel:
    case 0n:
      acc
    case 1n+p:
      match lines:
        case Nil{}:
          acc
        case Con{+line, rest}:
          count_name_lines(p, rest, count_name_inc(String.starts_with(line, "name "), acc))

def run_locked_count(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Done{n}:
      IO.pure(String, n)
    case Fail{_}:
      do IO<String>:
        lock : String <- read_text("knot.lock")
        u : Unit <- run_offline()
        return Nat.show(count_name_lines(4096n, String.lines(lock), 0n))

def run_install_locked() -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    r : Result<&1, &1, U32 & String, String> <- Fs.offline_lock()
    n : String <- run_locked_count(r)
    u_sum : Unit <- progress(n ++ " packages installed")
    end : Nat <- IO.now()
    progress(format_elapsed(Nat.sub(end, start)))

def run_install_resolve(+registry: String, +pairs: String, +text: String) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    ws : String <- json_optional_lines(text, "workspaces")
    pairs2 : String <- link_workspaces(8n, String.lines(ws), pairs)
    +recs : List<&2, String> <- install_job(256n, Nil{}, String.lines(pairs2), registry, None{}, False{}, False{}, "\n", False{})
    u_sum : Unit <- progress(Nat.show(List.length(&2, String, recs)) ++ " packages installed")
    write_text("knot.lock", render_lock(List.sort(~String, ~lock_le, recs)))
    end : Nat <- IO.now()
    progress(format_elapsed(Nat.sub(end, start)))

def run_install_covered(ok: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match ok:
    case True{}:
      run_install_locked()
    case False{}:
      run_install_resolve(registry, pairs, text)

def run_install_has(has: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match has:
    case False{}:
      run_install_resolve(registry, pairs, text)
    case True{}:
      do IO<Unit>:
        lock : String <- read_text("knot.lock")
        run_install_covered(Bool.and(pairs_has_name(String.lines(pairs)), pairs_locked(lock, String.lines(pairs))), registry, pairs, text)

def run_install_with(+registry: String, offline: Bool, frozen: Bool, +pairs: String, +text: String) -> IO(Unit):
  match offline:
    case True{}:
      run_offline()
    case False{}:
      match frozen:
        case True{}:
          run_frozen(pairs)
        case False{}:
          do IO<Unit>:
            has : Bool <- file_exists("knot.lock")
            run_install_has(has, registry, pairs, text)

def run_install_maybe_dry(dry: Bool, +registry: String, offline: Bool, frozen: Bool, +pairs: String, +text: String) -> IO(Unit):
  match dry:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      run_install_with(registry, offline, frozen, pairs, text)

def install_pairs(prod: Bool, +text: String) -> IO(String):
  match prod:
    case True{}:
      json_optional_pairs(text, "dependencies")
    case False{}:
      do IO<String>:
        deps : String <- json_optional_pairs(text, "dependencies")
        devs : String <- json_optional_pairs(text, "devDependencies")
        return join_pair_lines(deps, devs)

def check_protocol_spec(bad: Bool) -> IO(Unit):
  match bad:
    case True{}:
      IO.die(Unit, 1, "knot: unsupported protocol (unsupported_protocol)")
    case False{}:
      IO.pure(Unit, Unit{})

def check_protocol_parts(parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{_, Con{+spec, Nil{}}}:
      check_protocol_spec(String.contains(spec, ":"))
    case _:
      IO.pure(Unit, Unit{})

def check_protocol_line(line: String) -> IO(Unit):
  check_protocol_parts(String.split(line, '\t'))

def check_protocols(fuel: Nat, lines: List<&2, String>) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      match lines:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{line, rest}:
          do IO<Unit>:
            check_protocol_line(line)
            check_protocols(p, rest)


def run_install_parsed(parsed: String & Bool & Bool) -> IO(Unit):
  (registry, frozen, offline) = parsed
  do IO<Unit>:
    +text : String <- read_text("package.json")
    prod : Bool <- file_exists(".knot/production")
    dry : Bool <- file_exists(".knot/dry-run")
    +pairs : String <- install_pairs(prod, text)
    check_protocols(32n, String.lines(pairs))

    run_install_maybe_dry(dry, registry, offline, frozen, pairs, text)





def run_install(args: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    parsed : String & Bool & Bool <- parse_install_args(args)
    run_install_parsed(parsed)

def render_app_json(+app: String, +dep: String, +ver: String) -> String:
  "{\n  \"name\": \"" ++ app ++ "\",\n  \"type\": \"module\",\n  \"dependencies\": {\n    \"" ++ dep ++ "\": \"" ++ ver ++ "\"\n  }\n}\n"

def parse_add_done(name: Maybe<&2, String>, registry: Maybe<&2, String>) -> IO(String & String):
  match name:
    case None{}:
      IO.die(String & String, 2, "knot: unknown command add (unknown_command)")
    case Some{n}:
      match registry:
        case None{}:
          IO.die(String & String, 2, "knot: unknown command add (unknown_command)")
        case Some{url}:
          IO.pure(String & String, (n, url))

def parse_add(
  fuel: Nat,
  phase: Nat,
  args: List<&2, String>,
  name: Maybe<&2, String>,
  registry: Maybe<&2, String>,
  +flag: String,
  is_b: Bool
) -> IO(String & String):
  match fuel:
    case 0n:
      parse_add_done(name, registry)
    case 1n+p:
      match phase:
        case 0n:
          match args:
            case Nil{}:
              parse_add_done(name, registry)
            case Con{+f, rest}:
              parse_add(p, 1n, rest, name, registry, f, String.eq(f, "--registry"))
        case 1n:
          match is_b:
            case True{}:
              parse_add(p, 2n, args, name, registry, flag, False{})
            case False{}:
              parse_add(p, 0n, args, Some{flag}, registry, "", False{})
        case _:
          match args:
            case Con{url, more}:
              parse_add(p, 0n, more, name, Some{url}, "", False{})
            case Nil{}:
              IO.die(String & String, 2, "knot: unknown command add (unknown_command)")

def parse_add_args(+args: List<&2, String>) -> IO(String & String):
  parse_add(Nat.add(8n, Nat.mul(4n, List.length(&2, String, args))), 0n, args, None{}, None{}, "", False{})

def run_add_parsed(+name: String, +registry: String) -> IO(Unit):
  do IO<Unit>:
    text : String <- read_text("package.json")
    app : String <- IO.try(String, Json.query(text, "name", "string"))
    +meta : String <- Fetch.http_get(registry ++ "/" ++ name)
    ver : String <- IO.try(String, Json.query(meta, "dist-tags/latest", "string"))
    write_text("package.json", render_app_json(app, name, ver))
    run_install(Con{"--registry", Con{registry, Nil{}}})

def run_add_go(parsed: String & String) -> IO(Unit):
  (name, registry) = parsed
  run_add_parsed(name, registry)

def run_add(args: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    parsed : String & String <- parse_add_args(args)
    run_add_go(parsed)

def render_app_json_empty(+app: String) -> String:
  "{\n  \"name\": \"" ++ app ++ "\",\n  \"type\": \"module\",\n  \"dependencies\": {}\n}\n"

def run_remove_parsed(+name: String, +registry: String) -> IO(Unit):
  do IO<Unit>:
    text : String <- read_text("package.json")
    app : String <- IO.try(String, Json.query(text, "name", "string"))
    write_text("package.json", render_app_json_empty(app))
    u0 : Unit <- IO.try(Unit, Fs.unlink("node_modules/" ++ name))
    u1 : Unit <- IO.try(Unit, Fs.unlink("knot.lock"))
    run_install(Con{"--registry", Con{registry, Nil{}}})

def run_remove_go(parsed: String & String) -> IO(Unit):
  (name, registry) = parsed
  run_remove_parsed(name, registry)

def run_remove(args: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    parsed : String & String <- parse_add_args(args)
    run_remove_go(parsed)

def cache_unlink_one(+name: String) -> IO(Unit):
  match name:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case _:
      do IO<Unit>:
        root : String <- cache_root()
        u : Unit <- IO.try(Unit, Fs.unlink(root ++ "/" ++ name))
        return Unit{}

def cache_unlink_names(fuel: Nat, names: List<&2, String>) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      match names:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{name, rest}:
          do IO<Unit>:
            cache_unlink_one(name)
            cache_unlink_names(p, rest)

def run_cache_clean_dir(ex: Bool, +root: String) -> IO(Unit):
  match ex:
    case False{}:
      progress("cleared registry metadata cache")
    case True{}:
      do IO<Unit>:
        listed : String <- IO.try(String, Fs.read_dir(root))
        cache_unlink_names(4096n, String.lines(listed))
        progress("cleared registry metadata cache")

def run_cache_clean() -> IO(Unit):
  do IO<Unit>:
    +root : String <- cache_root()
    ex : Bool <- file_exists(root)
    run_cache_clean_dir(ex, root)

def run_cache_eq(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      run_cache_clean()
    case False{}:
      IO.die(Unit, 2, "knot: unknown command cache (unknown_command)")

def run_cache(args: List<&2, String>) -> IO(Unit):
  match args:
    case Con{+sub, _}:
      run_cache_eq(String.eq(sub, "clean"))
    case Nil{}:
      IO.die(Unit, 2, "knot: unknown command cache (unknown_command)")

def dispatch_cache(+cmd: String, rest: List<&2, String>, is_cache: Bool) -> IO(Unit):
  match is_cache:
    case True{}:
      run_cache(rest)
    case False{}:
      IO.die(Unit, 2, "knot: unknown command " ++ cmd ++ " (unknown_command)")

def dispatch_update(+cmd: String, rest: List<&2, String>, is_update: Bool) -> IO(Unit):
  match is_update:
    case True{}:
      run_install(rest)
    case False{}:
      dispatch_cache(cmd, rest, String.eq(cmd, "cache"))


def dispatch_why(+cmd: String, rest: List<&2, String>, is_why: Bool) -> IO(Unit):
  match is_why:
    case True{}:
      run_why(rest)
    case False{}:
      dispatch_update(cmd, rest, String.eq(cmd, "update"))


def dispatch_store(+cmd: String, rest: List<&2, String>, is_store: Bool) -> IO(Unit):
  match is_store:
    case True{}:
      run_store(rest)
    case False{}:
      dispatch_why(cmd, rest, String.eq(cmd, "why"))


def dispatch_list(+cmd: String, rest: List<&2, String>, is_list: Bool) -> IO(Unit):
  match is_list:
    case True{}:
      run_list(rest)
    case False{}:
      dispatch_store(cmd, rest, String.eq(cmd, "store"))


def dispatch_remove(+cmd: String, rest: List<&2, String>, is_remove: Bool) -> IO(Unit):
  match is_remove:
    case True{}:
      run_remove(rest)
    case False{}:
      dispatch_list(cmd, rest, String.eq(cmd, "list"))


def dispatch_add(+cmd: String, rest: List<&2, String>, is_add: Bool) -> IO(Unit):
  match is_add:
    case True{}:
      run_add(rest)
    case False{}:
      dispatch_remove(cmd, rest, String.eq(cmd, "remove"))


def dispatch_fetch(+cmd: String, rest: List<&2, String>, is_fetch: Bool) -> IO(Unit):
  match is_fetch:
    case True{}:
      run_fetch(rest)
    case False{}:
      dispatch_add(cmd, rest, String.eq(cmd, "add"))


def dispatch_install(+cmd: String, rest: List<&2, String>, is_install: Bool) -> IO(Unit):
  match is_install:
    case True{}:
      run_install(rest)
    case False{}:
      dispatch_fetch(cmd, rest, String.eq(cmd, "fetch"))


def is_tsx_go(tsx: Bool, jsx: Bool) -> Bool:
  match tsx:
    case True{}:
      True{}
    case False{}:
      jsx

def is_tsx(+file: String) -> Bool:
  is_tsx_go(String.ends_with(file, ".tsx"), String.ends_with(file, ".jsx"))

def jsx_mode_ok(+mode: String) -> Bool:
  Bool.or(String.eq(mode, "classic"), Bool.or(String.eq(mode, "automatic"), String.eq(mode, "preserve")))

def jsx_prep_res(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.die(String, 1, "knot: jsx transform failed (syntax_error)")
    case Done{s}:
      IO.pure(String, s)

def jsx_prep_do(+src: String, +mode: String, +factory: String, +fragment: String, +isrc: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Jsx.lower(src, mode, factory, fragment, isrc)
    jsx_prep_res(r)

def jsx_prep_mode_pres(pres: Bool, +src: String, +mode: String, +factory: String, +fragment: String, +isrc: String) -> IO(String):
  match pres:
    case True{}:
      IO.pure(String, src)
    case False{}:
      jsx_prep_do(src, mode, factory, fragment, isrc)

def jsx_prep_mode(tsx: Bool, +src: String, +mode: String, +factory: String, +fragment: String, +isrc: String) -> IO(String):
  match tsx:
    case False{}:
      IO.pure(String, src)
    case True{}:
      jsx_prep_mode_pres(String.eq(mode, "preserve"), src, mode, factory, fragment, isrc)

def jsx_prep(+file: String, +src: String, +mode: String, +factory: String, +fragment: String, +isrc: String) -> IO(String):
  jsx_prep_mode(is_tsx(file), src, mode, factory, fragment, isrc)


def is_ts_go(ts: Bool, tsx: Bool) -> Bool:
  match ts:
    case True{}:
      True{}
    case False{}:
      tsx

def is_ts(+file: String) -> Bool:
  is_ts_go(String.ends_with(file, ".ts"), String.ends_with(file, ".tsx"))

def ts_prep_res(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.die(String, 1, "knot: ts transform failed (syntax_error)")
    case Done{s}:
      IO.pure(String, s)

def ts_prep_do(+src: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Ts.lower(src)
    ts_prep_res(r)

def ts_prep_mode(ts: Bool, +src: String) -> IO(String):
  match ts:
    case False{}:
      IO.pure(String, src)
    case True{}:
      ts_prep_do(src)

def ts_prep(+file: String, +src: String) -> IO(String):
  ts_prep_mode(is_ts(file), src)

def transpile_none(first: Bool) -> IO(Unit):
  match first:
    case True{}:
      IO.die(Unit, 2, "knot: transpile requires a file (missing_input)")
    case False{}:
      IO.pure(Unit, Unit{})

def transpile_write_js_none(none: Bool, +jsp: String, +js: String) -> IO(Unit):
  match none:
    case True{}:
      write_text(jsp, js ++ "\n")
    case False{}:
      write_text(jsp, js ++ "\n//# sourceMappingURL=" ++ Compiler.basename(jsp) ++ ".map\n")

def transpile_write_js_ext(ext: Bool, +jsp: String, +js: String, +sm: String) -> IO(Unit):
  match ext:
    case True{}:
      write_text(jsp, js ++ "\n")
    case False{}:
      transpile_write_js_none(String.eq(sm, "none"), jsp, js)

def transpile_write_js(+jsp: String, +js: String, +sm: String) -> IO(Unit):
  transpile_write_js_ext(String.eq(sm, "external"), jsp, js, sm)

def transpile_write_map_none(none: Bool, +jsp: String, +map: String) -> IO(Unit):
  match none:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      write_text(jsp ++ ".map", map)

def transpile_write_map(+jsp: String, +map: String, +sm: String) -> IO(Unit):
  transpile_write_map_none(String.eq(sm, "none"), jsp, map)

def transpile_ok_to(+jsp: String, js: String, map: String, +sm: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- IO.try(Unit, Fs.mkdir_p(Compiler.dirname(jsp)))
    u1 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot/build-cache"))
    u2 : Unit <- write_text(".knot/build-cache/v1", "1")
    u3 : Unit <- transpile_write_js(jsp, js, sm)
    transpile_write_map(jsp, map, sm)


def transpile_ok(+file: String, js: String, map: String, +sm: String) -> IO(Unit):
  transpile_ok_to(Compiler.js_path(file), js, map, sm)

def transpile_write(+file: String, r: Compiler.TRes, +sm: String) -> IO(Unit):
  match r:
    case Compiler.TOk{js, map}:
      transpile_ok(file, js, map, sm)
    case Compiler.TErr{msg, line, col}:
      IO.die(Unit, 1, "knot: " ++ file ++ ":" ++ U32.show(U32.inc(line)) ++ ":" ++ U32.show(U32.inc(col)) ++ ": " ++ msg ++ " (syntax_error)")

def transpile_write_to(+file: String, +jsp: String, r: Compiler.TRes, +sm: String) -> IO(Unit):
  match r:
    case Compiler.TOk{js, map}:
      transpile_ok_to(jsp, js, map, sm)
    case Compiler.TErr{msg, line, col}:
      IO.die(Unit, 1, "knot: " ++ file ++ ":" ++ U32.show(U32.inc(line)) ++ ":" ++ U32.show(U32.inc(col)) ++ ": " ++ msg ++ " (syntax_error)")

def transpile_one_miss(+file: String, +src: String, +sm: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- transpile_write(file, Compiler.transpile(file, src), sm)
    write_text(".knot/build-cache/src", src)

def transpile_one_eq(+file: String, +src: String, eq: Bool, +sm: String) -> IO(Unit):
  match eq:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      transpile_one_miss(file, src, sm)

def transpile_one_src_ex(+file: String, +src: String, ex: Bool, +sm: String) -> IO(Unit):
  match ex:
    case False{}:
      transpile_one_miss(file, src, sm)
    case True{}:
      do IO<Unit>:
        +c : String <- read_text(".knot/build-cache/src")
        transpile_one_eq(file, src, String.eq(src, c), sm)

def transpile_one_v1(+file: String, +src: String, v1: Bool, +sm: String) -> IO(Unit):
  match v1:
    case False{}:
      transpile_one_miss(file, src, sm)
    case True{}:
      do IO<Unit>:
        ex : Bool <- file_exists(".knot/build-cache/src")
        transpile_one_src_ex(file, src, ex, sm)


def transpile_one(+file: String, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  do IO<Unit>:
    +raw : String <- read_text(file)
    +mid : String <- ts_prep(file, raw)
    +src : String <- jsx_prep(file, mid, mode, factory, fragment, isrc)
    v1 : Bool <- file_exists(".knot/build-cache/v1")
    transpile_one_v1(file, src, v1, sm)


def transpile_one_to_min(+file: String, +out: String, minify: Bool, ids: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  do IO<Unit>:
    raw : String <- read_text(file)
    mid : String <- ts_prep(file, raw)
    src : String <- jsx_prep(file, mid, mode, factory, fragment, isrc)
    transpile_write_to(file, out, Compiler.transpile_opt(file, src, minify, ids), sm)

def transpile_one_to(+file: String, +out: String, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  transpile_one_to_min(file, out, False{}, False{}, mode, sm, factory, fragment, isrc)


def transpile_files(args: List<&2, String>, first: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  match args:
    case Nil{}:
      transpile_none(first)
    case Con{+file, rest}:
      do IO<Unit>:
        u : Unit <- transpile_one(file, mode, sm, factory, fragment, isrc)
        transpile_files(rest, False{}, mode, sm, factory, fragment, isrc)

def run_tp_ok_min(+file: String, +flag: String, +out: String, ok: Bool, minify: Bool, ids: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  match ok:
    case True{}:
      transpile_one_to_min(file, out, minify, ids, mode, sm, factory, fragment, isrc)
    case False{}:
      transpile_files(Con{file, Con{flag, Con{out, Nil{}}}}, True{}, mode, sm, factory, fragment, isrc)

def run_transpile_args(args: List<&2, String>, minify: Bool, ids: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  match args:
    case Con{+file, Con{+flag, Con{+out, Nil{}}}}:
      run_tp_ok_min(file, flag, out, String.eq(flag, "--outfile"), minify, ids, mode, sm, factory, fragment, isrc)
    case _:
      transpile_files(args, True{}, mode, sm, factory, fragment, isrc)

def run_transpile_i(+head: String, rest: List<&2, String>, mi: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  match mi:
    case True{}:
      run_transpile_args(rest, False{}, True{}, mode, sm, factory, fragment, isrc)
    case False{}:
      run_transpile_args(Con{head, rest}, False{}, False{}, mode, sm, factory, fragment, isrc)

def run_transpile_h(+head: String, rest: List<&2, String>, mw: Bool, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  match mw:
    case True{}:
      run_transpile_args(rest, True{}, False{}, mode, sm, factory, fragment, isrc)
    case False{}:
      run_transpile_i(head, rest, String.eq(head, "--minify-identifiers"), mode, sm, factory, fragment, isrc)

# sel: 0=go args; 1..5=flag kinds with head/rest; 10+=take which/val
# which codes via string still compared in arms through precomputed bools
@unsafe def run_transpile_k(sel: Nat, args: List<&2, String>, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String, +head: String, rest: List<&2, String>, +which: String, +val: String, b0: Bool, b1: Bool, b2: Bool, b3: Bool, b4: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          transpile_files(args, True{}, mode, sm, factory, fragment, isrc)
        case Con{+h, r}:
          run_transpile_k(1n, Nil{}, mode, sm, factory, fragment, isrc, h, r, "", "", String.eq(h, "--sourcemap"), String.eq(h, "--jsx-runtime"), String.eq(h, "--jsx-factory"), String.eq(h, "--jsx-fragment"), String.eq(h, "--jsx-import-source"))
    case 1n:
      match b0:
        case True{}:
          run_transpile_k(10n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "sourcemap", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(2n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "", "", b1, b2, b3, b4, False{})
    case 2n:
      match b0:
        case True{}:
          run_transpile_k(10n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "jsx-runtime", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(3n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "", "", b1, b2, b3, False{}, False{})
    case 3n:
      match b0:
        case True{}:
          run_transpile_k(10n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "jsx-factory", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(4n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "", "", b1, b2, False{}, False{}, False{})
    case 4n:
      match b0:
        case True{}:
          run_transpile_k(10n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "jsx-fragment", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(5n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "", "", b1, False{}, False{}, False{}, False{})
    case 5n:
      match b0:
        case True{}:
          run_transpile_k(10n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, "jsx-import-source", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_h(head, rest, String.eq(head, "--minify-whitespace"), mode, sm, factory, fragment, isrc)
    case 10n:
      match rest:
        case Con{+v, tail}:
          run_transpile_k(11n, Nil{}, mode, sm, factory, fragment, isrc, head, tail, which, v, String.eq(which, "sourcemap"), String.eq(which, "jsx-runtime"), String.eq(which, "jsx-factory"), String.eq(which, "jsx-fragment"), jsx_mode_ok(v))
        case Nil{}:
          run_transpile_k(20n, Nil{}, mode, sm, factory, fragment, isrc, head, Nil{}, which, "", String.eq(which, "sourcemap"), String.eq(which, "jsx-runtime"), String.eq(which, "jsx-factory"), String.eq(which, "jsx-fragment"), False{})
    case 11n:
      match b0:
        case True{}:
          run_transpile_k(0n, rest, mode, val, factory, fragment, isrc, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(12n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, which, val, b1, b2, b3, b4, False{})
    case 12n:
      match b0:
        case True{}:
          match b3:
            case True{}:
              run_transpile_k(0n, rest, val, sm, factory, fragment, isrc, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
            case False{}:
              IO.die(Unit, 2, "knot: --jsx-runtime requires classic|automatic|preserve (missing_input)")
        case False{}:
          run_transpile_k(13n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, which, val, b1, b2, False{}, False{}, False{})
    case 13n:
      match b0:
        case True{}:
          run_transpile_k(0n, rest, mode, sm, val, fragment, isrc, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(14n, Nil{}, mode, sm, factory, fragment, isrc, head, rest, which, val, b1, False{}, False{}, False{}, False{})
    case 14n:
      match b0:
        case True{}:
          run_transpile_k(0n, rest, mode, sm, factory, val, isrc, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_transpile_k(0n, rest, mode, sm, factory, fragment, val, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
    case _:
      match b0:
        case True{}:
          IO.die(Unit, 2, "knot: --sourcemap requires linked|external|none (missing_input)")
        case False{}:
          match b1:
            case True{}:
              IO.die(Unit, 2, "knot: --jsx-runtime requires classic|automatic|preserve (missing_input)")
            case False{}:
              match b2:
                case True{}:
                  IO.die(Unit, 2, "knot: --jsx-factory requires a name (missing_input)")
                case False{}:
                  match b3:
                    case True{}:
                      IO.die(Unit, 2, "knot: --jsx-fragment requires a name (missing_input)")
                    case False{}:
                      IO.die(Unit, 2, "knot: --jsx-import-source requires a package (missing_input)")

def run_transpile_go(args: List<&2, String>, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  run_transpile_k(0n, args, mode, sm, factory, fragment, isrc, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})

def run_transpile(args: List<&2, String>) -> IO(Unit):
  run_transpile_go(args, "classic", "linked", "React.createElement", "React.Fragment", "react")



def dispatch_transpile(+cmd: String, rest: List<&2, String>, is_transpile: Bool) -> IO(Unit):
  match is_transpile:
    case True{}:
      run_transpile(rest)
    case False{}:
      dispatch_install(cmd, rest, String.eq(cmd, "install"))

def analyze_none(first: Bool) -> IO(Unit):
  match first:
    case True{}:
      IO.die(Unit, 2, "knot: analyze requires an entrypoint (missing_input)")
    case False{}:
      IO.pure(Unit, Unit{})

def analyze_soft_tsx_ex(+tsx: String, ex2: Bool) -> IO(String):
  match ex2:
    case True{}:
      IO.pure(String, tsx)
    case False{}:
      IO.pure(String, "")

def analyze_soft_ts_ex(+path: String, +ts: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, ts)
    case False{}:
      do IO<String>:
        +tsx : String = path ++ ".tsx"
        ex2 : Bool <- file_exists(tsx)
        analyze_soft_tsx_ex(tsx, ex2)

def analyze_soft_ts(+path: String) -> IO(String):
  do IO<String>:
    +ts : String = path ++ ".ts"
    ex : Bool <- file_exists(ts)
    analyze_soft_ts_ex(path, ts, ex)

def analyze_soft_file_ex(+path: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, path)
    case False{}:
      analyze_soft_ts(path)

def analyze_soft_file(+path: String) -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists(path)
    analyze_soft_file_ex(path, ex)

def analyze_soft_index_ts_ex(+ts: String, ex2: Bool) -> IO(String):
  match ex2:
    case True{}:
      IO.pure(String, ts)
    case False{}:
      IO.pure(String, "")

def analyze_soft_index_ex(+spec: String, +js: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, js)
    case False{}:
      do IO<String>:
        +ts : String = Compiler.pkg_index_ts(spec)
        ex2 : Bool <- file_exists(ts)
        analyze_soft_index_ts_ex(ts, ex2)

def analyze_soft_index(+spec: String) -> IO(String):
  do IO<String>:
    +js : String = Compiler.pkg_index_js(spec)
    ex : Bool <- file_exists(js)
    analyze_soft_index_ex(spec, js, ex)

def analyze_soft_main(+spec: String, +main: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      analyze_soft_index(spec)
    case False{}:
      analyze_soft_file(Compiler.pkg_join(spec, main))

def analyze_soft_pkg_ex(+spec: String, +pj: String, ex: Bool) -> IO(String):
  match ex:
    case False{}:
      analyze_soft_index(spec)
    case True{}:
      do IO<String>:
        +text : String <- read_text(pj)
        +main : String <- json_optional_string(text, "main")
        analyze_soft_main(spec, main, String.is_empty(main))

def analyze_soft_pkg(+spec: String) -> IO(String):
  do IO<String>:
    +pj : String = Compiler.pkg_json(spec)
    ex : Bool <- file_exists(pj)
    analyze_soft_pkg_ex(spec, pj, ex)

def analyze_resolve_rel(rel: Bool, +importer: String, +spec: String) -> IO(String):
  match rel:
    case True{}:
      analyze_soft_file(Compiler.resolve_rel(importer, spec))
    case False{}:
      analyze_soft_pkg(spec)

def analyze_resolve(+importer: String, +spec: String) -> IO(String):
  analyze_resolve_rel(Compiler.is_rel(spec), importer, spec)

def analyze_mod_json(+file: String, imports: List<&2, String>, exports: List<&2, String>) -> String:
  "{\"file\":" ++ Compiler.json_str(file) ++ ",\"imports\":" ++ Compiler.json_list(imports) ++ ",\"exports\":" ++ Compiler.json_list(exports) ++ "}"

def analyze_mods_go(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      h
    case Con{h, t}:
      h ++ "," ++ analyze_mods_go(t)

def analyze_mods_json(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      "[]"
    case _:
      "[" ++ analyze_mods_go(xs) ++ "]"

def analyze_app(xs: List<&2, String>, x: String) -> List<&2, String>:
  match xs:
    case Nil{}:
      Con{x, Nil{}}
    case Con{h, t}:
      Con{h, analyze_app(t, x)}

@unsafe def analyze_has(sel: Nat, xs: List<&2, String>, +f: String, eq: Bool) -> Bool:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          False{}
        case Con{+h, t}:
          analyze_has(1n, t, f, String.eq(h, f))
    case _:
      match eq:
        case True{}:
          True{}
        case False{}:
          analyze_has(0n, xs, f, False{})

def analyze_miss_add(+miss: List<&2, String>, +spec: String, empty: Bool) -> List<&2, String>:
  match empty:
    case True{}:
      analyze_app(miss, spec)
    case False{}:
      miss

@unsafe def analyze_go(sel: Nat, +file: String, imps: List<&2, String>, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, seen: Bool, empty: Bool, +spec: String, +path: String, st: List<&2, String> & List<&2, String> & List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String>):
  match sel:
    case 0n:
      match seen:
        case True{}:
          IO.pure(List<&2, String> & List<&2, String> & List<&2, String>, (visited, mods, miss))
        case False{}:
          do IO<List<&2, String> & List<&2, String> & List<&2, String>>:
            +src : String <- read_text(file)
            +imps2 : List<&2, String> = Compiler.imports_of(src)
            +exps : List<&2, String> = Compiler.exports_of(src)
            +mod : String = analyze_mod_json(file, imps2, exps)
            analyze_go(1n, file, imps2, analyze_app(visited, file), analyze_app(mods, mod), miss, False{}, False{}, "", "", (Nil{}, Nil{}, Nil{}))
    case 1n:
      match imps:
        case Nil{}:
          IO.pure(List<&2, String> & List<&2, String> & List<&2, String>, (visited, mods, miss))
        case Con{+sp, rest}:
          do IO<List<&2, String> & List<&2, String> & List<&2, String>>:
            +p2 : String <- analyze_resolve(file, sp)
            analyze_go(2n, file, rest, visited, mods, miss, False{}, String.is_empty(p2), sp, p2, (Nil{}, Nil{}, Nil{}))
    case 2n:
      match empty:
        case True{}:
          analyze_go(1n, file, imps, visited, mods, analyze_miss_add(miss, spec, True{}), False{}, False{}, "", "", (Nil{}, Nil{}, Nil{}))
        case False{}:
          do IO<List<&2, String> & List<&2, String> & List<&2, String>>:
            st2 : List<&2, String> & List<&2, String> & List<&2, String> <- analyze_go(0n, path, Nil{}, visited, mods, miss, analyze_has(0n, visited, path, False{}), False{}, "", "", (Nil{}, Nil{}, Nil{}))
            analyze_go(3n, file, imps, visited, mods, miss, False{}, False{}, "", "", st2)
    case _:
      (vis2, mods2, miss2) = st
      analyze_go(1n, file, imps, vis2, mods2, miss2, False{}, False{}, "", "", (Nil{}, Nil{}, Nil{}))

def analyze_entry_cont(+file: String, +entries: List<&2, String>, st: List<&2, String> & List<&2, String> & List<&2, String>) -> List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>:
  (vis2, mods2, miss2) = st
  (analyze_app(entries, file), vis2, mods2, miss2)

def analyze_entry_ex(+file: String, ex: Bool, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, +entries: List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>):
  match ex:
    case False{}:
      IO.pure(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>, (analyze_app(entries, file), visited, mods, analyze_app(miss, file)))
    case True{}:
      do IO<List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>>:
        st : List<&2, String> & List<&2, String> & List<&2, String> <- analyze_go(0n, file, Nil{}, visited, mods, miss, analyze_has(0n, visited, file, False{}), False{}, "", "", (Nil{}, Nil{}, Nil{}))
        return analyze_entry_cont(file, entries, st)

def analyze_entry(+file: String, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, +entries: List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>):
  do IO<List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>>:
    ex : Bool <- file_exists(file)
    analyze_entry_ex(file, ex, visited, mods, miss, entries)

@unsafe def analyze_entries_k(sel: Nat, args: List<&2, String>, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, +entries: List<&2, String>, rest: List<&2, String>, quad: List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          IO.pure(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>, (entries, visited, mods, miss))
        case Con{+file, r}:
          do IO<List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>>:
            q : List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String> <- analyze_entry(file, visited, mods, miss, entries)
            analyze_entries_k(1n, Nil{}, visited, mods, miss, entries, r, q)
    case _:
      (ents2, vis2, mods2, miss2) = quad
      analyze_entries_k(0n, rest, vis2, mods2, miss2, ents2, Nil{}, (Nil{}, Nil{}, Nil{}, Nil{}))

def analyze_entries(args: List<&2, String>, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, +entries: List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>):
  analyze_entries_k(0n, args, visited, mods, miss, entries, Nil{}, (Nil{}, Nil{}, Nil{}, Nil{}))



def analyze_print(entries: List<&2, String>, mods: List<&2, String>, miss: List<&2, String>) -> IO(Unit):
  IO.print("{\"entries\":" ++ Compiler.json_list(entries) ++ ",\"modules\":" ++ analyze_mods_json(mods) ++ ",\"missing\":" ++ Compiler.json_list(miss) ++ "}")

def run_analyze_print(quad: List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String>) -> IO(Unit):
  (entries, visited, mods, miss) = quad
  analyze_print(entries, mods, miss)

def run_analyze(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      analyze_none(True{})
    case _:
      do IO<Unit>:
        quad : List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String> <- analyze_entries(args, Nil{}, Nil{}, Nil{}, Nil{})
        run_analyze_print(quad)

def dispatch_analyze(+cmd: String, rest: List<&2, String>, is_analyze: Bool) -> IO(Unit):
  match is_analyze:
    case True{}:
      run_analyze(rest)
    case False{}:
      dispatch_transpile(cmd, rest, String.eq(cmd, "transpile"))

def scan_none(first: Bool) -> IO(Unit):
  match first:
    case True{}:
      IO.die(Unit, 2, "knot: scan requires a file (missing_input)")
    case False{}:
      IO.pure(Unit, Unit{})

def scan_write(+file: String, r: Compiler.TRes) -> IO(Unit):
  match r:
    case Compiler.TOk{js, map}:
      IO.print(js)
    case Compiler.TErr{msg, line, col}:
      IO.die(Unit, 1, "knot: " ++ file ++ ":" ++ U32.show(U32.inc(line)) ++ ":" ++ U32.show(U32.inc(col)) ++ ": " ++ msg ++ " (syntax_error)")

def scan_one(+file: String) -> IO(Unit):
  do IO<Unit>:
    src : String <- read_text(file)
    scan_write(file, Compiler.scan(file, src))

def scan_files(args: List<&2, String>, first: Bool) -> IO(Unit):
  match args:
    case Nil{}:
      scan_none(first)
    case Con{+file, rest}:
      do IO<Unit>:
        u : Unit <- scan_one(file)
        scan_files(rest, False{})

def run_scan(args: List<&2, String>) -> IO(Unit):
  scan_files(args, True{})

def dispatch_scan(+cmd: String, rest: List<&2, String>, is_scan: Bool) -> IO(Unit):
  match is_scan:
    case True{}:
      run_scan(rest)
    case False{}:
      dispatch_analyze(cmd, rest, String.eq(cmd, "analyze"))



def bundle_concat_empty(a: String, b: String, empty: Bool) -> String:
  match empty:
    case True{}:
      b
    case False{}:
      a ++ "\n" ++ b

def bundle_concat(+a: String, b: String) -> String:
  bundle_concat_empty(a, b, String.is_empty(a))

def bundle_js(+file: String, r: Compiler.TRes) -> IO(String):
  match r:
    case Compiler.TOk{js, map}:
      IO.pure(String, js)
    case Compiler.TErr{msg, line, col}:
      IO.die(String, 1, "knot: " ++ file ++ ":" ++ U32.show(U32.inc(line)) ++ ":" ++ U32.show(U32.inc(col)) ++ ": " ++ msg ++ " (syntax_error)")


def die_missing(+spec: String) -> IO(String):
  IO.die(String, 1, "knot: missing dependency " ++ spec ++ "; run knot install " ++ spec ++ " (missing_dependency)")

def resolve_pkg_ts_ex(+spec: String, +ts: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, ts)
    case False{}:
      die_missing(spec)

def resolve_pkg_ts(+spec: String) -> IO(String):
  do IO<String>:
    +ts : String = Compiler.pkg_index_ts(spec)
    ex : Bool <- file_exists(ts)
    resolve_pkg_ts_ex(spec, ts, ex)

def resolve_pkg_js_ex(+spec: String, +js: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, js)
    case False{}:
      resolve_pkg_ts(spec)

def resolve_pkg_index(+spec: String) -> IO(String):
  do IO<String>:
    +js : String = Compiler.pkg_index_js(spec)
    ex : Bool <- file_exists(js)
    resolve_pkg_js_ex(spec, js, ex)

def resolve_pkg_main_ex(+spec: String, +path: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, path)
    case False{}:
      resolve_pkg_index(spec)

def resolve_pkg_main_file(+spec: String, +main: String) -> IO(String):
  do IO<String>:
    +path : String = Compiler.pkg_join(spec, main)
    ex : Bool <- file_exists(path)
    resolve_pkg_main_ex(spec, path, ex)

def resolve_pkg_main_s(+spec: String, +main: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      resolve_pkg_index(spec)
    case False{}:
      resolve_pkg_main_file(spec, main)

def resolve_pkg_main_from_text(+spec: String, +text: String) -> IO(String):
  do IO<String>:
    +main : String <- json_optional_string(text, "main")
    resolve_pkg_main_s(spec, main, String.is_empty(main))

def resolve_pkg_expdot_s(+spec: String, +text: String, +expd: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      resolve_pkg_main_from_text(spec, text)
    case False{}:
      resolve_pkg_main_file(spec, expd)

def resolve_pkg_expdot(+spec: String, +text: String) -> IO(String):
  do IO<String>:
    +expd : String <- json_optional_string(text, "exports/.")
    resolve_pkg_expdot_s(spec, text, expd, String.is_empty(expd))

def resolve_pkg_exp(+spec: String, +text: String, +exp: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      resolve_pkg_expdot(spec, text)
    case False{}:
      resolve_pkg_main_file(spec, exp)

def resolve_pkg_cond_ok(+spec: String, +got: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      resolve_pkg_main_file(spec, got)

def resolve_pkg_cond_res(+spec: String, +text: String, r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.pure(String, "")
    case Done{+got}:
      resolve_pkg_cond_ok(spec, got, String.is_empty(got))

def resolve_pkg_try_cond(+spec: String, +text: String, +conds: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Pkg.exports(text, ".", conds)
    resolve_pkg_cond_res(spec, text, r)

def resolve_pkg_after_cond(+spec: String, +text: String, +via: String, empty: Bool) -> IO(String):
  match empty:
    case False{}:
      IO.pure(String, via)
    case True{}:
      do IO<String>:
        +exp : String <- json_optional_string(text, "exports")
        resolve_pkg_exp(spec, text, exp, String.is_empty(exp))

def resolve_pkg_main_conds(+spec: String, +pj: String, +conds: String) -> IO(String):
  do IO<String>:
    +text : String <- read_text(pj)
    +via : String <- resolve_pkg_try_cond(spec, text, conds)
    resolve_pkg_after_cond(spec, text, via, String.is_empty(via))

def resolve_pkg_main(+spec: String, +pj: String) -> IO(String):
  resolve_pkg_main_conds(spec, pj, "import,module,node,default")


def resolve_pkg_pj_conds(+spec: String, +pj: String, ex: Bool, +conds: String) -> IO(String):
  match ex:
    case True{}:
      resolve_pkg_main_conds(spec, pj, conds)
    case False{}:
      resolve_pkg_index(spec)

def resolve_pkg_pj(+spec: String, +pj: String, ex: Bool) -> IO(String):
  resolve_pkg_pj_conds(spec, pj, ex, "import,module,node,default")

def resolve_pkg_conds(+spec: String, +conds: String) -> IO(String):
  do IO<String>:
    +pj : String = Compiler.pkg_json(spec)
    ex : Bool <- file_exists(pj)
    resolve_pkg_pj_conds(spec, pj, ex, conds)

def resolve_pkg(+spec: String) -> IO(String):
  resolve_pkg_conds(spec, "import,module,node,default")


def resolve_rel_ts_ex(+path: String, +ts: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, ts)
    case False{}:
      die_missing(path)

def resolve_rel_ts(+path: String) -> IO(String):
  do IO<String>:
    +ts : String = path ++ ".ts"
    ex : Bool <- file_exists(ts)
    resolve_rel_ts_ex(path, ts, ex)

def resolve_rel_ex(+path: String, ex: Bool) -> IO(String):
  match ex:
    case True{}:
      IO.pure(String, path)
    case False{}:
      resolve_rel_ts(path)

def resolve_rel_file(+path: String) -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists(path)
    resolve_rel_ex(path, ex)


def take_after_tab(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'\t', t}:
      t
    case SCon{h, t}:
      take_after_tab(t)

def drop_last(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{h, SNil{}}:
      ""
    case SCon{h, t}:
      SCon{h, drop_last(t)}

def take_before_tab(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'\t', t}:
      ""
    case SCon{h, t}:
      SCon{h, take_before_tab(t)}

def subst_star(val: String, +rest: String) -> String:
  match val:
    case SNil{}:
      ""
    case SCon{'*', t}:
      rest ++ t
    case SCon{h, t}:
      SCon{h, subst_star(t, rest)}

def alias_wild_ok(+spec: String, +prefix: String, +val: String, ok: Bool) -> String:
  match ok:
    case False{}:
      ""
    case True{}:
      subst_star(val, String.drop(spec, String.length(prefix)))

def alias_wild_pre(+spec: String, +prefix: String, +val: String) -> String:
  alias_wild_ok(spec, prefix, val, String.starts_with(spec, prefix))

def alias_wild_star(+spec: String, +key: String, +val: String, star: Bool) -> String:
  match star:
    case False{}:
      ""
    case True{}:
      alias_wild_pre(spec, drop_last(key), val)

def alias_wild_kv(+spec: String, +key: String, +val: String) -> String:
  alias_wild_star(spec, key, val, String.ends_with(key, "/*"))

def alias_wild(+line: String, +spec: String) -> String:
  alias_wild_kv(spec, take_before_tab(line), take_after_tab(line))

def alias_ok(+line: String, +spec: String, ok: Bool) -> String:
  match ok:
    case True{}:
      take_after_tab(line)
    case False{}:
      alias_wild(line, spec)

def alias_match(+line: String, +spec: String) -> String:
  alias_ok(line, spec, String.starts_with(line, spec ++ "\t"))


@unsafe def alias_pick(sel: Nat, lines: List<&2, String>, +spec: String, +hit: String, empty: Bool) -> String:
  match sel:
    case 0n:
      match lines:
        case Nil{}:
          ""
        case Con{+h, t}:
          +found : String = alias_match(h, spec)
          alias_pick(1n, t, spec, found, String.is_empty(found))
    case _:
      match empty:
        case True{}:
          alias_pick(0n, lines, spec, "", True{})
        case False{}:
          hit

def resolve_alias_path_conds(+importer: String, +spec: String, +mapped: String, empty: Bool, +conds: String) -> IO(String):
  match empty:
    case True{}:
      resolve_pkg_conds(spec, conds)
    case False{}:
      resolve_rel_file(Compiler.resolve_rel(importer, mapped))

def resolve_alias_path(+importer: String, +spec: String, +mapped: String, empty: Bool) -> IO(String):
  resolve_alias_path_conds(importer, spec, mapped, empty, "import,module,node,default")

def resolve_tsconfig_pairs_conds(+importer: String, +spec: String, lines: List<&2, String>, +conds: String) -> IO(String):
  do IO<String>:
    +mapped : String = alias_pick(0n, lines, spec, "", True{})
    resolve_alias_path_conds(importer, spec, mapped, String.is_empty(mapped), conds)

def resolve_tsconfig_pairs(+importer: String, +spec: String, lines: List<&2, String>) -> IO(String):
  resolve_tsconfig_pairs_conds(importer, spec, lines, "import,module,node,default")

def resolve_tsconfig_ex_conds(+importer: String, +spec: String, ex: Bool, +conds: String) -> IO(String):
  match ex:
    case False{}:
      resolve_pkg_conds(spec, conds)
    case True{}:
      do IO<String>:
        text : String <- read_text("tsconfig.json")
        pairs : String <- json_optional_pairs(text, "compilerOptions/paths")
        resolve_tsconfig_pairs_conds(importer, spec, String.lines(pairs), conds)

def resolve_tsconfig_ex(+importer: String, +spec: String, ex: Bool) -> IO(String):
  resolve_tsconfig_ex_conds(importer, spec, ex, "import,module,node,default")

def resolve_tsconfig_conds(+importer: String, +spec: String, +conds: String) -> IO(String):
  do IO<String>:
    ex : Bool <- file_exists("tsconfig.json")
    resolve_tsconfig_ex_conds(importer, spec, ex, conds)

def resolve_tsconfig(+importer: String, +spec: String) -> IO(String):
  resolve_tsconfig_conds(importer, spec, "import,module,node,default")

def resolve_open_rel_conds(+importer: String, +spec: String, rel: Bool, +conds: String) -> IO(String):
  match rel:
    case True{}:
      resolve_rel_file(Compiler.resolve_rel(importer, spec))
    case False{}:
      resolve_tsconfig_conds(importer, spec, conds)

def resolve_open_rel(+importer: String, +spec: String, rel: Bool) -> IO(String):
  resolve_open_rel_conds(importer, spec, rel, "import,module,node,default")

def resolve_open_conds(+importer: String, +spec: String, +conds: String) -> IO(String):
  resolve_open_rel_conds(importer, spec, Compiler.is_rel(spec), conds)

def resolve_open(+importer: String, +spec: String) -> IO(String):
  resolve_open_conds(importer, spec, "import,module,node,default")


@unsafe def has_file(sel: Nat, xs: List<&2, String>, +f: String, eq: Bool) -> Bool:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          False{}
        case Con{+h, t}:
          has_file(1n, t, f, String.eq(h, f))
    case _:
      match eq:
        case True{}:
          True{}
        case False{}:
          has_file(0n, xs, f, False{})


def list_app(xs: List<&2, String>, x: String) -> List<&2, String>:
  match xs:
    case Nil{}:
      Con{x, Nil{}}
    case Con{h, t}:
      Con{h, list_app(t, x)}

@unsafe def collect_go(sel: Nat, +file: String, imps: List<&2, String>, +visited: List<&2, String>, seen: Bool, +conds: String) -> IO(List<&2, String>):
  match sel:
    case 0n:
      match seen:
        case True{}:
          IO.pure(List<&2, String>, visited)
        case False{}:
          do IO<List<&2, String>>:
            src : String <- read_text(file)
            vis2 : List<&2, String> <- collect_go(1n, file, Compiler.imports_of(src), visited, False{}, conds)
            return list_app(vis2, file)
    case _:
      match imps:
        case Nil{}:
          IO.pure(List<&2, String>, visited)
        case Con{+spec, rest}:
          do IO<List<&2, String>>:
            +path : String <- resolve_open_conds(file, spec, conds)
            vis2 : List<&2, String> <- collect_go(0n, path, Nil{}, visited, has_file(0n, visited, path, False{}), conds)
            collect_go(1n, file, rest, vis2, False{}, conds)

def strs_cat(a: List<&2, String>, b: List<&2, String>) -> List<&2, String>:
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{h, strs_cat(t, b)}

def live_imports_res(r: Result<&1, &1, U32 & String, String>) -> IO(List<&2, String>):
  match r:
    case Fail{_}:
      IO.pure(List<&2, String>, Nil{})
    case Done{s}:
      IO.pure(List<&2, String>, String.lines(s))

def live_imports_of(+src: String) -> IO(List<&2, String>):
  do IO<List<&2, String>>:
    r : Result<&1, &1, U32 & String, String> <- Live.imports(src)
    live_imports_res(r)

def collect_keep(files: List<&2, String>) -> IO(List<&2, String>):
  match files:
    case Nil{}:
      IO.pure(List<&2, String>, Nil{})
    case Con{+f, rest}:
      do IO<List<&2, String>>:
        src : String <- read_text(f)
        names : List<&2, String> <- live_imports_of(src)
        more : List<&2, String> <- collect_keep(rest)
        return strs_cat(names, more)

def se_flag_trim(+s: String) -> String:
  String.take(s, 1n)

def se_flag_res(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.pure(String, "1")
    case Done{+s}:
      IO.pure(String, se_flag_trim(s))

def se_flag_of(+f: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Pkg.file_side_effects(f)
    se_flag_res(r)

def export_names_of(+src: String) -> List<&2, String>:
  Compiler.exports_of(src)

@unsafe def has_any_keep(sel: Nat, names: List<&2, String>, +keep: List<&2, String>, hit: Bool) -> Bool:
  match sel:
    case 0n:
      match names:
        case Nil{}:
          False{}
        case Con{+h, t}:
          has_any_keep(1n, t, keep, Compiler.has_name(0n, keep, h, False{}))
    case _:
      match hit:
        case True{}:
          True{}
        case False{}:
          has_any_keep(0n, names, keep, False{})

def emit_one_go(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, drop: Bool) -> IO(String):
  match drop:
    case True{}:
      IO.pure(String, "")
    case False{}:
      bundle_js(f, Compiler.transpile_bundle_keep(f, src, keep, shake))

def emit_one_drop(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, pure: Bool) -> IO(String):
  emit_one_go(f, src, keep, shake, Bool.and(shake, Bool.and(pure, Bool.not(has_any_keep(0n, export_names_of(src), keep, False{})))))

def emit_one_se(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, +se: String) -> IO(String):
  emit_one_drop(f, src, keep, shake, String.eq(se, "0"))

def emit_one(+f: String, +keep: List<&2, String>, +shake: Bool) -> IO(String):
  do IO<String>:
    raw : String <- read_text(f)
    src : String <- ts_prep(f, raw)
    se : String <- se_flag_of(f)
    emit_one_se(f, src, keep, shake, se)

def emit_files(files: List<&2, String>, +keep: List<&2, String>) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, Nil{}}:
      emit_one(f, keep, False{})
    case Con{+f, rest}:
      do IO<String>:
        js : String <- emit_one(f, keep, True{})
        more : String <- emit_files(rest, keep)
        return bundle_concat(js, more)

def bundle_entry_conds(+file: String, +conds: String) -> IO(String):
  do IO<String>:
    +files : List<&2, String> <- collect_go(0n, file, Nil{}, Nil{}, False{}, conds)
    keep : List<&2, String> <- collect_keep(files)
    emit_files(files, keep)

def bundle_entry(+file: String) -> IO(String):
  bundle_entry_conds(file, "import,module,node,default")

def bundle_files_conds(+file: String, +conds: String) -> IO(List<&2, String>):
  collect_go(0n, file, Nil{}, Nil{}, False{}, conds)



def hash_ok(+c: Char) -> Bool:
  Bool.and(Bool.not(Char.is_eq(c, '+')), Bool.and(Bool.not(Char.is_eq(c, '/')), Bool.not(Char.is_eq(c, '='))))

@unsafe def take_hash(sel: Nat, s: String, n: Nat, acc: String, c: Char, ok: Bool) -> String:
  match sel:
    case 0n:
      match n:
        case 0n:
          String.reverse(acc)
        case _:
          take_hash(3n, s, n, acc, c, ok)
    case 3n:
      match s:
        case SNil{}:
          String.reverse(acc)
        case SCon{+h, t}:
          take_hash(1n, t, n, acc, h, hash_ok(h))
    case 1n:
      match ok:
        case True{}:
          take_hash(4n, s, n, acc, c, ok)
        case False{}:
          take_hash(0n, s, n, acc, 'a', False{})
    case _:
      match n:
        case 0n:
          String.reverse(acc)
        case 1n+n2:
          take_hash(0n, s, n2, SCon{c, acc}, 'a', False{})


@unsafe def str_replace(sel: Nat, +hay: String, +needle: String, +rep: String, ok: Bool, empty: Bool) -> String:
  match sel:
    case 0n:
      str_replace(1n, hay, needle, rep, String.starts_with(hay, needle), False{})
    case 1n:
      match ok:
        case True{}:
          rep ++ String.drop(hay, String.length(needle))
        case False{}:
          str_replace(2n, hay, needle, rep, False{}, String.is_empty(hay))
    case _:
      match empty:
        case True{}:
          ""
        case False{}:
          +h1 : String = String.take(hay, 1n)
          +h2 : String = String.drop(hay, 1n)
          h1 ++ str_replace(0n, h2, needle, rep, False{}, False{})



def dyn_old_rel(rel: Bool, +spec: String) -> String:
  match rel:
    case True{}:
      "./" ++ Compiler.basename(Compiler.js_path(String.drop(spec, 2n)))
    case False{}:
      Compiler.basename(Compiler.js_path(spec))

def dyn_old(+spec: String) -> String:
  dyn_old_rel(String.starts_with(spec, "./"), spec)

def emit_dyn_one(+importer: String, +outdir: String, +spec: String) -> IO(String):
  do IO<String>:
    +path : String <- resolve_open(importer, spec)
    raw : String <- read_text(path)
    src : String <- ts_prep(path, raw)
    js : String <- bundle_js(path, Compiler.transpile(path, src))
    +got : String <- IO.try(String, Hash.sha512_b64(path))
    +name : String = take_hash(0n, got, 8n, "", 'a', False{}) ++ ".js"
    u : Unit <- transpile_ok_to(Compiler.join_rel(outdir, name), js, Compiler.make_map(path, Nil{}), "linked")
    return name

def emit_dyn_go(+importer: String, +out: String, +spec: String) -> IO(Unit):
  do IO<Unit>:
    +name : String <- emit_dyn_one(importer, Compiler.dirname(out), spec)
    js : String <- read_text(out)
    write_text(out, str_replace(0n, js, dyn_old(spec), "./" ++ name, False{}, False{}))

def emit_dyn(+importer: String, +out: String, specs: List<&2, String>) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- emit_dyn_go(importer, out, spec)
        emit_dyn(importer, out, rest)


def emit_req_one(+importer: String, +outdir: String, +spec: String) -> IO(Unit):
  do IO<Unit>:
    +path : String <- resolve_open(importer, spec)
    raw : String <- read_text(path)
    src : String <- ts_prep(path, raw)
    js : String <- bundle_js(path, Compiler.transpile(path, src))
    transpile_ok_to(Compiler.join_rel(outdir, Compiler.basename(Compiler.js_path(path))), js, Compiler.make_map(path, Nil{}), "linked")

def emit_req(+importer: String, +out: String, specs: List<&2, String>) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- emit_req_one(importer, Compiler.dirname(out), spec)
        emit_req(importer, out, rest)

def bundle_write_dyn(+file: String, +out: String, +src: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- emit_dyn(file, out, Compiler.dyn_imports_of(src))
    emit_req(file, out, Compiler.requires_of(src))

def meta_input_one(+f: String) -> IO(String):
  do IO<String>:
    src : String <- read_text(f)
    return Compiler.json_str(f) ++ ":{\"bytes\":" ++ Nat.show(String.length(src)) ++ "}"

def meta_inputs_go(files: List<&2, String>) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, Nil{}}:
      meta_input_one(f)
    case Con{+f, rest}:
      do IO<String>:
        a : String <- meta_input_one(f)
        b : String <- meta_inputs_go(rest)
        return a ++ "," ++ b

def meta_write_none(none: Bool, +meta: String, +file: String, +out: String, +js: String, files: List<&2, String>) -> IO(Unit):
  match none:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        inputs : String <- meta_inputs_go(files)
        +body : String = "{\"inputs\":{" ++ inputs ++ "},\"outputs\":{" ++ Compiler.json_str(out) ++ ":{\"bytes\":" ++ Nat.show(String.length(js)) ++ "}}}"
        write_text(meta, body)

def meta_write(+meta: String, +file: String, +out: String, +js: String, files: List<&2, String>) -> IO(Unit):
  meta_write_none(String.is_empty(meta), meta, file, out, js, files)

def bundle_write_opts(+file: String, +out: String, +conds: String, +meta: String) -> IO(Unit):
  do IO<Unit>:
    +files : List<&2, String> <- bundle_files_conds(file, conds)
    keep : List<&2, String> <- collect_keep(files)
    +js : String <- emit_files(files, keep)
    u0 : Unit <- transpile_ok_to(out, js, Compiler.make_map(file, Nil{}), "linked")
    u1 : Unit <- meta_write(meta, file, out, js, files)
    +src : String <- read_text(file)
    bundle_write_dyn(file, out, src)

def bundle_write(+file: String, +out: String) -> IO(Unit):
  bundle_write_opts(file, out, "import,module,node,default", "")

def conds_add(+extra: String, +acc: String, empty: Bool) -> String:
  match empty:
    case True{}:
      extra
    case False{}:
      acc ++ "," ++ extra

def conds_join_e(empty: Bool, +extra: String) -> String:
  match empty:
    case True{}:
      "import,module,node,default"
    case False{}:
      extra ++ ",import,module,node,default"

def conds_join(+extra: String) -> String:
  conds_join_e(String.is_empty(extra), extra)

@unsafe def run_build_k(sel: Nat, args: List<&2, String>, +file: String, +out: String, +conds: String, +meta: String, +head: String, rest: List<&2, String>, +which: String, +val: String, b0: Bool, b1: Bool, b2: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          run_build_k(20n, Nil{}, file, out, conds, meta, "", Nil{}, "", "", String.is_empty(file), String.is_empty(out), False{})
        case Con{+h, r}:
          run_build_k(1n, Nil{}, file, out, conds, meta, h, r, "", "", String.eq(h, "--outfile"), String.eq(h, "--conditions"), String.eq(h, "--metafile"))
    case 1n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, head, rest, "outfile", "", False{}, False{}, False{})
        case False{}:
          run_build_k(2n, Nil{}, file, out, conds, meta, head, rest, "", "", b1, b2, False{})
    case 2n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, head, rest, "conditions", "", False{}, False{}, False{})
        case False{}:
          run_build_k(3n, Nil{}, file, out, conds, meta, head, rest, "", "", b1, False{}, False{})
    case 3n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, head, rest, "metafile", "", False{}, False{}, False{})
        case False{}:
          run_build_k(21n, Nil{}, file, out, conds, meta, head, rest, "", "", String.is_empty(file), False{}, False{})
    case 10n:
      match rest:
        case Con{+v, tail}:
          run_build_k(11n, Nil{}, file, out, conds, meta, head, tail, which, v, String.eq(which, "outfile"), String.eq(which, "conditions"), String.eq(which, "metafile"))
        case Nil{}:
          IO.die(Unit, 2, "knot: build flag " ++ which ++ " requires a value (unknown_command)")
    case 11n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, val, conds, meta, "", Nil{}, "", "", False{}, False{}, False{})
        case False{}:
          run_build_k(12n, Nil{}, file, out, conds, meta, head, rest, which, val, b1, b2, False{})
    case 12n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, out, conds_add(val, conds, String.is_empty(conds)), meta, "", Nil{}, "", "", False{}, False{}, False{})
        case False{}:
          run_build_k(0n, rest, file, out, conds, val, "", Nil{}, "", "", False{}, False{}, False{})
    case 20n:
      match b0:
        case True{}:
          IO.die(Unit, 2, "knot: build requires a file (missing_input)")
        case False{}:
          run_build_k(22n, Nil{}, file, out, conds, meta, "", Nil{}, "", "", b1, False{}, False{})
    case 21n:
      match b0:
        case True{}:
          run_build_k(0n, rest, head, out, conds, meta, "", Nil{}, "", "", False{}, False{}, False{})
        case False{}:
          IO.die(Unit, 2, "knot: unknown build flag " ++ head ++ " (unknown_command)")
    case 22n:
      match b0:
        case True{}:
          bundle_write_opts(file, Compiler.js_path(file), conds_join(conds), meta)
        case False{}:
          bundle_write_opts(file, out, conds_join(conds), meta)
    case _:
      IO.die(Unit, 2, "knot: build parse error (unknown_command)")


def run_build_out(+file: String, rest: List<&2, String>) -> IO(Unit):
  run_build_k(0n, Con{file, rest}, "", "", "", "", "", Nil{}, "", "", False{}, False{}, False{})

def run_build_nb(no_bundle: Bool, +head: String, rest: List<&2, String>) -> IO(Unit):
  match no_bundle:
    case True{}:
      run_transpile(rest)
    case False{}:
      run_build_out(head, rest)

@unsafe def watch_loop(sel: Nat, +file: String, +last: String, +src: String, same: Bool) -> IO(Unit):
  match sel:
    case 0n:
      do IO<Unit>:
        u : Unit <- IO.sleep(50)
        +now : String <- read_text(file)
        watch_loop(1n, file, last, now, String.eq(last, now))
    case _:
      match same:
        case True{}:
          watch_loop(0n, file, last, src, False{})
        case False{}:
          do IO<Unit>:
            u : Unit <- transpile_one(file, "classic", "linked", "React.createElement", "React.Fragment", "react")
            watch_loop(0n, file, src, src, False{})

def watch_transpile(args: List<&2, String>) -> IO(Unit):
  match args:
    case Con{+file, _}:
      do IO<Unit>:
        u : Unit <- transpile_one(file, "classic", "linked", "React.createElement", "React.Fragment", "react")
        +src : String <- read_text(file)
        watch_loop(0n, file, src, src, False{})
    case Nil{}:
      IO.die(Unit, 2, "knot: build requires a file (missing_input)")

def concat_sources(files: List<&2, String>) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, rest}:
      do IO<String>:
        src : String <- read_text(f)
        more : String <- concat_sources(rest)
        return f ++ ":" ++ src ++ more

def fingerprint(+file: String) -> IO(String):
  do IO<String>:
    files : List<&2, String> <- collect_go(0n, file, Nil{}, Nil{}, False{}, "import,module,node,default")
    srcs : String <- concat_sources(files)
    listed : String <- IO.try(String, Fs.read_dir(Compiler.dirname(file)))
    return listed ++ "\n" ++ srcs


@unsafe def watch_bundle_loop(sel: Nat, +file: String, +out: String, +last: String, +src: String, same: Bool) -> IO(Unit):
  match sel:
    case 0n:
      do IO<Unit>:
        u : Unit <- IO.sleep(50)
        +now : String <- fingerprint(file)
        watch_bundle_loop(1n, file, out, last, now, String.eq(last, now))
    case _:
      match same:
        case True{}:
          watch_bundle_loop(0n, file, out, last, src, False{})
        case False{}:
          do IO<Unit>:
            u : Unit <- bundle_write(file, out)
            watch_bundle_loop(0n, file, out, src, src, False{})

def run_watch_flag(+file: String, +flag: String, +out: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      do IO<Unit>:
        u : Unit <- bundle_write(file, out)
        +fp : String <- fingerprint(file)
        watch_bundle_loop(0n, file, out, fp, fp, False{})
    case False{}:
      IO.die(Unit, 2, "knot: watch requires --outfile (unknown_command)")

def run_watch_out(+file: String, rest: List<&2, String>) -> IO(Unit):
  match rest:
    case Con{+flag, Con{+out, Nil{}}}:
      run_watch_flag(file, flag, out, String.eq(flag, "--outfile"))
    case _:
      IO.die(Unit, 2, "knot: watch requires --outfile (unknown_command)")

def run_watch_nb(nb: Bool, +head: String, rest: List<&2, String>) -> IO(Unit):
  match nb:
    case True{}:
      watch_transpile(rest)
    case False{}:
      run_watch_out(head, rest)


def run_watch(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      IO.die(Unit, 2, "knot: build requires a file (missing_input)")
    case Con{+head, rest}:
      run_watch_nb(String.eq(head, "--no-bundle"), head, rest)

def run_build_w(+head: String, rest: List<&2, String>, watch: Bool) -> IO(Unit):
  match watch:
    case True{}:
      run_watch(rest)
    case False{}:
      run_build_nb(String.eq(head, "--no-bundle"), head, rest)

def run_build(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      IO.die(Unit, 2, "knot: build requires a file (missing_input)")
    case Con{+head, rest}:
      run_build_w(head, rest, String.eq(head, "--watch"))



def run_clean_bc(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      do IO<Unit>:
        u : Unit <- IO.try(Unit, Fs.unlink(".knot/build-cache/v1"))
        return Unit{}
    case False{}:
      IO.die(Unit, 2, "knot: unknown command clean (unknown_command)")

def run_clean(args: List<&2, String>) -> IO(Unit):
  match args:
    case Con{+flag, _}:
      run_clean_bc(String.eq(flag, "--build-cache"))
    case Nil{}:
      IO.die(Unit, 2, "knot: unknown command clean (unknown_command)")

def dispatch_build(+cmd: String, rest: List<&2, String>, is_build: Bool) -> IO(Unit):
  match is_build:
    case True{}:
      run_build(rest)
    case False{}:
      dispatch_scan(cmd, rest, String.eq(cmd, "scan"))

def dispatch_clean(+cmd: String, rest: List<&2, String>, is_clean: Bool) -> IO(Unit):
  match is_clean:
    case True{}:
      run_clean(rest)
    case False{}:
      dispatch_build(cmd, rest, String.eq(cmd, "build"))


def run_help() -> IO(Unit):
  IO.print("Usage: knot <command>\n\nCommands:\n  install      Install dependencies from package.json\n  add          Add a dependency and install\n  remove       Remove a dependency\n  update       Re-resolve dependency ranges\n  list         Print direct dependencies\n  why          Show why a package is installed\n  fetch        Fill the store from the lockfile\n  store        Inspect the content-addressed store\n  cache clean  Remove the registry metadata cache\n  transpile    Transform TypeScript or JavaScript without bundling\n  scan         Print runtime imports and exports as JSON\n  analyze      Walk import graph from entrypoints as JSON\n  build        Compile entry points; --no-bundle skips graph linking\n  clean        Remove compiler caches with --build-cache")

def dispatch_version(+cmd: String, rest: List<&2, String>, is_version: Bool) -> IO(Unit):
  match is_version:
    case True{}:
      IO.print("0.0.0")
    case False{}:
      dispatch_clean(cmd, rest, String.eq(cmd, "clean"))


def dispatch_help(+cmd: String, rest: List<&2, String>, is_help: Bool) -> IO(Unit):
  match is_help:
    case True{}:
      run_help()
    case False{}:
      dispatch_version(cmd, rest, String.eq(cmd, "--version"))



def dispatch(+cmd: String, rest: List<&2, String>) -> IO(Unit):
  dispatch_help(cmd, rest, Bool.or(String.eq(cmd, "--help"), String.eq(cmd, "-h")))

def dispatch_args(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      run_help()
    case Con{+cmd, rest}:
      dispatch(cmd, rest)

def run_with_argc(argc_m: Maybe<&2, Nat>) -> IO(Unit):
  match argc_m:
    case None{}:
      IO.die(Unit, 2, "knot: unknown command  (unknown_command)")
    case Some{n}:
      do IO<Unit>:
        args : List<&2, String> <- load_args(n, 1n)
        dispatch_args(args)

def main() -> IO(Unit):
  do IO<Unit>:
    argc_s : String <- IO.try(String, IO.get_env("KNOT_ARGC"))
    argc_m : Maybe<&2, Nat> = Nat.read(argc_s)
    run_with_argc(argc_m)
