import Base
import ./sri.bend as Sri
import ./http.bend as Fetch
import ./semver.bend as Semver
import ./compiler.bend as Compiler
import ./profile.bend as Profile


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

def Fs.replace_dir(src: String, dst: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_replace_dir.c"
  import "./host/fs_replace_dir.js"

def Fs.publish(op: String, a: String, b: String, c: String, d: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_publish.c"
  import "./host/fs_publish.js"



def Fs.offline_lock() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_offline_lock.c"
  import "./host/fs_offline_lock.js"

def Fs.unlink(path: String) -> IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_unlink.c"
  import "./host/fs_unlink.js"

def Fs.remove_dir(path: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_remove_dir.c"
  import "./host/fs_remove_dir.js"
def Fs.rename(src: String, dst: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/fs_rename.c"
  import "./host/fs_rename.js"


def Fs.read_dir(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_read_dir.c"
  import "./host/fs_read_dir.js"

def Fs.cwd() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_cwd.c"
  import "./host/fs_cwd.js"

def Fs.regular_file(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/fs_regular_file.c"
  import "./host/fs_regular_file.js"




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

def Os.exec_many(cmd: String, args: String, cwd: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/os_exec_many.c"
  import "./host/os_exec_many.js"

def Server.run(port: U32, root: String, entry: String, naming: U32) -> IO(Unit):
  import "./host/server_run.c"
  import "./host/server_run.js"



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
def Hash.sha256_b64(path: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/hash_sha256_b64.c"
  import "./host/hash_sha256_b64.js"

def Hash.sha256_text(text: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/hash_sha256_text.c"
  import "./host/hash_sha256_text.js"

def Protocol.request() -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/protocol_request.c"
  import "./host/protocol_request.js"


def Tar.extract(archive: String, dest: String) ->
  IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/tar_extract.c"
  import "./host/tar_extract.js"

def Json.query(text: String, path: String, mode: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/json_query.c"
  import "./host/json_query.js"
def Data.read_utf8(path: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/data_read_utf8.c"
  import "./host/data_read_utf8.js"
def Data.toml(text: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/data_toml.c"
  import "./host/data_toml.js"

def Data.yaml(text: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/data_yaml.c"
  import "./host/data_yaml.js"
def Data.limits(spec: String) -> IO(Result<&1, &1, U32 & String, Unit>):
  import "./host/data_limits.c"
  import "./host/data_limits.js"




def Jsx.lower(source: String, mode: String, factory: String, fragment: String, import_source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/jsx_lower.c"
  import "./host/jsx_lower.js"

def Ts.lower(source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/ts_lower.c"
  import "./host/ts_lower.js"

def Syntax.validate(source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/syntax_validate.c"
  import "./host/syntax_validate.js"

def Source.normalize(source: String) ->
  IO(Result<&1, &1, U32 & String, String>):
  import "./host/source_normalize.c"
  import "./host/source_normalize.js"

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
def rename_result(r: Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.die(Unit, 2, "knot: atomic activation failed")
    case Done{_}:
      IO.pure(Unit, Unit{})

def write_text_atomic(+path: String, +text: String) -> IO(Unit):
  do IO<Unit>:
    +tmp : String = path ++ ".tmp"
    u0 : Unit <- write_text(tmp, text)
    r : Result<&1, &1, U32 & String, Unit> <- Fs.rename(tmp, path)
    rename_result(r)

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

def place_pkg_mode(+unp: String, +dest: String, replace: Bool) -> IO(Unit):
  match replace:
    case True{}:
      IO.try(Unit, Fs.replace_dir(unp, dest))
    case False{}:
      IO.try(Unit, Fs.clone_dir(unp, dest))

def place_pkg(+tar: String, +dest: String, +integrity: String, replace: Bool) -> IO(Unit):
  do IO<Unit>:
    +unp : String <- unpacked_path(integrity)
    has : Bool <- file_exists(unp ++ "/package.json")
    ensure_unpacked(has, tar, unp)
    place_pkg_mode(unp, dest, replace)

def materialize_verified(ok: Bool, +tar: String, +dest: String, +integrity: String, replace: Bool) -> IO(Unit):
  match ok:
    case False{}:
      die_integrity()
    case True{}:
      place_pkg(tar, dest, integrity, replace)

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

def materialize_pkg_fetch(
  +tarball: String,
  +tar_path: String,
  +cas: String,
  +dest: String,
  +integrity: String,
  replace: Bool
) -> IO(Unit):
  do IO<Unit>:
    +ex : Bool <- file_exists(cas)
    +tar_use : String <- fetch_tar(tarball, tar_path, cas, ex)
    got : String <- IO.try(String, Hash.sha512_b64(tar_use))
    materialize_verified(sri_ok(got, integrity), tar_use, dest, integrity, replace)
    commit_cas(tar_use, cas, ex)

def materialize_pkg_existing(
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
      materialize_pkg_fetch(tarball, tar_path, cas, dest, integrity, False{})

def materialize_pkg(
  exists: Bool,
  +tarball: String,
  +tar_path: String,
  +cas: String,
  +dest: String,
  +integrity: String,
  replace: Bool
) -> IO(Unit):
  match replace:
    case True{}:
      materialize_pkg_fetch(tarball, tar_path, cas, dest, integrity, True{})
    case False{}:
      materialize_pkg_existing(exists, tarball, tar_path, cas, dest, integrity)


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
  +hit: Bool,
  +force: Bool
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
              install_job(p, Nil{}, rest, registry, None{}, False{}, False{}, seen, False{}, force)
            case Con{+line, rest}:
              install_job(p, String.split(line, '\t'), rest, registry, None{}, String.contains(line, "\topt"), False{}, seen, parts_hit(seen, String.split(line, '\t')), force)
        case Con{+name, Con{+spec, +tail}}:
          match meta_m:
            case None{}:
              match hit:
                case True{}:
                  do IO<List<&2, String>>:
                    link_root_if(name, is_root_parts(tail))
                    install_job(p, Nil{}, queue, registry, None{}, False{}, False{}, seen, False{}, force)
                case False{}:
                  do IO<List<&2, String>>:
                    +reg : String <- registry_for(registry, name)
                    +path : String <- cache_path(reg, name)
                    ex : Bool <- file_exists(path)
                    got : Maybe<&2, String> <- load_meta(ex, path, reg ++ "/" ++ name)
                    install_job(p, Con{name, Con{spec, tail}}, queue, registry, got, optional, False{}, seen ++ name ++ "\n", False{}, force)
            case Some{SNil{}}:
              match optional:
                case True{}:
                  install_job(p, Nil{}, queue, registry, None{}, False{}, False{}, seen, False{}, force)
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
                    install_job(p, Con{name, Con{spec, tail}}, queue, registry, os_meta_or_skip(meta, Bool.and(os_allowed(osf, plat), os_allowed(cpf, arch))), optional, True{}, seen, False{}, force)

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
                    u_m : Unit <- materialize_pkg(ex_pkg, tarball, tar_path, cas, dest, integrity, force)
                    u_log : Unit <- progress("+ " ++ name ++ "@" ++ picked)
                    +nested_txt : String <- read_text(dest ++ "/package.json")
                    run_approved_scripts(name, dest, nested_txt)

                    +req : String <- join_nested_deps(nested_txt)
                    +opt : String <- json_optional_pairs(nested_txt, "optionalDependencies")
                    more : List<&2, String> <- install_job(p, Nil{}, List.append(&2, String, mark_nested_lines(String.lines(req)), List.append(&2, String, mark_optional_lines(String.lines(opt)), queue)), registry, None{}, False{}, False{}, seen, False{}, force)
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
    place_pkg(cas, dest, integrity, False{})
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
        materialize_verified(sri_ok(got, integrity), tar_use, dest, integrity, False{})
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
        u_log : Unit <- progress("+ " ++ name ++ "@" ++ ver)
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
  do IO<Unit>:
    u0 : Unit <- note_backend_ok(Bool.or(String.eq(mode, "copy"), Bool.or(String.eq(mode, "auto"), Bool.or(String.eq(mode, "hardlink"), String.eq(mode, "clone")))), mode)
    u1 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
    write_text(".knot/backend", mode)

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
    u4 : Unit <- IO.try(Unit, Fs.unlink(".knot/backend"))
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

def run_install_resolve(+registry: String, +pairs: String, +text: String, force: Bool) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    ws : String <- json_optional_lines(text, "workspaces")
    pairs2 : String <- link_workspaces(8n, String.lines(ws), pairs)
    +recs : List<&2, String> <- install_job(256n, Nil{}, String.lines(pairs2), registry, None{}, False{}, False{}, "\n", False{}, force)
    u_sum : Unit <- progress(Nat.show(List.length(&2, String, recs)) ++ " packages installed")
    write_text("knot.lock", render_lock(List.sort(~String, ~lock_le, recs)))
    end : Nat <- IO.now()
    progress(format_elapsed(Nat.sub(end, start)))

def run_install_covered(ok: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match ok:
    case True{}:
      run_install_locked()
    case False{}:
      run_install_resolve(registry, pairs, text, False{})

def run_install_has(has: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match has:
    case False{}:
      run_install_resolve(registry, pairs, text, False{})
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

def run_update_resolve(dry: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match dry:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      run_install_resolve(registry, pairs, text, True{})

def run_update_frozen(dry: Bool, frozen: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match frozen:
    case True{}:
      IO.die(Unit, 2, "knot update cannot use a frozen lockfile (frozen_update)")
    case False{}:
      run_update_resolve(dry, registry, pairs, text)

def run_update_flags(dry: Bool, frozen: Bool, offline: Bool, +registry: String, +pairs: String, +text: String) -> IO(Unit):
  match offline:
    case True{}:
      IO.die(Unit, 2, "knot update cannot run offline (offline_update)")
    case False{}:
      run_update_frozen(dry, frozen, registry, pairs, text)

def run_update_parsed(parsed: String & Bool & Bool) -> IO(Unit):
  (registry, frozen, offline) = parsed
  do IO<Unit>:
    +text : String <- read_text("package.json")
    prod : Bool <- file_exists(".knot/production")
    dry : Bool <- file_exists(".knot/dry-run")
    +pairs : String <- install_pairs(prod, text)
    check_protocols(32n, String.lines(pairs))
    run_update_flags(dry, frozen, offline, registry, pairs, text)

def run_update(args: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    parsed : String & Bool & Bool <- parse_install_args(args)
    run_update_parsed(parsed)

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
      run_update(rest)
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
def validate_source_msg(+src: String, +msg: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, src)
    case False{}:
      IO.die(String, 1, "knot: " ++ msg ++ " (syntax_error)")

def validate_source_res(+src: String, r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.die(String, 1, "knot: syntax validation failed (syntax_error)")
    case Done{+msg}:
      validate_source_msg(src, msg, String.is_empty(msg))

def validate_source(+src: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Syntax.validate(src)
    validate_source_res(src, r)


def normalize_source_res(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.die(String, 1, "knot: source normalization failed (syntax_error)")
    case Done{+s}:
      IO.pure(String, s)

def normalize_source(+src: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Source.normalize(src)
    normalize_source_res(r)


def ts_prep(+file: String, +src: String) -> IO(String):
  do IO<String>:
    normalized : String <- normalize_source(src)
    mid : String <- ts_prep_mode(is_ts(file), normalized)
    validate_source(mid)

def transpile_none(first: Bool) -> IO(Unit):
  match first:
    case True{}:
      IO.die(Unit, 2, "knot: transpile requires a file (missing_input)")
    case False{}:
      IO.pure(Unit, Unit{})

def transpile_write_js_none(none: Bool, +jsp: String, +js: String) -> IO(Unit):
  match none:
    case True{}:
      write_text_atomic(jsp, js ++ "\n")
    case False{}:
      write_text_atomic(jsp, js ++ "\n//# sourceMappingURL=" ++ Compiler.basename(jsp) ++ ".map\n")

def transpile_write_js_inline(inline: Bool, +jsp: String, +js: String, +map: String) -> IO(Unit):
  match inline:
    case True{}:
      write_text_atomic(jsp, js ++ "\n//# sourceMappingURL=data:application/json;base64," ++ Compiler.b64_encode(map) ++ "\n")
    case False{}:
      IO.pure(Unit, Unit{})

def transpile_write_js_ext(ext: Bool, inline: Bool, +jsp: String, +js: String, +map: String, +sm: String) -> IO(Unit):
  match ext:
    case True{}:
      write_text_atomic(jsp, js ++ "\n")
    case False{}:
      match inline:
        case True{}:
          transpile_write_js_inline(True{}, jsp, js, map)
        case False{}:
          transpile_write_js_none(String.eq(sm, "none"), jsp, js)

def transpile_write_js(+jsp: String, +js: String, +map: String, +sm: String) -> IO(Unit):
  transpile_write_js_ext(String.eq(sm, "external"), String.eq(sm, "inline"), jsp, js, map, sm)

def transpile_write_map_none(none: Bool, +jsp: String, +map: String) -> IO(Unit):
  match none:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      write_text_atomic(jsp ++ ".map", map)

def transpile_write_map(+jsp: String, +map: String, +sm: String) -> IO(Unit):
  transpile_write_map_none(Bool.or(String.eq(sm, "none"), String.eq(sm, "inline")), jsp, map)

def transpile_ok_to(+jsp: String, js: String, +map: String, +sm: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- IO.try(Unit, Fs.mkdir_p(Compiler.dirname(jsp)))
    u1 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot/build-cache"))
    u2 : Unit <- transpile_write_js(jsp, js, map, sm)
    u3 : Unit <- transpile_write_map(jsp, map, sm)
    write_text_atomic(".knot/build-cache/v1", "2")


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

def transpile_cache_key(+file: String, +src: String, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> String:
  "knot-cache-v2\n" ++ file ++ "\n" ++ mode ++ "\n" ++ sm ++ "\n" ++ factory ++ "\n" ++ fragment ++ "\n" ++ isrc ++ "\n" ++ src

def transpile_one_miss(+file: String, +src: String, +sm: String, +key: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- transpile_write(file, Compiler.transpile(file, src), sm)
    write_text_atomic(".knot/build-cache/src", key)

def transpile_one_eq(+file: String, +src: String, eq: Bool, +sm: String, +key: String, output: Bool) -> IO(Unit):
  match eq:
    case False{}:
      transpile_one_miss(file, src, sm, key)
    case True{}:
      match output:
        case True{}:
          IO.pure(Unit, Unit{})
        case False{}:
          transpile_one_miss(file, src, sm, key)

def transpile_cache_output_map_mode(none: Bool, +jsp: String) -> IO(Bool):
  match none:
    case True{}:
      IO.pure(Bool, True{})
    case False{}:
      file_exists(jsp ++ ".map")

def transpile_cache_output_map(+sm: String, +jsp: String, js: Bool) -> IO(Bool):
  match js:
    case False{}:
      IO.pure(Bool, False{})
    case True{}:
      transpile_cache_output_map_mode(Bool.or(String.eq(sm, "none"), String.eq(sm, "inline")), jsp)

def transpile_one_src_ex(+file: String, +src: String, ex: Bool, +sm: String, +key: String) -> IO(Unit):
  match ex:
    case False{}:
      transpile_one_miss(file, src, sm, key)
    case True{}:
      do IO<Unit>:
        +c : String <- read_text(".knot/build-cache/src")
        js : Bool <- file_exists(Compiler.js_path(file))
        output : Bool <- transpile_cache_output_map(sm, Compiler.js_path(file), js)
        transpile_one_eq(file, src, String.eq(key, c), sm, key, output)

def transpile_one_v1(+file: String, +src: String, v1: Bool, +sm: String, +key: String) -> IO(Unit):
  match v1:
    case False{}:
      transpile_one_miss(file, src, sm, key)
    case True{}:
      do IO<Unit>:
        ex : Bool <- file_exists(".knot/build-cache/src")
        transpile_one_src_ex(file, src, ex, sm, key)

def transpile_one(+file: String, +mode: String, +sm: String, +factory: String, +fragment: String, +isrc: String) -> IO(Unit):
  do IO<Unit>:
    +raw : String <- read_text(file)
    +mid : String <- ts_prep(file, raw)
    +src : String <- jsx_prep(file, mid, mode, factory, fragment, isrc)
    key : String = transpile_cache_key(file, src, mode, sm, factory, fragment, isrc)
    v1 : Bool <- file_exists(".knot/build-cache/v1")
    transpile_one_v1(file, src, v1, sm, key)


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
          IO.die(Unit, 2, "knot: --sourcemap requires linked|external|inline|none (missing_input)")
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

def analyze_edge_one(+kind: String, +spec: String) -> String:
  "{\"kind\":" ++ Compiler.json_str(kind) ++ ",\"specifier\":" ++ Compiler.json_str(spec) ++ "}"

def analyze_edge_body(+kind: String, specs: List<&2, String>) -> String:
  match specs:
    case Nil{}:
      ""
    case Con{+h, Nil{}}:
      analyze_edge_one(kind, h)
    case Con{+h, rest}:
      analyze_edge_one(kind, h) ++ "," ++ analyze_edge_body(kind, rest)

def analyze_edge_join(+left: String, +right: String, left_empty: Bool, right_empty: Bool) -> String:
  match left_empty:
    case True{}:
      right
    case False{}:
      match right_empty:
        case True{}:
          left
        case False{}:
          left ++ "," ++ right

def analyze_edges_json(
  imports: List<&2, String>, dynamics: List<&2, String>, requires: List<&2, String>
) -> String:
  +static_body : String = analyze_edge_body("static-import", imports)
  +dynamic_body : String = analyze_edge_body("dynamic-import", dynamics)
  +require_body : String = analyze_edge_body("require", requires)
  +static_empty : Bool = String.is_empty(static_body)
  +dynamic_empty : Bool = String.is_empty(dynamic_body)
  +require_empty : Bool = String.is_empty(require_body)
  +first_empty : Bool = Bool.and(static_empty, dynamic_empty)
  +first : String = analyze_edge_join(static_body, dynamic_body, static_empty, dynamic_empty)
  body : String = analyze_edge_join(first, require_body, first_empty, require_empty)
  "[" ++ body ++ "]"

def analyze_mod_json(
  +file: String,
  +imports: List<&2, String>,
  exports: List<&2, String>,
  +dynamics: List<&2, String>,
  +requires: List<&2, String>
) -> String:
  "{\"file\":" ++ Compiler.json_str(file) ++ ",\"imports\":" ++ Compiler.json_list(imports) ++ ",\"exports\":" ++ Compiler.json_list(exports) ++ ",\"edges\":" ++ analyze_edges_json(imports, dynamics, requires) ++ "}"


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

def analyze_list_cat(xs: List<&2, String>, ys: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      ys
    case Con{h, t}:
      Con{h, analyze_list_cat(t, ys)}

@unsafe def analyze_go(sel: Nat, +file: String, imps: List<&2, String>, +visited: List<&2, String>, +mods: List<&2, String>, +miss: List<&2, String>, seen: Bool, empty: Bool, +spec: String, +path: String, st: List<&2, String> & List<&2, String> & List<&2, String>) -> IO(List<&2, String> & List<&2, String> & List<&2, String>):
  match sel:
    case 0n:
      match seen:
        case True{}:
          IO.pure(List<&2, String> & List<&2, String> & List<&2, String>, (visited, mods, miss))
        case False{}:
          do IO<List<&2, String> & List<&2, String> & List<&2, String>>:
            raw : String <- read_text(file)
            +src : String <- normalize_source(raw)
            +imps2 : List<&2, String> = Compiler.imports_of(src)
            +dyns2 : List<&2, String> = Compiler.dyn_imports_of(src)
            +reqs2 : List<&2, String> = Compiler.requires_of(src)
            +exps : List<&2, String> = Compiler.exports_of(src)
            +mod : String = analyze_mod_json(file, imps2, exps, dyns2, reqs2)
            +walk : List<&2, String> = analyze_list_cat(imps2, analyze_list_cat(dyns2, reqs2))
            analyze_go(1n, file, walk, analyze_app(visited, file), analyze_app(mods, mod), miss, False{}, False{}, "", "", (Nil{}, Nil{}, Nil{}))
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

def target_format_validate_kind(browser_cjs: Bool) -> IO(Unit):
  match browser_cjs:
    case True{}:
      IO.die(Unit, 2, "knot: browser target does not support CommonJS (unsupported_format)")
    case False{}:
      IO.pure(Unit, Unit{})

def target_format_validate(+target: String, +format: String) -> IO(Unit):
  target_format_validate_kind(Bool.and(Bool.or(String.is_empty(target), String.eq(target, "browser")), String.eq(format, "cjs")))

@unsafe def analyze_parse(args: List<&2, String>, entries: List<&2, String>, +target: String, +format: String) -> IO(List<&2, String>):
  match args:
    case Nil{}:
      do IO<List<&2, String>>:
        u : Unit <- target_format_validate(target, format)
        return entries
    case Con{+head, rest}:
      match head:
        case "--target":
          match rest:
            case Con{+value, tail}:
              analyze_parse(tail, entries, value, format)
            case Nil{}:
              IO.die(List<&2, String>, 2, "knot: --target requires a value (invalid_option)")
        case "--format":
          match rest:
            case Con{+value, tail}:
              analyze_parse(tail, entries, target, value)
            case Nil{}:
              IO.die(List<&2, String>, 2, "knot: --format requires a value (invalid_option)")
        case _:
          analyze_parse(rest, analyze_app(entries, head), target, format)

def run_analyze_entries(entries: List<&2, String>) -> IO(Unit):
  match entries:
    case Nil{}:
      analyze_none(True{})
    case _:
      do IO<Unit>:
        quad : List<&2, String> & List<&2, String> & List<&2, String> & List<&2, String> <- analyze_entries(entries, Nil{}, Nil{}, Nil{}, Nil{})
        run_analyze_print(quad)

def run_analyze(args: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    entries : List<&2, String> <- analyze_parse(args, Nil{}, "browser", "esm")
    run_analyze_entries(entries)

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
      a ++ "\n;\n" ++ b

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

def resolve_tsconfig_at(+importer: String, +spec: String, +path: String, +conds: String, ex: Bool) -> IO(String):
  match ex:
    case False{}:
      resolve_pkg_conds(spec, conds)
    case True{}:
      do IO<String>:
        text : String <- read_text(path)
        pairs : String <- json_optional_pairs(text, "compilerOptions/paths")
        resolve_tsconfig_pairs_conds(importer, spec, String.lines(pairs), conds)
def resolve_tsconfig_custom(+importer: String, +spec: String, +conds: String, custom: Bool) -> IO(String):
  match custom:
    case False{}:
      do IO<String>:
        ex : Bool <- file_exists("tsconfig.json")
        resolve_tsconfig_ex_conds(importer, spec, ex, conds)
    case True{}:
      do IO<String>:
        +path : String <- read_text(".knot/tsconfig-path")
        ex : Bool <- file_exists(path)
        resolve_tsconfig_at(importer, spec, path, conds, ex)
def resolve_tsconfig_conds(+importer: String, +spec: String, +conds: String) -> IO(String):
  do IO<String>:
    custom : Bool <- file_exists(".knot/tsconfig-path")
    resolve_tsconfig_custom(importer, spec, conds, custom)

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



@unsafe def list_rev_go(sel: Nat, +xs: List<&2, String>, +acc: List<&2, String>) -> List<&2, String>:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          acc
        case Con{+h, t}:
          list_rev_go(0n, t, Con{h, acc})
    case _:
      acc
def list_rev(+xs: List<&2, String>) -> List<&2, String>:
  list_rev_go(0n, xs, Nil{})
def take_until_semicolon(+s: String, +acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{';', _}:
      acc
    case SCon{h, t}:
      take_until_semicolon(t, acc ++ SCon{h, SNil{}})
def take_until_tab(+s: String, +acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'\t', _}:
      acc
    case SCon{h, t}:
      take_until_tab(t, acc ++ SCon{h, SNil{}})
def str_dup_cons(+head: Char, pair: String & String) -> String & String:
  (left, right) = pair
  (SCon{head, left}, SCon{head, right})
def str_dup(s: String) -> String & String:
  match s:
    case SNil{}:
      ("", "")
    case SCon{+head, tail}:
      str_dup_cons(head, str_dup(tail))
def list_dup_cons(+head: String, pair: List<&2, String> & List<&2, String>) -> List<&2, String> & List<&2, String>:
  (left, right) = pair
  (Con{head, left}, Con{head, right})
def list_dup(xs: List<&2, String>) -> List<&2, String> & List<&2, String>:
  match xs:
    case Nil{}:
      (Nil{}, Nil{})
    case Con{+head, tail}:
      list_dup_cons(head, list_dup(tail))
def split_head(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{+head, _}:
      head
def split_tail(xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{_, +tail}:
      tail
def split_field(index: Nat, xs: List<&2, String>) -> String:
  match index:
    case 0n:
      split_head(xs)
    case 1n+rest:
      split_field(rest, split_tail(xs))
def take_until_equals(+s: String, +acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'=', _}:
      acc
    case SCon{h, t}:
      take_until_equals(t, acc ++ SCon{h, SNil{}})

def loader_extension(+loader: String) -> String:
  take_until_equals(loader, "")

def loader_is_text(+file: String, +loader: String) -> Bool:
  Bool.and(String.ends_with(loader, "=text"), String.ends_with(file, loader_extension(loader)))

def drop_last_early_kind(+s: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      String.take(s, Nat.sub(String.length(s), 1n))

def drop_last_early(+s: String) -> String:
  drop_last_early_kind(s, String.is_empty(s))


def external_marker_kind(+value: String, +packages: String, explicit: Bool, external_packages: Bool) -> String:
  match explicit:
    case True{}:
      value
    case False{}:
      match external_packages:
        case True{}:
          "*"
        case False{}:
          ""

def external_marker(+conds: String) -> String:
  +tail : String = drop_until_key(conds, ";external=")
  +value : String = take_until_semicolon(tail, "")
  +packages_tail : String = drop_until_key(conds, ";packages=")
  +packages : String = take_until_semicolon(packages_tail, "")
  external_marker_kind(value, packages, String.contains(conds, ";external="), String.eq(packages, "external"))

def external_conds_kind(+conds: String, +external: String, empty: Bool) -> String:
  match empty:
    case True{}:
      conds
    case False{}:
      conds ++ ";external=" ++ external

def external_conds(+conds: String, +format: String) -> String:
  +external : String = external_marker(format)
  external_conds_kind(conds, external, String.is_empty(external))

def external_spec_kind(+external: String, +spec: String, wildcard: Bool) -> Bool:
  match wildcard:
    case True{}:
      Bool.and(
        Bool.not(String.starts_with(spec, "./")),
        Bool.and(
          Bool.not(String.starts_with(spec, "../")),
          Bool.and(Bool.not(String.starts_with(spec, "/")), Bool.not(String.starts_with(spec, "#")))))
    case False{}:
      Bool.or(String.eq(external, spec), String.starts_with(spec, external ++ "/"))

def external_spec(+external: String, +spec: String) -> Bool:
  external_spec_kind(external, spec, String.eq(external, "*"))

@unsafe def filter_external_go(sel: Nat, +specs: List<&2, String>, +external: String, +acc: List<&2, String>, +head: String, external_hit: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match specs:
        case Nil{}:
          list_rev(acc)
        case Con{+h, t}:
          filter_external_go(1n, t, external, acc, h, external_spec(external, h))
    case _:
      match external_hit:
        case True{}:
          filter_external_go(0n, specs, external, acc, "", False{})
        case False{}:
          filter_external_go(0n, specs, external, Con{head, acc}, "", False{})

def collect_imports_conds_kind(+imports: List<&2, String>, +external: String, empty: Bool) -> List<&2, String>:
  match empty:
    case True{}:
      imports
    case False{}:
      filter_external_go(0n, imports, external, Nil{}, "", False{})


def collect_imports_kind(+file: String, +src: String, module: Bool) -> List<&2, String>:
  match module:
    case True{}:
      Nil{}
    case False{}:
      Compiler.imports_of(src)

def collect_imports(+file: String, +src: String) -> List<&2, String>:
  collect_imports_kind(file, src, String.ends_with(file, ".module.css"))
def collect_imports_conds(+file: String, +src: String, +conds: String) -> List<&2, String>:
  +imports : List<&2, String> = collect_imports(file, src)
  +external : String = external_marker(conds)
  collect_imports_conds_kind(imports, external, String.is_empty(external))
def external_line_spec_kind(+line: String, +external: String, wildcard: Bool) -> Bool:
  match wildcard:
    case True{}:
      Bool.and(
        String.contains(line, "\""),
        Bool.and(
          Bool.not(String.contains(line, "\"./")),
          Bool.and(
            Bool.not(String.contains(line, "\"../")),
            Bool.and(Bool.not(String.contains(line, "\"/")), Bool.not(String.contains(line, "\"#"))))))
    case False{}:
      Bool.or(String.contains(line, "\"" ++ external ++ "\""), String.contains(line, "\"" ++ external ++ "/"))

def external_line_spec(+line: String, +external: String) -> Bool:
  external_line_spec_kind(line, external, String.eq(external, "*"))

def external_import_line_kind(+line: String, +external: String, hit: Bool) -> Bool:
  match hit:
    case True{}:
      external_line_spec(line, external)
    case False{}:
      False{}

def external_import_line(+line: String, +external: String) -> Bool:
  external_import_line_kind(line, external, Bool.or(String.starts_with(line, "import "), String.starts_with(line, "export ")))
def external_import_piece_kind(+line: String, semicolon: Bool) -> String:
  match semicolon:
    case True{}:
      take_until_semicolon(line, "") ++ ";"
    case False{}:
      line

def external_import_piece(+line: String) -> String:
  external_import_piece_kind(line, String.contains(line, ";"))


@unsafe def external_imports_go(sel: Nat, +lines: List<&2, String>, +external: String, +acc: String, +line: String, hit: Bool) -> String:
  match sel:
    case 0n:
      match lines:
        case Nil{}:
          acc
        case Con{+h, t}:
          external_imports_go(1n, t, external, acc, h, external_import_line(h, external))
    case _:
      match hit:
        case True{}:
          external_imports_go(0n, lines, external, acc ++ external_import_piece(line) ++ "\n", "", False{})
        case False{}:
          external_imports_go(0n, lines, external, acc, "", False{})

def external_imports_kind(+src: String, +external: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      external_imports_go(0n, String.lines(src), external, "", "", False{})

def external_imports(+src: String, +external: String) -> String:
  external_imports_kind(src, external, String.is_empty(external))

def collect_data_result(+file: String, visited: List<&2, String>, result: Result<&1, &1, U32 & String, String>) -> IO(List<&2, String>):
  match result:
    case Done{_}:
      IO.pure(List<&2, String>, list_app(visited, file))
    case Fail{_}:
      IO.die(List<&2, String>, 2, "knot: invalid data or text encoding (invalid_encoding)")

def collect_data_file(+file: String, visited: List<&2, String>) -> IO(List<&2, String>):
  do IO<List<&2, String>>:
    result : Result<&1, &1, U32 & String, String> <- Data.read_utf8(file)
    collect_data_result(file, visited, result)

def collect_data_state(data: Bool) -> Nat:
  match data:
    case True{}:
      2n
    case False{}:
      3n

@unsafe def collect_go(sel: Nat, +file: String, imps: List<&2, String>, +visited: List<&2, String>, seen: Bool, +conds: String) -> IO(List<&2, String>):
  match sel:
    case 0n:
      match seen:
        case True{}:
          IO.pure(List<&2, String>, visited)
        case False{}:
          collect_go(collect_data_state(Bool.or(String.ends_with(file, ".json"), Bool.or(String.ends_with(file, ".jsonc"), Bool.or(String.ends_with(file, ".toml"), Bool.or(String.ends_with(file, ".yaml"), Bool.or(String.ends_with(file, ".yml"), Bool.or(String.ends_with(file, ".txt"), String.ends_with(file, ".svg")))))))), file, imps, visited, False{}, conds)
    case 2n:
      collect_data_file(file, visited)
    case 3n:
      do IO<List<&2, String>>:
        raw : String <- read_text(file)
        src : String <- normalize_source(raw)
        vis2 : List<&2, String> <- collect_go(1n, file, collect_imports_conds(file, src, conds), visited, False{}, conds)
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


def is_asset_file(+f: String) -> Bool:
  Bool.or(String.ends_with(f, ".png"), Bool.or(String.ends_with(f, ".jpg"), Bool.or(String.ends_with(f, ".jpeg"), Bool.or(String.ends_with(f, ".gif"), Bool.or(String.ends_with(f, ".webp"), Bool.or(String.ends_with(f, ".woff"), Bool.or(String.ends_with(f, ".woff2"), Bool.or(String.ends_with(f, ".ttf"), Bool.or(String.ends_with(f, ".eot"), String.ends_with(f, ".avif"))))))))))

@unsafe def collect_keep_go(sel: Nat, +files: List<&2, String>, +f: String, asset: Bool) -> IO(List<&2, String>):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(List<&2, String>, Nil{})
        case Con{+h, rest}:
          collect_keep_go(1n, rest, h, Bool.or(is_asset_file(h), Bool.or(String.ends_with(h, ".json"), Bool.or(String.ends_with(h, ".jsonc"), Bool.or(String.ends_with(h, ".toml"), Bool.or(String.ends_with(h, ".yaml"), Bool.or(String.ends_with(h, ".yml"), Bool.or(String.ends_with(h, ".txt"), String.ends_with(h, ".svg")))))))))
    case _:
      match asset:
        case True{}:
          collect_keep_go(0n, files, "", False{})
        case False{}:
          do IO<List<&2, String>>:
            raw : String <- read_text(f)
            src : String <- normalize_source(raw)
            names : List<&2, String> <- live_imports_of(src)
            raw2 : String <- read_text(f)
            src2 : String <- normalize_source(raw2)
            local : List<&2, String> = Compiler.non_export_function_names_of(src2)
            more : List<&2, String> <- collect_keep_go(0n, files, "", False{})
            return strs_cat(names, strs_cat(local, more))

def collect_keep(files: List<&2, String>) -> IO(List<&2, String>):
  collect_keep_go(0n, files, "", False{})

def se_flag_trim(+s: String) -> String:
  String.take(s, 1n)

def se_flag_res(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Fail{_}:
      IO.pure(String, "1")
    case Done{+s}:
      IO.pure(String, se_flag_trim(s))

def se_flag_of(+f: String, ignore: Bool) -> IO(String):
  match ignore:
    case True{}:
      IO.pure(String, "1")
    case False{}:
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

def css_default_binding(+f: String) -> String:
  +base : String = Compiler.basename(f)
  "__knot_default_" ++ String.take(base, Nat.sub(String.length(base), 11n))


def loader_is_json_kind(+file: String, +loader: String, matched: Bool) -> Bool:
  match matched:
    case True{}:
      String.ends_with(loader, "=json")
    case False{}:
      String.ends_with(file, ".json")

def loader_is_json(+file: String, +loader: String) -> Bool:
  loader_is_json_kind(file, loader, Bool.and(String.contains(loader, "="), String.ends_with(file, loader_extension(loader))))
def loader_is_jsonc_kind(+file: String, +loader: String, matched: Bool) -> Bool:
  match matched:
    case True{}:
      String.ends_with(loader, "=jsonc")
    case False{}:
      String.ends_with(file, ".jsonc")

def loader_is_jsonc(+file: String, +loader: String) -> Bool:
  loader_is_jsonc_kind(file, loader, Bool.and(String.contains(loader, "="), String.ends_with(file, loader_extension(loader))))
def loader_builtin_kind(+file: String, +loader: String, +kind: String, builtin: Bool, matched: Bool) -> Bool:
  match matched:
    case True{}:
      String.ends_with(loader, "=" ++ kind)
    case False{}:
      builtin

def loader_is_toml(+file: String, +loader: String) -> Bool:
  loader_builtin_kind(file, loader, "toml", String.ends_with(file, ".toml"), Bool.and(String.contains(loader, "="), String.ends_with(file, loader_extension(loader))))

def loader_is_yaml(+file: String, +loader: String) -> Bool:
  loader_builtin_kind(file, loader, "yaml", Bool.or(String.ends_with(file, ".yaml"), String.ends_with(file, ".yml")), Bool.and(String.contains(loader, "="), String.ends_with(file, loader_extension(loader))))

def loader_is_file(+file: String, +loader: String) -> Bool:
  Bool.or(is_asset_file(file), String.ends_with(loader, "=file"))
def alias_data_file(+file: String, +loader: String) -> Bool:
  Bool.or(loader_is_json(file, loader), Bool.or(loader_is_jsonc(file, loader), Bool.or(loader_is_toml(file, loader), Bool.or(loader_is_yaml(file, loader), Bool.or(loader_is_text(file, loader), Bool.or(String.ends_with(file, ".txt"), Bool.or(String.ends_with(file, ".svg"), loader_is_file(file, loader))))))))

def alias_data_binding(+importer: String, +pair: String, selected: Bool) -> IO(String):
  match selected:
    case True{}:
      do IO<String>:
        +file : String <- resolve_open(importer, Compiler.default_import_path(pair))
        return "__knot_data_values[" ++ Compiler.json_str(file) ++ "]"
    case False{}:
      IO.pure(String, Compiler.default_import_binding(pair))

def default_alias_lines(+importer: String, +loader: String, pairs: List<&2, String>, +acc: String) -> IO(String):
  match pairs:
    case Nil{}:
      IO.pure(String, acc)
    case Con{+pair, rest}:
      do IO<String>:
        +name : String = Compiler.default_import_name(pair)
        +binding : String <- alias_data_binding(importer, pair, alias_data_file(Compiler.default_import_path(pair), loader))
        default_alias_lines(importer, loader, rest, acc ++ "const " ++ name ++ " = " ++ binding ++ ";\n")

def emit_one_go(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, drop: Bool, minify: Bool, ids: Bool, +loader: String) -> IO(String):
  match drop:
    case True{}:
      IO.pure(String, "")
    case False{}:
      do IO<String>:
        +aliases : String <- default_alias_lines(f, loader, Compiler.default_imports_of(src), "")
        js : String <- bundle_js(f, Compiler.transpile_bundle_opt(f, src, keep, shake, minify, ids))
        return aliases ++ js
def emit_one_drop(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, pure: Bool, minify: Bool, ids: Bool, +loader: String) -> IO(String):
  emit_one_go(f, src, keep, shake, Bool.and(shake, Bool.and(pure, Bool.not(has_any_keep(0n, export_names_of(src), keep, False{})))), minify, ids, loader)

def emit_one_se(+f: String, +src: String, +keep: List<&2, String>, +shake: Bool, +se: String, minify: Bool, ids: Bool, +loader: String) -> IO(String):
  emit_one_drop(f, src, keep, shake, String.eq(se, "0"), minify, ids, loader)


def css_module_char_ok(c: Char) -> Bool:
  match c:
    case ' ':
      False{}
    case '\t':
      False{}
    case '\n':
      False{}
    case '\r':
      False{}
    case '{':
      False{}
    case '}':
      False{}
    case ':':
      False{}
    case ',':
      False{}
    case ';':
      False{}
    case '.':
      False{}
    case '#':
      False{}
    case '(':
      False{}
    case ')':
      False{}
    case _:
      True{}

@unsafe def css_module_take_go(sel: Nat, +s: String, +acc: String, c: Char, ok: Bool) -> String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          acc
        case SCon{+h, t}:
          css_module_take_go(1n, t, acc, h, css_module_char_ok(h))
    case _:
      match ok:
        case True{}:
          css_module_take_go(0n, s, acc ++ SCon{c, SNil{}}, 'a', False{})
        case False{}:
          acc

def css_module_take(+s: String) -> String:
  css_module_take_go(0n, s, "", 'a', False{})

def css_module_name_state_kind(empty: Bool) -> Nat:
  match empty:
    case True{}:
      2n
    case False{}:
      3n

def css_module_name_state(+name: String) -> Nat:
  css_module_name_state_kind(String.is_empty(name))

def css_module_add_kind(+name: String, +acc: List<&2, String>, seen: Bool) -> List<&2, String>:
  match seen:
    case True{}:
      acc
    case False{}:
      list_app(acc, name)

def css_module_add(+name: String, +acc: List<&2, String>) -> List<&2, String>:
  css_module_add_kind(name, acc, has_file(0n, acc, name, False{}))

@unsafe def css_module_names_go(sel: Nat, +rest: String, +acc: List<&2, String>, +after: String, +name: String, +tail: String, found: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      +next_after : String = drop_until_key(rest, ".")
      css_module_names_go(1n, rest, acc, next_after, "", "", String.contains(rest, "."))
    case 1n+p:
      match p:
        case 0n:
          match found:
            case False{}:
              acc
            case True{}:
              +next_name : String = css_module_take(after)
              +next_tail : String = String.drop(after, String.length(next_name))
              css_module_names_go(css_module_name_state(next_name), rest, acc, after, next_name, next_tail, True{})
        case 1n+p2:
          match p2:
            case 0n:
              css_module_names_go(0n, String.drop(after, 1n), acc, "", "", "", False{})
            case _:
              css_module_names_go(0n, tail, css_module_add(name, acc), "", "", "", False{})

def css_module_names_cross_kind(+raw: String, +after: String, from: Bool) -> List<&2, String>:
  match from:
    case True{}:
      css_module_names_go(0n, String.take(raw, Nat.sub(String.length(raw), String.length(after))), Nil{}, "", "", "", False{})
    case False{}:
      css_module_names_go(0n, raw, Nil{}, "", "", "", False{})

def css_module_names(+raw: String) -> List<&2, String>:
  +after : String = drop_until_key(raw, " from \"")
  css_module_names_cross_kind(raw, after, String.contains(raw, " from \""))


@unsafe def css_module_replace_scan(sel: Nat, +hay: String, +needle: String, +replacement: String, found: Bool, empty: Bool) -> String:
  match sel:
    case 0n:
      css_module_replace_scan(1n, hay, needle, replacement, String.starts_with(hay, needle), False{})
    case 1n+p:
      match p:
        case 0n:
          match found:
            case True{}:
              replacement ++ String.drop(hay, String.length(needle))
            case False{}:
              css_module_replace_scan(2n, hay, needle, replacement, False{}, String.is_empty(hay))
        case 1n+p2:
          match empty:
            case True{}:
              ""
            case False{}:
              String.take(hay, 1n) ++ css_module_replace_scan(0n, String.drop(hay, 1n), needle, replacement, False{}, False{})

@unsafe def css_module_replace_go(sel: Nat, +hay: String, +needle: String, +replacement: String, found: Bool) -> String:
  match sel:
    case 0n:
      css_module_replace_go(1n, hay, needle, replacement, String.contains(hay, needle))
    case _:
      match found:
        case True{}:
          css_module_replace_go(0n, css_module_replace_scan(0n, hay, needle, replacement, False{}, False{}), needle, replacement, False{})
        case False{}:
          hay

def css_module_replace_names(+names: List<&2, String>, +raw: String, +prefix: String) -> String:
  match names:
    case Nil{}:
      raw
    case Con{+name, rest}:
      css_module_replace_names(rest, css_module_replace_scan(0n, raw, "." ++ name, "." ++ prefix ++ name, False{}, False{}), prefix)

def css_module_prefix(+file: String) -> String:
  +base : String = Compiler.basename(file)
  String.take(base, Nat.sub(String.length(base), 11n)) ++ "_"

@unsafe def css_module_until_go(sel: Nat, +s: String, +target: Char, +acc: String, c: Char, hit: Bool) -> String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          acc
        case SCon{+h, t}:
          css_module_until_go(1n, t, target, acc, h, Char.is_eq(h, target))
    case _:
      match hit:
        case True{}:
          acc
        case False{}:
          css_module_until_go(0n, s, target, acc ++ SCon{c, SNil{}}, 'a', False{})

def css_module_until(+s: String, target: Char) -> String:
  css_module_until_go(0n, s, target, "", 'a', False{})

def css_module_compose_ref_kind(+body: String, +after: String, found: Bool) -> String:
  match found:
    case True{}:
      css_module_until(after, ';')
    case False{}:
      ""

def css_module_compose_ref(+raw: String, +name: String) -> String:
  +body : String = css_module_until(drop_until_key(raw, "." ++ name), '}')
  +needle : String = "composes: "
  +after : String = drop_until_key(body, needle)
  css_module_compose_ref_kind(body, after, String.contains(body, needle))
def css_module_compose_name_parts(parts: List<&2, String>) -> String:
  match parts:
    case Nil{}:
      ""
    case Con{+name, _}:
      name

def css_module_compose_name(+compose: String) -> String:
  css_module_compose_name_parts(String.split(compose, ' '))

def css_module_compose_local_kind(+compose: String, from: Bool) -> String:
  match from:
    case True{}:
      css_module_compose_name(compose)
    case False{}:
      compose

def css_module_compose_local(+compose: String) -> String:
  css_module_compose_local_kind(compose, String.contains(compose, " from "))

def css_module_from_ref_kind(+compose: String, from: Bool) -> String:
  match from:
    case True{}:
      css_module_until(drop_until_key(compose, "from \""), '"')
    case False{}:
      ""

def css_module_from_ref(+compose: String) -> String:
  css_module_from_ref_kind(compose, String.contains(compose, "from \""))

def css_module_cross_path_kind(+file: String, +ref: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      IO.pure(String, Compiler.resolve_rel(file, ref))

def css_module_cross_path(+file: String, +raw: String) -> IO(String):
  +compose : String = drop_until_key(raw, "composes: ")
  +ref : String = css_module_from_ref(compose)
  css_module_cross_path_kind(file, ref, String.is_empty(ref))

@unsafe def css_module_cycle_go(sel: Nat, fuel: Nat, +file: String, +raw: String, +root: String, +path: String, empty: Bool, equal: Bool) -> IO(Bool):
  match sel:
    case 0n:
      match fuel:
        case 0n:
          IO.pure(Bool, False{})
        case 1n+n:
          do IO<Bool>:
            +next_path : String <- css_module_cross_path(file, raw)
            css_module_cycle_go(1n, n, file, raw, root, next_path, String.is_empty(next_path), String.eq(next_path, root))
    case _:
      match empty:
        case True{}:
          IO.pure(Bool, False{})
        case False{}:
          match equal:
            case True{}:
              IO.pure(Bool, True{})
            case False{}:
              do IO<Bool>:
                +next : String <- read_text(path)
                css_module_cycle_go(0n, fuel, path, next, root, "", True{}, False{})

def css_module_cycle(+file: String, +raw: String) -> IO(Bool):
  css_module_cycle_go(0n, 16n, file, raw, file, "", True{}, False{})
def css_module_value_kind(+name: String, +prefix: String, +compose: String, empty: Bool) -> String:
  match empty:
    case True{}:
      prefix ++ name
    case False{}:
      prefix ++ name ++ " " ++ prefix ++ compose

def css_module_value(+name: String, +prefix: String, +raw: String) -> String:
  +compose : String = css_module_compose_local(css_module_compose_ref(raw, name))
  css_module_value_kind(name, prefix, compose, String.is_empty(compose))

def css_module_value_cross(+file: String, +raw: String, +name: String, +prefix: String, +compose: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, css_module_value(name, prefix, raw))
    case False{}:
      do IO<String>:
        +ref : String = css_module_from_ref(compose)
        +path : String = Compiler.resolve_rel(file, ref)
        imported : String <- read_text(path)
        +imported_name : String = css_module_compose_name(compose)
        +value : String = css_module_value(imported_name, css_module_prefix(path), imported)
        return prefix ++ name ++ " " ++ value

def css_module_export_value(+file: String, +raw: String, +name: String, +prefix: String) -> IO(String):
  +compose : String = css_module_compose_ref(raw, name)
  css_module_value_cross(file, raw, name, prefix, compose, String.is_empty(css_module_from_ref(compose)))
def css_module_strip_one_kind(+raw: String, +compose: String, +empty: Bool) -> String:
  match empty:
    case True{}:
      raw
    case False{}:
      css_module_replace_go(0n, raw, "composes: " ++ compose ++ ";", "", False{})

def css_module_strip_composes(+names: List<&2, String>, +raw: String) -> String:
  match names:
    case Nil{}:
      raw
    case Con{+name, rest}:
      +compose : String = css_module_compose_ref(raw, name)
      +next : String = css_module_strip_one_kind(raw, compose, String.is_empty(compose))
      css_module_strip_composes(rest, next)

def css_module_map_next(+acc: String, +piece: String, first: Bool) -> String:
  match first:
    case True{}:
      piece
    case False{}:
      acc ++ "," ++ piece

@unsafe def css_module_map_go_io(+names: List<&2, String>, +file: String, +prefix: String, +raw: String, +acc: String, first: Bool) -> IO(String):
  match names:
    case Nil{}:
      IO.pure(String, acc)
    case Con{+name, rest}:
      do IO<String>:
        +value : String <- css_module_export_value(file, raw, name, prefix)
        +piece : String = Compiler.json_str(name) ++ ":" ++ Compiler.json_str(value)
        +next : String = css_module_map_next(acc, piece, first)
        css_module_map_go_io(rest, file, prefix, raw, next, False{})

def css_module_js_cycle(cycle: Bool, +file: String, +raw: String) -> IO(String):
  match cycle:
    case True{}:
      IO.die(String, 1, "knot: CSS Modules composition cycle (css_module_cycle)")
    case False{}:
      +names : List<&2, String> = css_module_names(raw)
      +prefix : String = css_module_prefix(file)
      do IO<String>:
        +map : String <- css_module_map_go_io(names, file, prefix, raw, "", True{})
        return "const " ++ css_default_binding(file) ++ " = {" ++ map ++ "};\n"
def css_module_cross_name(+raw: String) -> String:
  css_module_take(drop_until_key(raw, "."))

def css_module_cross_compose(+raw: String) -> String:
  css_module_until(drop_until_key(raw, "composes: "), ';')

def css_module_raw_cross(+file: String, +raw: String) -> String:
  +name : String = css_module_cross_name(raw)
  +compose : String = css_module_cross_compose(raw)
  +stripped : String = css_module_replace_go(0n, raw, "composes: " ++ compose ++ ";", "", False{})
  css_module_replace_scan(0n, stripped, "." ++ name, "." ++ css_module_prefix(file) ++ name, False{}, False{})

def css_module_js_cross(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    +name : String = css_module_cross_name(raw)
    +compose : String = css_module_cross_compose(raw)
    +ref : String = css_module_from_ref(compose)
    +path : String = Compiler.resolve_rel(file, ref)
    imported : String <- read_text(path)
    +imported_name : String = css_module_compose_name(compose)
    +value : String = css_module_value(imported_name, css_module_prefix(path), imported)
    return "const " ++ css_default_binding(file) ++ " = {" ++ Compiler.json_str(name) ++ ":" ++ Compiler.json_str(css_module_prefix(file) ++ name ++ " " ++ value) ++ "};\n"

def css_module_js_cross_cycle(cycle: Bool, +file: String, +raw: String) -> IO(String):
  match cycle:
    case True{}:
      IO.die(String, 1, "knot: CSS Modules composition cycle (css_module_cycle)")
    case False{}:
      css_module_js_cross(file, raw)

def css_module_js_kind(cross: Bool, +file: String, +raw: String) -> IO(String):
  match cross:
    case True{}:
      do IO<String>:
        +cycle : Bool <- css_module_cycle(file, raw)
        css_module_js_cross_cycle(cycle, file, raw)
    case False{}:
      do IO<String>:
        +cycle : Bool <- css_module_cycle(file, raw)
        css_module_js_cycle(cycle, file, raw)

def css_module_js(+file: String, +raw: String) -> IO(String):
  css_module_js_kind(String.contains(raw, " from \""), file, raw)

def css_module_raw_module_kind(+file: String, +raw: String, cross: Bool) -> String:
  match cross:
    case True{}:
      css_module_raw_cross(file, raw)
    case False{}:
      +stripped : String = css_module_strip_composes(css_module_names(raw), raw)
      css_module_replace_names(css_module_names(stripped), stripped, css_module_prefix(file))

def css_module_raw_kind(+file: String, +raw: String, module: Bool) -> String:
  match module:
    case True{}:
      css_module_raw_module_kind(file, raw, String.contains(raw, " from \""))
    case False{}:
      raw


def css_module_import_css_kind(+path: String, +imported: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      IO.pure(String, css_module_raw_kind(path, imported, True{}))

def css_module_import_css_path(+path: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      do IO<String>:
        imported : String <- read_text(path)
        css_module_import_css_kind(path, imported, False{})

def css_module_import_css(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    +path : String <- css_module_cross_path(file, raw)
    css_module_import_css_path(path, String.is_empty(path))

def css_minify_pair(+css: String, +token: String) -> String:
  +left : String = css_module_replace_go(0n, css, " " ++ token, token, False{})
  css_module_replace_go(0n, left, token ++ " ", token, False{})

@unsafe def css_minify_spaces_go(sel: Nat, +css: String, found: Bool) -> String:
  match sel:
    case 0n:
      css_minify_spaces_go(1n, css, String.contains(css, "  "))
    case _:
      match found:
        case True{}:
          css_minify_spaces_go(0n, css_module_replace_go(0n, css, "  ", " ", False{}), False{})
        case False{}:
          css

@unsafe def css_strip_comments_go(sel: Nat, +s: String, +acc: String, inside: Bool, c: Char, open: Bool, close: Bool, quote: Char, escaped: Bool) -> String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          acc
        case SCon{+h, t}:
          css_strip_comments_go(1n, t, acc, inside, h, String.starts_with(s, "/*"), String.starts_with(s, "*/"), quote, escaped)
    case 1n:
      match inside:
        case True{}:
          css_strip_comments_go(2n, s, acc, inside, c, open, close, quote, escaped)
        case False{}:
          css_strip_comments_go(3n, s, acc, inside, c, open, close, quote, escaped)
    case 2n:
      match close:
        case True{}:
          css_strip_comments_go(0n, String.drop(s, 1n), acc, False{}, 'a', False{}, False{}, 'a', False{})
        case False{}:
          css_strip_comments_go(0n, s, acc, True{}, c, False{}, False{}, 'a', False{})
    case 3n:
      match quote:
        case '"':
          css_strip_comments_go(4n, s, acc, inside, c, open, close, quote, escaped)
        case '\'':
          css_strip_comments_go(5n, s, acc, inside, c, open, close, quote, escaped)
        case _:
          css_strip_comments_go(8n, s, acc, inside, c, open, close, quote, escaped)
    case 4n:
      match escaped:
        case True{}:
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '"', False{})
        case False{}:
          css_strip_comments_go(6n, s, acc, inside, c, open, close, quote, escaped)
    case 5n:
      match escaped:
        case True{}:
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '\'', False{})
        case False{}:
          css_strip_comments_go(7n, s, acc, inside, c, open, close, quote, escaped)
    case 6n:
      match c:
        case '\\':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '"', True{})
        case '"':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, 'a', False{})
        case _:
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '"', False{})
    case 7n:
      match c:
        case '\\':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '\'', True{})
        case '\'':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, 'a', False{})
        case _:
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '\'', False{})
    case 8n:
      match c:
        case '"':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '"', False{})
        case '\'':
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, '\'', False{})
        case _:
          css_strip_comments_go(9n, s, acc, inside, c, open, close, quote, escaped)
    case _:
      match open:
        case True{}:
          css_strip_comments_go(0n, String.drop(s, 1n), acc, True{}, 'a', False{}, False{}, 'a', False{})
        case False{}:
          css_strip_comments_go(0n, s, acc ++ SCon{c, SNil{}}, False{}, 'a', False{}, False{}, 'a', False{})
def css_strip_comments(+css: String) -> String:
  css_strip_comments_go(0n, css, "", False{}, 'a', False{}, False{}, 'a', False{})

@unsafe def css_take_var(sel: Nat, +s: String, +acc: String, depth: Nat) -> String & String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          (acc, "")
        case SCon{'(', t}:
          css_take_var(0n, t, acc ++ "(", Nat.add(depth, 1n))
        case SCon{')', t}:
          css_take_var(1n, t, acc, depth)
        case SCon{h, t}:
          css_take_var(0n, t, acc ++ SCon{h, SNil{}}, depth)
    case _:
      match depth:
        case 1n:
          (acc ++ ")", s)
        case _:
          css_take_var(0n, s, acc ++ ")", Nat.sub(depth, 1n))
def css_before_var(+css: String, +after: String) -> String:
  String.take(css, Nat.sub(Nat.sub(String.length(css), String.length(after)), 4n))
def css_minify_zero_values(+css: String) -> String:
  +a : String = css_module_replace_go(0n, css, "0px", "0", False{})
  +b : String = css_module_replace_go(0n, a, "0em", "0", False{})
  +c : String = css_module_replace_go(0n, b, "0rem", "0", False{})
  css_module_replace_go(0n, c, "0%", "0", False{})
def css_minify_text_plain(+css: String) -> String:
  +lines : String = css_module_replace_go(0n, css, "\r", "", False{})
  +tabs : String = css_module_replace_go(0n, lines, "\t", " ", False{})
  +spaces : String = css_minify_spaces_go(0n, tabs, False{})
  +brace0 : String = css_minify_pair(spaces, "{")
  +brace1 : String = css_minify_pair(brace0, "}")
  +colon : String = css_minify_pair(brace1, ":")
  +semicolon : String = css_minify_pair(colon, ";")
  +comma : String = css_minify_pair(semicolon, ",")
  +greater : String = css_minify_pair(comma, ">")
  +zero : String = css_minify_zero_values(greater)
  css_module_replace_go(0n, zero, "\n", "", False{})
@unsafe def css_take_quoted(sel: Nat, +s: String, +acc: String, quote: Char, escaped: Bool, c: Char) -> String & String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          (acc, "")
        case SCon{+h, t}:
          css_take_quoted(1n, t, acc, quote, escaped, h)
    case 1n:
      match escaped:
        case True{}:
          css_take_quoted(0n, s, acc ++ SCon{c, SNil{}}, quote, False{}, 'a')
        case False{}:
          css_take_quoted(2n, s, acc, quote, False{}, c)
    case 2n:
      match quote:
        case '"':
          css_take_quoted(3n, s, acc, quote, False{}, c)
        case '\'':
          css_take_quoted(4n, s, acc, quote, False{}, c)
        case _:
          (acc, s)
    case 3n:
      match c:
        case '\\':
          css_take_quoted(0n, s, acc ++ SCon{c, SNil{}}, '"', True{}, 'a')
        case '"':
          (acc ++ SCon{c, SNil{}}, s)
        case _:
          css_take_quoted(0n, s, acc ++ SCon{c, SNil{}}, '"', False{}, 'a')
    case _:
      match c:
        case '\\':
          css_take_quoted(0n, s, acc ++ SCon{c, SNil{}}, '\'', True{}, 'a')
        case '\'':
          (acc ++ SCon{c, SNil{}}, s)
        case _:
          css_take_quoted(0n, s, acc ++ SCon{c, SNil{}}, '\'', False{}, 'a')
@unsafe def css_minify_text_go(sel: Nat, +css: String, +acc: String, +plain: String, pair: String & String) -> String:
  match sel:
    case 0n:
      match css:
        case SNil{}:
          acc ++ css_minify_text_plain(plain)
        case SCon{'"', t}:
          +quoted : String & String = css_take_quoted(0n, t, "\"", '"', False{}, 'a')
          css_minify_text_go(1n, "", acc, plain, quoted)
        case SCon{'\'', t}:
          +quoted : String & String = css_take_quoted(0n, t, "'", '\'', False{}, 'a')
          css_minify_text_go(1n, "", acc, plain, quoted)
        case SCon{+h, t}:
          css_minify_text_go(0n, t, acc, plain ++ SCon{h, SNil{}}, ("", ""))
    case _:
      (quoted, +rest) = pair
      css_minify_text_go(0n, rest, acc ++ css_minify_text_plain(plain) ++ quoted, "", ("", ""))
def css_minify_text(+css: String) -> String:
  css_minify_text_go(0n, css, "", "", ("", ""))
@unsafe def css_minify_protected(sel: Nat, +css: String, +acc: String, +after: String, pair: String & String, has_var: Bool) -> String:
  match sel:
    case 0n:
      match has_var:
        case False{}:
          acc ++ css_minify_text(css)
        case True{}:
          css_minify_protected(1n, css, acc, drop_until_key(css, "var("), ("", ""), True{})
    case 1n:
      +next : String & String = css_take_var(0n, after, "var(", 1n)
      css_minify_protected(2n, css, acc, after, next, True{})
    case _:
      (body, +rest) = pair
      css_minify_protected(0n, rest, acc ++ css_minify_text(css_before_var(css, after)) ++ body, "", ("", ""), String.contains(rest, "var("))
def css_minify(+css: String) -> String:
  +stripped : String = css_strip_comments(css)
  css_minify_protected(0n, stripped, "", "", ("", ""), String.contains(stripped, "var("))

def css_minify_kind(+css: String, minify: Bool) -> String:
  match minify:
    case True{}:
      css_minify(css)
    case False{}:
      css

def emit_data_value(+file: String, +value: String) -> String:
  "var __knot_data_values = __knot_data_values || Object.create(null);\n__knot_data_values[" ++ Compiler.json_str(file) ++ "] = " ++ value ++ ";\n"

def data_code_span(+status: String, spanned: Bool) -> String:
  match spanned:
    case True{}:
      take_until_tab(status, "")
    case False{}:
      status
def data_code(+status: String) -> String:
  data_code_span(status, String.contains(status, "\t"))
def data_phrase(+code: String) -> String:
  match code:
    case "data_number":
      "number outside the finite safe range"
    case "duplicate_key":
      "duplicate structured data key"
    case "data_schema":
      "unsupported structured data schema"
    case "resource_limit":
      "structured data limit exceeded"
    case "invalid_encoding":
      "invalid UTF-8"
    case _:
      "invalid structured data"
def data_location_pair(pair: List<&2, String> & List<&2, String>) -> String:
  (line_parts, col_parts) = pair
  ":" ++ split_field(1n, line_parts) ++ ":" ++ split_field(2n, col_parts)
def data_location_fields(parts: List<&2, String>) -> String:
  data_location_pair(list_dup(parts))
def data_location_span(+status: String, spanned: Bool) -> String:
  match spanned:
    case False{}:
      ""
    case True{}:
      data_location_fields(String.split(status, '\t'))
def data_location(+status: String) -> String:
  data_location_span(status, String.contains(status, "\t"))
def data_text_phrase(+file: String, +located: String, pair: String & String) -> String:
  (phrase_src, shown) = pair
  "knot: " ++ file ++ data_location(located) ++ ": " ++ data_phrase(phrase_src) ++ " (" ++ shown ++ ")"
def data_text_split(+file: String, pair: String & String) -> String:
  (located, coded) = pair
  data_text_phrase(file, located, str_dup(coded))
def data_text(+file: String, +status: String) -> String:
  data_text_split(file, str_dup(status))
def data_json_from_parts(+file: String, pair: List<&2, String> & List<&2, String>) -> String:
  (code_parts, phrase_parts) = pair
  "{\"version\":1,\"chain\":[],\"code\":" ++ Compiler.json_str(split_head(code_parts)) ++ ",\"generation\":null,\"identity\":{\"kind\":\"project\",\"value\":" ++ Compiler.json_str(file) ++ "},\"location\":null,\"message\":" ++ Compiler.json_str(data_phrase(split_head(phrase_parts))) ++ ",\"phase\":\"load\",\"related\":[],\"severity\":\"error\",\"suggestion\":null}"
def data_json_located(+file: String, +parts: List<&2, String>) -> String:
  data_json_from_parts(file, list_dup(parts))
def data_json_plain(+file: String, pair: String & String) -> String:
  (code, phrase) = pair
  "{\"version\":1,\"chain\":[],\"code\":" ++ Compiler.json_str(code) ++ ",\"generation\":null,\"identity\":{\"kind\":\"project\",\"value\":" ++ Compiler.json_str(file) ++ "},\"location\":null,\"message\":" ++ Compiler.json_str(data_phrase(phrase)) ++ ",\"phase\":\"load\",\"related\":[],\"severity\":\"error\",\"suggestion\":null}"
def data_json_record(+file: String, +status: String, spanned: Bool) -> String:
  match spanned:
    case False{}:
      data_json_plain(file, str_dup(status))
    case True{}:
      data_json_located(file, String.split(status, '\t'))
def data_fail_known(+file: String, +status: String, json: Bool, spanned: Bool) -> IO(String):
  match json:
    case True{}:
      IO.die(String, 2, data_json_record(file, status, spanned))
    case False{}:
      IO.die(String, 2, data_text(file, status))
def data_fail_pair(+file: String, json: Bool, pair: String & String) -> IO(String):
  (flagged, full) = pair
  data_fail_known(file, full, json, String.contains(flagged, "\t"))
def data_fail_mode(+file: String, +status: String, json: Bool) -> IO(String):
  data_fail_pair(file, json, str_dup(status))
def data_fail_selected(+file: String, +status: String) -> IO(String):
  do IO<String>:
    json : Bool <- file_exists(".knot/diagnostics-json")
    data_fail_mode(file, status, json)
def data_clear_kind(+file: String, +status: String, clear: Bool) -> IO(String):
  match clear:
    case False{}:
      data_fail_selected(file, status)
    case True{}:
      do IO<String>:
        +dir : String <- read_text(".knot/clear-on-error")
        u : Unit <- IO.try(Unit, Fs.remove_dir(dir))
        data_fail_selected(file, status)
def data_fail(+file: String, +status: String) -> IO(String):
  do IO<String>:
    clear : Bool <- file_exists(".knot/clear-on-error")
    data_clear_kind(file, status, clear)
def emit_json_status_code(+file: String, +raw: String, +status: String, +code: String) -> IO(String):
  match code:
    case "ok":
      IO.pure(String, emit_data_value(file, "JSON.parse(" ++ Compiler.json_str(raw) ++ ")"))
    case _:
      data_fail(file, status)
def emit_json_status_pair(+file: String, +raw: String, pair: String & String) -> IO(String):
  (coded, full) = pair
  emit_json_status_code(file, raw, full, data_code(coded))
def emit_json_status(+file: String, +raw: String, status: String) -> IO(String):
  emit_json_status_pair(file, raw, str_dup(status))

def emit_json_checked(+file: String, +raw: String, validated: Result<&1, &1, U32 & String, String>) -> IO(String):
  match validated:
    case Fail{_}:
      IO.die(String, 2, "knot: invalid JSON data (syntax_error)")
    case Done{status}:
      emit_json_status(file, raw, status)

def emit_json(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    validated : Result<&1, &1, U32 & String, String> <- Json.query(raw, "", "validate")
    emit_json_checked(file, raw, validated)

def emit_jsonc_normalized(+file: String, normalized: String, failed: Bool) -> IO(String):
  match failed:
    case True{}:
      emit_json_status(file, "", String.drop(normalized, 4n))
    case False{}:
      emit_json_status(file, String.drop(normalized, 3n), "ok")

def emit_jsonc_result(+file: String, result: Result<&1, &1, U32 & String, String>) -> IO(String):
  match result:
    case Fail{_}:
      IO.die(String, 2, "knot: JSONC normalization failed (resource_limit)")
    case Done{+normalized}:
      emit_jsonc_normalized(file, normalized, String.starts_with(normalized, "ERR:"))

def emit_jsonc(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    result : Result<&1, &1, U32 & String, String> <- Json.query(raw, "", "normalize_jsonc")
    emit_jsonc_result(file, result)

# A text loader removes only a leading U+FEFF, not an interior character.
def strip_text_bom(raw: String) -> String:
  match raw:
    case SCon{'﻿', rest}:
      rest
    case SCon{head, tail}:
      SCon{head, tail}
    case SNil{}:
      SNil{}

def emit_text(+file: String, +raw: String) -> IO(String):
  IO.pure(String, emit_data_value(file, Compiler.json_str(strip_text_bom(raw))))

def asset_public_url_join(+public: String, +name: String, slash: Bool) -> String:
  match slash:
    case True{}:
      public ++ name
    case False{}:
      public ++ "/" ++ name

def asset_public_url_kind(+public: String, +name: String, empty: Bool) -> String:
  match empty:
    case True{}:
      name
    case False{}:
      asset_public_url_join(public, name, String.ends_with(public, "/"))

def asset_public_url(+public: String, +name: String) -> String:
  asset_public_url_kind(public, name, String.is_empty(public))

def emit_asset(+file: String) -> IO(String):
  IO.pure(String, emit_data_value(file, Compiler.json_str(Compiler.basename(file))))

def emit_css_kind(+f: String, +raw: String, module: Bool) -> IO(String):
  match module:
    case True{}:
      css_module_js(f, raw)
    case False{}:
      IO.pure(String, "")


def emit_one_asset_kind(+f: String, +raw: String, +keep: List<&2, String>, +shake: Bool, asset: Bool, minify: Bool, ids: Bool, ignore: Bool, +loader: String) -> IO(String):
  match asset:
    case True{}:
      emit_asset(f)
    case False{}:
      do IO<String>:
        src : String <- ts_prep(f, raw)
        se : String <- se_flag_of(f, ignore)
        emit_one_se(f, src, keep, shake, se, minify, ids, loader)

def emit_one_loader_kind(+f: String, +raw: String, +keep: List<&2, String>, +shake: Bool, loader_text: Bool, asset: Bool, minify: Bool, ids: Bool, ignore: Bool, +loader: String) -> IO(String):
  match loader_text:
    case True{}:
      emit_text(f, raw)
    case False{}:
      emit_one_asset_kind(f, raw, keep, shake, asset, minify, ids, ignore, loader)

def emit_one_text_branch(+f: String, +raw: String, +keep: List<&2, String>, +shake: Bool, text: Bool, +loader: String, asset: Bool, minify: Bool, ids: Bool, ignore: Bool) -> IO(String):
  match text:
    case True{}:
      emit_text(f, raw)
    case False{}:
      emit_one_loader_kind(f, raw, keep, shake, loader_is_text(f, loader), asset, minify, ids, ignore, loader)

def emit_converted_value(+file: String, +json: String, failed: Bool) -> IO(String):
  match failed:
    case True{}:
      emit_json_status(file, "", String.drop(json, 4n))
    case False{}:
      emit_json_status(file, json, "ok")

def emit_converted_result(+file: String, converted: Result<&1, &1, U32 & String, String>) -> IO(String):
  match converted:
    case Fail{_}:
      IO.die(String, 2, "knot: data conversion failed (resource_limit)")
    case Done{+json}:
      emit_converted_value(file, json, String.starts_with(json, "ERR:"))

def emit_toml(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    converted : Result<&1, &1, U32 & String, String> <- Data.toml(raw)
    emit_converted_result(file, converted)

def emit_yaml(+file: String, +raw: String) -> IO(String):
  do IO<String>:
    converted : Result<&1, &1, U32 & String, String> <- Data.yaml(raw)
    emit_converted_result(file, converted)

def emit_one_structured(+f: String, +raw: String, +keep: List<&2, String>, +shake: Bool, toml: Bool, yaml: Bool, css: Bool, module: Bool, text: Bool, asset: Bool, minify: Bool, ids: Bool, +loader: String, ignore: Bool) -> IO(String):
  match toml:
    case True{}:
      emit_toml(f, raw)
    case False{}:
      match yaml:
        case True{}:
          emit_yaml(f, raw)
        case False{}:
          match css:
            case True{}:
              emit_css_kind(f, raw, module)
            case False{}:
              emit_one_text_branch(f, raw, keep, shake, text, loader, asset, minify, ids, ignore)

def emit_one_kind(+f: String, +raw: String, +keep: List<&2, String>, +shake: Bool, json: Bool, jsonc: Bool, toml: Bool, yaml: Bool, css: Bool, module: Bool, text: Bool, asset: Bool, minify: Bool, ids: Bool, +loader: String, ignore: Bool) -> IO(String):
  match json:
    case True{}:
      emit_json(f, raw)
    case False{}:
      match jsonc:
        case True{}:
          emit_jsonc(f, raw)
        case False{}:
          emit_one_structured(f, raw, keep, shake, toml, yaml, css, module, text, asset, minify, ids, loader, ignore)

def read_data_source_result(result: Result<&1, &1, U32 & String, String>) -> IO(String):
  match result:
    case Done{text}:
      IO.pure(String, text)
    case Fail{_}:
      IO.die(String, 2, "knot: invalid data or text encoding (invalid_encoding)")

def read_data_source_kind(+file: String, selected: Bool) -> IO(String):
  match selected:
    case True{}:
      do IO<String>:
        result : Result<&1, &1, U32 & String, String> <- Data.read_utf8(file)
        read_data_source_result(result)
    case False{}:
      read_text(file)

def read_data_source(+file: String, +loader: String) -> IO(String):
  read_data_source_kind(file, Bool.or(loader_is_jsonc(file, loader), Bool.or(loader_is_json(file, loader), Bool.or(loader_is_toml(file, loader), Bool.or(loader_is_yaml(file, loader), Bool.or(loader_is_text(file, loader), Bool.or(String.ends_with(file, ".txt"), String.ends_with(file, ".svg"))))))))

def emit_one(+f: String, +keep: List<&2, String>, +shake: Bool, minify: Bool, ids: Bool, +loader: String, ignore: Bool) -> IO(String):
  do IO<String>:
    raw : String <- read_data_source(f, loader)
    emit_one_kind(f, raw, keep, shake, loader_is_json(f, loader), loader_is_jsonc(f, loader), loader_is_toml(f, loader), loader_is_yaml(f, loader), String.ends_with(f, ".css"), String.ends_with(f, ".module.css"), Bool.or(String.ends_with(f, ".txt"), String.ends_with(f, ".svg")), loader_is_file(f, loader), minify, ids, loader, ignore)
def css_join_empty(+a: String, +b: String, empty: Bool) -> String:
  match empty:
    case True{}:
      b
    case False{}:
      a ++ "\n" ++ b

def css_join(+a: String, +b: String) -> String:
  css_join_empty(a, b, String.is_empty(a))

def css_take_char_go(+s: String, +target: Char, +acc: String, hit: Bool) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{+h, t}:
      match hit:
        case True{}:
          acc
        case False{}:
          css_take_char_go(t, target, acc ++ SCon{h, SNil{}}, Char.is_eq(h, target))

def css_take_until_char(+s: String, target: Char) -> String:
  css_take_char_go(s, target, "", False{})

def css_drop_char_go(+s: String, +target: Char, hit: Bool) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{+h, t}:
      match hit:
        case True{}:
          s
        case False{}:
          css_drop_char_go(t, target, Char.is_eq(h, target))

def css_drop_after_char(+s: String, target: Char) -> String:
  css_drop_char_go(s, target, False{})

def css_take_word_go(+s: String, +acc: String, stop: Bool) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{+h, t}:
      match stop:
        case True{}:
          acc
        case False{}:
          css_take_word_go(t, acc ++ SCon{h, SNil{}}, Bool.or(Char.is_eq(h, ' '), Char.is_eq(h, '\t')))

def css_drop_last_char(s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{_, SNil{}}:
      ""
    case SCon{h, t}:
      SCon{h, css_drop_last_char(t)}

def css_ref_path_hash(+ref: String, has_hash: Bool) -> String:
  match has_hash:
    case True{}:
      css_drop_last_char(css_take_until_char(ref, '#'))
    case False{}:
      ref

def css_ref_path_q(+ref: String, has_query: Bool) -> String:
  match has_query:
    case True{}:
      css_drop_last_char(css_take_until_char(ref, '?'))
    case False{}:
      css_ref_path_hash(ref, String.contains(ref, "#"))

def css_ref_path(+ref: String) -> String:
  css_ref_path_q(ref, String.contains(ref, "?"))

def css_ref_suffix(+ref: String, +path: String) -> String:
  String.drop(ref, String.length(path))

@unsafe def css_trim_leading_go(sel: Nat, +s: String, skip: Bool, h: Char) -> String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          ""
        case SCon{+c, t}:
          match skip:
            case True{}:
              css_trim_leading_go(1n, t, Bool.or(Char.is_eq(c, ' '), Char.is_eq(c, '\t')), c)
            case False{}:
              s
    case _:
      match skip:
        case True{}:
          css_trim_leading_go(0n, s, True{}, h)
        case False{}:
          SCon{h, s}

def css_trim_leading(+s: String) -> String:
  css_trim_leading_go(0n, s, True{}, ' ')

def css_trim_word_tail(+word: String, has_space: Bool) -> String:
  match has_space:
    case True{}:
      css_drop_last_char(word)
    case False{}:
      word

def css_url_word_ref(+inside: String) -> String:
  +trimmed : String = css_trim_leading(inside)
  +word : String = css_take_word_go(trimmed, "", False{})
  css_trim_word_tail(word, Bool.or(String.contains(trimmed, " "), String.contains(trimmed, "\t")))

def css_url_ref(+inside: String) -> String:
  match inside:
    case SNil{}:
      ""
    case SCon{'"', t}:
      css_drop_last_char(css_take_until_char(t, '"'))
    case SCon{'\'', t}:
      css_drop_last_char(css_take_until_char(t, '\''))
    case _:
      css_url_word_ref(inside)

def css_url_inside(+after: String) -> String:
  css_drop_last_char(css_take_until_char(after, ')'))

def css_url_tail(+after: String) -> String:
  css_drop_after_char(after, ')')

def css_drop_leading_newline(+s: String) -> String:
  match s:
    case SCon{'\n', t}:
      t
    case _:
      s

def css_import_kind_single(+s: String, one: Bool) -> Nat:
  match one:
    case True{}:
      2n
    case False{}:
      0n

def css_import_kind_double(+s: String, two: Bool) -> Nat:
  match two:
    case True{}:
      1n
    case False{}:
      css_import_kind_single(s, String.starts_with(s, "@import '"))

def css_import_kind(+s: String) -> Nat:
  css_import_kind_double(s, String.starts_with(s, "@import \""))

@unsafe def css_strip_imports_go(
  sel: Nat,
  +rest: String,
  +acc: String,
  fuel: Nat,
  kind: Nat,
  +full: String,
  +tail: String,
  local: Bool,
  bare: Bool
) -> String:
  match sel:
    case 0n:
      match fuel:
        case 0n:
          acc ++ rest
        case 1n+p:
          css_strip_imports_go(2n, rest, acc, p, kind, full, tail, local, bare)
    case 2n:
      match rest:
        case SNil{}:
          acc
        case SCon{+h, t}:
          match kind:
            case 1n:
              +after : String = String.drop(rest, 9n)
              +ref : String = css_drop_last_char(css_take_until_char(after, '"'))
              +next_tail : String = css_drop_after_char(after, ';')
              +next_full : String = String.take(rest, Nat.sub(String.length(rest), String.length(next_tail)))
              css_strip_imports_go(3n, next_tail, acc, fuel, 0n, next_full, next_tail, Compiler.is_rel(ref), String.starts_with(css_drop_after_char(after, '"'), ";"))
            case 2n:
              +after : String = String.drop(rest, 9n)
              +ref : String = css_drop_last_char(css_take_until_char(after, '\''))
              +next_tail : String = css_drop_after_char(after, ';')
              +next_full : String = String.take(rest, Nat.sub(String.length(rest), String.length(next_tail)))
              css_strip_imports_go(3n, next_tail, acc, fuel, 0n, next_full, next_tail, Compiler.is_rel(ref), String.starts_with(css_drop_after_char(after, '\''), ";"))
            case _:
              css_strip_imports_go(0n, t, acc ++ SCon{h, SNil{}}, fuel, css_import_kind(t), "", "", False{}, False{})
    case _:
      match local:
        case True{}:
          match bare:
            case True{}:
              +next_tail : String = css_drop_leading_newline(tail)
              css_strip_imports_go(0n, next_tail, acc, fuel, css_import_kind(next_tail), "", "", False{}, False{})
            case False{}:
              css_strip_imports_go(0n, tail, acc ++ full, fuel, css_import_kind(tail), "", "", False{}, False{})
        case False{}:
          css_strip_imports_go(0n, tail, acc ++ full, fuel, css_import_kind(tail), "", "", False{}, False{})

def asset_hash_ok(+c: Char) -> Bool:
  Bool.and(Bool.not(Char.is_eq(c, '+')), Bool.and(Bool.not(Char.is_eq(c, '/')), Bool.not(Char.is_eq(c, '='))))

@unsafe def asset_hash_go(sel: Nat, +s: String, n: Nat, +acc: String, c: Char, ok: Bool) -> String:
  match sel:
    case 0n:
      match n:
        case 0n:
          String.reverse(acc)
        case _:
          asset_hash_go(3n, s, n, acc, c, ok)
    case 3n:
      match s:
        case SNil{}:
          String.reverse(acc)
        case SCon{+h, t}:
          asset_hash_go(1n, t, n, acc, h, asset_hash_ok(h))
    case 1n:
      match ok:
        case True{}:
          asset_hash_go(4n, s, n, acc, c, ok)
        case False{}:
          asset_hash_go(0n, s, n, acc, 'a', False{})
    case _:
      match n:
        case 0n:
          String.reverse(acc)
        case 1n+n2:
          asset_hash_go(0n, s, n2, SCon{c, acc}, 'a', False{})

def asset_hash_prefix(+file: String) -> IO(String):
  do IO<String>:
    +digest : String <- IO.try(String, Hash.sha256_b64(file))
    return asset_hash_go(0n, digest, 8n, "", 'a', False{})
def asset_dir_kind(+parent: String, top: Bool) -> String:
  match top:
    case True{}:
      ""
    case False{}:
      parent ++ "/"
def asset_dir(+file: String) -> String:
  +parent : String = Compiler.dirname(file)
  asset_dir_kind(parent, Bool.or(String.eq(parent, "."), String.is_empty(parent)))
def asset_template_kind(+file: String, +template: String, +hash: String, empty: Bool) -> String:
  match empty:
    case True{}:
      Compiler.basename(file)
    case False{}:
      +base : String = Compiler.basename(file)
      +stem0 : String = css_take_until_char(base, '.')
      +stem : String = String.take(stem0, Nat.sub(String.length(stem0), 1n))
      +ext : String = String.drop(base, Nat.add(String.length(stem), 1n))
      +name0 : String = css_module_replace_go(0n, template, "[name]", stem, False{})
      +name1 : String = css_module_replace_go(0n, name0, "[ext]", ext, False{})
      +name2 : String = css_module_replace_go(0n, name1, "[hash:8]", hash, False{})
      +name3 : String = css_module_replace_go(0n, name2, "[hash]", hash, False{})
      css_module_replace_go(0n, name3, "[dir]", asset_dir(file), False{})

def asset_template_name(+file: String, +template: String, +hash: String) -> String:
  asset_template_kind(file, template, hash, String.is_empty(template))

def asset_output_name_check(+name: String, invalid: Bool) -> IO(String):
  match invalid:
    case True{}:
      IO.die(String, 2, "knot: invalid asset naming template (unknown_command)")
    case False{}:
      IO.pure(String, name)

def asset_output_name(+file: String, +template: String) -> IO(String):
  do IO<String>:
    +hash : String <- asset_hash_prefix(file)
    +name : String = asset_template_name(file, template, hash)
    asset_output_name_check(name, Bool.or(Bool.or(String.contains(name, "["), String.contains(name, "]")), Bool.or(String.starts_with(name, "/"), String.contains(name, ".."))))
@unsafe def css_rewrite_go(
  sel: Nat,
  +rest: String,
  +file: String,
  +outdir: String,
  +template: String,
  +public: String,
  +acc: String,
  fuel: Nat,
  hit: Bool,
  +full: String,
  +ref: String,
  +suffix: String,
  local: Bool
) -> IO(String):
  match sel:
    case 0n:
      match fuel:
        case 0n:
          IO.pure(String, acc ++ rest)
        case 1n+p:
          css_rewrite_go(2n, rest, file, outdir, template, public, acc, p, hit, full, ref, suffix, local)
    case 2n:
      match rest:
        case SNil{}:
          IO.pure(String, acc)
        case SCon{+h, t}:
          match hit:
            case True{}:
              +after : String = String.drop(rest, 4n)
              +inside : String = css_url_inside(after)
              +tail : String = css_url_tail(after)
              +next_raw : String = css_url_ref(inside)
              +next_ref : String = css_ref_path(next_raw)
              +next_suffix : String = css_ref_suffix(next_raw, next_ref)
              +next_full : String = "url(" ++ inside ++ ")"
              css_rewrite_go(1n, tail, file, outdir, template, public, acc, fuel, String.starts_with(tail, "url("), next_full, next_ref, next_suffix, Compiler.is_rel(next_ref))
            case False{}:
              css_rewrite_go(0n, t, file, outdir, template, public, acc ++ SCon{h, SNil{}}, fuel, String.starts_with(t, "url("), "", "", "", False{})
    case _:
      match local:
        case False{}:
          css_rewrite_go(0n, rest, file, outdir, template, public, acc ++ full, fuel, String.starts_with(rest, "url("), "", "", "", False{})
        case True{}:
          do IO<String>:
            +path : String <- resolve_open(file, ref)
            +name : String <- asset_output_name(path, template)
            u : Unit <- IO.try(Unit, Fs.copy(path, Compiler.join_rel(outdir, name)))
            css_rewrite_go(0n, rest, file, outdir, template, public, acc ++ "url(\"" ++ asset_public_url(public, name) ++ suffix ++ "\")", fuel, String.starts_with(rest, "url("), "", "", "", False{})

def css_rewrite_urls(+file: String, +outdir: String, +raw: String, +template: String, +public: String) -> IO(String):
  do IO<String>:
    imported : String <- css_module_import_css(file, raw)
    +local : String = css_module_raw_kind(file, raw, String.ends_with(file, ".module.css"))
    +prepared : String = css_join(imported, local)
    +stripped : String = css_strip_imports_go(0n, prepared, "", 65536n, css_import_kind(prepared), "", "", False{}, False{})
    css_rewrite_go(0n, stripped, file, outdir, template, public, "", 65536n, String.starts_with(stripped, "url("), "", "", "", False{})

@unsafe def emit_css_go(sel: Nat, files: List<&2, String>, +outdir: String, +template: String, +public: String, minify: Bool, +file: String, +acc: String, css: Bool) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, css_minify_kind(acc, minify))
        case Con{+f, rest}:
          emit_css_go(1n, rest, outdir, template, public, minify, f, acc, String.ends_with(f, ".css"))
    case _:
      match css:
        case True{}:
          do IO<String>:
            raw : String <- read_text(file)
            rewritten : String <- css_rewrite_urls(file, outdir, raw, template, public)
            +next : String = css_join(acc, rewritten)
            emit_css_go(0n, files, outdir, template, public, minify, "", next, False{})
        case False{}:
          emit_css_go(0n, files, outdir, template, public, minify, "", acc, False{})

def emit_css_files(files: List<&2, String>, +outdir: String, +acc: String, +template: String, +public: String, minify: Bool) -> IO(String):
  emit_css_go(0n, files, outdir, template, public, minify, "", acc, False{})

def css_path_kind(+out: String, cjs: Bool) -> String:
  match cjs:
    case True{}:
      String.take(out, Nat.sub(String.length(out), 3n)) ++ "css"
    case False{}:
      String.take(out, Nat.sub(String.length(out), 2n)) ++ "css"

def css_path(+out: String) -> String:
  css_path_kind(out, String.ends_with(out, ".cjs"))

@unsafe def css_map_sources_go(sel: Nat, +files: List<&2, String>, +acc: String, +piece: String, first: Bool, is_css: Bool) -> String:
  match sel:
    case 0n:
      match files:
        case Nil{}:
          acc
        case Con{+h, rest}:
          css_map_sources_go(1n, rest, acc, Compiler.json_str(Compiler.basename(h)), first, String.ends_with(h, ".css"))
    case 1n:
      match is_css:
        case True{}:
          css_map_sources_go(2n, files, acc, piece, first, is_css)
        case False{}:
          css_map_sources_go(0n, files, acc, "", first, False{})
    case _:
      match first:
        case True{}:
          css_map_sources_go(0n, files, piece, "", False{}, False{})
        case False{}:
          css_map_sources_go(0n, files, acc ++ "," ++ piece, "", False{}, False{})

def css_map_line_next(+acc: String, +piece: String, first: Bool) -> String:
  match first:
    case True{}:
      piece
    case False{}:
      acc ++ ";" ++ piece

@unsafe def css_only_files_go(sel: Nat, +files: List<&2, String>, +acc: List<&2, String>, +file: String, is_css: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match files:
        case Nil{}:
          acc
        case Con{+h, rest}:
          css_only_files_go(1n, rest, acc, h, String.ends_with(h, ".css"))
    case _:
      match is_css:
        case True{}:
          css_only_files_go(0n, files, list_app(acc, file), "", False{})
        case False{}:
          css_only_files_go(0n, files, acc, "", False{})

def css_only_files(+files: List<&2, String>) -> List<&2, String>:
  css_only_files_go(0n, files, Nil{}, "", False{})

@unsafe def css_map_composed_go(
  sel: Nat,
  files: List<&2, String>,
  source_lines: List<&2, String>,
  rest: List<&2, String>,
  +source: U32,
  +line: U32,
  prev_source: U32,
  prev_line: U32,
  remaining: Nat,
  +acc: String,
  first: Bool
) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, acc)
        case Con{+h, tail}:
          do IO<String>:
            raw : String <- read_text(h)
            +source_lines : List<&2, String> = String.lines(raw)
            css_map_composed_go(1n, Nil{}, source_lines, tail, source, 0, prev_source, prev_line, remaining, acc, first)
    case _:
      match source_lines:
        case Nil{}:
          css_map_composed_go(0n, rest, Nil{}, Nil{}, U32.inc(source), 0, prev_source, prev_line, remaining, acc, first)
        case Con{_, tail}:
          match remaining:
            case 0n:
              IO.pure(String, acc)
            case 1n+n:
              +piece : String = Compiler.map_seg_source(0, 0, source, prev_source, line, prev_line, 0, 0)
              css_map_composed_go(1n, Nil{}, tail, rest, source, U32.inc(line), source, line, n, css_map_line_next(acc, piece, first), False{})

def css_map_mappings_composed(+files: List<&2, String>, +css: String) -> IO(String):
  css_map_composed_go(0n, css_only_files(files), Nil{}, Nil{}, 0, 0, 0, 0, List.length(&2, String, String.lines(css)), "", True{})


def css_map_body(+file: String, files: List<&2, String>, +mappings: String) -> String:
  "{\"version\":3,\"file\":" ++ Compiler.json_str(file) ++ ",\"sources\":[" ++ css_map_sources_go(0n, files, "", "", True{}, False{}) ++ "],\"names\":[],\"mappings\":" ++ Compiler.json_str(mappings) ++ "}"
def css_map_css_kind(+css: String, +file: String, +map: String, +mode: String) -> String:
  match mode:
    case "inline":
      css ++ "\n/*# sourceMappingURL=data:application/json;base64," ++ Compiler.b64_encode(map) ++ " */\n"
    case "linked":
      css ++ "\n/*# sourceMappingURL=" ++ file ++ ".map */\n"
    case "external":
      css ++ "\n/*# sourceMappingURL=" ++ file ++ ".map */\n"
    case _:
      css
def css_map_css_pair(+css: String, pair: String & String, +mode: String, files: List<&2, String>, +mappings: String) -> String:
  (file, file_copy) = pair
  css_map_css_kind(css, file, css_map_body(file_copy, files, mappings), mode)
def css_map_css(+css: String, +file: String, +mode: String, files: List<&2, String>, +mappings: String) -> String:
  css_map_css_pair(css, str_dup(file), mode, files, mappings)

def css_template_apply(+out: String, +template: String) -> String:
  +base : String = Compiler.basename(css_path(out))
  +stem0 : String = css_take_until_char(base, '.')
  +stem : String = String.take(stem0, Nat.sub(String.length(stem0), 1n))
  +named0 : String = css_module_replace_go(0n, template, "[name]", stem, False{})
  +named1 : String = css_module_replace_go(0n, named0, "[ext]", "css", False{})
  +named2 : String = css_module_replace_go(0n, named1, "[dir]", asset_dir(out), False{})
  Compiler.join_rel(Compiler.dirname(out), named2)
def css_written_read(+out: String, custom: Bool) -> IO(String):
  match custom:
    case False{}:
      IO.pure(String, css_path(out))
    case True{}:
      do IO<String>:
        +template : String <- read_text(".knot/css-naming")
        return css_template_apply(out, template)
def css_written_path(+out: String) -> IO(String):
  do IO<String>:
    custom : Bool <- file_exists(".knot/css-naming")
    css_written_read(out, custom)
def css_path_base(pair: String & String) -> String & String:
  (path, copy) = pair
  (path, Compiler.basename(copy))
def write_text_atomic_named(pair: String & String, +css: String, +mode: String, files: List<&2, String>, +mappings: String) -> IO(Unit):
  (path, file) = pair
  write_text_atomic(path, css_map_css(css, file, mode, files, mappings))
def write_css_if(+out: String, +css: String, empty: Bool, +mode: String, +files: List<&2, String>) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        +path : String <- css_written_path(out)
        +mappings : String <- css_map_mappings_composed(files, css)
        write_text_atomic_named(css_path_base(str_dup(path)), css, mode, files, mappings)
def write_css_map_named(pair: String & String, files: List<&2, String>, +mappings: String) -> IO(Unit):
  (path, file) = pair
  write_text_atomic(path ++ ".map", css_map_body(file, files, mappings))
def write_css_map_kind(+out: String, +css: String, +files: List<&2, String>, +mode: String, external: Bool) -> IO(Unit):
  match external:
    case True{}:
      do IO<Unit>:
        +path : String <- css_written_path(out)
        +mappings : String <- css_map_mappings_composed(files, css)
        write_css_map_named(css_path_base(str_dup(path)), files, mappings)
    case False{}:
      IO.pure(Unit, Unit{})

def write_css_map_if(+out: String, +css: String, files: List<&2, String>, +mode: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      write_css_map_kind(out, css, files, mode, Bool.or(String.eq(mode, "linked"), String.eq(mode, "external")))


@unsafe def copy_assets_go(sel: Nat, +files: List<&2, String>, +outdir: String, +file: String, asset: Bool, +template: String) -> IO(Unit):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{+h, rest}:
          copy_assets_go(1n, rest, outdir, h, is_asset_file(h), template)
    case _:
      match asset:
        case True{}:
          do IO<Unit>:
            +name : String <- asset_output_name(file, template)
            u : Unit <- IO.try(Unit, Fs.copy(file, Compiler.join_rel(outdir, name)))
            copy_assets_go(0n, files, outdir, "", False{}, template)
        case False{}:
          copy_assets_go(0n, files, outdir, "", False{}, template)

def copy_assets(+files: List<&2, String>, +out: String, +template: String) -> IO(Unit):
  copy_assets_go(0n, files, Compiler.dirname(out), "", False{}, template)
def rewrite_asset_value_kind(+js: String, +old: String, +target: String, same: Bool) -> String:
  match same:
    case True{}:
      js
    case False{}:
      css_module_replace_go(0n, js, old, target, False{})

@unsafe def rewrite_asset_refs_go(sel: Nat, +files: List<&2, String>, +js: String, +template: String, +public: String, +file: String, asset: Bool) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, js)
        case Con{+h, rest}:
          rewrite_asset_refs_go(1n, rest, js, template, public, h, is_asset_file(h))
    case _:
      match asset:
        case True{}:
          do IO<String>:
            +name : String <- asset_output_name(file, template)
            +target : String = asset_public_url(public, name)
            +rewritten : String = rewrite_asset_value_kind(js, Compiler.basename(file), target, String.eq(Compiler.basename(file), target))
            rewrite_asset_refs_go(0n, files, rewritten, template, public, "", False{})
        case False{}:
          rewrite_asset_refs_go(0n, files, js, template, public, "", False{})

def rewrite_asset_refs(+files: List<&2, String>, +js: String, +template: String, +public: String) -> IO(String):
  rewrite_asset_refs_go(0n, files, js, template, public, "", False{})


def emit_files(files: List<&2, String>, +keep: List<&2, String>, +minify: Bool, +ids: Bool, +loader: String, +ignore: Bool) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, Nil{}}:
      emit_one(f, keep, False{}, minify, ids, loader, ignore)
    case Con{+f, rest}:
      do IO<String>:
        js : String <- emit_one(f, keep, True{}, minify, ids, loader, ignore)
        more : String <- emit_files(rest, keep, minify, ids, loader, ignore)
        return bundle_concat(js, more)

def bundle_entry_conds(+file: String, +conds: String) -> IO(String):
  do IO<String>:
    +files : List<&2, String> <- collect_go(0n, file, Nil{}, Nil{}, False{}, conds)
    keep : List<&2, String> <- collect_keep(files)
    emit_files(files, keep, False{}, False{}, "", False{})

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
def early_format_marker_kind(+tail: String, found: Bool) -> String:
  match found:
    case True{}:
      take_until_semicolon(tail, "")
    case False{}:
      ""

def early_format_marker(+format: String, +key: String) -> String:
  +needle : String = ";" ++ key ++ "="
  +tail : String = drop_until_key(format, needle)
  early_format_marker_kind(tail, String.contains(format, needle))

def option_pair_key(+marker: String) -> String:
  drop_last_early(css_take_until_char(marker, '='))

def option_pair_value(+marker: String) -> String:
  +key : String = css_take_until_char(marker, '=')
  String.drop(marker, String.length(key))

def apply_define_kind(+js: String, +marker: String, empty: Bool) -> String:
  match empty:
    case True{}:
      js
    case False{}:
      str_replace(0n, js, option_pair_key(marker), option_pair_value(marker), False{}, False{})

def apply_drop_kind(+js: String, +marker: String, empty: Bool) -> String:
  match empty:
    case True{}:
      js
    case False{}:
      +direct : String = str_replace(0n, js, marker ++ "(", "void (", False{}, False{})
      +spaced : String = str_replace(0n, marker, ".", " . ", False{}, False{}) ++ " ("
      str_replace(0n, direct, spaced, "void (", False{}, False{})

def apply_build_transforms(+js: String, +format: String) -> String:
  +define : String = early_format_marker(format, "define")
  +drop : String = early_format_marker(format, "drop")
  +defined : String = apply_define_kind(js, define, String.is_empty(define))
  apply_drop_kind(defined, drop, String.is_empty(drop))

def strip_external_alias_kind(+js: String, +pair: String, +external: String, hit: Bool) -> String:
  match hit:
    case True{}:
      str_replace(0n, js, "const " ++ Compiler.default_import_name(pair) ++ " = " ++ Compiler.default_import_binding(pair) ++ ";\n", "", False{}, False{})
    case False{}:
      js

@unsafe def strip_external_aliases_go(+pairs: List<&2, String>, +external: String, +js: String) -> String:
  match pairs:
    case Nil{}:
      js
    case Con{+pair, rest}:
      +hit : Bool = external_spec(external, Compiler.default_import_path(pair))
      strip_external_aliases_go(rest, external, strip_external_alias_kind(js, pair, external, hit))

def strip_external_aliases_kind(+src: String, +external: String, +js: String, empty: Bool) -> String:
  match empty:
    case True{}:
      js
    case False{}:
      strip_external_aliases_go(Compiler.default_imports_of(src), external, js)

def strip_external_aliases(+src: String, +external: String, +js: String) -> String:
  strip_external_aliases_kind(src, external, js, String.is_empty(external))

def lower_default_tail(+js: String) -> String:
  +semi : String = str_replace(0n, js, ";\ndefault ", ";\nconst __knot_default_value = ", False{}, False{})
  +line : String = str_replace(0n, semi, "\ndefault ", "\nconst __knot_default_value = ", False{}, False{})
  str_replace(0n, line, "} const ", "}; const ", False{}, False{})

def lower_default_head(+js: String, start: Bool) -> String:
  match start:
    case True{}:
      lower_default_tail(str_replace(0n, js, "default ", "const __knot_default_value = ", False{}, False{}))
    case False{}:
      lower_default_tail(js)

def lower_default_body(+js: String) -> String:
  lower_default_head(js, String.starts_with(js, "default "))




def sourcemap_mode_kind(+marker: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "none"
    case False{}:
      marker

def sourcemap_mode(+marker: String) -> String:
  sourcemap_mode_kind(marker, String.is_empty(marker))
def manifest_source_map_value(+path: String, +mode: String) -> String:
  match mode:
    case "inline":
      Compiler.json_str("inline")
    case "linked":
      Compiler.json_str(path ++ ".map")
    case "external":
      Compiler.json_str(path ++ ".map")
    case _:
      ""

def manifest_source_map_field(+path: String, +mode: String) -> String:
  match mode:
    case "none":
      ""
    case _:
      ",\"sourceMap\":" ++ manifest_source_map_value(path, mode)


def dyn_path_parts(xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      list_rev(acc)
    case Con{+h, rest}:
      match h:
        case "":
          dyn_path_parts(rest, acc)
        case ".":
          dyn_path_parts(rest, acc)
        case "..":
          match acc:
            case Nil{}:
              dyn_path_parts(rest, Con{"..", acc})
            case Con{"..", _}:
              dyn_path_parts(rest, Con{"..", acc})
            case Con{_, prev}:
              dyn_path_parts(rest, prev)
        case _:
          dyn_path_parts(rest, Con{h, acc})

def dyn_normal_path(+path: String) -> String:
  Compiler.join_slash(dyn_path_parts(String.split(path, '/'), Nil{}))

def dyn_source_path(+importer: String, +spec: String) -> String:
  dyn_normal_path(Compiler.join_rel(Compiler.dirname(importer), spec))

def dyn_js_entry(+file: String) -> Bool:
  Bool.or(String.ends_with(file, ".ts"), Bool.or(String.ends_with(file, ".tsx"), Bool.or(String.ends_with(file, ".js"), Bool.or(String.ends_with(file, ".jsx"), Bool.or(String.ends_with(file, ".mts"), String.ends_with(file, ".mjs"))))))

def entry_template_parts_cjs(+base: String, cjs: Bool) -> String & String:
  match cjs:
    case True{}:
      (String.take(base, Nat.sub(String.length(base), 4n)), "cjs")
    case False{}:
      (String.take(base, Nat.sub(String.length(base), 3n)), "js")

def entry_template_parts_js(+base: String, mjs: Bool) -> String & String:
  match mjs:
    case True{}:
      (String.take(base, Nat.sub(String.length(base), 4n)), "mjs")
    case False{}:
      entry_template_parts_cjs(base, String.ends_with(base, ".cjs"))

def entry_template_parts(+file: String, html: Bool) -> String & String:
  match html:
    case True{}:
      (String.take(Compiler.basename(file), Nat.sub(String.length(Compiler.basename(file)), 5n)), "html")
    case False{}:
      +base : String = Compiler.basename(Compiler.js_path(file))
      entry_template_parts_js(base, String.ends_with(base, ".mjs"))

def strip_root_kind(+file: String, +root: String, hit: Bool) -> String:
  match hit:
    case True{}:
      String.drop(file, Nat.add(String.length(root), 1n))
    case False{}:
      file
def strip_root(+file: String, +root: String) -> String:
  strip_root_kind(file, root, Bool.and(Bool.not(String.is_empty(root)), String.starts_with(file, root ++ "/")))
def entry_parent_kind(+parent: String, top: Bool) -> String:
  match top:
    case True{}:
      ""
    case False{}:
      parent ++ "/"
def entry_parent_dir(+file: String) -> String:
  +parent : String = Compiler.dirname(file)
  entry_parent_kind(parent, Bool.or(String.eq(parent, "."), String.is_empty(parent)))
def entry_name_ext_present(+name: String) -> Bool:
  Bool.or(String.ends_with(name, ".js"), Bool.or(String.ends_with(name, ".mjs"), Bool.or(String.ends_with(name, ".cjs"), String.ends_with(name, ".html"))))
def entry_template_finish(+name: String, +ext: String, keep: Bool) -> String:
  match keep:
    case True{}:
      name
    case False{}:
      name ++ "." ++ ext
def entry_template_with_ext(+template: String, +hash: String, +stem: String, ext_pair: String & String, +dir: String) -> String:
  (ext, ext_copy) = ext_pair
  +keep : Bool = Bool.or(String.contains(template, "[ext]"), entry_name_ext_present(template))
  +name0 : String = css_module_replace_go(0n, template, "[name]", stem, False{})
  +name1 : String = css_module_replace_go(0n, name0, "[ext]", ext, False{})
  +name2 : String = css_module_replace_go(0n, name1, "[hash]", hash, False{})
  +named : String = css_module_replace_go(0n, name2, "[dir]", dir, False{})
  entry_template_finish(named, ext_copy, keep)
def entry_template_name_kind(+template: String, +hash: String, parts: String & String, +dir: String) -> String:
  (stem, ext0) = parts
  entry_template_with_ext(template, hash, stem, str_dup(ext0), dir)
def entry_template_name_root(+file: String, +template: String, +hash: String, html: Bool, +root: String) -> String:
  entry_template_name_kind(template, hash, entry_template_parts(file, html), entry_parent_dir(strip_root(file, root)))
def entry_template_name(+file: String, +template: String, +hash: String, html: Bool) -> String:
  entry_template_name_root(file, template, hash, html, "")

def entry_template_hash_kind(+file: String, used: Bool) -> IO(String):
  match used:
    case True{}:
      asset_hash_prefix(file)
    case False{}:
      IO.pure(String, "")

def entry_template_hash(+file: String, +template: String) -> IO(String):
  entry_template_hash_kind(file, String.contains(template, "[hash]"))

def node_output_suffix_kind(cjs: Bool) -> String:
  match cjs:
    case True{}:
      ".cjs"
    case False{}:
      ".mjs"

def node_output_suffix(+format: String) -> String:
  node_output_suffix_kind(String.starts_with(format, "cjs"))

def node_output_stem(+path: String, long: Bool) -> String:
  match long:
    case True{}:
      String.take(path, Nat.sub(String.length(path), 4n))
    case False{}:
      String.take(path, Nat.sub(String.length(path), 3n))

def node_output_name_kind(+path: String, +format: String, automatic: Bool) -> String:
  match automatic:
    case True{}:
      node_output_stem(path, Bool.or(String.ends_with(path, ".mjs"), String.ends_with(path, ".cjs"))) ++ node_output_suffix(format)
    case False{}:
      path

def node_output_name(+path: String, +format: String, automatic: Bool) -> String:
  node_output_name_kind(path, format, Bool.and(automatic, Bool.and(String.eq(early_format_marker(format, "target"), "node"), Bool.or(String.ends_with(path, ".js"), Bool.or(String.ends_with(path, ".mjs"), String.ends_with(path, ".cjs"))))))

def dyn_entry_match(+source: String, +entry: String) -> Bool:
  +path : String = dyn_normal_path(entry)
  Bool.or(String.eq(source, path), Bool.or(
    Bool.and(String.ends_with(source, ".js"), String.eq(String.take(source, Compiler.nat_sub(String.length(source), 3n)) ++ ".ts", path)),
    Bool.and(String.ends_with(source, ".jsx"), String.eq(String.take(source, Compiler.nat_sub(String.length(source), 4n)) ++ ".tsx", path))))

@unsafe def dyn_entry_find_go(sel: Nat, +source: String, entries: List<&2, String>, +entry: String, rest: List<&2, String>, found: Bool) -> String:
  match sel:
    case 0n:
      match entries:
        case Nil{}:
          ""
        case Con{+h, tail}:
          dyn_entry_find_go(1n, source, Nil{}, h, tail, dyn_entry_match(source, h))
    case _:
      match found:
        case True{}:
          entry
        case False{}:
          dyn_entry_find_go(0n, source, rest, "", Nil{}, False{})

def dyn_entry_find(+source: String, entries: List<&2, String>) -> String:
  dyn_entry_find_go(0n, source, entries, "", Nil{}, False{})

def dyn_relative_rest(dirs: List<&2, String>, target: List<&2, String>) -> String:
  match dirs:
    case Nil{}:
      "./" ++ Compiler.join_slash(target)
    case Con{_, rest}:
      "../" ++ dyn_relative_rest(rest, target)

@unsafe def dyn_relative_parts_go(sel: Nat, dirs: List<&2, String>, target: List<&2, String>, same: Bool) -> String:
  match sel:
    case 0n:
      match dirs target:
        case Con{+a, ar} Con{+b, br}:
          dyn_relative_parts_go(1n, Con{a, ar}, Con{b, br}, String.eq(a, b))
        case _ _:
          dyn_relative_rest(dirs, target)
    case 1n:
      match same:
        case True{}:
          dyn_relative_parts_go(2n, dirs, target, False{})
        case False{}:
          dyn_relative_rest(dirs, target)
    case _:
      match dirs target:
        case Con{_, ar} Con{_, br}:
          dyn_relative_parts_go(0n, ar, br, False{})
        case _ _:
          dyn_relative_rest(dirs, target)

def dyn_relative_parts(dirs: List<&2, String>, target: List<&2, String>) -> String:
  dyn_relative_parts_go(0n, dirs, target, False{})

def dyn_output_relative(+from: String, +to: String) -> String:
  dyn_relative_parts(dyn_path_parts(String.split(Compiler.dirname(from), '/'), Nil{}), dyn_path_parts(String.split(to, '/'), Nil{}))

def dyn_external_path(+spec: String) -> Bool:
  Bool.or(String.starts_with(spec, "./"), String.starts_with(spec, "../"))

def dyn_external_hit(+importer: String, +spec: String, +format: String) -> Bool:
  Bool.and(dyn_external_path(spec), Bool.or(external_spec(external_marker(format), spec), external_spec(external_marker(format), dyn_source_path(importer, spec))))

def dyn_external_valid_kind(+entry: String, +output: String, valid: Bool) -> IO(String):
  match valid:
    case True{}:
      IO.pure(String, output)
    case False{}:
      IO.die(String, 2, "knot: incompatible external dynamic entry " ++ entry ++ " (external_format)")

def dyn_external_valid(+entry: String, +output: String, +format: String) -> IO(String):
  dyn_external_valid_kind(entry, output, Bool.and(dyn_js_entry(entry), Bool.and(Bool.or(String.ends_with(output, ".js"), String.ends_with(output, ".mjs")), Bool.or(String.eq(format, "esm"), String.starts_with(format, "esm;")))))

def dyn_external_entry_kind(+entry: String, +spec: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.die(String, 2, "knot: external dynamic target is not an entry " ++ spec ++ " (external_format)")
    case False{}:
      IO.pure(String, entry)

def dyn_external_entry(+importer: String, +spec: String, entries: List<&2, String>) -> IO(String):
  +entry : String = dyn_entry_find(dyn_source_path(importer, spec), entries)
  dyn_external_entry_kind(entry, spec, String.is_empty(entry))

def dyn_external_distinct(+entry: String, +path: String, +importer_path: String, +format: String, same: Bool) -> IO(String & String):
  match same:
    case True{}:
      IO.die(String & String, 2, "knot: external dynamic entry collides with importer output " ++ entry ++ " (external_format)")
    case False{}:
      do IO<String & String>:
        +output : String <- dyn_external_valid(entry, path, format)
        return (entry, output)

def dyn_entry_output_kind(+file: String, +outdir: String, +format: String, +template: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, node_output_name(Compiler.join_rel(outdir, Compiler.basename(Compiler.js_path(file))), format, True{}))
    case False{}:
      do IO<String>:
        +hash : String <- entry_template_hash(file, template)
        +named : String = entry_template_name_root(file, template, hash, False{}, early_format_marker(format, "root"))
        return node_output_name(Compiler.join_rel(outdir, named), format, String.contains(template, "[ext]"))

def dyn_entry_output(+file: String, +outdir: String, +format: String) -> IO(String):
  +template : String = early_format_marker(format, "entry-names")
  dyn_entry_output_kind(file, outdir, format, template, String.is_empty(template))

def dyn_external_present(+entry: String, +importer: String, +outdir: String, +format: String, exists: Bool) -> IO(String & String):
  match exists:
    case False{}:
      IO.die(String & String, 2, "knot: missing external dynamic entry " ++ entry ++ " (external_format)")
    case True{}:
      do IO<String & String>:
        +path : String <- dyn_entry_output(entry, outdir, format)
        +importer_path : String <- dyn_entry_output(importer, outdir, format)
        dyn_external_distinct(entry, path, importer_path, format, String.eq(path, importer_path))

def dyn_external_root_kind(+importer: String, +out: String, +format: String, +template: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, Compiler.dirname(out))
    case False{}:
      do IO<String>:
        +hash : String <- entry_template_hash(importer, template)
        +named : String = entry_template_name_root(importer, template, hash, False{}, early_format_marker(format, "root"))
        +actual : String = node_output_name(named, format, String.contains(template, "[ext]"))
        return String.take(out, Nat.sub(String.length(out), Nat.add(String.length(actual), 1n)))

def dyn_external_root(+importer: String, +out: String, +format: String) -> IO(String):
  +template : String = early_format_marker(format, "entry-names")
  dyn_external_root_kind(importer, out, format, template, String.is_empty(template))

def dyn_external_output(+importer: String, +spec: String, entries: List<&2, String>, +out: String, +format: String) -> IO(String & String):
  do IO<String & String>:
    +entry : String <- dyn_external_entry(importer, spec, entries)
    exists : Bool <- file_exists(entry)
    +outdir : String <- dyn_external_root(importer, out, format)
    dyn_external_present(entry, importer, outdir, format, exists)

def dyn_runtime_spec_kind(+spec: String, ts: Bool) -> String:
  match ts:
    case True{}:
      String.take(spec, Compiler.nat_sub(String.length(spec), 3n)) ++ ".js"
    case False{}:
      spec

def dyn_runtime_spec(+spec: String) -> String:
  dyn_runtime_spec_kind(spec, String.ends_with(spec, ".ts"))

def dyn_entries_kind(+marker: String, found: Bool) -> List<&2, String>:
  match found:
    case True{}:
      String.lines(marker)
    case False{}:
      Nil{}

def dyn_entries(+format: String) -> List<&2, String>:
  +marker : String = take_until_semicolon(drop_until_key(format, ";entry-roots="), "")
  dyn_entries_kind(marker, String.contains(format, ";entry-roots="))

def dyn_public_ref_kind(+public: String, +name: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "./" ++ name
    case False{}:
      asset_public_url(public, name)

def dyn_public_ref(+public: String, +name: String) -> String:
  dyn_public_ref_kind(public, name, String.is_empty(public))

def dyn_old_rel(rel: Bool, +spec: String) -> String:
  match rel:
    case True{}:
      "./" ++ Compiler.basename(Compiler.js_path(String.drop(spec, 2n)))
    case False{}:
      Compiler.basename(Compiler.js_path(spec))

def dyn_old(+spec: String) -> String:
  dyn_old_rel(String.starts_with(spec, "./"), spec)

def dyn_chunk_name(+digest: String, +format: String) -> String:
  node_output_name(take_hash(0n, digest, 8n, "", 'a', False{}) ++ ".js", format, True{})

def emit_dyn_one(+importer: String, +outdir: String, +spec: String, +sm: String, +format: String) -> IO(String):
  do IO<String>:
    +path : String <- resolve_open(importer, spec)
    raw : String <- read_text(path)
    src : String <- ts_prep(path, raw)
    js : String <- bundle_js(path, Compiler.transpile(path, src))
    +got : String <- IO.try(String, Hash.sha256_b64(path))
    +name : String = dyn_chunk_name(got, format)
    u : Unit <- transpile_ok_to(Compiler.join_rel(outdir, name), js, Compiler.make_map(path, Nil{}), sm)
    return name

def emit_dyn_external_rewrite(+out: String, +spec: String, target: String & String) -> IO(Unit):
  (entry, output) = target
  do IO<Unit>:
    js : String <- read_text(out)
    write_text_atomic(out, str_replace(0n, js, dyn_runtime_spec(spec), dyn_output_relative(out, output), False{}, False{}))

def emit_dyn_go_kind(+importer: String, +out: String, +spec: String, +public: String, +sm: String, +format: String, external: Bool) -> IO(Unit):
  match external:
    case True{}:
      do IO<Unit>:
        target : String & String <- dyn_external_output(importer, spec, dyn_entries(format), out, format)
        emit_dyn_external_rewrite(out, spec, target)
    case False{}:
      do IO<Unit>:
        +name : String <- emit_dyn_one(importer, Compiler.dirname(out), spec, sm, format)
        js : String <- read_text(out)
        write_text_atomic(out, str_replace(0n, js, dyn_old(spec), dyn_public_ref(public, name), False{}, False{}))

def emit_dyn_go(+importer: String, +out: String, +spec: String, +public: String, +sm: String, +format: String) -> IO(Unit):
  emit_dyn_go_kind(importer, out, spec, public, sm, format, dyn_external_hit(importer, spec, format))

def emit_dyn(+importer: String, +out: String, specs: List<&2, String>, +public: String, +sm: String, +format: String) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- emit_dyn_go(importer, out, spec, public, sm, format)
        emit_dyn(importer, out, rest, public, sm, format)


def emit_req_one(+importer: String, +outdir: String, +spec: String, +sm: String) -> IO(Unit):
  do IO<Unit>:
    +path : String <- resolve_open(importer, spec)
    raw : String <- read_text(path)
    src : String <- ts_prep(path, raw)
    js : String <- bundle_js(path, Compiler.transpile(path, src))
    transpile_ok_to(Compiler.join_rel(outdir, Compiler.basename(Compiler.js_path(path))), js, Compiler.make_map(path, Nil{}), sm)

def emit_req(+importer: String, +out: String, specs: List<&2, String>, +sm: String) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- emit_req_one(importer, Compiler.dirname(out), spec, sm)
        emit_req(importer, out, rest, sm)

def bundle_preflight_one(+importer: String, +spec: String) -> IO(Unit):
  do IO<Unit>:
    +path : String <- resolve_open(importer, spec)
    raw : String <- read_text(path)
    src : String <- ts_prep(path, raw)
    validated : String <- bundle_js(path, Compiler.transpile(path, src))
    IO.pure(Unit, Unit{})

def bundle_preflight_dyn_kind(+importer: String, +spec: String, +out: String, +format: String, external: Bool) -> IO(Unit):
  match external:
    case True{}:
      do IO<Unit>:
        target : String & String <- dyn_external_output(importer, spec, dyn_entries(format), out, format)
        return Unit{}
    case False{}:
      bundle_preflight_one(importer, spec)

def bundle_preflight_dyn_one(+importer: String, +spec: String, +out: String, +format: String) -> IO(Unit):
  bundle_preflight_dyn_kind(importer, spec, out, format, dyn_external_hit(importer, spec, format))

def bundle_preflight_dyn(+importer: String, specs: List<&2, String>, +out: String, +format: String) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- bundle_preflight_dyn_one(importer, spec, out, format)
        bundle_preflight_dyn(importer, rest, out, format)

def bundle_preflight_specs(+importer: String, specs: List<&2, String>) -> IO(Unit):
  match specs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+spec, rest}:
      do IO<Unit>:
        u : Unit <- bundle_preflight_one(importer, spec)
        bundle_preflight_specs(importer, rest)

def bundle_preflight(+file: String, +src: String, +out: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- bundle_preflight_dyn(file, Compiler.dyn_imports_of(src), out, format)
    bundle_preflight_specs(file, Compiler.requires_of(src))


def graph_js_file(+file: String) -> Bool:
  Bool.or(String.ends_with(file, ".ts"), Bool.or(String.ends_with(file, ".tsx"), Bool.or(String.ends_with(file, ".js"), Bool.or(String.ends_with(file, ".jsx"), Bool.or(String.ends_with(file, ".mjs"), String.ends_with(file, ".cjs"))))))
def graph_dyn_join(+edge: String, +more: String, edge_empty: Bool, more_empty: Bool) -> String:
  match edge_empty:
    case True{}:
      more
    case False{}:
      match more_empty:
        case True{}:
          edge
        case False{}:
          edge ++ "," ++ more
@unsafe def graph_dyn_emit(sel: Nat, files: List<&2, String>, +out: String, +public: String, +sm: String, +format: String, +file: String, js: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{+f, rest}:
          graph_dyn_emit(1n, rest, out, public, sm, format, f, graph_js_file(f))
    case _:
      match js:
        case False{}:
          graph_dyn_emit(0n, files, out, public, sm, format, "", False{})
        case True{}:
          do IO<Unit>:
            raw : String <- read_text(file)
            u : Unit <- emit_dyn(file, out, Compiler.dyn_imports_of(raw), public, sm, format)
            graph_dyn_emit(0n, files, out, public, sm, format, "", False{})

def bundle_write_dyn(+file: String, +out: String, +src: String, +public: String, +sm: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    u : Unit <- emit_dyn(file, out, Compiler.dyn_imports_of(src), public, sm, format)
    emit_req(file, out, Compiler.requires_of(src), sm)

def meta_input_one(+f: String) -> IO(String):
  do IO<String>:
    src : String <- read_text(f)
    +digest : String <- IO.try(String, Hash.sha256_b64(f))
    return Compiler.json_str(f) ++ ":{\"bytes\":" ++ Nat.show(String.length(src)) ++ ",\"digest\":" ++ Compiler.json_str(digest) ++ "}"

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

def meta_css_field(+out: String, +css: String, empty: Bool, +mode: String) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      ",\"css\":" ++ Compiler.json_str(css_path(out)) ++ manifest_source_map_field(css_path(out), mode)

def removed_piece(+file: String, +name: String) -> String:
  "{\"file\":" ++ Compiler.json_str(file) ++ ",\"name\":" ++ Compiler.json_str(name) ++ ",\"reason\":\"unused-export\"}"
def removed_cat_kind(+acc: String, +piece: String, piece_empty: Bool, acc_empty: Bool) -> String:
  match piece_empty:
    case True{}:
      acc
    case False{}:
      match acc_empty:
        case True{}:
          piece
        case False{}:
          acc ++ "," ++ piece
def removed_cat(+acc: String, +piece: String) -> String:
  removed_cat_kind(acc, piece, String.is_empty(piece), String.is_empty(acc))
@unsafe def removed_join(sel: Nat, names: List<&2, String>, +keep: String, +file: String, +acc: String, +name: String, hit: Bool, empty: Bool) -> String:
  match sel:
    case 0n:
      match names:
        case Nil{}:
          acc
        case Con{+h, t}:
          removed_join(1n, t, keep, file, acc, h, String.contains(keep, "\n" ++ h ++ "\n"), String.is_empty(acc))
    case _:
      match hit:
        case True{}:
          removed_join(0n, names, keep, file, acc, "", False{}, False{})
        case False{}:
          removed_join(0n, names, keep, file, removed_cat_kind(acc, removed_piece(file, name), False{}, empty), "", False{}, False{})
def removed_names(names: List<&2, String>, +keep: String, +file: String) -> String:
  removed_join(0n, names, keep, file, "", "", False{}, True{})
def removed_is_code(+file: String) -> Bool:
  Bool.or(String.ends_with(file, ".ts"), Bool.or(String.ends_with(file, ".tsx"), Bool.or(String.ends_with(file, ".js"), Bool.or(String.ends_with(file, ".jsx"), Bool.or(String.ends_with(file, ".mjs"), String.ends_with(file, ".cjs"))))))
def removed_skip(+file: String, +entry: String) -> Bool:
  Bool.or(String.eq(file, entry), Bool.not(removed_is_code(file)))
def keep_text(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      "\n"
    case Con{+h, t}:
      "\n" ++ h ++ keep_text(t)
def paths_encode(files: List<&2, String>) -> String:
  match files:
    case Nil{}:
      ""
    case Con{+h, Nil{}}:
      h
    case Con{+h, t}:
      h ++ "\n" ++ paths_encode(t)
def removed_of_file(+file: String, +keep: String, skip: Bool) -> IO(String):
  match skip:
    case True{}:
      IO.pure(String, "")
    case False{}:
      do IO<String>:
        raw : String <- read_text(file)
        src : String <- normalize_source(raw)
        return removed_names(Compiler.exports_of(src), keep, file)
def removed_files_go(files: List<&2, String>, +keep: String, +entry: String) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, rest}:
      do IO<String>:
        piece : String <- removed_of_file(f, keep, removed_skip(f, entry))
        more : String <- removed_files_go(rest, keep, entry)
        return removed_cat(piece, more)
def meta_removed(+encoded: String, +entry: String) -> IO(String):
  do IO<String>:
    keep : List<&2, String> <- collect_keep(String.lines(encoded))
    body : String <- removed_files_go(String.lines(encoded), keep_text(keep), entry)
    return ",\"removed\":[" ++ body ++ "]"

@unsafe def find_go(sel: Nat, +src: String, +needle: String, +i: Nat, hit: Bool, fuel: Nat) -> Nat:
  match sel:
    case 0n:
      match fuel:
        case 0n:
          0n
        case 1n+n:
          find_go(1n, src, needle, i, String.starts_with(String.drop(src, i), needle), n)
    case _:
      match hit:
        case True{}:
          i
        case False{}:
          find_go(0n, src, needle, Nat.add(i, 1n), False{}, fuel)
def find_index(+src: String, +needle: String) -> Nat:
  find_go(0n, src, needle, 0n, False{}, Nat.add(String.length(src), 1n))
def find_hit(+src: String, +needle: String, +i: Nat) -> Bool:
  String.starts_with(String.drop(src, i), needle)
def import_record_kind(+spec: String, +start: Nat, +end: Nat, hit: Bool) -> String:
  match hit:
    case True{}:
      "{\"specifier\":" ++ Compiler.json_str(spec) ++ ",\"start\":" ++ Nat.show(start) ++ ",\"end\":" ++ Nat.show(end) ++ "}"
    case False{}:
      ""
def import_record_quoted(+spec: String, +src: String, +quoted: String) -> String:
  +i : Nat = find_index(src, quoted)
  import_record_kind(spec, i, Nat.add(i, String.length(quoted)), find_hit(src, quoted, i))
def import_record_single(+spec: String, +src: String) -> String:
  import_record_quoted(spec, src, "'" ++ spec ++ "'")
def import_record_pick(+double: String, +spec: String, +src: String, empty: Bool) -> String:
  match empty:
    case True{}:
      import_record_single(spec, src)
    case False{}:
      double
def import_record(+spec: String, +src: String) -> String:
  import_record_pick(import_record_quoted(spec, src, "\"" ++ spec ++ "\""), spec, src, String.is_empty(import_record_quoted(spec, src, "\"" ++ spec ++ "\"")))
def import_records_go(specs: List<&2, String>, +src: String) -> String:
  match specs:
    case Nil{}:
      ""
    case Con{+h, t}:
      removed_cat(import_record(h, src), import_records_go(t, src))

def export_bool(kept: Bool) -> String:
  match kept:
    case True{}:
      "true"
    case False{}:
      "false"
def export_start_or(+src: String, +name: String, +prefix: String, +next: Nat, miss: Bool) -> Nat:
  match miss:
    case True{}:
      next
    case False{}:
      Nat.add(find_index(src, prefix ++ name), String.length(prefix))
def export_start(+src: String, +name: String) -> Nat:
  export_start_or(src, name, "function ", export_start_or(src, name, "const ", export_start_or(src, name, "let ", export_start_or(src, name, "class ", export_start_or(src, name, "var ", 0n, Bool.not(String.contains(src, "var " ++ name))), Bool.not(String.contains(src, "class " ++ name))), Bool.not(String.contains(src, "let " ++ name))), Bool.not(String.contains(src, "const " ++ name))), Bool.not(String.contains(src, "function " ++ name)))
def export_piece(+file: String, +name: String, +src: String, +keep: String) -> String:
  +start : Nat = export_start(src, name)
  "{\"file\":" ++ Compiler.json_str(file) ++ ",\"name\":" ++ Compiler.json_str(name) ++ ",\"start\":" ++ Nat.show(start) ++ ",\"end\":" ++ Nat.show(Nat.add(start, String.length(name))) ++ ",\"kept\":" ++ export_bool(String.contains(keep, "\n" ++ name ++ "\n")) ++ "}"
def export_names_go(names: List<&2, String>, +file: String, +src: String, +keep: String) -> String:
  match names:
    case Nil{}:
      ""
    case Con{+h, t}:
      removed_cat(export_piece(file, h, src, keep), export_names_go(t, file, src, keep))
def export_of_file(+file: String, +keep: String, skip: Bool) -> IO(String):
  match skip:
    case True{}:
      IO.pure(String, "")
    case False{}:
      do IO<String>:
        raw : String <- read_text(file)
        src : String <- normalize_source(raw)
        names : List<&2, String> = Compiler.exports_of(src)
        raw2 : String <- read_text(file)
        src2 : String <- normalize_source(raw2)
        return export_names_go(names, file, src2, keep)
def export_files_go(files: List<&2, String>, +keep: String, +entry: String) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+f, rest}:
      do IO<String>:
        piece : String <- export_of_file(f, keep, removed_skip(f, entry))
        more : String <- export_files_go(rest, keep, entry)
        return removed_cat(piece, more)
def meta_exports(+encoded: String, +entry: String) -> IO(String):
  do IO<String>:
    keep : List<&2, String> <- collect_keep(String.lines(encoded))
    body : String <- export_files_go(String.lines(encoded), keep_text(keep), entry)
    return ",\"exports\":[" ++ body ++ "]"
def css_record(+spec: String, +src: String, css: Bool) -> String:
  match css:
    case True{}:
      import_record(spec, src)
    case False{}:
      ""
def css_records_go(specs: List<&2, String>, +src: String) -> String:
  match specs:
    case Nil{}:
      ""
    case Con{+h, t}:
      removed_cat(css_record(h, src, String.ends_with(h, ".css")), css_records_go(t, src))

def meta_write_none(none: Bool, +meta: String, +file: String, +out: String, +src: String, +js: String, +css: String, files: List<&2, String>, +mode: String) -> IO(Unit):
  match none:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        +encoded : String = paths_encode(files)
        inputs : String <- meta_inputs_go(String.lines(encoded))
        +digest : String <- IO.try(String, Hash.sha256_b64(out))
        +removed : String <- meta_removed(encoded, file)
        +exports : String <- meta_exports(encoded, file)
        +output : String = Compiler.json_str(out) ++ ":{\"kind\":\"js\",\"bytes\":" ++ Nat.show(String.length(js)) ++ ",\"digest\":" ++ Compiler.json_str(digest) ++ ",\"entry\":" ++ Compiler.json_str(file) ++ ",\"imports\":" ++ Compiler.json_list(Compiler.imports_of(src)) ++ ",\"importRecords\":[" ++ import_records_go(Compiler.imports_of(src), src) ++ "],\"cssRecords\":[" ++ css_records_go(Compiler.imports_of(src), src) ++ "],\"exports\":" ++ Compiler.json_list(Compiler.exports_of(src)) ++ meta_css_field(out, css, String.is_empty(css), mode) ++ manifest_source_map_field(out, mode) ++ "}"
        +body : String = "{\"inputs\":{" ++ inputs ++ "},\"outputs\":{" ++ output ++ "}" ++ removed ++ exports ++ "}"
        write_text_atomic(meta, body)

def manifest_css_kind(+out: String, +css: String, +digest: String, empty: Bool, +mode: String) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      ",\"" ++ css_path(out) ++ "\":{\"bytes\":" ++ Nat.show(String.length(css)) ++ ",\"kind\":\"css\",\"digest\":" ++ Compiler.json_str(digest) ++ manifest_source_map_field(css_path(out), mode) ++ "}"

def manifest_css(+out: String, +css: String, empty: Bool, +mode: String) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      do IO<String>:
        +digest : String <- IO.try(String, Hash.sha256_b64(css_path(out)))
        return manifest_css_kind(out, css, digest, False{}, mode)
@unsafe def manifest_dyn_go(sel: Nat, +importer: String, +outdir: String, specs: List<&2, String>, +spec: String, +mode: String, +format: String, external: Bool) -> IO(String):
  match sel:
    case 0n:
      match specs:
        case Nil{}:
          IO.pure(String, "")
        case Con{+h, tail}:
          manifest_dyn_go(1n, importer, outdir, tail, h, mode, format, dyn_external_hit(importer, h, format))
    case _:
      match external:
        case True{}:
          manifest_dyn_go(0n, importer, outdir, specs, "", mode, format, False{})
        case False{}:
          do IO<String>:
            +path : String <- resolve_open(importer, spec)
            +got : String <- IO.try(String, Hash.sha256_b64(path))
            +name : String = dyn_chunk_name(got, format)
            +chunk_path : String = Compiler.join_rel(outdir, name)
            +chunk : String <- read_text(chunk_path)
            +digest : String <- IO.try(String, Hash.sha256_b64(chunk_path))
            +more : String <- manifest_dyn_go(0n, importer, outdir, specs, "", mode, format, False{})
            return "," ++ Compiler.json_str(name) ++ ":{\"bytes\":" ++ Nat.show(String.length(chunk)) ++ ",\"kind\":\"dynamic\",\"digest\":" ++ Compiler.json_str(digest) ++ manifest_source_map_field(name, mode) ++ "}" ++ more

def manifest_dyn(+importer: String, +outdir: String, specs: List<&2, String>, +mode: String, +format: String) -> IO(String):
  manifest_dyn_go(0n, importer, outdir, specs, "", mode, format, False{})

def dyn_external_public_kind(+from: String, +to: String, +public: String, empty: Bool) -> String:
  match empty:
    case True{}:
      dyn_output_relative(from, to)
    case False{}:
      asset_public_url(public, Compiler.basename(to))

def dyn_external_public(+from: String, +to: String, +format: String) -> String:
  +public : String = early_format_marker(format, "public")
  dyn_external_public_kind(from, to, public, String.is_empty(public))

def manifest_external_edge_fields(+importer: String, +out: String, +spec: String, +format: String, +entry: String, +output: String) -> String:
  "{\"importer\":" ++ Compiler.json_str(Compiler.basename(importer)) ++ ",\"source\":" ++ Compiler.json_str(spec) ++ ",\"resolved\":" ++ Compiler.json_str(Compiler.basename(entry)) ++ ",\"output\":" ++ Compiler.json_str(output) ++ ",\"publicUrl\":" ++ Compiler.json_str(dyn_external_public(out, output, format)) ++ ",\"lazy\":true,\"targetKind\":\"external-entry\"}"

def manifest_external_edge_json(+importer: String, +out: String, +spec: String, +format: String, target: String & String) -> String:
  (entry, output) = target
  manifest_external_edge_fields(importer, out, spec, format, entry, output)

def dyn_range_kind(+start: Nat, +end: Nat, hit: Bool) -> String:
  match hit:
    case True{}:
      ",\"range\":[" ++ Nat.show(start) ++ "," ++ Nat.show(end) ++ "]"
    case False{}:
      ""
def dyn_range_quoted(+src: String, +quoted: String) -> String:
  +start : Nat = find_index(src, quoted)
  dyn_range_kind(start, Nat.add(start, String.length(quoted)), find_hit(src, quoted, start))
def dyn_range_pick(+double: String, +src: String, +spec: String, empty: Bool) -> String:
  match empty:
    case True{}:
      dyn_range_quoted(src, "'" ++ spec ++ "'")
    case False{}:
      double
def dyn_range_json(+src: String, +spec: String) -> String:
  dyn_range_pick(dyn_range_quoted(src, "\"" ++ spec ++ "\""), src, spec, String.is_empty(dyn_range_quoted(src, "\"" ++ spec ++ "\"")))
def dyn_range_of(+importer: String, +spec: String) -> IO(String):
  do IO<String>:
    raw : String <- read_text(importer)
    return dyn_range_json(raw, spec)
def edge_with_range(+edge: String, +range: String) -> String:
  String.take(edge, Nat.sub(String.length(edge), 1n)) ++ range ++ "}"

def manifest_dynamic_edge_kind(+importer: String, +out: String, +spec: String, +format: String, external: Bool) -> IO(String):
  match external:
    case True{}:
      do IO<String>:
        target : String & String <- dyn_external_output(importer, spec, dyn_entries(format), out, format)
        +range : String <- dyn_range_of(importer, spec)
        return edge_with_range(manifest_external_edge_json(importer, out, spec, format, target), range)
    case False{}:
      do IO<String>:
        +path : String <- resolve_open(importer, spec)
        +got : String <- IO.try(String, Hash.sha256_b64(path))
        +name : String = dyn_chunk_name(got, format)
        +range : String <- dyn_range_of(importer, spec)
        return edge_with_range("{\"importer\":" ++ Compiler.json_str(Compiler.basename(importer)) ++ ",\"source\":" ++ Compiler.json_str(spec) ++ ",\"resolved\":" ++ Compiler.json_str(path) ++ ",\"output\":" ++ Compiler.json_str(name) ++ ",\"publicUrl\":" ++ Compiler.json_str(dyn_public_ref(early_format_marker(format, "public"), name)) ++ ",\"lazy\":true,\"targetKind\":\"lazy-chunk\"}", range)

def manifest_dynamic_edge(+importer: String, +out: String, +spec: String, +format: String) -> IO(String):
  manifest_dynamic_edge_kind(importer, out, spec, format, dyn_external_hit(importer, spec, format))

def manifest_dynamic_edges_join(+edge: String, +more: String, empty: Bool) -> String:
  match empty:
    case True{}:
      edge
    case False{}:
      edge ++ "," ++ more

def manifest_dynamic_edges(+importer: String, +out: String, specs: List<&2, String>, +format: String) -> IO(String):
  match specs:
    case Nil{}:
      IO.pure(String, "")
    case Con{+spec, rest}:
      do IO<String>:
        +edge : String <- manifest_dynamic_edge(importer, out, spec, format)
        +more : String <- manifest_dynamic_edges(importer, out, rest, format)
        return manifest_dynamic_edges_join(edge, more, String.is_empty(more))

def manifest_dynamic_imports(+importer: String, +out: String, specs: List<&2, String>, +format: String) -> IO(String):
  do IO<String>:
    +edges : String <- manifest_dynamic_edges(importer, out, specs, format)
    return ",\"dynamicImports\":[" ++ edges ++ "]"

@unsafe def graph_dyn_edges(sel: Nat, files: List<&2, String>, +out: String, +format: String, +file: String, js: Bool) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, "")
        case Con{+f, rest}:
          graph_dyn_edges(1n, rest, out, format, f, graph_js_file(f))
    case _:
      match js:
        case False{}:
          graph_dyn_edges(0n, files, out, format, "", False{})
        case True{}:
          do IO<String>:
            raw : String <- read_text(file)
            +edge : String <- manifest_dynamic_edges(file, out, Compiler.dyn_imports_of(raw), format)
            +more : String <- graph_dyn_edges(0n, files, out, format, "", False{})
            return graph_dyn_join(edge, more, String.is_empty(edge), String.is_empty(more))
@unsafe def graph_dyn_records(sel: Nat, files: List<&2, String>, +outdir: String, +mode: String, +format: String, +file: String, js: Bool) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, "")
        case Con{+f, rest}:
          graph_dyn_records(1n, rest, outdir, mode, format, f, graph_js_file(f))
    case _:
      match js:
        case False{}:
          graph_dyn_records(0n, files, outdir, mode, format, "", False{})
        case True{}:
          do IO<String>:
            raw : String <- read_text(file)
            +part : String <- manifest_dyn(file, outdir, Compiler.dyn_imports_of(raw), mode, format)
            +more : String <- graph_dyn_records(0n, files, outdir, mode, format, "", False{})
            return part ++ more
def graph_dynamic_imports(files: List<&2, String>, +out: String, +format: String) -> IO(String):
  do IO<String>:
    +edges : String <- graph_dyn_edges(0n, files, out, format, "", False{})
    return ",\"dynamicImports\":[" ++ edges ++ "]"

@unsafe def manifest_asset_go(sel: Nat, +files: List<&2, String>, +outdir: String, +file: String, asset: Bool, +template: String) -> IO(String):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String, "")
        case Con{+h, rest}:
          manifest_asset_go(1n, rest, outdir, h, is_asset_file(h), template)
    case _:
      match asset:
        case True{}:
          do IO<String>:
            +name : String <- asset_output_name(file, template)
            +digest : String <- IO.try(String, Hash.sha256_b64(file))
            +copy : String <- read_text(Compiler.join_rel(outdir, name))
            +more : String <- manifest_asset_go(0n, files, outdir, "", False{}, template)
            return ",\"" ++ name ++ "\":{\"bytes\":" ++ Nat.show(String.length(copy)) ++ ",\"kind\":\"asset\",\"digest\":" ++ Compiler.json_str(digest) ++ "}" ++ more
        case False{}:
          manifest_asset_go(0n, files, outdir, "", False{}, template)

def manifest_assets(+out: String, files: List<&2, String>, +template: String) -> IO(String):
  manifest_asset_go(0n, files, Compiler.dirname(out), "", False{}, template)

def manifest_write(+manifest: String, +file: String, +out: String, +src: String, +js: String, +css: String, +files: List<&2, String>, +template: String, +mode: String) -> IO(Unit):
  do IO<Unit>:
    +dynamic : String <- graph_dyn_records(0n, files, Compiler.dirname(out), mode, "esm", "", False{})
    +dynamic_edges : String <- graph_dynamic_imports(files, out, "esm")
    +assets : String <- manifest_assets(out, files, template)
    +css_output : String <- manifest_css(out, css, String.is_empty(css), mode)
    +output_digest : String <- IO.try(String, Hash.sha256_b64(out))
    +body : String = "{\"version\":1,\"entries\":{" ++ Compiler.json_str(Compiler.basename(file)) ++ ":" ++ Compiler.json_str(out) ++ "},\"outputs\":{" ++ Compiler.json_str(out) ++ ":{\"kind\":\"js\",\"bytes\":" ++ Nat.show(String.length(js)) ++ ",\"digest\":" ++ Compiler.json_str(output_digest) ++ ",\"entry\":" ++ Compiler.json_str(file) ++ dynamic_edges ++ manifest_source_map_field(out, mode) ++ "}" ++ css_output ++ assets ++ dynamic ++ "}}"
    write_text_atomic(manifest, body)

def meta_write_kind(+meta: String, +file: String, +out: String, +src: String, +js: String, +css: String, files: List<&2, String>, +template: String, manifest: Bool, +mode: String) -> IO(Unit):
  match manifest:
    case True{}:
      manifest_write(String.drop(meta, 9n), file, out, src, js, css, files, template, mode)
    case False{}:
      meta_write_none(String.is_empty(meta), meta, file, out, src, js, css, files, mode)

def meta_write(+meta: String, +file: String, +out: String, +src: String, +js: String, +css: String, files: List<&2, String>, +template: String, +mode: String) -> IO(Unit):
  meta_write_kind(meta, file, out, src, js, css, files, template, String.starts_with(meta, "manifest:"), mode)

def cjs_export_line(+name: String, default: Bool) -> String:
  match default:
    case True{}:
      "module.exports[\"default\"] = __knot_default_value;\n"
    case False{}:
      "module.exports[" ++ Compiler.json_str(name) ++ "] = " ++ name ++ ";\n"

def cjs_exports_go(names: List<&2, String>, +acc: String) -> String:
  match names:
    case Nil{}:
      acc
    case Con{+h, rest}:
      cjs_exports_go(rest, acc ++ cjs_export_line(h, String.eq(h, "default")))

def bundle_cjs(+src: String, +js: String) -> IO(String):
  names : List<&2, String> = Compiler.exports_of(src)
  +body0 : String = lower_default_body(js)
  +body : String = body0
  IO.pure(String, cjs_exports_go(names, "\"use strict\";\n" ++ body ++ "\n"))

def esm_export_line(+name: String, default: Bool) -> String:
  match default:
    case True{}:
      "export { __knot_default_value as default };\n"
    case False{}:
      "export { " ++ name ++ " };\n"

def esm_exports_go(names: List<&2, String>, +acc: String) -> String:
  match names:
    case Nil{}:
      acc
    case Con{+h, rest}:
      esm_exports_go(rest, acc ++ esm_export_line(h, String.eq(h, "default")))

def bundle_esm(+src: String, +js: String) -> IO(String):
  names : List<&2, String> = Compiler.exports_of(src)
  +body0 : String = lower_default_body(js)
  +body : String = body0
  IO.pure(String, esm_exports_go(names, body ++ "\n"))

def build_format_base_kind(+format: String, +tail: String, has_marker: Bool) -> String:
  match has_marker:
    case True{}:
      String.take(format, Nat.sub(String.length(format), Nat.add(String.length(tail), 1n)))
    case False{}:
      format

def build_format_base(+format: String) -> String:
  +tail : String = drop_until_key(format, ";")
  build_format_base_kind(format, tail, String.contains(format, ";"))

def build_format_marker_value(+tail: String, semicolon: Bool) -> String:
  match semicolon:
    case True{}:
      css_drop_last_char(css_take_until_char(tail, ';'))
    case False{}:
      tail

def build_format_marker_kind(+tail: String, found: Bool) -> String:
  match found:
    case True{}:
      build_format_marker_value(tail, String.contains(tail, ";"))
    case False{}:
      ""

def build_format_marker(+format: String, +key: String) -> String:
  +needle : String = ";" ++ key ++ "="
  +tail : String = drop_until_key(format, needle)
  build_format_marker_kind(tail, String.contains(format, needle))
def bundle_split_validate_kind(splitting: Bool, esm: Bool) -> IO(Unit):
  match splitting:
    case True{}:
      match esm:
        case True{}:
          IO.pure(Unit, Unit{})
        case False{}:
          IO.die(Unit, 2, "knot: --splitting requires --format esm (unsupported_split)")
    case False{}:
      IO.die(Unit, 2, "knot: dynamic imports require --splitting (unsupported_split)")

def bundle_split_validate_present(+format: String) -> IO(Unit):
  bundle_split_validate_kind(String.eq(build_format_marker(format, "splitting"), "true"), String.eq(build_format_base(format), "esm"))

def bundle_split_validate(+format: String, dyns: List<&2, String>, reqs: List<&2, String>) -> IO(Unit):
  match dyns:
    case Nil{}:
      match reqs:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{_, _}:
          bundle_split_validate_present(format)
    case Con{_, _}:
      bundle_split_validate_present(format)

def build_option_validate_empty_kind(+key: String, +value: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: --" ++ key ++ " is unsupported in this release (unsupported_option)")

def loader_supported(+loader: String) -> Bool:
  Bool.and(
    Bool.not(String.is_empty(loader)),
    Bool.and(
      Bool.not(String.is_empty(loader_extension(loader))),
      Bool.or(
        String.ends_with(loader, "=jsonc"),
        Bool.or(
          String.ends_with(loader, "=text"),
          Bool.or(
            String.ends_with(loader, "=json"),
            Bool.or(
              String.ends_with(loader, "=toml"),
              Bool.or(
                String.ends_with(loader, "=yaml"),
                Bool.or(
                  String.ends_with(loader, "=css"),
                  Bool.or(
                    String.ends_with(loader, "=file"),
                    Bool.or(
                      String.ends_with(loader, "=empty"),
                      Bool.or(
                        String.ends_with(loader, "=external"),
                        Bool.or(
                          String.ends_with(loader, "=js"),
                          Bool.or(
                            String.ends_with(loader, "=jsx"),
                            Bool.or(String.ends_with(loader, "=ts"), Bool.or(String.ends_with(loader, "=tsx"), String.ends_with(loader, "=html"))))))))))))))))
def loader_validate_kind(+loader: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: unsupported loader " ++ loader ++ " (unsupported_loader)")
def loader_validate(+format: String) -> IO(Unit):
  +loader : String = build_format_marker(format, "loader")
  loader_validate_kind(loader, Bool.or(String.is_empty(loader), loader_supported(loader)))
def option_enum_validate(+key: String, +value: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: invalid --" ++ key ++ " " ++ value ++ " (invalid_option)")
def digits_text_rest(s: String) -> Bool:
  match s:
    case SNil{}:
      True{}
    case SCon{h, t}:
      Bool.and(Char.is_digit(h), digits_text_rest(t))
def digits_text(s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{h, t}:
      Bool.and(Char.is_digit(h), digits_text_rest(t))
def preload_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "preload")
  option_enum_validate("preload", value, Bool.or(String.is_empty(value), Bool.or(String.eq(value, "none"), String.eq(value, "static"))))
def sources_content_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "sources-content")
  option_enum_validate("sources-content", value, Bool.or(String.is_empty(value), Bool.or(String.eq(value, "exclude"), String.eq(value, "include"))))
def naming_template_safe(+value: String) -> Bool:
  Bool.and(Bool.not(String.contains(value, "..")), Bool.and(Bool.not(String.starts_with(value, "/")), Bool.not(String.contains(value, "\\"))))
def css_naming_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "css-naming")
  option_enum_validate("css-naming", value, Bool.or(String.is_empty(value), naming_template_safe(value)))
def root_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "root")
  option_enum_validate("root", value, Bool.or(String.is_empty(value), naming_template_safe(value)))
def min_chunk_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "min-chunk-size")
  option_enum_validate("min-chunk-size", value, Bool.or(String.is_empty(value), digits_text(value)))
def flag_true_validate(+key: String, +value: String) -> IO(Unit):
  option_enum_validate(key, value, Bool.or(String.is_empty(value), String.eq(value, "true")))
def log_level_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "log-level")
  option_enum_validate("log-level", value, Bool.or(String.is_empty(value), Bool.or(String.eq(value, "silent"), Bool.or(String.eq(value, "error"), Bool.or(String.eq(value, "warning"), Bool.or(String.eq(value, "info"), String.eq(value, "debug")))))))
def diagnostics_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "diagnostics")
  option_enum_validate("diagnostics", value, Bool.or(String.is_empty(value), Bool.or(String.eq(value, "text"), String.eq(value, "json"))))
def tsconfig_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "tsconfig-raw")
  +other : String = build_format_marker(format, "tsconfig")
  option_enum_validate("tsconfig", value, Bool.and(Bool.or(String.is_empty(value), naming_template_safe(value)), Bool.or(String.is_empty(other), naming_template_safe(other))))
def ignore_annotations_validate_kind(+value: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: invalid --ignore-side-effects-annotations " ++ value ++ " (invalid_option)")
def ignore_annotations_validate(+value: String) -> IO(Unit):
  ignore_annotations_validate_kind(value, Bool.or(String.is_empty(value), Bool.or(String.eq(value, "true"), String.eq(value, "false"))))
def build_write_mode_validate_kind(valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: --write must be true or false (invalid_option)")
def build_write_mode_validate(+format: String) -> IO(Unit):
  +value : String = build_format_marker(format, "write")
  build_write_mode_validate_kind(Bool.or(String.is_empty(value), Bool.or(String.eq(value, "true"), String.eq(value, "false"))))
def build_profile_repeat_validate(conflict: Bool) -> IO(Unit):
  match conflict:
    case True{}:
      IO.die(Unit, 2, "knot: conflicting --profile options (duplicate_option)")
    case False{}:
      IO.pure(Unit, Unit{})
def data_limit_validate(+key: String, +value: String) -> IO(Unit):
  option_enum_validate(key, value, Bool.or(String.is_empty(value), Bool.and(digits_text(value), Bool.not(String.eq(value, "0")))))
def build_options_validate(+format: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- loader_validate(format)
    u1 : Unit <- sources_content_validate(format)
    u1b : Unit <- preload_validate(format)
    u2 : Unit <- css_naming_validate(format)
    u3 : Unit <- root_validate(format)
    u4 : Unit <- min_chunk_validate(format)
    u5 : Unit <- flag_true_validate("clear-on-error", build_format_marker(format, "clear-on-error"))
    u6 : Unit <- ignore_annotations_validate(build_format_marker(format, "ignore-side-effects-annotations"))
    u7 : Unit <- log_level_validate(format)
    u8 : Unit <- diagnostics_validate(format)
    u9 : Unit <- option_enum_validate("packages", build_format_marker(format, "packages"), Bool.or(String.is_empty(build_format_marker(format, "packages")), Bool.or(String.eq(build_format_marker(format, "packages"), "bundle"), String.eq(build_format_marker(format, "packages"), "external"))))
    u10 : Unit <- flag_true_validate("gpu", build_format_marker(format, "gpu"))
    u11 : Unit <- build_option_validate_empty_kind("platform", build_format_marker(format, "platform"), String.is_empty(build_format_marker(format, "platform")))
    u12 : Unit <- tsconfig_validate(format)
    u13 : Unit <- data_limit_validate("data-depth", build_format_marker(format, "data-depth"))
    u14 : Unit <- data_limit_validate("data-nodes", build_format_marker(format, "data-nodes"))
    u15 : Unit <- build_write_mode_validate(format)
    build_profile_repeat_validate(String.contains(format, ";profile-conflict=true"))

def splitting_output_dir_kind(empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.die(Unit, 2, "knot: --splitting requires --outdir (unsupported_split)")
    case False{}:
      IO.pure(Unit, Unit{})

def splitting_output_validate_kind(splitting: Bool, +outdir: String) -> IO(Unit):
  match splitting:
    case True{}:
      splitting_output_dir_kind(String.is_empty(outdir))
    case False{}:
      IO.pure(Unit, Unit{})

def splitting_output_validate(+format: String, +outdir: String) -> IO(Unit):
  splitting_output_validate_kind(String.eq(build_format_marker(format, "splitting"), "true"), outdir)

def build_minify_enabled(+format: String) -> Bool:
  Bool.or(
    String.eq(build_format_marker(format, "minify"), "true"),
    Bool.or(String.eq(build_format_marker(format, "minify-syntax"), "true"), String.eq(build_format_marker(format, "minify-whitespace"), "true")))

def build_format_apply_other(+format: String, +val: String, +which: String) -> String:
  format ++ ";" ++ which ++ "=" ++ val

def build_format_apply_flag_kind(+format: String, +val: String, +which: String, is_format: Bool) -> String:
  match is_format:
    case True{}:
      val ++ String.drop(format, String.length(build_format_base(format))) ++ ";format-explicit=true"
    case False{}:
      build_format_apply_other(format, val, which)

def build_format_apply_flag(+format: String, +val: String, +which: String) -> String:
  build_format_apply_flag_kind(format, val, which, String.eq(which, "format"))
def build_path_apply_outdir(+outdir: String, +val: String, is_outdir: Bool) -> String:
  match is_outdir:
    case True{}:
      val
    case False{}:
      outdir

def build_path_apply_format(+format: String, +val: String, is_outdir: Bool) -> String:
  match is_outdir:
    case True{}:
      format
    case False{}:
      format ++ ";public=" ++ val

def build_format_value_flag(+head: String) -> String:
  match head:
    case "--format":
      "format"
    case "--asset-naming":
      "asset"
    case "--sourcemap":
      "sourcemap"
    case "--splitting":
      "splitting"
    case "--minify-syntax":
      "minify-syntax"
    case "--minify-whitespace":
      "minify-whitespace"
    case "--minify-identifiers":
      "minify-identifiers"
    case "--keep-names":
      "keep-names"
    case "--legal-comments":
      "legal-comments"
    case _:
      "sourcemap"

def build_format_option(+head: String) -> Bool:
  Bool.or(String.eq(head, "--format"), Bool.or(String.eq(head, "--asset-naming"), Bool.or(String.eq(head, "--sourcemap"), Bool.or(String.eq(head, "--splitting"), Bool.or(String.eq(head, "--minify-syntax"), Bool.or(String.eq(head, "--minify-whitespace"), Bool.or(String.eq(head, "--minify-identifiers"), Bool.or(String.eq(head, "--keep-names"), String.eq(head, "--legal-comments")))))))))

def build_format_key_option(+which: String) -> Bool:
  Bool.or(String.eq(which, "format"), Bool.or(String.eq(which, "asset"), Bool.or(String.eq(which, "sourcemap"), Bool.or(String.eq(which, "splitting"), Bool.or(String.eq(which, "minify-syntax"), Bool.or(String.eq(which, "minify-whitespace"), Bool.or(String.eq(which, "minify-identifiers"), Bool.or(String.eq(which, "keep-names"), String.eq(which, "legal-comments")))))))))


def build_path_value_flag_kind(+head: String, is_outdir: Bool) -> String:
  match is_outdir:
    case True{}:
      "outdir"
    case False{}:
      "public"
def build_path_value_flag(+head: String) -> String:
  build_path_value_flag_kind(head, String.eq(head, "--outdir"))


def bundle_format_pick_kind(+format: String, +src: String, +js: String, cjs: Bool, esm: Bool) -> IO(String):
  match cjs:
    case True{}:
      bundle_cjs(src, js)
    case False{}:
      match esm:
        case True{}:
          bundle_esm(src, js)
        case False{}:
          IO.die(String, 2, "knot: unsupported format " ++ format ++ " (unknown_command)")

def bundle_format_pick(+format: String, +src: String, +js: String, cjs: Bool, esm: Bool) -> IO(String):
  +base : String = build_format_base(format)
  bundle_format_pick_kind(base, src, js, String.eq(base, "cjs"), String.eq(base, "esm"))
def content_join(+acc: String, +item: String, first: Bool) -> String:
  match first:
    case True{}:
      acc ++ item
    case False{}:
      acc ++ "," ++ item
def content_array_go(files: List<&2, String>, +acc: String, first: Bool) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, acc ++ "]")
    case Con{+file, rest}:
      do IO<String>:
        raw : String <- read_text(file)
        content_array_go(rest, content_join(acc, Compiler.json_str(raw), first), False{})
def map_with_content_kind(+map: String, files: List<&2, String>, include: Bool) -> IO(String):
  match include:
    case False{}:
      IO.pure(String, map)
    case True{}:
      do IO<String>:
        +body : String <- content_array_go(files, "[", True{})
        return String.take(map, Nat.sub(String.length(map), 1n)) ++ ",\"sourcesContent\":" ++ body ++ "}"
def map_with_content(+map: String, files: List<&2, String>) -> IO(String):
  do IO<String>:
    include : Bool <- file_exists(".knot/sources-include")
    map_with_content_kind(map, files, include)
def map_from_lex(+file: String, files: List<&2, String>, lr: Compiler.LexRes) -> String:
  match lr:
    case Compiler.LexErr{msg, line, col}:
      Compiler.make_map_sources(file, files, Nil{})
    case Compiler.LexOk{tokens}:
      Compiler.make_map_sources(file, files, tokens)
def map_add_name_kind(+map: String, +name: String, empty: Bool) -> String:
  match empty:
    case True{}:
      str_replace(0n, map, "\"names\":[]", "\"names\":[" ++ Compiler.json_str(name) ++ "]", False{}, False{})
    case False{}:
      str_replace(0n, map, "\"names\":[", "\"names\":[" ++ Compiler.json_str(name) ++ ",", False{}, False{})
def map_add_name(+map: String, +name: String) -> String:
  map_add_name_kind(map, name, String.contains(map, "\"names\":[]"))
def map_replace_source(+map: String, +file: String, +source: String, empty: Bool) -> String:
  match empty:
    case True{}:
      map
    case False{}:
      str_replace(0n, map, Compiler.json_str(file), Compiler.json_str(source), False{}, False{})
def map_add_name_if(+map: String, +name: String, empty: Bool) -> String:
  match empty:
    case True{}:
      map
    case False{}:
      map_add_name(map, name)
def map_compose_kind(+map: String, +file: String, +source: String, +name: String, source_empty: Bool, name_empty: Bool) -> String:
  map_add_name_if(map_replace_source(map, file, source, source_empty), name, name_empty)
def map_skip_quote(+s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'"', t}:
      t
    case SCon{_, t}:
      map_skip_quote(t)
def map_take_quote(+s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'"', _}:
      ""
    case SCon{h, t}:
      SCon{h, map_take_quote(t)}
def map_after_quote(+s: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{'"', t}:
      t
    case SCon{_, t}:
      map_after_quote(t)
def map_field_string(+raw: String, +key: String) -> String:
  map_take_quote(map_skip_quote(drop_until_key(raw, key)))
@unsafe def map_add_prior_names(sel: Nat, +map: String, +body: String, +name: String) -> String:
  match sel:
    case 0n:
      +opened : String = map_skip_quote(body)
      +quoted : String = map_skip_quote(body)
      map_add_prior_names(1n, map, map_after_quote(opened), map_take_quote(quoted))
    case _:
      match name:
        case SNil{}:
          map
        case _:
          map_add_prior_names(0n, map_add_name(map, name), body, "")
def map_compose_loaded(+map: String, +file: String, +raw: String) -> String:
  +source : String = map_field_string(raw, "\"sources\":")
  map_add_prior_names(0n, map_replace_source(map, file, source, String.is_empty(source)), drop_until_key(raw, "\"names\":"), "")
def map_compose_loaded_result(+map: String, +file: String, r: Result<&1, &1, U32 & String, String>) -> String:
  match r:
    case Fail{_}:
      map
    case Done{raw}:
      map_compose_loaded(map, file, raw)
def map_compose_one_abs(+map: String, +file: String, +root: String, present: Bool) -> IO(String):
  match present:
    case False{}:
      IO.pure(String, map)
    case True{}:
      do IO<String>:
        raw : String <- read_text(root ++ "/" ++ file ++ ".map")
        return map_compose_loaded(map, file, raw)
def map_compose_one_present(+map: String, +file: String, +root: String, present: Bool) -> IO(String):
  match present:
    case False{}:
      do IO<String>:
        ex : Bool <- file_exists(root ++ "/" ++ file ++ ".map")
        map_compose_one_abs(map, file, root, ex)
    case True{}:
      do IO<String>:
        raw : String <- read_text(file ++ ".map")
        return map_compose_loaded(map, file, raw)
def map_compose_one(+map: String, +file: String) -> IO(String):
  do IO<String>:
    +root : String <- IO.try(String, Fs.cwd())
    ex : Bool <- file_exists(file ++ ".map")
    map_compose_one_present(map, file, root, ex)
@unsafe def map_compose_sources(sel: Nat, +map: String, +body: String, +source: String) -> IO(String):
  match sel:
    case 0n:
      +opened : String = map_skip_quote(body)
      +quoted : String = map_skip_quote(body)
      map_compose_sources(1n, map, map_after_quote(opened), map_take_quote(quoted))
    case _:
      match source:
        case SNil{}:
          IO.pure(String, map)
        case _:
          do IO<String>:
            next : String <- map_compose_one(map, source)
            map_compose_sources(0n, next, body, "")
def map_compose_text(+map: String) -> IO(String):
  map_compose_sources(0n, map, drop_until_key(map, "\"sources\":"), "")

def bundle_write_opts_format(+file: String, +out: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    raw : String <- read_text(file)
    +src : String <- normalize_source(raw)
    split_check : Unit <- bundle_split_validate(format, Compiler.dyn_imports_of(src), Nil{})
    +files : List<&2, String> <- bundle_files_conds(file, external_conds(conds, format))
    keep : List<&2, String> <- collect_keep(files)
    +asset_template : String = build_format_marker(format, "asset")
    +js0 : String <- emit_files(files, keep, build_minify_enabled(format), String.eq(build_format_marker(format, "minify-identifiers"), "true"), build_format_marker(format, "loader"), String.eq(build_format_marker(format, "ignore-side-effects-annotations"), "true"))
    +js1 : String = apply_build_transforms(external_imports(src, external_marker(format)) ++ strip_external_aliases(src, external_marker(format), js0), format)
    +js : String <- rewrite_asset_refs(files, js1, asset_template, build_format_marker(format, "public"))
    +css : String <- emit_css_files(files, Compiler.dirname(css_path(out)), "", asset_template, build_format_marker(format, "public"), build_minify_enabled(format))
    +output : String <- bundle_format_pick(format, src, js, String.eq(format, "cjs"), String.eq(format, "esm"))
    preflight : Unit <- bundle_preflight(file, src, out, format)
    +base_map : String = map_from_lex(file, files, Compiler.lex(src))
    +composed : String <- map_compose_text(base_map)
    +full_map : String <- map_with_content(composed, files)
    map_write : Unit <- transpile_ok_to(out, output, full_map, sourcemap_mode(build_format_marker(format, "sourcemap")))
    u2 : Unit <- write_css_if(out, css, String.is_empty(css), build_format_marker(format, "sourcemap"), files)
    u3 : Unit <- write_css_map_if(out, css, files, build_format_marker(format, "sourcemap"), String.is_empty(css))
    u4 : Unit <- copy_assets(files, out, build_format_marker(format, "asset"))
    u5 : Unit <- bundle_write_dyn(file, out, src, build_format_marker(format, "public"), sourcemap_mode(build_format_marker(format, "sourcemap")), format)
    u5b : Unit <- graph_dyn_emit(0n, files, out, build_format_marker(format, "public"), sourcemap_mode(build_format_marker(format, "sourcemap")), format, "", False{})
    u6 : Unit <- meta_write(meta, file, out, src, output, css, files, asset_template, sourcemap_mode(build_format_marker(format, "sourcemap")))
    return Unit{}
def bundle_write_opts(+file: String, +out: String, +conds: String, +meta: String) -> IO(Unit):
  bundle_write_opts_format(file, out, conds, meta, "esm")

def bundle_write(+file: String, +out: String) -> IO(Unit):
  bundle_write_opts(file, out, "import,module,node,default", "")

@unsafe def html_quote_go(sel: Nat, +text: String, +acc: String, c: Char, stop: Bool) -> String:
  match sel:
    case 0n:
      match text:
        case SNil{}:
          String.reverse(acc)
        case SCon{+h, t}:
          html_quote_go(1n, t, acc, h, Char.is_eq(h, '"'))
    case _:
      match stop:
        case True{}:
          String.reverse(acc)
        case False{}:
          html_quote_go(0n, text, SCon{c, acc}, 'a', False{})


def html_script_src_pick(+after: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      html_quote_go(0n, after, "", 'a', False{})


@unsafe def html_drop_attr_go(sel: Nat, +html: String, +key: String, quote_mark: Bool, single: Bool) -> String:
  match sel:
    case 0n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(4n, html, key, String.starts_with(html, "<!--"), False{})
    case 1n:
      html_drop_attr_go(6n, html, key, String.starts_with(html, key), False{})
    case 2n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(9n, t, key, Char.is_eq(h, '"'), False{})
    case 3n:
      html_drop_attr_go(10n, html, key, String.starts_with(html, "-->"), False{})
    case 4n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(3n, String.drop(html, 4n), key, False{}, False{})
        case False{}:
          html_drop_attr_go(11n, html, key, False{}, False{})
    case 11n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(5n, html, key, Char.is_eq(h, '<'), False{})
    case 5n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(1n, html, key, False{}, False{})
        case False{}:
          html_drop_attr_go(0n, String.drop(html, 1n), key, False{}, False{})
    case 6n:
      match quote_mark:
        case True{}:
          html
        case False{}:
          html_drop_attr_go(12n, html, key, False{}, False{})
    case 12n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(7n, t, key, Char.is_eq(h, '>'), False{})
    case 7n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(0n, html, key, False{}, False{})
        case False{}:
          html_drop_attr_go(13n, html, key, False{}, False{})
    case 13n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(8n, t, key, Bool.or(Char.is_eq(h, '"'), Char.is_eq(h, '\'')), Char.is_eq(h, '\''))
    case 8n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(14n, html, key, True{}, single)
        case False{}:
          html_drop_attr_go(1n, html, key, False{}, False{})
    case 14n:
      match single:
        case True{}:
          html_drop_attr_go(15n, html, key, False{}, True{})
        case False{}:
          html_drop_attr_go(2n, html, key, False{}, False{})
    case 15n:
      match html:
        case SNil{}:
          ""
        case SCon{+h, t}:
          html_drop_attr_go(16n, t, key, Char.is_eq(h, '\''), False{})
    case 16n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(1n, html, key, False{}, False{})
        case False{}:
          html_drop_attr_go(15n, html, key, False{}, True{})
    case 9n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(1n, html, key, False{}, False{})
        case False{}:
          html_drop_attr_go(2n, html, key, False{}, False{})
    case 10n:
      match quote_mark:
        case True{}:
          html_drop_attr_go(0n, String.drop(html, 3n), key, False{}, False{})
        case False{}:
          html_drop_attr_go(17n, html, key, False{}, False{})
    case 17n:
      match html:
        case SNil{}:
          ""
        case SCon{_, t}:
          html_drop_attr_go(3n, t, key, False{}, False{})
    case _:
      ""

def html_drop_attr(+html: String, +key: String) -> String:
  html_drop_attr_go(0n, html, key, False{}, False{})

def html_attr_quote_kind(single: Bool) -> String:
  match single:
    case True{}:
      "'"
    case False{}:
      "\""

def html_attr_quote(+key: String) -> String:
  html_attr_quote_kind(String.ends_with(key, "'"))

def html_attr_keys_kind(+html: String, +key: String, +double: String, found: Bool) -> String:
  match found:
    case True{}:
      double
    case False{}:
      html_drop_attr(html, key ++ "'")

def html_attr_keys(+html: String, +key: String) -> String:
  +double : String = html_drop_attr(html, key ++ "\"")
  html_attr_keys_kind(html, key, double, Bool.not(String.is_empty(double)))

def html_attr_ref_pick(+after: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      html_quote_go(0n, after, "", 'a', False{})

def html_script_tag_attr_kind(+double: String, +single: String, found_double: Bool) -> String:
  match found_double:
    case True{}:
      html_quote_go(0n, double, "", 'a', False{})
    case False{}:
      css_take_until_char(single, '\'')
def html_script_tag_attr(+html: String, +key: String) -> String:
  +tag : String = css_take_until_char(drop_until_key(html, "<script"), '>')
  +double : String = drop_until_key(tag, " " ++ key ++ "=\"")
  +single : String = drop_until_key(tag, " " ++ key ++ "='")
  html_script_tag_attr_kind(double, single, Bool.not(String.is_empty(double)))

def html_script_src(+html: String) -> String:
  +tag : String = drop_until_key(html, "<script")
  +after : String = drop_until_key(tag, "src=\"")
  html_script_src_pick(after, String.is_empty(after))

def html_attr_ref(+html: String, +key: String) -> String:
  +after : String = html_attr_keys(html, key)
  html_attr_ref_pick(after, String.is_empty(after))

@unsafe def html_last_delim_go(sel: Nat, +s: String, last: Char, hit: Bool, c: Char) -> Char:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          last
        case SCon{+h, t}:
          html_last_delim_go(1n, t, last, Bool.or(Char.is_eq(h, '<'), Char.is_eq(h, '>')), h)
    case 1n:
      match hit:
        case True{}:
          html_last_delim_go(0n, s, c, False{}, 'a')
        case False{}:
          html_last_delim_go(0n, s, last, False{}, 'a')
    case _:
      last

def html_tag_active_kind(open: Bool) -> Bool:
  match open:
    case True{}:
      True{}
    case False{}:
      False{}

def html_tag_active(+s: String) -> Bool:
  +last : Char = html_last_delim_go(0n, s, 'a', False{}, 'a')
  html_tag_active_kind(Char.is_eq(last, '<'))

@unsafe def html_pair_active_go(sel: Nat, +s: String, +open_key: String, +close_key: String, +after_open: String, +after_close: String, found_open: Bool, found_close: Bool) -> Bool:
  match sel:
    case 0n:
      +next_open : String = drop_until_key(s, open_key)
      html_pair_active_go(1n, s, open_key, close_key, next_open, "", Bool.not(String.is_empty(next_open)), False{})
    case 1n:
      match found_open:
        case False{}:
          False{}
        case True{}:
          +next_close : String = drop_until_key(after_open, close_key)
          html_pair_active_go(2n, s, open_key, close_key, after_open, next_close, True{}, Bool.not(String.is_empty(next_close)))
    case 2n:
      match found_close:
        case True{}:
          html_pair_active_go(0n, after_close, open_key, close_key, "", "", False{}, False{})
        case False{}:
          True{}
    case _:
      False{}

def html_pair_active(+s: String, +open_key: String, +close_key: String) -> Bool:
  html_pair_active_go(0n, s, open_key, close_key, "", "", False{}, False{})

def html_prefix_valid_kind(tag: Bool, comment: Bool) -> Bool:
  match comment:
    case True{}:
      False{}
    case False{}:
      tag

@unsafe def html_attr_candidate_go(sel: Nat, +root: String, +key: String, +search: String, +after: String, +ref: String, +tail: String, found: Bool, valid: Bool) -> String:
  match sel:
    case 0n:
      +next_after : String = drop_until_key(search, key)
      html_attr_candidate_go(1n, root, key, search, next_after, "", "", Bool.not(String.is_empty(next_after)), False{})
    case 1n:
      match found:
        case False{}:
          ""
        case True{}:
          +prefix_len : Nat = Nat.sub(Nat.sub(String.length(root), String.length(after)), String.length(key))
          +prefix : String = String.take(root, prefix_len)
          +tag : Bool = html_tag_active(prefix)
          +img_tag : Bool = String.contains(prefix, "<img")
          +tag_or_img : Bool = Bool.or(tag, img_tag)
          +script_open : Bool = String.contains(prefix, "<script")
          +script_close : Bool = String.contains(prefix, "</script>")
          +script_active : Bool = Bool.and(script_open, Bool.not(script_close))
          +safe_tag : Bool = Bool.and(tag_or_img, Bool.not(script_active))
          +comment_open : Bool = String.contains(prefix, "<!--")
          +comment_close : Bool = String.contains(prefix, "-->")
          +comment : Bool = Bool.and(comment_open, Bool.not(comment_close))
          html_attr_candidate_go(2n, root, key, search, after, "", "", True{}, html_prefix_valid_kind(safe_tag, comment))
    case 2n:
      match valid:
        case True{}:
          after
        case False{}:
          +value : String = html_quote_go(0n, after, "", 'a', False{})
          +next_tail : String = String.drop(after, Nat.add(String.length(value), 1n))
          html_attr_candidate_go(0n, root, key, next_tail, "", "", "", False{}, False{})
    case _:
      ""

def html_drop_attr_key(+html: String, +key: String) -> String:
  html_attr_candidate_go(0n, html, key, html, "", "", "", False{}, False{})
def html_copy_ref(+file: String, +out: String, +ref: String, local: Bool) -> IO(Unit):
  match local:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      do IO<Unit>:
        +path : String <- resolve_open(file, ref)
        IO.try(Unit, Fs.copy(path, Compiler.join_rel(Compiler.dirname(out), Compiler.basename(path))))

def html_rewrite_ref(+html: String, +key: String, +ref: String, +name: String, local: Bool) -> String:
  match local:
    case False{}:
      html
    case True{}:
      str_replace(0n, html, key ++ ref ++ "\"", key ++ name ++ "\"", False{}, False{})
def html_attr_local_state(local: Bool) -> Nat:
  match local:
    case True{}:
      3n
    case False{}:
      2n

def html_srcset_join(+segment: String, +more: String, comma: Bool) -> String:
  match comma:
    case True{}:
      segment ++ "," ++ more
    case False{}:
      segment ++ more

def html_srcset_replace_kind(+segment: String, +path: String, +target: String, same: Bool) -> String:
  match same:
    case True{}:
      segment
    case False{}:
      css_module_replace_go(0n, segment, path, target, False{})

def html_srcset_segment_kind(+rest: String, comma: Bool) -> String:
  match comma:
    case True{}:
      css_drop_last_char(css_take_until_char(rest, ','))
    case False{}:
      rest

@unsafe def html_srcset_go(
  sel: Nat,
  +rest: String,
  +file: String,
  +outdir: String,
  +template: String,
  +public: String,
  +segment: String,
  +path: String,
  +tail: String,
  comma: Bool,
  local: Bool
) -> IO(String):
  match sel:
    case 0n:
      match rest:
        case SNil{}:
          IO.pure(String, "")
        case SCon{_, _}:
          +has_comma : Bool = String.contains(rest, ",")
          +next_segment : String = html_srcset_segment_kind(rest, has_comma)
          +next_tail : String = css_drop_after_char(rest, ',')
          +next_path : String = css_url_word_ref(next_segment)
          html_srcset_go(1n, next_tail, file, outdir, template, public, next_segment, next_path, next_tail, String.contains(rest, ","), Compiler.is_rel(css_ref_path(next_path)))
    case _:
      match local:
        case False{}:
          do IO<String>:
            +more : String <- html_srcset_go(0n, tail, file, outdir, template, public, "", "", "", String.contains(tail, ","), False{})
            return html_srcset_join(segment, more, comma)
        case True{}:
          do IO<String>:
            +path_file : String <- resolve_open(file, css_ref_path(path))
            +name : String <- asset_output_name(path_file, template)
            u : Unit <- IO.try(Unit, Fs.copy(path_file, Compiler.join_rel(outdir, name)))
            +target : String = asset_public_url(public, name) ++ css_ref_suffix(path, css_ref_path(path))
            +rewritten : String = html_srcset_replace_kind(segment, path, target, String.eq(path, target))
            +more : String <- html_srcset_go(0n, tail, file, outdir, template, public, "", "", "", String.contains(tail, ","), False{})
            return html_srcset_join(rewritten, more, comma)

@unsafe def html_rewrite_srcset_go(sel: Nat, +html: String, +file: String, +outdir: String, +template: String, +public: String, +after: String, +prefix: String, found: Bool) -> IO(String):
  match sel:
    case 0n:
      +next_after : String = html_drop_attr_key(html, "srcset=\"")
      html_rewrite_srcset_go(1n, html, file, outdir, template, public, next_after, "", Bool.not(String.is_empty(next_after)))
    case _:
      match found:
        case False{}:
          IO.pure(String, html)
        case True{}:
          do IO<String>:
            +value : String = html_quote_go(0n, after, "", 'a', False{})
            +prefix_len : Nat = Nat.sub(String.length(html), Nat.add(String.length("srcset=\""), String.length(after)))
            +next_prefix : String = String.take(html, prefix_len)
            +tail : String = String.drop(after, Nat.add(String.length(value), 1n))
            +rewritten : String <- html_srcset_go(0n, value, file, outdir, template, public, "", "", "", False{}, False{})
            +more : String <- html_rewrite_srcset_go(0n, tail, file, outdir, template, public, "", "", False{})
            return next_prefix ++ "srcset=\"" ++ rewritten ++ "\"" ++ more

def html_rewrite_srcset(+file: String, +outdir: String, +html: String, +template: String, +public: String) -> IO(String):
  html_rewrite_srcset_go(0n, html, file, outdir, template, public, "", "", False{})

def html_template_guard_kind(+ref: String, inside: Bool) -> IO(Unit):
  match inside:
    case True{}:
      IO.die(Unit, 1, "knot: template reference " ++ ref ++ " (html_template_reference)")
    case False{}:
      IO.pure(Unit, Unit{})
def html_template_guard(+prefix: String, +ref: String) -> IO(Unit):
  html_template_guard_kind(ref, html_pair_active(prefix, "<template", "</template>"))

@unsafe def html_last_tag(sel: Nat, +s: String, +acc: String) -> String:
  match sel:
    case 0n:
      match s:
        case SNil{}:
          ""
        case SCon{'<', t}:
          html_last_tag(1n, t, "")
        case SCon{_, t}:
          html_last_tag(0n, t, "")
    case 1n:
      match s:
        case SNil{}:
          acc
        case SCon{' ', t}:
          html_last_tag(2n, t, acc)
        case SCon{'>', t}:
          html_last_tag(2n, t, acc)
        case SCon{h, t}:
          html_last_tag(1n, t, acc ++ SCon{h, SNil{}})
    case _:
      match s:
        case SNil{}:
          acc
        case SCon{'<', t}:
          html_last_tag(1n, t, "")
        case SCon{_, t}:
          html_last_tag(2n, t, acc)
def html_executable_tag(+tag: String) -> Bool:
  Bool.or(String.eq(tag, "script"), Bool.or(String.eq(tag, "link"), String.eq(tag, "iframe")))
def html_scheme_bad(+ref: String, +tag: String) -> Bool:
  Bool.or(
    Bool.or(String.starts_with(ref, "javascript:"), Bool.or(String.starts_with(ref, "vbscript:"), Bool.or(String.starts_with(ref, "file:"), String.starts_with(ref, "ftp:")))),
    Bool.and(html_executable_tag(tag), Bool.or(String.starts_with(ref, "blob:"), String.starts_with(ref, "data:")))
  )
def html_scheme_guard_kind(bad: Bool) -> IO(Unit):
  match bad:
    case True{}:
      IO.die(Unit, 1, "knot: unsupported URL scheme (html_url_scheme)")
    case False{}:
      IO.pure(Unit, Unit{})
def html_scheme_guard(+ref: String, +prefix: String) -> IO(Unit):
  html_scheme_guard_kind(html_scheme_bad(ref, html_last_tag(0n, prefix, "")))

@unsafe def html_rewrite_attrs_go(
  sel: Nat,
  +html: String,
  +file: String,
  +outdir: String,
  +template: String,
  +public: String,
  +key: String,
  +skip: String,
  +after: String,
  +prefix: String,
  +ref: String,
  +tail: String,
  ignored: Bool,
  found: Bool
) -> IO(String):
  match sel:
    case 0n:
      +next_after : String = html_drop_attr_key(html, key)
      html_rewrite_attrs_go(1n, html, file, outdir, template, public, key, skip, next_after, "", "", "", False{}, Bool.not(String.is_empty(next_after)))
    case 1n+p:
      match p:
        case 0n:
          match found:
            case False{}:
              IO.pure(String, html)
            case True{}:
              +next_ref : String = html_quote_go(0n, after, "", 'a', False{})
              +prefix_len : Nat = Nat.sub(String.length(html), Nat.add(String.length(key), String.length(after)))
              +next_prefix : String = String.take(html, prefix_len)
              +next_tail : String = String.drop(after, Nat.add(String.length(next_ref), 1n))
              html_rewrite_attrs_go(html_attr_local_state(Compiler.is_rel(next_ref)), next_tail, file, outdir, template, public, key, skip, "", next_prefix, next_ref, next_tail, String.eq(next_ref, skip), True{})
        case 1n+p2:
          match p2:
            case 0n:
              do IO<String>:
                guard : Unit <- html_scheme_guard(ref, prefix)
                +more : String <- html_rewrite_attrs_go(0n, tail, file, outdir, template, public, key, skip, "", "", "", "", False{}, False{})
                return prefix ++ key ++ ref ++ html_attr_quote(key) ++ more
            case _:
              match ignored:
                case True{}:
                  do IO<String>:
                    +more : String <- html_rewrite_attrs_go(0n, tail, file, outdir, template, public, key, skip, "", "", "", "", False{}, False{})
                    return prefix ++ key ++ ref ++ html_attr_quote(key) ++ more
                case False{}:
                  do IO<String>:
                    guard : Unit <- html_template_guard(prefix, ref)
                    +path : String <- resolve_open(file, css_ref_path(ref))
                    +name : String <- asset_output_name(path, template)
                    u : Unit <- IO.try(Unit, Fs.copy(path, Compiler.join_rel(outdir, name)))
                    +more : String <- html_rewrite_attrs_go(0n, tail, file, outdir, template, public, key, skip, "", "", "", "", False{}, False{})
                    return prefix ++ key ++ asset_public_url(public, name) ++ css_ref_suffix(ref, css_ref_path(ref)) ++ html_attr_quote(key) ++ more

def html_rewrite_attrs(+file: String, +outdir: String, +html: String, +key: String, +skip: String, +template: String, +public: String) -> IO(String):
  html_rewrite_attrs_go(0n, html, file, outdir, template, public, key, skip, "", "", "", "", False{}, False{})

def html_css_local(+ref: String) -> Bool:
  +remote : Bool = Bool.or(Bool.or(String.starts_with(ref, "http:"), String.starts_with(ref, "https:")), Bool.or(String.starts_with(ref, "//"), Bool.or(String.starts_with(ref, "/"), String.starts_with(ref, "data:"))))
  Bool.and(String.ends_with(css_ref_path(ref), ".css"), Bool.or(Compiler.is_rel(ref), Bool.not(remote)))


def html_css_anchor(+out: String) -> String:
  String.take(out, Nat.sub(String.length(out), 3n)) ++ "js"

def html_bundle_css_one(+file: String, +outdir: String, +conds: String, +format: String, +ref: String) -> IO(Unit):
  do IO<Unit>:
    +path : String <- resolve_open(file, css_ref_path(ref))
    +graph : List<&2, String> <- bundle_files_conds(path, external_conds(conds, format))
    +out : String = Compiler.join_rel(outdir, Compiler.basename(path))
    +css : String <- emit_css_files(graph, outdir, "", build_format_marker(format, "asset"), build_format_marker(format, "public"), build_minify_enabled(format))
    u0 : Unit <- write_css_if(html_css_anchor(out), css, String.is_empty(css), build_format_marker(format, "sourcemap"), graph)
    u1 : Unit <- write_css_map_if(html_css_anchor(out), css, graph, build_format_marker(format, "sourcemap"), String.is_empty(css))
    copy_assets(graph, out, build_format_marker(format, "asset"))



@unsafe def html_bundle_css_go(
  sel: Nat,
  +html: String,
  +file: String,
  +outdir: String,
  +conds: String,
  +format: String,
  +after: String,
  +ref: String,
  tail: String,
  found: Bool,
  local: Bool
) -> IO(Unit):
  match sel:
    case 0n:
      +next : String = html_drop_attr_key(html, "href=\"")
      html_bundle_css_go(1n, html, file, outdir, conds, format, next, "", "", Bool.not(String.is_empty(next)), False{})
    case 1n:
      match found:
        case False{}:
          IO.pure(Unit, Unit{})
        case True{}:
          do IO<Unit>:
            +next_ref : String = html_quote_go(0n, after, "", 'a', False{})
            +next_tail : String = String.drop(after, Nat.add(String.length(next_ref), 1n))
            html_bundle_css_go(2n, html, file, outdir, conds, format, "", next_ref, next_tail, False{}, html_css_local(next_ref))
    case _:
      match local:
        case True{}:
          do IO<Unit>:
            u : Unit <- html_bundle_css_one(file, outdir, conds, format, ref)
            html_bundle_css_go(0n, tail, file, outdir, conds, format, "", "", "", False{}, False{})
        case False{}:
          html_bundle_css_go(0n, tail, file, outdir, conds, format, "", "", "", False{}, False{})

def html_bundle_css(+file: String, +outdir: String, +conds: String, +format: String, +html: String) -> IO(Unit):
  html_bundle_css_go(0n, html, file, outdir, conds, format, "", "", "", False{}, False{})


def html_script_open(+html: String) -> String:
  css_take_until_char(drop_until_key(html, "<script"), '>')
def html_copied_attr_kind(+key: String, +value: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      " " ++ key ++ "=\"" ++ value ++ "\""
def html_open_attr(+html: String, +key: String) -> String:
  html_script_tag_attr(html, key)
def html_copied_attr(+html: String, +key: String) -> String:
  +value : String = html_open_attr(html, key)
  html_copied_attr_kind(key, value, String.is_empty(value))
def html_preload_crossorigin_kind(+value: String, empty: Bool, present: Bool) -> String:
  match empty:
    case False{}:
      " crossorigin=\"" ++ value ++ "\""
    case True{}:
      match present:
        case True{}:
          " crossorigin"
        case False{}:
          ""
def html_preload_crossorigin(+html: String) -> String:
  +value : String = html_open_attr(html, "crossorigin")
  html_preload_crossorigin_kind(value, String.is_empty(value), String.contains(html_script_open(html), "crossorigin"))
def html_preload_link_kind(+html: String, +href: String, enabled: Bool) -> String:
  match enabled:
    case False{}:
      ""
    case True{}:
      "<link rel=\"modulepreload\" href=\"" ++ href ++ "\"" ++ html_preload_crossorigin(html) ++ html_copied_attr(html, "referrerpolicy") ++ html_copied_attr(html, "nonce") ++ ">"
def html_insert_preload(+html: String, +link: String, empty: Bool) -> String:
  match empty:
    case True{}:
      html
    case False{}:
      str_replace(0n, html, "<script", link ++ "<script", False{}, False{})
def html_write_src(+file: String, +out: String, +conds: String, +meta: String, +format: String, +raw: String, +src: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.die(Unit, 2, "knot: HTML entry requires a module script src (unsupported_html)")
    case False{}:
      do IO<Unit>:
        +asset_template : String = build_format_marker(format, "asset")
        +public : String = build_format_marker(format, "public")
        +html_href : String <- html_rewrite_attrs(file, Compiler.dirname(out), raw, "href=\"", "", asset_template, public)
        +html_poster : String <- html_rewrite_attrs(file, Compiler.dirname(out), html_href, "poster=\"", "", asset_template, public)
        +html_srcsets : String <- html_rewrite_srcset(file, Compiler.dirname(out), html_poster, asset_template, public)
        +html_refs : String <- html_rewrite_attrs(file, Compiler.dirname(out), html_srcsets, "src=\"", src, asset_template, public)
        u1 : Unit <- html_bundle_css(file, Compiler.dirname(out), conds, format, raw)
        +script : String <- resolve_open(file, src)
        +href : String = Compiler.basename(Compiler.js_path(script))
        +js_out : String = Compiler.join_rel(Compiler.dirname(out), href)
        u2 : Unit <- bundle_write_opts_format(script, js_out, conds, "", format)
        +old_src : String = "src=\"" ++ src ++ "\""
        +new_src : String = "src=\"" ++ href ++ "\""
        +html : String = str_replace(0n, html_refs, old_src, new_src, False{}, False{})
        +link : String = html_preload_link_kind(raw, href, String.eq(build_format_marker(format, "preload"), "static"))
        +linked : String = html_insert_preload(html, link, String.is_empty(link))
        u3 : Unit <- write_text_atomic(out, linked)
        return Unit{}

def html_manifest_die() -> IO(Unit):
  IO.die(Unit, 1, "knot: invalid web app manifest (html_manifest)")
def html_manifest_status_kind(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      html_manifest_die()
def html_manifest_checked(result: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match result:
    case Fail{_}:
      html_manifest_die()
    case Done{status}:
      html_manifest_status_kind(String.eq(status, "ok"))
def html_manifest_read(+file: String, +href: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      html_manifest_die()
    case False{}:
      do IO<Unit>:
        +path : String <- resolve_open(file, css_ref_path(href))
        raw : String <- read_text(path)
        result : Result<&1, &1, U32 & String, String> <- Json.query(raw, "", "validate")
        html_manifest_checked(result)
def html_tag_href(+tag: String) -> String:
  html_quote_go(0n, drop_until_key(tag, "href=\""), "", 'a', False{})
def html_manifest_tag(+tag: String) -> Bool:
  String.contains(tag, "rel=\"manifest\"")
@unsafe def html_manifest_go(sel: Nat, +html: String, +file: String, +tag: String, +href: String, manifest: Bool, exhausted: Bool) -> IO(Unit):
  match sel:
    case 0n:
      +after : String = drop_until_key(html, "<link")
      html_manifest_go(1n, after, file, css_take_until_char(after, '>'), "", False{}, String.is_empty(after))
    case 1n:
      match exhausted:
        case True{}:
          IO.pure(Unit, Unit{})
        case False{}:
          html_manifest_go(2n, html, file, tag, html_tag_href(tag), html_manifest_tag(tag), False{})
    case 2n:
      match manifest:
        case False{}:
          html_manifest_go(0n, css_drop_after_char(html, '>'), file, "", "", False{}, False{})
        case True{}:
          html_manifest_go(3n, html, file, tag, href, True{}, Compiler.is_rel(href))
    case _:
      match exhausted:
        case False{}:
          html_manifest_go(0n, css_drop_after_char(html, '>'), file, "", "", False{}, False{})
        case True{}:
          do IO<Unit>:
            u : Unit <- html_manifest_read(file, href, String.is_empty(href))
            html_manifest_go(0n, css_drop_after_char(html, '>'), file, "", "", False{}, False{})

def html_write(+file: String, +out: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    raw : String <- read_text(file)
    scan : String <- read_text(file)
    +src : String = html_script_src(scan)
    body : String <- read_text(file)
    u : Unit <- html_manifest_go(0n, body, file, "", "", False{}, False{})
    html_write_src(file, out, conds, meta, format, raw, src, String.is_empty(src))
def bundle_write_entry(+file: String, +out: String, +conds: String, +meta: String, +format: String, html: Bool) -> IO(Unit):
  match html:
    case True{}:
      html_write(file, out, conds, meta, format)
    case False{}:
      bundle_write_opts_format(file, out, conds, meta, format)

def html_output_pick(+file: String, +out: String, +outdir: String, out_empty: Bool, dir_empty: Bool) -> IO(String):
  match out_empty:
    case False{}:
      match dir_empty:
        case True{}:
          IO.pure(String, out)
        case False{}:
          IO.die(String, 2, "knot: --outfile and --outdir cannot be combined (unknown_command)")
    case True{}:
      match dir_empty:
        case True{}:
          IO.die(String, 2, "knot: HTML build requires --outfile or --outdir (unknown_command)")
        case False{}:
          IO.pure(String, Compiler.join_rel(outdir, Compiler.basename(file)))



def conds_add_kind(+extra: String, +acc: String, empty: Bool, duplicate: Bool) -> String:
  match empty:
    case True{}:
      extra
    case False{}:
      match duplicate:
        case True{}:
          acc
        case False{}:
          acc ++ "\n" ++ extra

def conds_add(+extra: String, +acc: String, empty: Bool) -> String:
  conds_add_kind(extra, acc, empty, String.contains("\n" ++ acc ++ "\n", "\n" ++ extra ++ "\n"))

def conds_join_e(empty: Bool, +extra: String) -> String:
  match empty:
    case True{}:
      "import,module,node,default"
    case False{}:
      String.join(String.lines(extra), ",") ++ ",import,module,node,default"

def conds_join(+extra: String) -> String:
  conds_join_e(String.is_empty(extra), extra)

def bundle_output_pick(+file: String, +out: String, +outdir: String, out_empty: Bool, dir_empty: Bool) -> IO(String):
  match out_empty:
    case False{}:
      match dir_empty:
        case True{}:
          IO.pure(String, out)
        case False{}:
          IO.die(String, 2, "knot: --outfile and --outdir cannot be combined (unknown_command)")
    case True{}:
      match dir_empty:
        case True{}:
          IO.pure(String, Compiler.js_path(file))
        case False{}:
          IO.pure(String, Compiler.join_rel(outdir, Compiler.basename(Compiler.js_path(file))))

def bundle_output_pick_kind(+file: String, +out: String, +outdir: String, out_empty: Bool, dir_empty: Bool, html: Bool) -> IO(String):
  match html:
    case True{}:
      html_output_pick(file, out, outdir, out_empty, dir_empty)
    case False{}:
      bundle_output_pick(file, out, outdir, out_empty, dir_empty)
def build_entry_output_kind(+file: String, +chosen: String, +outdir: String, +format: String, html: Bool, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, chosen)
    case False{}:
      do IO<String>:
        +template : String = build_format_marker(format, "entry-names")
        +hash : String <- entry_template_hash(file, template)
        +name : String = entry_template_name_root(file, template, hash, html, build_format_marker(format, "root"))
        IO.pure(String, Compiler.join_rel(outdir, name))

def build_entry_output(+file: String, +chosen: String, +outdir: String, +format: String, html: Bool) -> IO(String):
  build_entry_output_kind(file, chosen, outdir, format, html, String.is_empty(build_format_marker(format, "entry-names")))

def build_output_final(+file: String, +out: String, +outdir: String, +format: String, +html: Bool) -> IO(String):
  do IO<String>:
    +picked : String <- bundle_output_pick_kind(file, out, outdir, String.is_empty(out), String.is_empty(outdir), html)
    +named : String <- build_entry_output(file, picked, outdir, format, html)
    +template : String = build_format_marker(format, "entry-names")
    return node_output_name(named, format, Bool.and(String.is_empty(out), Bool.or(String.is_empty(template), String.contains(template, "[ext]"))))

def scope_parent_root(+dir: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "/"
    case False{}:
      dir

def scope_parent(+dir: String) -> String:
  +parent : String = Compiler.dirname(dir)
  scope_parent_root(parent, String.is_empty(parent))

def scope_candidate(+dir: String) -> String:
  match dir:
    case "/":
      "/package.json"
    case _:
      dir ++ "/package.json"

def scope_absolute_kind(+root: String, +path: String, absolute: Bool) -> String:
  match absolute:
    case True{}:
      path
    case False{}:
      root ++ "/" ++ path

def scope_absolute(+root: String, +path: String) -> String:
  scope_absolute_kind(root, path, String.starts_with(path, "/"))

def scope_identity_kind(+root: String, +path: String, inside: Bool) -> IO(String):
  match inside:
    case True{}:
      IO.pure(String, String.drop(path, Nat.add(String.length(root), 1n)))
    case False{}:
      do IO<String>:
        hash : String <- IO.try(String, Hash.sha256_text(path))
        return "@local/" ++ hash

def scope_identity(+root: String, +path: String) -> IO(String):
  scope_identity_kind(root, path, String.starts_with(path, root ++ "/"))

def scope_probe_result(result: Result<&1, &1, U32 & String, String>) -> IO(String):
  match result:
    case Done{state}:
      IO.pure(String, state)
    case Fail{_}:
      IO.die(String, 2, "knot: unsafe output package scope candidate (output_module_type)")

def scope_probe(+path: String, skipped: Bool) -> IO(String):
  match skipped:
    case True{}:
      IO.pure(String, "absent")
    case False{}:
      do IO<String>:
        result : Result<&1, &1, U32 & String, String> <- Fs.regular_file(path)
        scope_probe_result(result)

def scope_checked_append(+checked: String, +identity: String, empty: Bool) -> String:
  match empty:
    case True{}:
      Compiler.json_str(identity)
    case False{}:
      checked ++ "," ++ Compiler.json_str(identity)

def scope_type_json(+typ: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "null"
    case False{}:
      Compiler.json_str(typ)

def scope_type_validate_kind(+typ: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: invalid output package type " ++ typ ++ " (output_module_type)")

def scope_type_validate(+typ: String) -> IO(Unit):
  scope_type_validate_kind(typ, Bool.or(String.is_empty(typ), Bool.or(String.eq(typ, "module"), String.eq(typ, "commonjs"))))

def scope_format_validate_kind(+output: String, compatible: Bool) -> IO(Unit):
  match compatible:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: output " ++ output ++ " has an incompatible package scope (output_module_type)")

def scope_format_validate(+output: String, +typ: String, +format: String) -> IO(Unit):
  scope_format_validate_kind(output, Bool.or(
    Bool.and(String.eq(format, "esm"), String.eq(typ, "module")),
    Bool.and(String.eq(format, "cjs"), Bool.not(String.eq(typ, "module")))))

def scope_absent_record(+output: String, +checked: String) -> String:
  "{\"checked\":[" ++ checked ++ "],\"digest\":null,\"output\":" ++ Compiler.json_str(output) ++ ",\"path\":null,\"state\":\"absent\",\"type\":null}"

def scope_present_record(+output: String, +checked: String, +identity: String, +digest: String, +typ: String) -> String:
  "{\"checked\":[" ++ checked ++ "],\"digest\":" ++ Compiler.json_str(digest) ++ ",\"output\":" ++ Compiler.json_str(output) ++ ",\"path\":" ++ Compiler.json_str(identity) ++ ",\"state\":\"present\",\"type\":" ++ scope_type_json(typ, String.is_empty(typ)) ++ "}"

def scope_has_type(keys: List<&2, String>) -> Bool:
  match keys:
    case Nil{}:
      False{}
    case Con{+key, rest}:
      Bool.or(String.eq(key, "type"), scope_has_type(rest))

def scope_type_result(r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Done{v}:
      IO.pure(String, v)
    case Fail{_}:
      IO.die(String, 2, "knot: invalid output package type (output_module_type)")

def scope_type_keys(+text: String, has_type: Bool) -> IO(String):
  match has_type:
    case True{}:
      do IO<String>:
        r : Result<&1, &1, U32 & String, String> <- Json.query(text, "type", "string")
        scope_type_result(r)
    case False{}:
      IO.pure(String, "")

def scope_keys_result(+text: String, r: Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case Done{+keys}:
      scope_type_keys(text, scope_has_type(String.lines(keys)))
    case Fail{_}:
      IO.die(String, 2, "knot: invalid output package manifest (output_module_type)")

def scope_package_type(+text: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- Json.query(text, "", "keys")
    scope_keys_result(text, r)

@unsafe def scope_walk(
  sel: Nat, +root: String, +dir: String, +output: String, +replaced: String, +format: String,
  +checked: String, +portable: Bool, +candidate: String, +identity: String,
  +state: String, inside: Bool
) -> IO(String & Bool):
  match sel:
    case 0n:
      do IO<String & Bool>:
        +next : String = scope_candidate(dir)
        +id : String <- scope_identity(root, next)
        +found : String <- scope_probe(next, Bool.and(Bool.not(String.is_empty(replaced)), String.starts_with(next, replaced ++ "/")))
        scope_walk(1n, root, dir, output, replaced, format, checked, portable, next, id, found, String.starts_with(next, root ++ "/"))
    case 1n:
      match state:
        case "present":
          do IO<String & Bool>:
            text : String <- read_text(candidate)
            +digest : String <- IO.try(String, Hash.sha256_b64(candidate))
            +typ : String <- scope_package_type(text)
            u0 : Unit <- scope_type_validate(typ)
            u1 : Unit <- scope_format_validate(output, typ, format)
            return (scope_present_record(output, checked, identity, digest, typ), Bool.and(portable, inside))
        case "absent":
          scope_walk(2n, root, dir, output, replaced, format, scope_checked_append(checked, identity, String.is_empty(checked)), Bool.and(portable, inside), "", "", "", False{})
        case _:
          IO.die(String & Bool, 2, "knot: package scope lookup failed (output_module_type)")
    case _:
      match dir:
        case "/":
          do IO<String & Bool>:
            u : Unit <- scope_format_validate(output, "", format)
            return (scope_absent_record(output, checked), portable)
        case _:
          scope_walk(0n, root, scope_parent(dir), output, replaced, format, checked, portable, "", "", "", False{})

def scope_output_paths(files: List<&2, String>, +out: String, +outdir: String, +format: String) -> IO(List<&2, String>):
  match files:
    case Nil{}:
      IO.pure(List<&2, String>, Nil{})
    case Con{+file, rest}:
      do IO<List<&2, String>>:
        +html : Bool = String.ends_with(file, ".html")
        +actual : String <- build_output_final(file, out, outdir, format, html)
        more : List<&2, String> <- scope_output_paths(rest, out, outdir, format)
        return Con{actual, more}

def scope_record_one_kind(+root: String, +path: String, +replaced: String, +format: String, js: Bool) -> IO(String & Bool):
  match js:
    case False{}:
      IO.pure(String & Bool, ("", True{}))
    case True{}:
      +absolute : String = scope_absolute(root, path)
      scope_walk(0n, root, Compiler.dirname(absolute), path, replaced, build_format_base(format), "", True{}, "", "", "", False{})

def scope_record_one(+root: String, +path: String, +replaced: String, +format: String) -> IO(String & Bool):
  scope_record_one_kind(root, path, replaced, format, String.ends_with(path, ".js"))

def scope_record_join(+acc: String, +record: String, empty: Bool) -> String:
  match empty:
    case True{}:
      record
    case False{}:
      acc ++ "," ++ record

@unsafe def scope_records_go(sel: Nat, files: List<&2, String>, +root: String, +replaced: String, +format: String, +acc: String, +portable: Bool, rest: List<&2, String>, record: String & Bool) -> IO(String & Bool):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(String & Bool, ("[" ++ acc ++ "]", portable))
        case Con{+path, next}:
          do IO<String & Bool>:
            one : String & Bool <- scope_record_one(root, path, replaced, format)
            scope_records_go(1n, Nil{}, root, replaced, format, acc, portable, next, one)
    case _:
      (one, local) = record
      match one:
        case "":
          scope_records_go(0n, rest, root, replaced, format, acc, Bool.and(portable, local), Nil{}, ("", True{}))
        case _:
          scope_records_go(0n, rest, root, replaced, format, scope_record_join(acc, one, String.is_empty(acc)), Bool.and(portable, local), Nil{}, ("", True{}))

def scope_replaced(+root: String, +outdir: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      scope_absolute(root, outdir)
def scope_cons_extra(outputs: List<&2, String>, +extra: String, empty: Bool) -> List<&2, String>:
  match empty:
    case True{}:
      outputs
    case False{}:
      Con{extra, outputs}
def scope_records_node(+file: String, +out: String, +outdir: String, +format: String, +extra: String) -> IO(String & Bool):
  do IO<String & Bool>:
    +root : String <- IO.try(String, Fs.cwd())
    outputs : List<&2, String> <- scope_output_paths(String.lines(file), out, outdir, format)
    +replaced : String = scope_replaced(root, outdir, String.is_empty(outdir))
    scope_records_go(0n, List.sort(~String, ~lock_le, scope_cons_extra(outputs, extra, String.is_empty(extra))), root, replaced, format, "", True{}, Nil{}, ("", True{}))
def scope_records_kind(+file: String, +out: String, +outdir: String, +format: String, +extra: String, node: Bool) -> IO(String & Bool):
  match node:
    case True{}:
      scope_records_node(file, out, outdir, format, extra)
    case False{}:
      IO.pure(String & Bool, ("[]", True{}))
def scope_records(+file: String, +out: String, +outdir: String, +format: String, +extra: String) -> IO(String & Bool):
  scope_records_kind(file, out, outdir, format, extra, String.eq(build_format_marker(format, "target"), "node"))

def config_bool(value: Bool) -> String:
  match value:
    case True{}:
      "true"
    case False{}:
      "false"

def config_default(+value: String, +fallback: String) -> String:
  match value:
    case "":
      fallback
    case _:
      value

def config_define_value(+definition: String, +value: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "{}"
    case False{}:
      "{" ++ Compiler.json_str(css_drop_last_char(css_take_until_char(definition, '='))) ++ ":" ++ Compiler.json_str(value) ++ "}"

def config_define_kind(+definition: String, redacted: Bool) -> String:
  match redacted:
    case True{}:
      config_define_value(definition, "<redacted>", String.is_empty(definition))
    case False{}:
      config_define_value(definition, String.drop(definition, Nat.add(String.length(css_drop_last_char(css_take_until_char(definition, '='))), 1n)), String.is_empty(definition))

def config_define(+format: String, redacted: Bool) -> String:
  config_define_kind(build_format_marker(format, "define"), redacted)

def config_identity(+root: String, +file: String) -> IO(String):
  scope_identity(root, scope_absolute(root, file))

def config_entries_separator(+more: String) -> String:
  match more:
    case "":
      ""
    case _:
      "," ++ more

def config_entries(+files: List<&2, String>, +root: String) -> IO(String):
  match files:
    case Nil{}:
      IO.pure(String, "")
    case Con{+file, rest}:
      do IO<String>:
        +identity : String <- config_identity(root, file)
        +more : String <- config_entries(rest, root)
        return Compiler.json_str(identity) ++ config_entries_separator(more)

def config_entries_kind(+file: String, +root: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      config_entries(String.lines(file), root)

def config_external_kind(+val: String) -> String:
  match val:
    case "":
      ""
    case _:
      Compiler.json_str(val)

def config_external(+format: String) -> String:
  config_external_kind(build_format_marker(format, "external"))

def config_conditions(+conds: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "[]"
    case False{}:
      Compiler.json_list(String.lines(conds))

def config_mapping_kind(+item: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "{}"
    case False{}:
      "{" ++ Compiler.json_str(css_drop_last_char(css_take_until_char(item, '='))) ++ ":" ++ Compiler.json_str(String.drop(item, Nat.add(String.length(css_drop_last_char(css_take_until_char(item, '='))), 1n))) ++ "}"

def config_naming(+format: String) -> String:
  "{\"asset\":" ++ Compiler.json_str(config_default(build_format_marker(format, "asset"), "[name]-[hash]")) ++
  ",\"chunk\":" ++ Compiler.json_str(config_default(build_format_marker(format, "chunk-names"), "[name]-[hash]")) ++
  ",\"css\":" ++ Compiler.json_str(config_default(build_format_marker(format, "css-naming"), "[name]")) ++ ",\"cssModule\":\"_[local]_[hash]\",\"entry\":" ++
  Compiler.json_str(config_default(build_format_marker(format, "entry-names"), "[dir][name]")) ++ "}"

def config_drop_kind(+drop: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "[]"
    case False{}:
      "[" ++ Compiler.json_str(drop) ++ "]"

def config_drop(+format: String) -> String:
  +drop : String = build_format_marker(format, "drop")
  config_drop_kind(drop, String.is_empty(drop))

def config_transforms(+format: String, redacted: Bool) -> String:
  +minify : Bool = String.eq(build_format_marker(format, "minify"), "true")
  "{\"baseUrl\":null,\"cssMinify\":" ++ config_bool(minify) ++ ",\"define\":" ++ config_define(format, redacted) ++
  ",\"drop\":" ++ config_drop(format) ++ ",\"experimentalDecorators\":false,\"importsNotUsedAsValues\":\"remove\",\"jsx\":\"automatic\",\"jsxFactory\":\"React.createElement\",\"jsxFragmentFactory\":\"React.Fragment\",\"jsxImportSource\":\"react\",\"minifyIdentifiers\":" ++
  config_bool(Bool.or(minify, String.eq(build_format_marker(format, "minify-identifiers"), "true"))) ++
  ",\"minifySyntax\":" ++ config_bool(Bool.or(minify, String.eq(build_format_marker(format, "minify-syntax"), "true"))) ++
  ",\"minifyWhitespace\":" ++ config_bool(Bool.or(minify, String.eq(build_format_marker(format, "minify-whitespace"), "true"))) ++
  ",\"paths\":{},\"useDefineForClassFields\":true,\"verbatimModuleSyntax\":false}"

def config_output_name(+file: String, +out: String, +format: String, has_dir: Bool) -> IO(String):
  match has_dir:
    case True{}:
      IO.pure(String, "")
    case False{}:
      build_output_final(file, out, "", format, False{})

def config_output_name_kind(+file: String, +out: String, +outdir: String, +format: String, empty: Bool) -> IO(String):
  match empty:
    case True{}:
      IO.pure(String, "")
    case False{}:
      config_output_name(file, out, format, Bool.not(String.is_empty(outdir)))

def config_output_file(+out: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "null"
    case False{}:
      Compiler.json_str(Compiler.basename(out))

def config_target_baseline(+target: String) -> String:
  match target:
    case "node":
      "node:24"
    case _:
      "chromium:153.0.8010.12"

def config_condition_tail(+conds: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      "," ++ css_drop_last_char(String.drop(config_conditions(conds, False{}), 1n))

def config_effective(+conds: String) -> String:
  +extra : String = config_condition_tail(conds, String.is_empty(conds))
  "{\"browserEsm\":[\"browser\",\"import\"" ++ extra ++ ",\"default\"],\"nodeCjs\":[\"node\",\"require\"" ++ extra ++
  ",\"default\"],\"nodeEsm\":[\"node\",\"import\"" ++ extra ++ ",\"default\"]}"

def config_toml_input_kind(+digest: String) -> String:
  match digest:
    case "":
      "null"
    case _:
      "{\"digest\":" ++ Compiler.json_str(digest) ++ ",\"path\":\"knot.toml\"}"

def config_toml_input(+format: String) -> String:
  config_toml_input_kind(build_format_marker(format, "toml-digest"))

def config_display_write_kind(+format: String, display: Bool) -> String:
  match display:
    case True{}:
      ",\"write\":" ++ config_bool(Bool.not(String.eq(build_format_marker(format, "write"), "false")))
    case False{}:
      ""
def config_min_chunk_kind(+value: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "null"
    case False{}:
      value
def config_min_chunk(+format: String) -> String:
  +value : String = build_format_marker(format, "min-chunk-size")
  config_min_chunk_kind(value, String.is_empty(value))
def config_limit_num(+format: String, +key: String, +fallback: String) -> String:
  config_default(build_format_marker(format, key), fallback)
def config_backend_kind(gpu: Bool) -> String:
  match gpu:
    case True{}:
      "gpu"
    case False{}:
      "cpu"
def config_backend(+format: String) -> String:
  config_backend_kind(String.eq(build_format_marker(format, "gpu"), "true"))
def config_display_ops(+format: String, display: Bool) -> String:
  match display:
    case False{}:
      ""
    case True{}:
      ",\"clearOnError\":" ++ config_bool(String.eq(build_format_marker(format, "clear-on-error"), "true")) ++ ",\"diagnostics\":" ++ Compiler.json_str(config_default(build_format_marker(format, "diagnostics"), "text")) ++ ",\"limits\":{\"assetBytes\":268435456,\"cssImports\":10000,\"cssNestingDepth\":256,\"dataDepth\":" ++ config_limit_num(format, "data-depth", "128") ++ ",\"dataNodes\":" ++ config_limit_num(format, "data-nodes", "1000000") ++ ",\"diagnosticBytes\":8388608,\"diagnosticRecords\":10000,\"edges\":500000,\"extensionBatchItems\":10000,\"extensionDependencies\":10000,\"extensionMemoryBytes\":268435456,\"extensionRequestBytes\":16777216,\"extensionResponseBytes\":16777216,\"extensionTimeoutMs\":30000,\"htmlDepth\":256,\"htmlReferences\":100000,\"importDepth\":1024,\"mapSegments\":10000000,\"modules\":100000,\"packageTargetDepth\":64,\"protocolFrameBytes\":67108864,\"sourceBytes\":1073741824,\"stagedBytes\":4294967296,\"watchEvents\":100000},\"logLevel\":" ++ Compiler.json_str(config_default(build_format_marker(format, "log-level"), "warning")) ++ ",\"requestedBackend\":" ++ Compiler.json_str(config_backend(format))
def config_fields(+entries: String, +out: String, +conds: String, +format: String, +packages: String, +scopes: String, +redacted: Bool) -> String:
  +target : String = config_default(build_format_marker(format, "target"), "browser")
  +ignore : Bool = String.eq(build_format_marker(format, "ignore-side-effects-annotations"), "true")
  +file : String = config_output_file(out, String.is_empty(out))
  +loader : String = build_format_marker(format, "loader")
  "{\"aliases\":{},\"chunkMergeOverhead\":{\"floorBytes\":32768,\"minChunkBytes\":" ++ config_min_chunk(format) ++ ",\"percent\":10},\"conditions\":" ++ config_conditions(conds, String.is_empty(conds)) ++
  ",\"configInputs\":{\"libraryManifest\":null,\"outputPackages\":" ++ scopes ++ ",\"toml\":" ++ config_toml_input(format) ++ ",\"tsconfig\":[]},\"effectiveConditions\":" ++ config_effective(conds) ++ ",\"entries\":[" ++ entries ++
  "],\"execution\":{\"cssBaseline\":\"chromium:153.0.8010.12\",\"targetBaseline\":" ++ Compiler.json_str(config_target_baseline(target)) ++ "},\"extensions\":[],\"external\":[" ++ config_external(format) ++
  "],\"format\":" ++ Compiler.json_str(build_format_base(format)) ++ ",\"ignoreSideEffectsAnnotations\":" ++ config_bool(ignore) ++
  ",\"library\":{\"exports\":{},\"packageJson\":null},\"loaders\":" ++ config_mapping_kind(loader, String.is_empty(loader)) ++
  ",\"lockfileDigest\":null,\"metadata\":{\"sourceRoot\":\"\"},\"naming\":" ++ config_naming(format) ++ ",\"output\":{\"file\":" ++ file ++
  "},\"packages\":" ++ Compiler.json_str(packages) ++ ",\"preload\":" ++ Compiler.json_str(config_default(build_format_marker(format, "preload"), "none")) ++ ",\"preserveSymlinks\":false,\"publicPath\":" ++ Compiler.json_str(build_format_marker(format, "public")) ++
  ",\"security\":{\"assetRoot\":\".\",\"csp\":null,\"strictAssets\":true},\"sourceMap\":" ++ Compiler.json_str(sourcemap_mode(build_format_marker(format, "sourcemap"))) ++
  ",\"sourcesContent\":" ++ Compiler.json_str(config_default(build_format_marker(format, "sources-content"), "exclude")) ++ ",\"splitting\":" ++
  config_bool(String.eq(build_format_marker(format, "splitting"), "true")) ++ ",\"target\":" ++ Compiler.json_str(target) ++
  ",\"transforms\":" ++ config_transforms(format, redacted) ++ ",\"treeShaking\":true,\"workspacePackages\":\"bundle\"" ++ config_display_write_kind(format, redacted) ++ config_display_ops(format, redacted) ++ "}"

def config_apply_library(+fields: String, +path: String, +digest: String, present: Bool) -> String:
  match present:
    case False{}:
      fields
    case True{}:
      str_replace(0n, str_replace(0n, fields, "\"libraryManifest\":null", "\"libraryManifest\":" ++ Compiler.json_str(digest), False{}, False{}), "\"packageJson\":null", "\"packageJson\":" ++ Compiler.json_str(path), False{}, False{})
def config_library_kind(+path: String, empty: Bool) -> IO(String & String & Bool):
  match empty:
    case True{}:
      IO.pure(String & String & Bool, ("", "", False{}))
    case False{}:
      do IO<String & String & Bool>:
        digest : String <- IO.try(String, Hash.sha256_b64(path))
        return (path, digest, True{})
def config_library(+format: String) -> IO(String & String & Bool):
  +path : String = build_format_marker(format, "library-exports")
  config_library_kind(path, String.is_empty(path))

def config_apply_both(+raw: String, +shown: String, +path: String, +digest: String, present: Bool) -> String & String:
  match present:
    case False{}:
      (raw, shown)
    case True{}:
      (config_apply_library(raw, path, digest, True{}), config_apply_library(shown, path, digest, True{}))

def config_finish(pair: String & String, +portable: Bool) -> IO(String):
  (+fields, +display) = pair
  do IO<String>:
    digest : String <- IO.try(String, Hash.sha256_text("{\"fields\":" ++ fields ++ ",\"portable\":" ++ config_bool(portable) ++ ",\"version\":1}"))
    return "{\"config\":" ++ display ++ ",\"configDigest\":" ++ Compiler.json_str(digest) ++ ",\"portable\":" ++ config_bool(portable) ++ ",\"version\":1}"

def config_record_scoped(+entries: String, +out: String, +conds: String, +format: String, scoped: String & Bool, lib: String & String & Bool) -> IO(String):
  (+scopes, +portable) = scoped
  (+lib_path, +lib_digest, lib_present) = lib
  +packages : String = config_default(build_format_marker(format, "packages"), "bundle")
  config_finish(config_apply_both(config_fields(entries, out, conds, format, packages, scopes, False{}), config_fields(entries, out, conds, format, packages, scopes, True{}), lib_path, lib_digest, lib_present), portable)

def config_record(+file: String, +out: String, +outdir: String, +conds: String, +format: String, +extra: String) -> IO(String):
  do IO<String>:
    +root : String <- IO.try(String, Fs.cwd())
    +entries : String <- config_entries_kind(file, root, String.is_empty(file))
    +output : String <- config_output_name_kind(file, out, outdir, format, String.is_empty(file))
    scoped : String & Bool <- scope_records(file, out, outdir, format, extra)
    lib : String & String & Bool <- config_library(format)
    config_record_scoped(entries, output, conds, format, scoped, lib)

def output_check_code(first: Bool, prev_dot: Bool, slash: Bool, dot: Bool) -> Nat:
  match first:
    case True{}:
      match slash:
        case True{}:
          match dot:
            case True{}:
              3n
            case False{}:
              2n
        case False{}:
          match dot:
            case True{}:
              1n
            case False{}:
              0n
    case False{}:
      match prev_dot:
        case True{}:
          match dot:
            case True{}:
              3n
            case False{}:
              0n
        case False{}:
          match dot:
            case True{}:
              1n
            case False{}:
              0n

def output_check_finish(+acc: String, safe: Bool) -> String:
  match safe:
    case True{}:
      String.reverse(acc)
    case False{}:
      ""

@unsafe def output_check_go(sel: Nat, +path: String, +acc: String, first: Bool, prev_dot: Bool, safe: Bool, c: Char, dot: Bool, slash: Bool, code: Nat) -> String:
  match sel:
    case 0n:
      match path:
        case SNil{}:
          output_check_finish(acc, safe)
        case SCon{+h, t}:
          +is_slash : Bool = Char.is_eq(h, '/')
          +is_dot : Bool = Char.is_eq(h, '.')
          output_check_go(1n, t, acc, first, prev_dot, safe, h, is_dot, is_slash, 0n)
    case 1n:
      output_check_go(2n, path, acc, False{}, False{}, safe, c, False{}, False{}, output_check_code(first, prev_dot, slash, dot))
    case _:
      match code:
        case 0n:
          output_check_go(0n, path, SCon{c, acc}, False{}, False{}, safe, 'a', False{}, False{}, 0n)
        case 1n:
          output_check_go(0n, path, SCon{c, acc}, False{}, True{}, safe, 'a', False{}, False{}, 0n)
        case 2n:
          output_check_go(0n, path, SCon{c, acc}, False{}, False{}, False{}, 'a', False{}, False{}, 0n)
        case _:
          output_check_go(0n, path, SCon{c, acc}, False{}, True{}, False{}, 'a', False{}, False{}, 0n)

def output_path_checked(+path: String) -> String:
  output_check_go(0n, path, "", True{}, False{}, True{}, 'a', False{}, False{}, 0n)

def bundle_write_checked_result(+file: String, +output: String, +conds: String, +meta: String, +format: String, html: Bool) -> IO(Unit):
  match output:
    case SNil{}:
      IO.die(Unit, 2, "knot: output path escapes the project (unsafe_output)")
    case SCon{h, t}:
      bundle_write_entry(file, SCon{h, t}, conds, meta, format, html)

def bundle_write_checked(+file: String, +output: String, +conds: String, +meta: String, +format: String, html: Bool) -> IO(Unit):
  +checked : String = output_path_checked(output)
  bundle_write_checked_result(file, checked, conds, meta, format, html)

def build_meta_flag(+flag: String) -> String:
  match flag:
    case "--manifest":
      "manifest"
    case "--metafile":
      "metafile"
    case "--profile":
      "profile"
    case "--target":
      "target"
    case "--loader":
      "loader"
    case "--external":
      "external"
    case "--define":
      "define"
    case "--drop":
      "drop"
    case "--entry-names":
      "entry-names"
    case "--entry-naming":
      "entry-names"
    case "--chunk-names":
      "chunk-names"
    case "--chunk-naming":
      "chunk-names"
    case "--asset-names":
      "asset-names"
    case "--asset-naming":
      "asset-names"
    case "--css-naming":
      "css-naming"
    case "--root":
      "root"
    case "--packages":
      "packages"
    case "--min-chunk-size":
      "min-chunk-size"
    case "--sources-content":
      "sources-content"
    case "--preload":
      "preload"
    case "--clear-on-error":
      "clear-on-error"
    case "--ignore-side-effects-annotations":
      "ignore-side-effects-annotations"
    case "--log-level":
      "log-level"
    case "--diagnostics":
      "diagnostics"
    case "--cpu":
      "cpu"
    case "--gpu":
      "gpu"
    case "--write":
      "write"
    case "--charset":
      "charset"
    case "--platform":
      "platform"
    case "--tsconfig-raw":
      "tsconfig-raw"
    case "--tsconfig":
      "tsconfig"
    case "--data-depth":
      "data-depth"
    case "--data-nodes":
      "data-nodes"
    case "--library-exports":
      "library-exports"
    case _:
      "metafile"

def build_extra_value_flag(+flag: String) -> Bool:
  match flag:
    case "--target":
      True{}
    case "--profile":
      True{}
    case "--loader":
      True{}
    case "--external":
      True{}
    case "--define":
      True{}
    case "--drop":
      True{}
    case "--entry-names":
      True{}
    case "--chunk-names":
      True{}
    case "--asset-names":
      True{}
    case "--entry-naming":
      True{}
    case "--chunk-naming":
      True{}
    case "--css-naming":
      True{}
    case "--root":
      True{}
    case "--packages":
      True{}
    case "--min-chunk-size":
      True{}
    case "--sources-content":
      True{}
    case "--preload":
      True{}
    case "--clear-on-error":
      True{}
    case "--ignore-side-effects-annotations":
      True{}
    case "--log-level":
      True{}
    case "--diagnostics":
      True{}
    case "--cpu":
      True{}
    case "--gpu":
      True{}
    case "--write":
      True{}
    case "--charset":
      True{}
    case "--platform":
      True{}
    case "--tsconfig-raw":
      True{}
    case "--tsconfig":
      True{}
    case "--data-depth":
      True{}
    case "--data-nodes":
      True{}
    case "--library-exports":
      True{}
    case _:
      False{}

def build_value_flag(+flag: String) -> Bool:
  Bool.or(String.eq(flag, "--manifest"), Bool.or(String.eq(flag, "--metafile"), build_extra_value_flag(flag)))
@unsafe def build_expand_args_go(sel: Nat, +args: List<&2, String>, +head: String, +tail: List<&2, String>, inline: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match args:
        case Nil{}:
          Nil{}
        case Con{+h, rest}:
          build_expand_args_go(1n, rest, h, rest, Bool.and(String.starts_with(h, "--"), String.contains(h, "=")))
    case 1n:
      match inline:
        case True{}:
          +key : String = css_drop_last_char(css_take_until_char(head, '='))
          +value : String = String.drop(head, Nat.add(String.length(key), 1n))
          +more : List<&2, String> = build_expand_args_go(0n, tail, "", Nil{}, False{})
          Con{key, Con{value, more}}
        case False{}:
          +more : List<&2, String> = build_expand_args_go(0n, tail, "", Nil{}, False{})
          Con{head, more}
    case _:
      Nil{}

def build_expand_args(+args: List<&2, String>) -> List<&2, String>:
  build_expand_args_go(0n, args, "", Nil{}, False{})

def is_meta_flag(+which: String) -> Bool:
  match which:
    case "manifest":
      True{}
    case "metafile":
      True{}
    case "profile":
      True{}
    case "target":
      True{}
    case "loader":
      True{}
    case "external":
      True{}
    case "define":
      True{}
    case "drop":
      True{}
    case "entry-names":
      True{}
    case "chunk-names":
      True{}
    case "asset-names":
      True{}
    case "css-naming":
      True{}
    case "root":
      True{}
    case "packages":
      True{}
    case "min-chunk-size":
      True{}
    case "sources-content":
      True{}
    case "preload":
      True{}
    case "clear-on-error":
      True{}
    case "ignore-side-effects-annotations":
      True{}
    case "log-level":
      True{}
    case "diagnostics":
      True{}
    case "cpu":
      True{}
    case "gpu":
      True{}
    case "write":
      True{}
    case "charset":
      True{}
    case "platform":
      True{}
    case "tsconfig-raw":
      True{}
    case "tsconfig":
      True{}
    case "data-depth":
      True{}
    case "data-nodes":
      True{}
    case "library-exports":
      True{}
    case _:
      False{}

def build_meta_value(+meta: String, +which: String, +val: String) -> String:
  match which:
    case "manifest":
      "manifest:" ++ val
    case "metafile":
      val
    case _:
      meta

def build_profile_flag_kind(+format: String, +value: String, first: Bool, same: Bool) -> String:
  match first:
    case True{}:
      format ++ ";profile=" ++ value
    case False{}:
      match same:
        case True{}:
          format
        case False{}:
          format ++ ";profile-conflict=true"

def build_profile_flag(+format: String, +value: String) -> String:
  build_profile_flag_kind(format, value, Bool.not(String.contains(format, ";profile=")), String.eq(build_format_marker(format, "profile"), value))

def build_option_format(+format: String, +which: String, +val: String) -> String:
  match which:
    case "manifest":
      format
    case "metafile":
      format
    case "profile":
      build_profile_flag(format, val)
    case "target":
      format ++ ";target=" ++ val
    case "loader":
      format ++ ";loader=" ++ val
    case "external":
      format ++ ";external=" ++ val
    case "define":
      format ++ ";define=" ++ val
    case "drop":
      format ++ ";drop=" ++ val
    case "entry-names":
      format ++ ";entry-names=" ++ val
    case "chunk-names":
      format ++ ";chunk-names=" ++ val
    case "asset-names":
      format ++ ";asset=" ++ val
    case "css-naming":
      format ++ ";css-naming=" ++ val
    case "root":
      format ++ ";root=" ++ val
    case "packages":
      format ++ ";packages=" ++ val
    case "min-chunk-size":
      format ++ ";min-chunk-size=" ++ val
    case "sources-content":
      format ++ ";sources-content=" ++ val
    case "preload":
      format ++ ";preload=" ++ val
    case "clear-on-error":
      format ++ ";clear-on-error=" ++ val
    case "ignore-side-effects-annotations":
      format ++ ";ignore-side-effects-annotations=" ++ val
    case "log-level":
      format ++ ";log-level=" ++ val
    case "diagnostics":
      format ++ ";diagnostics=" ++ val
    case "cpu":
      format ++ ";cpu=" ++ val
    case "gpu":
      format ++ ";gpu=" ++ val
    case "write":
      format ++ ";write=" ++ val
    case "charset":
      format ++ ";charset=" ++ val
    case "platform":
      format ++ ";platform=" ++ val
    case "tsconfig-raw":
      format ++ ";tsconfig-raw=" ++ val
    case "tsconfig":
      format ++ ";tsconfig=" ++ val
    case "data-depth":
      format ++ ";data-depth=" ++ val
    case "data-nodes":
      format ++ ";data-nodes=" ++ val
    case "library-exports":
      format ++ ";library-exports=" ++ val
    case _:
      format
def manifest_many_append(+acc: String, +piece: String, empty: Bool) -> String:
  match empty:
    case True{}:
      piece
    case False{}:
      acc ++ "," ++ piece

def manifest_many_css(+path: String, present: Bool) -> IO(String & Bool):
  match present:
    case True{}:
      do IO<String & Bool>:
        +css : String <- read_text(path)
        return (css, False{})
    case False{}:
      IO.pure(String & Bool, ("", True{}))

def manifest_many_output_piece(+out: String, +js: String, css_info: String & Bool, +assets: String, +dynamic: String, +dynamic_edges: String, +digest: String, +mode: String) -> IO(String):
  (css, css_empty) = css_info
  do IO<String>:
    +css_output : String <- manifest_css(out, css, css_empty, mode)
    return Compiler.json_str(out) ++ ":{\"kind\":\"js\",\"bytes\":" ++ Nat.show(String.length(js)) ++ ",\"digest\":" ++ Compiler.json_str(digest) ++ dynamic_edges ++ manifest_source_map_field(out, mode) ++ "}" ++ css_output ++ assets ++ dynamic

@unsafe def manifest_many_go(
  files: List<&2, String>,
  +outdir: String,
  +conds: String,
  +format: String,
  +entries: String,
  +outputs: String
) -> IO(String & String):
  match files:
    case Nil{}:
      IO.pure(String & String, (entries, outputs))
    case Con{+file, rest}:
      do IO<String & String>:
        +output : String <- build_output_final(file, "", outdir, format, String.ends_with(file, ".html"))
        u : Unit <- bundle_write_checked(file, output, conds, "", format, String.ends_with(file, ".html"))
        raw : String <- read_text(file)
        +src : String <- normalize_source(raw)
        js : String <- read_text(output)
        +css_file : String = css_path(output)
        css_present : Bool <- file_exists(css_file)
        css_info : String & Bool <- manifest_many_css(css_file, css_present)
        +digest : String <- IO.try(String, Hash.sha256_b64(output))
        +graph : List<&2, String> <- bundle_files_conds(file, external_conds(conds, format))
        +dynamic : String <- graph_dyn_records(0n, graph, Compiler.dirname(output), sourcemap_mode(build_format_marker(format, "sourcemap")), format, "", False{})
        +dynamic_edges : String <- graph_dynamic_imports(graph, output, format)
        +assets : String <- manifest_assets(output, graph, build_format_marker(format, "asset"))
        +entry : String = Compiler.json_str(Compiler.basename(file)) ++ ":" ++ Compiler.json_str(output)
        +output_piece : String <- manifest_many_output_piece(output, js, css_info, assets, dynamic, dynamic_edges, digest, sourcemap_mode(build_format_marker(format, "sourcemap")))
        +more : String & String <- manifest_many_go(rest, outdir, conds, format, manifest_many_append(entries, entry, String.is_empty(entries)), manifest_many_append(outputs, output_piece, String.is_empty(outputs)))
        return more

@unsafe def manifest_collect_go(
  files: List<&2, String>,
  +outdir: String,
  +conds: String,
  +format: String,
  +entries: String,
  +outputs: String
) -> IO(String & String):
  match files:
    case Nil{}:
      IO.pure(String & String, (entries, outputs))
    case Con{+file, rest}:
      do IO<String & String>:
        +output : String <- build_output_final(file, "", outdir, format, String.ends_with(file, ".html"))
        raw : String <- read_text(file)
        +src : String <- normalize_source(raw)
        js : String <- read_text(output)
        +css_file : String = css_path(output)
        css_present : Bool <- file_exists(css_file)
        css_info : String & Bool <- manifest_many_css(css_file, css_present)
        +digest : String <- IO.try(String, Hash.sha256_b64(output))
        +graph : List<&2, String> <- bundle_files_conds(file, external_conds(conds, format))
        +dynamic : String <- graph_dyn_records(0n, graph, Compiler.dirname(output), sourcemap_mode(build_format_marker(format, "sourcemap")), format, "", False{})
        +dynamic_edges : String <- graph_dynamic_imports(graph, output, format)
        +assets : String <- manifest_assets(output, graph, build_format_marker(format, "asset"))
        +entry : String = Compiler.json_str(Compiler.basename(file)) ++ ":" ++ Compiler.json_str(output)
        +output_piece : String <- manifest_many_output_piece(output, js, css_info, assets, dynamic, dynamic_edges, digest, sourcemap_mode(build_format_marker(format, "sourcemap")))
        +more : String & String <- manifest_collect_go(rest, outdir, conds, format, manifest_many_append(entries, entry, String.is_empty(entries)), manifest_many_append(outputs, output_piece, String.is_empty(outputs)))
        return more

def manifest_shared_chunk_kind(+path: String, exists: Bool, +mode: String) -> IO(String):
  match exists:
    case True{}:
      do IO<String>:
        +chunk : String <- read_text(path)
        +digest : String <- IO.try(String, Hash.sha256_b64(path))
        return "," ++ Compiler.json_str(path) ++ ":{\"bytes\":" ++ Nat.show(String.length(chunk)) ++ ",\"kind\":\"chunk\",\"digest\":" ++ Compiler.json_str(digest) ++ manifest_source_map_field(path, mode) ++ "}"
    case False{}:
      IO.pure(String, "")

def manifest_shared_chunk(+outdir: String, +chunk: String, +mode: String) -> IO(String):
  +path : String = Compiler.join_rel(outdir, chunk)
  do IO<String>:
    exists : Bool <- file_exists(path)
    manifest_shared_chunk_kind(path, exists, mode)


def build_entries_manifest_done(+meta: String, parts: String & String) -> IO(Unit):
  (entries, outputs) = parts
  write_text_atomic(String.drop(meta, 9n), "{\"version\":1,\"entries\":{" ++ entries ++ "},\"outputs\":{" ++ outputs ++ "}}")

def build_entries_manifest(+file: String, +outdir: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    parts : String & String <- manifest_many_go(String.lines(file), outdir, conds_join(conds), format ++ ";entry-roots=" ++ file, "", "")
    build_entries_manifest_done(meta, parts)


@unsafe def list_intersect_go(sel: Nat, +files: List<&2, String>, +other: List<&2, String>, +acc: List<&2, String>, +h: String, seen: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match files:
        case Nil{}:
          acc
        case Con{+head, rest}:
          list_intersect_go(1n, rest, other, acc, head, has_file(0n, other, head, False{}))
    case _:
      match seen:
        case True{}:
          list_intersect_go(0n, files, other, list_app(acc, h), "", False{})
        case False{}:
          list_intersect_go(0n, files, other, acc, "", False{})

def list_intersect(files: List<&2, String>, other: List<&2, String>) -> List<&2, String>:
  list_intersect_go(0n, files, other, Nil{}, "", False{})

@unsafe def list_diff_go(sel: Nat, +files: List<&2, String>, +shared: List<&2, String>, +acc: List<&2, String>, +h: String, seen: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match files:
        case Nil{}:
          acc
        case Con{+head, rest}:
          list_diff_go(1n, rest, shared, acc, head, has_file(0n, shared, head, False{}))
    case _:
      match seen:
        case True{}:
          list_diff_go(0n, files, shared, acc, "", False{})
        case False{}:
          list_diff_go(0n, files, shared, list_app(acc, h), "", False{})

def list_diff(files: List<&2, String>, shared: List<&2, String>) -> List<&2, String>:
  list_diff_go(0n, files, shared, Nil{}, "", False{})


@unsafe def shared_entries_go(sel: Nat, files: List<&2, String>, shared: List<&2, String>, first: Bool, +conds: String, graph: List<&2, String>) -> IO(List<&2, String>):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(List<&2, String>, shared)
        case Con{+file, rest}:
          do IO<List<&2, String>>:
            next_graph : List<&2, String> <- bundle_files_conds(file, conds)
            shared_entries_go(1n, rest, shared, first, conds, next_graph)
    case _:
      match first:
        case True{}:
          shared_entries_go(0n, files, graph, False{}, conds, Nil{})
        case False{}:
          shared_entries_go(0n, files, list_intersect(shared, graph), False{}, conds, Nil{})

@unsafe def collect_keep_entries_go(files: List<&2, String>, +conds: String, +acc: List<&2, String>) -> IO(List<&2, String>):
  match files:
    case Nil{}:
      IO.pure(List<&2, String>, acc)
    case Con{+file, rest}:
      do IO<List<&2, String>>:
        graph : List<&2, String> <- bundle_files_conds(file, conds)
        keep : List<&2, String> <- collect_keep(graph)
        collect_keep_entries_go(rest, conds, strs_cat(acc, keep))

@unsafe def list_unique_go(sel: Nat, +xs: List<&2, String>, +acc: List<&2, String>, +h: String, seen: Bool) -> List<&2, String>:
  match sel:
    case 0n:
      match xs:
        case Nil{}:
          acc
        case Con{+head, rest}:
          list_unique_go(1n, rest, acc, head, has_file(0n, acc, head, False{}))
    case _:
      match seen:
        case True{}:
          list_unique_go(0n, xs, acc, "", False{})
        case False{}:
          list_unique_go(0n, xs, list_app(acc, h), "", False{})

def list_unique(xs: List<&2, String>) -> List<&2, String>:
  list_unique_go(0n, xs, Nil{}, "", False{})

@unsafe def shared_exports_go(files: List<&2, String>, +acc: List<&2, String>) -> IO(List<&2, String>):
  match files:
    case Nil{}:
      IO.pure(List<&2, String>, acc)
    case Con{+file, rest}:
      do IO<List<&2, String>>:
        raw : String <- read_text(file)
        src : String <- normalize_source(raw)
        names : List<&2, String> <- shared_exports_go(rest, list_unique(strs_cat(acc, Compiler.exports_of(src))))
        return names


def shared_import_item_kind(+name: String, default: Bool) -> String:
  match default:
    case True{}:
      "default as __knot_default_value"
    case False{}:
      name

def shared_import_item(+name: String) -> String:
  shared_import_item_kind(name, String.eq(name, "default"))

def shared_import_next(+acc: String, +item: String, first: Bool) -> String:
  match first:
    case True{}:
      item
    case False{}:
      acc ++ ", " ++ item

@unsafe def shared_import_names_go(+names: List<&2, String>, +acc: String, first: Bool) -> String:
  match names:
    case Nil{}:
      acc
    case Con{+h, rest}:
      +item : String = shared_import_item(h)
      shared_import_names_go(rest, shared_import_next(acc, item, first), False{})

def shared_import_prefix_items(+chunk: String, +items: String, none: Bool) -> String:
  match none:
    case True{}:
      "import \"./" ++ Compiler.basename(chunk) ++ "\";\n"
    case False{}:
      "import { " ++ items ++ " } from \"./" ++ Compiler.basename(chunk) ++ "\";\n"

def shared_import_prefix_kind(+chunk: String, +items: String, empty: Bool) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      shared_import_prefix_items(chunk, items, String.is_empty(items))

def shared_import_prefix(+chunk: String, names: List<&2, String>) -> String:
  shared_import_prefix_kind(chunk, shared_import_names_go(names, "", True{}), String.is_empty(chunk))

def write_shared_chunk_esm(shared: List<&2, String>, +keep: List<&2, String>, +chunk: String, +outdir: String, names: List<&2, String>, +format: String) -> IO(Unit):
  do IO<Unit>:
    js : String <- emit_files(shared, keep, False{}, False{}, "", String.eq(build_format_marker(format, "ignore-side-effects-annotations"), "true"))
    +body : String = js ++ "\n" ++ esm_exports_go(names, "")
    transpile_ok_to(Compiler.join_rel(outdir, chunk), body, Compiler.make_map(chunk, Nil{}), "linked")

@unsafe def build_entries_shared_go(files: List<&2, String>, +outdir: String, +conds: String, +format: String, +link_format: String, +shared: List<&2, String>, +keep: List<&2, String>, +chunk: String, +names: List<&2, String>) -> IO(Unit):
  match files:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+file, rest}:
      do IO<Unit>:
        +output : String <- build_output_final(file, "", outdir, format, False{})
        +graph : List<&2, String> <- bundle_files_conds(file, conds)
        +unique : List<&2, String> = list_diff(graph, shared)
        +js0 : String <- emit_files(unique, keep, build_minify_enabled(format), String.eq(build_format_marker(format, "minify-identifiers"), "true"), build_format_marker(format, "loader"), String.eq(build_format_marker(format, "ignore-side-effects-annotations"), "true"))
        js : String <- rewrite_asset_refs(unique, js0, build_format_marker(format, "asset"), build_format_marker(format, "public"))
        raw : String <- read_text(file)
        +src : String <- normalize_source(raw)
        formatted : String <- bundle_format_pick(format, src, js, String.eq(format, "cjs"), String.eq(format, "esm"))
        +output_src : String = shared_import_prefix(chunk, names) ++ formatted
        split_check : Unit <- bundle_split_validate(link_format, Compiler.dyn_imports_of(src), Nil{})
        u0 : Unit <- bundle_preflight(file, src, output, link_format)
        u1 : Unit <- transpile_ok_to(output, output_src, Compiler.make_map(file, Nil{}), sourcemap_mode(build_format_marker(format, "sourcemap")))
        +css : String <- emit_css_files(graph, Compiler.dirname(css_path(output)), "", build_format_marker(format, "asset"), build_format_marker(format, "public"), build_minify_enabled(format))
        u2 : Unit <- write_css_if(output, css, String.is_empty(css), build_format_marker(format, "sourcemap"), graph)
        u3 : Unit <- write_css_map_if(output, css, graph, build_format_marker(format, "sourcemap"), String.is_empty(css))
        u4 : Unit <- copy_assets(graph, output, build_format_marker(format, "asset"))
        u5 : Unit <- bundle_write_dyn(file, output, src, build_format_marker(format, "public"), sourcemap_mode(build_format_marker(format, "sourcemap")), link_format)
        u5b : Unit <- graph_dyn_emit(0n, graph, output, build_format_marker(format, "public"), sourcemap_mode(build_format_marker(format, "sourcemap")), link_format, "", False{})
        build_entries_shared_go(rest, outdir, conds, format, link_format, shared, keep, chunk, names)

def build_entries_plain_go(files: List<&2, String>, +outdir: String, +conds: String, +format: String) -> IO(Unit):
  match files:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{+file, rest}:
      do IO<Unit>:
        +output : String <- build_output_final(file, "", outdir, format, String.ends_with(file, ".html"))
        u : Unit <- bundle_write_checked(file, output, conds, "", format, String.ends_with(file, ".html"))
        build_entries_plain_go(rest, outdir, conds, format)

def entries_have_html(+files: List<&2, String>) -> Bool:
  match files:
    case Nil{}:
      False{}
    case Con{+file, rest}:
      Bool.or(String.ends_with(file, ".html"), entries_have_html(rest))

def list_is_empty(+xs: List<&2, String>) -> Bool:
  match xs:
    case Nil{}:
      True{}
    case Con{_, _}:
      False{}

def write_shared_chunk_if(shared: List<&2, String>, keep: List<&2, String>, +chunk: String, +outdir: String, names: List<&2, String>, empty: Bool, +format: String) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      write_shared_chunk_esm(shared, keep, chunk, outdir, names, format)

def shared_chunk_template_kind(empty: Bool, +template: String) -> String:
  match empty:
    case True{}:
      ""
    case False{}:
      match template:
        case "":
          "knot-shared.js"
        case _:
          entry_template_name("shared.ts", template, "", False{})

def scope_chunk_js(+outdir: String, +name: String, js: Bool) -> String:
  match js:
    case True{}:
      Compiler.join_rel(outdir, name)
    case False{}:
      ""
def shared_chunk_name(empty: Bool, +template: String, +format: String) -> String:
  node_output_name(shared_chunk_template_kind(empty, template), format, Bool.or(String.is_empty(template), String.contains(template, "[ext]")))
def scope_chunk_emit(+outdir: String, +name: String) -> String:
  scope_chunk_js(outdir, name, String.ends_with(name, ".js"))
def scope_chunk_present_kind(+outdir: String, +format: String, emit: Bool) -> String:
  match emit:
    case False{}:
      ""
    case True{}:
      scope_chunk_emit(outdir, shared_chunk_name(False{}, build_format_marker(format, "chunk-names"), format))
def scope_chunk_path_kind(+file: String, +outdir: String, +conds: String, +format: String, splitting: Bool) -> IO(String):
  match splitting:
    case False{}:
      IO.pure(String, "")
    case True{}:
      do IO<String>:
        +shared : List<&2, String> <- shared_entries_go(0n, String.lines(file), Nil{}, True{}, conds, Nil{})
        return scope_chunk_present_kind(outdir, format, Bool.not(list_is_empty(shared)))
def scope_chunk_path(+file: String, +outdir: String, +conds: String, +format: String) -> IO(String):
  scope_chunk_path_kind(file, outdir, conds, format, String.eq(build_format_marker(format, "splitting"), "true"))

def build_entries_shared_esm(+file: String, +outdir: String, +conds: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    +shared : List<&2, String> <- shared_entries_go(0n, String.lines(file), Nil{}, True{}, conds, Nil{})
    +keep : List<&2, String> <- collect_keep_entries_go(String.lines(file), conds, Nil{})
    +names : List<&2, String> <- shared_exports_go(shared, Nil{})
    +chunk : String = shared_chunk_name(list_is_empty(shared), build_format_marker(format, "chunk-names"), format)
    u0 : Unit <- write_shared_chunk_if(shared, keep, chunk, outdir, names, list_is_empty(shared), format)
    build_entries_shared_go(String.lines(file), outdir, conds, format, "esm;target=" ++ build_format_marker(format, "target") ++ ";entry-names=" ++ build_format_marker(format, "entry-names") ++ ";external=" ++ external_marker(format) ++ ";splitting=" ++ build_format_marker(format, "splitting") ++ ";entry-roots=" ++ file, shared, keep, chunk, names)
def build_entries_manifest_done_chunk(+meta: String, parts: String & String, +chunk: String) -> IO(Unit):
  (entries, outputs) = parts
  write_text_atomic(String.drop(meta, 9n), "{\"version\":1,\"entries\":{" ++ entries ++ "},\"outputs\":{" ++ outputs ++ chunk ++ "}}")

def build_entries_manifest_esm(+file: String, +outdir: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- build_entries_shared_esm(file, outdir, conds_join(conds), format)
    parts : String & String <- manifest_collect_go(String.lines(file), outdir, conds_join(conds), format ++ ";entry-roots=" ++ file, "", "")
    +chunk_name : String = shared_chunk_name(False{}, build_format_marker(format, "chunk-names"), format)
    +chunk : String <- manifest_shared_chunk(outdir, chunk_name, sourcemap_mode(build_format_marker(format, "sourcemap")))
    build_entries_manifest_done_chunk(meta, parts, chunk)

def build_entries_manifest_kind(+file: String, +outdir: String, +conds: String, +meta: String, +format: String, esm: Bool) -> IO(Unit):
  match esm:
    case True{}:
      build_entries_manifest_esm(file, outdir, conds, meta, format)
    case False{}:
      do IO<Unit>:
        parts : String & String <- manifest_many_go(String.lines(file), outdir, conds_join(conds), format ++ ";entry-roots=" ++ file, "", "")
        build_entries_manifest_done(meta, parts)

def build_entries_kind(files: List<&2, String>, +file: String, +outdir: String, +conds: String, +format: String, html: Bool, esm: Bool) -> IO(Unit):
  match html:
    case True{}:
      build_entries_plain_go(files, outdir, conds, format)
    case False{}:
      match esm:
        case True{}:
          build_entries_shared_esm(file, outdir, conds, format)
        case False{}:
          build_entries_plain_go(files, outdir, conds, format)

def build_entries_go(+file: String, +outdir: String, +conds: String, +format: String) -> IO(Unit):
  build_entries_kind(String.lines(file), file, outdir, conds, format ++ ";entry-roots=" ++ file, entries_have_html(String.lines(file)), String.eq(build_format_base(format), "esm"))
def build_entries_many_meta_kind(+file: String, +outdir: String, +conds: String, +meta: String, +format: String, meta_empty: Bool, manifest: Bool) -> IO(Unit):
  match meta_empty:
    case True{}:
      build_entries_go(file, outdir, conds_join(conds), format)
    case False{}:
      match manifest:
        case True{}:
          build_entries_manifest_kind(file, outdir, conds, meta, format, String.eq(build_format_base(format), "esm"))
        case False{}:
          IO.die(Unit, 2, "knot: multiple entries require --manifest metadata (unsupported_build)")

def build_entries_many_meta(+file: String, +outdir: String, +conds: String, +meta: String, +format: String, meta_empty: Bool) -> IO(Unit):
  build_entries_many_meta_kind(file, outdir, conds, meta, format, meta_empty, String.starts_with(meta, "manifest:"))


def output_collision_seen(+path: String, seen: List<&2, String>) -> Bool:
  match seen:
    case Nil{}:
      False{}
    case Con{+head, rest}:
      Bool.or(String.eq(path, head), output_collision_seen(path, rest))
@unsafe def output_collision_k(sel: Nat, files: List<&2, String>, +outdir: String, +format: String, +seen: List<&2, String>, +output: String, hit: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match files:
        case Nil{}:
          IO.pure(Unit, Unit{})
        case Con{+file, rest}:
          output_collision_k(1n, rest, outdir, format, seen, file, False{})
    case 1n:
      do IO<Unit>:
        +actual : String <- build_output_final(output, "", outdir, format, String.ends_with(output, ".html"))
        output_collision_k(2n, files, outdir, format, seen, actual, output_collision_seen(actual, seen))
    case _:
      match hit:
        case True{}:
          IO.die(Unit, 1, "knot: " ++ output ++ " collides with another output (output_collision)")
        case False{}:
          output_collision_k(0n, files, outdir, format, Con{output, seen}, "", False{})
def output_collision(+file: String, +outdir: String, +format: String) -> IO(Unit):
  output_collision_k(0n, String.lines(file), outdir, format, Nil{}, "", False{})

def build_entries_many_paths(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, out_empty: Bool, dir_empty: Bool) -> IO(Unit):
  match out_empty:
    case False{}:
      IO.die(Unit, 2, "knot: --outfile cannot be combined with multiple entries (unknown_command)")
    case True{}:
      match dir_empty:
        case True{}:
          IO.die(Unit, 2, "knot: multiple entries require --outdir (missing_output)")
        case False{}:
          do IO<Unit>:
            u : Unit <- output_collision(file, outdir, format)
            build_entries_many_meta(file, outdir, conds, meta, format, String.is_empty(meta))

def target_supported(+target: String) -> Bool:
  Bool.or(String.is_empty(target), Bool.or(String.eq(target, "browser"), String.eq(target, "node")))

def target_validate_kind(+target: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: unsupported target " ++ target ++ " (unknown_command)")

def target_validate(+format: String) -> IO(Unit):
  do IO<Unit>:
    +target : String = build_format_marker(format, "target")
    u : Unit <- target_validate_kind(target, target_supported(target))
    target_format_validate(target, build_format_base(format))

def sourcemap_supported(+mode: String) -> Bool:
  Bool.or(String.eq(mode, "none"), Bool.or(String.eq(mode, "linked"), Bool.or(String.eq(mode, "external"), String.eq(mode, "inline"))))

def sourcemap_validate_kind(+mode: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: unsupported source map mode " ++ mode ++ " (unknown_command)")

def sourcemap_validate(+format: String) -> IO(Unit):
  +mode : String = sourcemap_mode(build_format_marker(format, "sourcemap"))
  sourcemap_validate_kind(mode, sourcemap_supported(mode))

def build_meta_validate_kind(multiple: Bool, empty: Bool, manifest: Bool) -> IO(Unit):
  match multiple:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      match empty:
        case True{}:
          IO.pure(Unit, Unit{})
        case False{}:
          match manifest:
            case True{}:
              IO.pure(Unit, Unit{})
            case False{}:
              IO.die(Unit, 2, "knot: multiple entries require --manifest metadata (unsupported_build)")

def build_meta_validate(+meta: String, multiple: Bool) -> IO(Unit):
  build_meta_validate_kind(multiple, String.is_empty(meta), String.starts_with(meta, "manifest:"))

def build_meta_css_kind(+path: String, present: Bool) -> IO(String):
  match present:
    case True{}:
      read_text(path)
    case False{}:
      IO.pure(String, "")

def build_meta_after_single(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, html: Bool) -> IO(Unit):
  match html:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        +output : String <- build_output_final(file, out, outdir, format, False{})
        raw : String <- read_text(file)
        +src : String <- normalize_source(raw)
        js : String <- read_text(output)
        +css_file : String = css_path(output)
        css_present : Bool <- file_exists(css_file)
        css : String <- build_meta_css_kind(css_file, css_present)
        files : List<&2, String> <- bundle_files_conds(file, conds_join(conds))
        meta_write(meta, file, output, src, js, css, files, build_format_marker(format, "asset"), sourcemap_mode(build_format_marker(format, "sourcemap")))

def build_meta_after_many_kind(+file: String, +outdir: String, +conds: String, +meta: String, +format: String, esm: Bool) -> IO(Unit):
  match esm:
    case True{}:
      do IO<Unit>:
        parts : String & String <- manifest_collect_go(String.lines(file), outdir, conds_join(conds), format ++ ";entry-roots=" ++ file, "", "")
        +chunk_name : String = shared_chunk_name(False{}, build_format_marker(format, "chunk-names"), format)
        +chunk : String <- manifest_shared_chunk(outdir, chunk_name, sourcemap_mode(build_format_marker(format, "sourcemap")))
        build_entries_manifest_done_chunk(meta, parts, chunk)
    case False{}:
      build_entries_manifest(file, outdir, conds, meta, format)

def build_meta_after_kind(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, multiple: Bool) -> IO(Unit):
  match multiple:
    case True{}:
      build_meta_after_many_kind(file, outdir, conds, meta, format, String.eq(build_format_base(format), "esm"))
    case False{}:
      build_meta_after_single(file, out, outdir, conds, meta, format, String.ends_with(file, ".html"))

def build_meta_after_kind_empty(empty: Bool, +file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      build_meta_after_kind(file, out, outdir, conds, meta, format, String.contains(file, "\n"))

def build_meta_after(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String) -> IO(Unit):
  build_meta_after_kind_empty(String.is_empty(meta), file, out, outdir, conds, meta, format)

def build_output_dispatch(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, multiple: Bool) -> IO(Unit):
  match multiple:
    case True{}:
      build_entries_many_paths(file, out, outdir, conds, meta, format, String.is_empty(out), String.is_empty(outdir))
    case False{}:
      do IO<Unit>:
        +output : String <- build_output_final(file, out, outdir, format, String.ends_with(file, ".html"))
        bundle_write_checked(file, output, conds_join(conds), meta, format, String.ends_with(file, ".html"))

def build_output_discard_target(+file: String, +out: String, stamp: Nat, out_empty: Bool) -> String:
  match out_empty:
    case True{}:
      file ++ ".knot-check-" ++ Nat.show(stamp)
    case False{}:
      out ++ ".knot-check-" ++ Nat.show(stamp)

def scope_shared_chunk_present(+root: String, +outdir: String, +format: String, +chunk: String, state: String) -> IO(Unit):
  match state:
    case "present":
      do IO<Unit>:
        checked : String & Bool <- scope_record_one(root, Compiler.join_rel(outdir, chunk), scope_replaced(root, outdir, False{}), format)
        return Unit{}
    case "absent":
      IO.pure(Unit, Unit{})
    case _:
      IO.die(Unit, 2, "knot: shared chunk lookup failed (output_module_type)")

def scope_shared_chunk_kind(+outdir: String, +staged: String, +format: String, check: Bool) -> IO(Unit):
  match check:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      do IO<Unit>:
        +root : String <- IO.try(String, Fs.cwd())
        +chunk : String = shared_chunk_name(False{}, build_format_marker(format, "chunk-names"), format)
        +state : String <- scope_probe(Compiler.join_rel(staged, chunk), False{})
        scope_shared_chunk_present(root, outdir, format, chunk, state)

def scope_shared_chunk(+outdir: String, +staged: String, +format: String, multiple: Bool) -> IO(Unit):
  scope_shared_chunk_kind(outdir, staged, format, Bool.and(multiple, Bool.and(String.eq(build_format_marker(format, "target"), "node"), String.eq(build_format_base(format), "esm"))))

def build_output_discard(+file: String, +out: String, +outdir: String, +conds: String, +format: String, +multiple: Bool, dir_empty: Bool) -> IO(Unit):
  match dir_empty:
    case False{}:
      do IO<Unit>:
        stamp : Nat <- IO.now
        +stage : String = outdir ++ ".knot-check-" ++ Nat.show(stamp)
        u0 : Unit <- build_output_dispatch(file, out, stage, conds, "", format, multiple)
        u1 : Unit <- scope_shared_chunk(outdir, stage, format, multiple)
        IO.try(Unit, Fs.remove_dir(stage))
    case True{}:
      do IO<Unit>:
        stamp : Nat <- IO.now
        +target : String = build_output_discard_target(file, out, stamp, String.is_empty(out))
        u0 : Unit <- build_output_dispatch(file, target, "", conds, "", format, multiple)
        IO.try(Unit, Fs.unlink(target))


def write_control(+path: String, +text: String, enabled: Bool) -> IO(Unit):
  match enabled:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      write_text(path, text)
def selected_tsconfig_kind(+raw: String, empty: Bool, +other: String) -> String:
  match empty:
    case False{}:
      raw
    case True{}:
      other
def selected_tsconfig(+format: String) -> String:
  +raw : String = build_format_marker(format, "tsconfig-raw")
  selected_tsconfig_kind(raw, String.is_empty(raw), build_format_marker(format, "tsconfig"))
def prepare_controls(+outdir: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- IO.try(Unit, Fs.mkdir_p(".knot"))
    u1 : Unit <- IO.try(Unit, Data.limits(config_limit_num(format, "data-depth", "128") ++ ":" ++ config_limit_num(format, "data-nodes", "1000000")))
    u2 : Unit <- write_control(".knot/diagnostics-json", "json", String.eq(build_format_marker(format, "diagnostics"), "json"))
    u3 : Unit <- write_control(".knot/clear-on-error", outdir, String.eq(build_format_marker(format, "clear-on-error"), "true"))
    +tsconfig : String = selected_tsconfig(format)
    u4 : Unit <- write_control(".knot/tsconfig-path", tsconfig, Bool.not(String.is_empty(tsconfig)))
    +css : String = build_format_marker(format, "css-naming")
    u5 : Unit <- write_control(".knot/css-naming", css, Bool.not(String.is_empty(css)))
    u6 : Unit <- write_control(".knot/sources-include", "include", String.eq(build_format_marker(format, "sources-content"), "include"))
    return Unit{}
def build_show_config(+file: String, +out: String, +outdir: String, +conds: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    u0 : Unit <- prepare_controls(outdir, format)
    u1 : Unit <- sourcemap_validate(format)
    u2 : Unit <- target_validate(format)
    u3 : Unit <- build_options_validate(format)
    u4 : Unit <- splitting_output_validate(format, outdir)
    +chunk : String <- scope_chunk_path(file, outdir, conds, format)
    +json : String <- config_record(file, out, outdir, conds, format, chunk)
    IO.print(json)

def scope_snapshot_pair(record: String & Bool) -> String:
  (identity, portable) = record
  identity

def scope_snapshot(+file: String, +out: String, +outdir: String, +format: String) -> IO(String):
  do IO<String>:
    current : String & Bool <- scope_records(file, out, outdir, format, "")
    return scope_snapshot_pair(current)

def scope_assert_kind(same: Bool) -> IO(Unit):
  match same:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 2, "knot: output package scope changed during build (output_module_type)")

def scope_assert(+file: String, +out: String, +outdir: String, +format: String, +previous: String) -> IO(Unit):
  do IO<Unit>:
    current : String <- scope_snapshot(file, out, outdir, format)
    scope_assert_kind(String.eq(previous, current))

def scope_validate(+file: String, +out: String, +outdir: String, +format: String) -> IO(Unit):
  do IO<Unit>:
    current : String & Bool <- scope_records(file, out, outdir, format, "")
    return Unit{}

def publish_meta(+format: String, +digest: String) -> String:
  digest ++ "|" ++ config_default(build_format_marker(format, "target"), "browser") ++ "|" ++ build_format_base(format) ++ "|" ++ build_format_marker(format, "public")
def publish_status_recovery(+status: String, recovery: Bool) -> IO(Unit):
  match recovery:
    case True{}:
      IO.die(Unit, 1, "knot: publication record is corrupt (publication_recovery)")
    case False{}:
      IO.die(Unit, 1, "knot: publication failed (publication_error)")
def publish_status_busy(+status: String, busy: Bool) -> IO(Unit):
  match busy:
    case True{}:
      IO.die(Unit, 1, "knot: publication lock is held (publication_busy)")
    case False{}:
      publish_status_recovery(status, String.eq(status, "recovery"))
def publish_status_kind(+status: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      publish_status_busy(status, String.eq(status, "busy"))
def publish_status(+status: String) -> IO(Unit):
  publish_status_kind(status, String.starts_with(status, "ok|"))
def publish_generation(+staged: String, +outdir: String, +format: String, stamp: Nat) -> IO(Unit):
  do IO<Unit>:
    +digest : String <- IO.try(String, Hash.sha256_text(format))
    +status : String <- IO.try(String, Fs.publish("publish", staged, outdir, Nat.show(stamp), publish_meta(format, digest)))
    publish_status(status)

def build_output_atomic_kind(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, +previous: String, +multiple: Bool, stage: Bool) -> IO(Unit):
  match stage:
    case True{}:
      do IO<Unit>:
        +stamp : Nat <- IO.now
        +staged : String = outdir ++ ".knot-stage-" ++ Nat.show(stamp)
        u0 : Unit <- build_output_dispatch(file, out, staged, conds, "", format, multiple)
        u1 : Unit <- scope_assert(file, out, outdir, format, previous)
        u1b : Unit <- scope_shared_chunk(outdir, staged, format, multiple)
        +published : Nat <- IO.now
        u2 : Unit <- publish_generation(staged, outdir, format, published)
        build_meta_after(file, out, outdir, conds, meta, format)
    case False{}:
      build_output_dispatch(file, out, outdir, conds, meta, format, multiple)

def build_output_atomic_write_kind(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, multiple: Bool, write: Bool) -> IO(Unit):
  match write:
    case False{}:
      do IO<Unit>:
        u0 : Unit <- prepare_controls(outdir, format)
        u1 : Unit <- sourcemap_validate(format)
        u2 : Unit <- target_validate(format)
        u3 : Unit <- build_meta_validate(meta, String.contains(file, "\n"))
        u4 : Unit <- build_options_validate(format)
        u5 : Unit <- splitting_output_validate(format, outdir)
        u6 : Unit <- scope_validate(file, out, outdir, format)
        build_output_discard(file, out, outdir, conds, format, multiple, String.is_empty(outdir))
    case True{}:
      do IO<Unit>:
        u0 : Unit <- prepare_controls(outdir, format)
        u1 : Unit <- sourcemap_validate(format)
        u2 : Unit <- target_validate(format)
        u3 : Unit <- build_meta_validate(meta, String.contains(file, "\n"))
        u4 : Unit <- build_options_validate(format)
        u5 : Unit <- splitting_output_validate(format, outdir)
        +previous : String <- scope_snapshot(file, out, outdir, format)
        build_output_atomic_kind(file, out, outdir, conds, meta, format, previous, multiple, Bool.not(String.is_empty(outdir)))

def build_output_atomic(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, multiple: Bool) -> IO(Unit):
  build_output_atomic_write_kind(file, out, outdir, conds, meta, format, multiple, Bool.not(String.eq(build_format_marker(format, "write"), "false")))
def strip_rel_kind(+path: String, dot: Bool) -> String:
  match dot:
    case True{}:
      String.drop(path, 2n)
    case False{}:
      path
def strip_rel(+path: String) -> String:
  strip_rel_kind(path, String.starts_with(path, "./"))
def library_die() -> IO(Unit):
  IO.die(Unit, 2, "knot: package exports do not match the planned output (library_exports)")
def library_ok(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      library_die()
def library_choose(+branch: String, +fallback: String, empty: Bool) -> String:
  match empty:
    case True{}:
      fallback
    case False{}:
      branch
def library_type_ok(+pkg_type: String, cjs: Bool) -> Bool:
  match cjs:
    case True{}:
      Bool.or(String.is_empty(pkg_type), String.eq(pkg_type, "commonjs"))
    case False{}:
      String.eq(pkg_type, "module")
def library_branch_key(cjs: Bool) -> String:
  match cjs:
    case True{}:
      "require"
    case False{}:
      "import"
def library_mode_ok(+format: String) -> Bool:
  Bool.and(String.eq(build_format_marker(format, "packages"), "external"), String.eq(build_format_marker(format, "target"), "node"))
def library_check(+format: String, +out: String, +text: String) -> IO(Unit):
  do IO<Unit>:
    +pkg_type : String <- json_optional_string(text, "type")
    +cjs : Bool = String.eq(build_format_base(format), "cjs")
    +branch : String <- json_optional_string(text, "exports/./" ++ library_branch_key(cjs))
    +fallback : String <- json_optional_string(text, "exports/.")
    +chosen : String = library_choose(branch, fallback, String.is_empty(branch))
    library_ok(Bool.and(library_mode_ok(format), Bool.and(library_type_ok(pkg_type, cjs), Bool.and(Bool.not(String.is_empty(chosen)), String.eq(strip_rel(chosen), strip_rel(out))))))
def library_validate_kind(+format: String, +out: String, +path: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      do IO<Unit>:
        text : String <- read_text(path)
        library_check(format, out, text)
def library_validate(+format: String, +out: String) -> IO(Unit):
  +path : String = build_format_marker(format, "library-exports")
  library_validate_kind(format, out, path, String.is_empty(path))

def serve_output_root_parent(+parent: String, empty: Bool) -> String:
  match empty:
    case True{}:
      "."
    case False{}:
      parent

def serve_output_root_kind(+outdir: String, +output: String, dir_empty: Bool) -> String:
  match dir_empty:
    case True{}:
      serve_output_root_parent(Compiler.dirname(output), String.is_empty(Compiler.dirname(output)))
    case False{}:
      outdir

def serve_output_root(+outdir: String, +output: String) -> String:
  serve_output_root_kind(outdir, output, String.is_empty(outdir))

def serve_output_relative_kind(+root: String, +output: String, starts_root: Bool, dot_root: Bool, starts_dot: Bool) -> String:
  match starts_root:
    case True{}:
      String.drop(output, Nat.add(String.length(root), 1n))
    case False{}:
      match dot_root:
        case True{}:
          match starts_dot:
            case True{}:
              String.drop(output, 2n)
            case False{}:
              output
        case False{}:
          ""

def serve_output_relative(+root: String, +output: String) -> String:
  serve_output_relative_kind(root, output, String.starts_with(output, root ++ "/"), String.eq(root, "."), String.starts_with(output, "./"))

def serve_start_naming(+port: U32, +root: String, +entry: String, naming: Bool) -> IO(Unit):
  match naming:
    case True{}:
      Server.run(port, root, entry, 1)
    case False{}:
      Server.run(port, root, entry, 0)

def serve_start_checked(+root: String, +entry: String, +format: String, port: U32, safe: Bool) -> IO(Unit):
  match safe:
    case True{}:
      serve_start_naming(port, root, entry, Bool.not(String.is_empty(build_format_marker(format, "entry-names"))))
    case False{}:
      IO.die(Unit, 2, "knot serve: output root must be a safe project subdirectory containing the entry (unsafe_output)")

def serve_start_output(+file: String, +out: String, +outdir: String, +format: String, port: U32) -> IO(Unit):
  do IO<Unit>:
    +output : String <- build_output_final(file, out, outdir, format, True{})
    +root : String = serve_output_root(outdir, output)
    +checked_root : String = output_path_checked(root)
    +checked_output : String = output_path_checked(output)
    +entry : String = serve_output_relative(checked_root, checked_output)
    +safe : Bool = Bool.and(Bool.not(String.is_empty(checked_root)), Bool.and(Bool.not(String.eq(checked_root, ".")), Bool.and(Bool.not(String.is_empty(checked_output)), Bool.not(String.is_empty(entry)))))
    serve_start_checked(checked_root, entry, format, port, safe)

def serve_port_nonzero(parsed: Maybe<&2, U32>) -> Bool:
  match parsed:
    case None{}:
      False{}
    case Some{+port}:
      U32.is_ne(port, 0)

def serve_port_at_most(parsed: Maybe<&2, U32>) -> Bool:
  match parsed:
    case None{}:
      False{}
    case Some{+port}:
      U32.is_le(port, 65535)

def serve_port_in_range(+text: String) -> Bool:
  Bool.and(serve_port_nonzero(U32.read(text)), serve_port_at_most(U32.read(text)))

def serve_port_start(+file: String, +out: String, +outdir: String, +format: String, parsed: Maybe<&2, U32>) -> IO(Unit):
  match parsed:
    case None{}:
      IO.die(Unit, 2, "knot serve: --port must be an integer from 1 through 65535 (invalid_option)")
    case Some{+port}:
      serve_start_output(file, out, outdir, format, port)

def serve_port_checked(+file: String, +out: String, +outdir: String, +format: String, +text: String, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      serve_port_start(file, out, outdir, format, U32.read(text))
    case False{}:
      IO.die(Unit, 2, "knot serve: --port must be an integer from 1 through 65535 (invalid_option)")

def serve_port_result(+file: String, +out: String, +outdir: String, +format: String, +text: String) -> IO(Unit):
  serve_port_checked(file, out, outdir, format, text, serve_port_in_range(text))

def serve_browser_target(+target: String) -> Bool:
  Bool.or(String.is_empty(target), String.eq(target, "browser"))

def serve_browser_esm(+format: String) -> Bool:
  Bool.and(String.eq(build_format_base(format), "esm"), serve_browser_target(build_format_marker(format, "target")))


def serve_finish_valid(+file: String, +out: String, +outdir: String, +meta: String, +format: String, show: Bool, valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      serve_port_result(file, out, outdir, format, build_format_marker(format, "serve-port"))
    case False{}:
      IO.die(Unit, 2, "knot serve: expected one browser ESM HTML entry and an output-producing build configuration (unknown_command)")

def serve_finish_meta(+file: String, +out: String, +outdir: String, +meta: String, +format: String, show: Bool, allowed: Bool) -> IO(Unit):
  match allowed:
    case True{}:
      serve_finish_valid(file, out, outdir, meta, format, show, Bool.and(Bool.and(String.ends_with(file, ".html"), Bool.not(String.contains(file, "\n"))), serve_browser_esm(format)))
    case False{}:
      IO.die(Unit, 2, "knot serve: metadata written to stdout is incompatible with a server (unknown_command)")

def serve_finish_write(+file: String, +out: String, +outdir: String, +meta: String, +format: String, show: Bool, allowed: Bool) -> IO(Unit):
  match allowed:
    case True{}:
      serve_finish_meta(file, out, outdir, meta, format, show, Bool.and(Bool.not(String.eq(meta, "-")), Bool.not(String.eq(meta, "manifest:-"))))
    case False{}:
      IO.die(Unit, 2, "knot serve: --write=false is incompatible with serving output (unknown_command)")

def serve_finish_show(+file: String, +out: String, +outdir: String, +meta: String, +format: String, show: Bool) -> IO(Unit):
  match show:
    case True{}:
      IO.die(Unit, 2, "knot serve: --show-config is an inspection-only option (unknown_command)")
    case False{}:
      serve_finish_write(file, out, outdir, meta, format, show, Bool.not(String.eq(build_format_marker(format, "write"), "false")))

def serve_finish(+file: String, +out: String, +outdir: String, +meta: String, +format: String, show: Bool) -> IO(Unit):
  serve_finish_show(file, out, outdir, meta, format, show)

def build_finish_selected_regular(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool) -> IO(Unit):
  match show:
    case True{}:
      do IO<Unit>:
        +planned : String <- build_output_final(file, out, outdir, format, False{})
        u : Unit <- library_validate(format, planned)
        build_show_config(file, out, outdir, conds, format)
    case False{}:
      do IO<Unit>:
        +planned : String <- build_output_final(file, out, outdir, format, False{})
        u : Unit <- library_validate(format, planned)
        build_output_atomic(file, out, outdir, conds, meta, format, String.contains(file, "\n"))

def build_finish_selected_mode(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool, serving: Bool) -> IO(Unit):
  match serving:
    case True{}:
      serve_finish(file, out, outdir, meta, format, show)
    case False{}:
      build_finish_selected_regular(file, out, outdir, conds, meta, format, show)

def build_finish_selected(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool) -> IO(Unit):
  build_finish_selected_mode(file, out, outdir, conds, meta, format, show, String.eq(build_format_marker(format, "serve"), "true"))
def build_profile_target_default(+format: String, +target: String, given: Bool) -> String:
  match given:
    case True{}:
      format
    case False{}:
      format ++ ";target=" ++ target

def build_profile_format_default(+format: String, +base: String, explicit: Bool) -> String:
  match explicit:
    case True{}:
      format
    case False{}:
      base ++ String.drop(format, String.length(build_format_base(format)))

def build_profile_dir_default(+outdir: String, +profile_dir: String, overridden: Bool) -> String:
  match overridden:
    case True{}:
      outdir
    case False{}:
      profile_dir

def serve_directory_default_empty(+directory: String, no_out: Bool) -> String:
  match no_out:
    case True{}:
      "dist"
    case False{}:
      directory

def serve_directory_default_kind(+directory: String, +out: String, serving: Bool, empty: Bool) -> String:
  match serving:
    case True{}:
      match empty:
        case True{}:
          serve_directory_default_empty(directory, String.is_empty(out))
        case False{}:
          directory
    case False{}:
      directory

def serve_directory_default(+directory: String, +out: String, +format: String, empty: Bool) -> String:
  serve_directory_default_kind(directory, out, String.eq(build_format_marker(format, "serve"), "true"), empty)

def build_profile_minify_enabled(+format: String, enabled: Bool) -> String:
  match enabled:
    case True{}:
      format ++ ";minify=true"
    case False{}:
      format

def build_profile_minify_default(+format: String, enabled: Bool, explicit: Bool) -> String:
  match explicit:
    case True{}:
      format
    case False{}:
      build_profile_minify_enabled(format, enabled)

def build_profile_marker_set(+format: String, +key: String, +value: String, empty: Bool) -> String:
  match empty:
    case True{}:
      format
    case False{}:
      format ++ ";" ++ key ++ "=" ++ value

def build_profile_marker_default(+format: String, +key: String, +value: String, explicit: Bool) -> String:
  match explicit:
    case True{}:
      format
    case False{}:
      build_profile_marker_set(format, key, value, String.is_empty(value))

def build_profile_bool_enabled(+format: String, +key: String, enabled: Bool) -> String:
  match enabled:
    case True{}:
      format ++ ";" ++ key ++ "=true"
    case False{}:
      format
def build_profile_bool_default(+format: String, +key: String, enabled: Bool, explicit: Bool) -> String:
  match explicit:
    case True{}:
      format
    case False{}:
      build_profile_bool_enabled(format, key, enabled)
def build_finish_profile(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool, selected: Profile.Settings) -> IO(Unit):
  match selected:
    case Profile.Settings{+target, +base, +profile_dir, minify, +sourcemap, +packages, +library, splitting}:
      +with_format : String = build_profile_format_default(format, base, String.eq(build_format_marker(format, "format-explicit"), "true"))
      +with_target : String = build_profile_target_default(with_format, target, Bool.not(String.is_empty(build_format_marker(with_format, "target"))))
      +with_minify : String = build_profile_minify_default(with_target, minify, Bool.not(String.is_empty(build_format_marker(with_target, "minify"))))
      +with_map : String = build_profile_marker_default(with_minify, "sourcemap", sourcemap, Bool.not(String.is_empty(build_format_marker(with_minify, "sourcemap"))))
      +with_packages : String = build_profile_marker_default(with_map, "packages", packages, Bool.not(String.is_empty(build_format_marker(with_map, "packages"))))
      +with_library : String = build_profile_marker_default(with_packages, "library-exports", library, Bool.not(String.is_empty(build_format_marker(with_packages, "library-exports"))))
      +with_split : String = build_profile_bool_default(with_library, "splitting", splitting, String.eq(build_format_marker(with_library, "splitting"), "true"))
      +profile_directory : String = build_profile_dir_default(outdir, profile_dir, Bool.or(Bool.not(String.is_empty(out)), Bool.not(String.is_empty(outdir))))
      +directory : String = serve_directory_default(profile_directory, out, with_split, String.is_empty(profile_directory))
      build_finish_selected(file, out, directory, conds, meta, with_split, show)

def build_finish_profile_result(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool, result: Result<&2, &2, String, Profile.Settings>) -> IO(Unit):
  match result:
    case Fail{message}:
      IO.die(Unit, 2, message)
    case Done{selected}:
      build_finish_profile(file, out, outdir, conds, meta, format, show, selected)

def build_finish_toml(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool, exists: Bool) -> IO(Unit):
  match exists:
    case True{}:
      do IO<Unit>:
        raw : String <- read_text("knot.toml")
        digest : String <- IO.try(String, Hash.sha256_b64("knot.toml"))
        build_finish_profile_result(file, out, outdir, conds, meta, format ++ ";toml-digest=" ++ digest, show, Profile.select(raw, config_default(build_format_marker(format, "profile"), "default")))
    case False{}:
      build_finish_profile_result(file, out, outdir, conds, meta, format, show, Profile.select("", config_default(build_format_marker(format, "profile"), "default")))

def build_finish(+file: String, +out: String, +outdir: String, +conds: String, +meta: String, +format: String, show: Bool) -> IO(Unit):
  do IO<Unit>:
    exists : Bool <- file_exists("knot.toml")
    build_finish_toml(file, out, outdir, conds, meta, format, show, exists)

def build_simple_flag(+format: String, +flag: String) -> String:
  match flag:
    case "--minify":
      format ++ ";minify=true"
    case _:
      format ++ ";show-config=true"

def build_simple_supported(+flag: String) -> Bool:
  Bool.or(String.eq(flag, "--minify"), String.eq(flag, "--show-config"))

def build_optional_format_flag(+which: String) -> Bool:
  Bool.or(
    String.eq(which, "splitting"),
    Bool.or(
      String.eq(which, "minify-syntax"),
      Bool.or(
        String.eq(which, "minify-whitespace"),
        Bool.or(
          String.eq(which, "minify-identifiers"),
          Bool.or(
            String.eq(which, "keep-names"),
            Bool.or(
              String.eq(which, "clear-on-error"),
              Bool.or(String.eq(which, "ignore-side-effects-annotations"), Bool.or(String.eq(which, "cpu"), String.eq(which, "gpu")))))))))

def build_value_state_kind(missing: Bool) -> Nat:
  match missing:
    case True{}:
      16n
    case False{}:
      11n

def build_value_state(+which: String, +value: String) -> Nat:
  build_value_state_kind(Bool.and(build_optional_format_flag(which), String.starts_with(value, "--")))
def build_value_rest_kind(missing: Bool, +value: String, tail: List<&2, String>) -> List<&2, String>:
  match missing:
    case True{}:
      Con{value, tail}
    case False{}:
      tail

def build_value_rest(+which: String, +value: String, tail: List<&2, String>) -> List<&2, String>:
  build_value_rest_kind(Bool.and(build_optional_format_flag(which), String.starts_with(value, "--")), value, tail)
def build_end_value_state_kind(optional: Bool) -> Nat:
  match optional:
    case True{}:
      16n
    case False{}:
      17n

def build_end_value_state(+which: String) -> Nat:
  build_end_value_state_kind(build_optional_format_flag(which))

@unsafe def run_build_k(sel: Nat, args: List<&2, String>, +file: String, +out: String, +conds: String, +meta: String, +outdir: String, +format: String, +head: String, rest: List<&2, String>, +which: String, +val: String, b0: Bool, b1: Bool, b2: Bool, b3: Bool, b4: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          run_build_k(20n, Nil{}, file, out, conds, meta, outdir, format, "", Nil{}, "", "", String.is_empty(file), String.is_empty(out), False{}, False{}, False{})
        case Con{+h, r}:
          run_build_k(1n, Nil{}, file, out, conds, meta, outdir, format, h, r, "", "", String.eq(h, "--outfile"), String.eq(h, "--conditions"), build_value_flag(h), build_format_option(h), Bool.or(String.eq(h, "--outdir"), String.eq(h, "--public-path")))
    case 1n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "outfile", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(2n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", b1, b2, b3, b4, False{})
    case 2n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "conditions", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(3n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", b1, b2, b3, b4, False{})
    case 3n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, outdir, format, head, rest, build_meta_flag(head), "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(4n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", b1, b2, b3, b4, False{})
    case 4n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, outdir, format, head, rest, build_format_value_flag(head), "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(5n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", b1, b2, b3, b4, False{})
    case 5n:
      match b0:
        case True{}:
          run_build_k(10n, Nil{}, file, out, conds, meta, outdir, format, head, rest, build_path_value_flag(head), "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(21n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", String.is_empty(file), False{}, False{}, False{}, False{})
    case 10n:
      match rest:
        case Con{+v, tail}:
          run_build_k(build_value_state(which, v), Nil{}, file, out, conds, meta, outdir, format, head, build_value_rest(which, v, tail), which, v, String.eq(which, "outfile"), String.eq(which, "conditions"), is_meta_flag(which), build_format_key_option(which), Bool.or(String.eq(which, "outdir"), String.eq(which, "public")))
        case Nil{}:
          run_build_k(build_end_value_state(which), Nil{}, file, out, conds, meta, outdir, format, head, Nil{}, which, "", False{}, False{}, False{}, False{}, False{})
    case 11n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, val, conds, meta, outdir, format, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(12n, Nil{}, file, out, conds, meta, outdir, format, head, rest, which, val, b1, b2, b3, b4, False{})
    case 12n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, out, conds_add(val, conds, String.is_empty(conds)), meta, outdir, format, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(13n, Nil{}, file, out, conds, meta, outdir, format, head, rest, which, val, b1, b2, b3, b4, False{})
    case 13n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, out, conds, build_meta_value(meta, which, val), outdir, build_option_format(format, which, val), "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(14n, Nil{}, file, out, conds, meta, outdir, format, head, rest, which, val, b1, b2, b3, b4, False{})
    case 14n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, out, conds, meta, outdir, build_format_apply_flag(format, val, which), "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          run_build_k(15n, Nil{}, file, out, conds, meta, outdir, format, head, rest, which, val, b1, b2, b3, b4, False{})
    case 15n:
      match b0:
        case True{}:
          run_build_k(0n, rest, file, out, conds, meta, build_path_apply_outdir(outdir, val, String.eq(which, "outdir")), build_path_apply_format(format, val, String.eq(which, "outdir")), "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
        case False{}:
          IO.die(Unit, 2, "knot: unknown build flag " ++ which ++ " (unknown_command)")
    case 17n:
      IO.die(Unit, 2, "knot: build flag " ++ which ++ " requires a value (unknown_command)")
    case 16n:
      run_build_k(0n, rest, file, out, conds, meta, outdir, build_format_apply_flag(format, "true", which), "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
    case 20n:
      match b0:
        case True{}:
          build_finish("", out, outdir, conds, meta, format, String.eq(build_format_marker(format, "show-config"), "true"))
        case False{}:
          run_build_k(22n, Nil{}, file, out, conds, meta, outdir, format, "", Nil{}, "", "", b1, False{}, False{}, False{}, False{})
    case 21n:
      run_build_k(23n, Nil{}, file, out, conds, meta, outdir, format, head, rest, "", "", String.starts_with(head, "-"), build_simple_supported(head), String.is_empty(file), False{}, False{})
    case 23n:
      match b0:
        case True{}:
          match b1:
            case True{}:
              run_build_k(0n, rest, file, out, conds, meta, outdir, build_simple_flag(format, head), "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
            case False{}:
              IO.die(Unit, 2, "knot: unknown build flag " ++ head ++ " (unknown_command)")
        case False{}:
          match b2:
            case True{}:
              run_build_k(0n, rest, head, out, conds, meta, outdir, format, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
            case False{}:
              run_build_k(0n, rest, file ++ "\n" ++ head, out, conds, meta, outdir, format, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})
    case 22n:
      build_finish(file, out, outdir, conds, meta, format, String.eq(build_format_marker(format, "show-config"), "true"))
    case _:
      IO.die(Unit, 2, "knot: build parse error (unknown_command)")


def run_serve_help() -> IO(Unit):
  IO.print("Usage: knot serve <html-entry> [--port N] [build options]\n\nOptions:\n  --port N   Bind to loopback port N (default: 3000)\n  -h, --help Show this help")

def serve_reverse_go(xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      acc
    case Con{h, rest}:
      serve_reverse_go(rest, Con{h, acc})

def serve_reverse(xs: List<&2, String>) -> List<&2, String>:
  serve_reverse_go(xs, Nil{})

def serve_args_ready(+port: String, +args: List<&2, String>) -> IO(Unit):
  +format : String = "esm;serve=true;serve-port=" ++ port
  run_build_k(0n, serve_reverse(args), "", "", "", "", "", format, "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})


@unsafe def run_serve_parse_k(sel: Nat, args: List<&2, String>, kept: List<&2, String>, +port: String, has_port: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          serve_args_ready(port, kept)
        case Con{+head, rest}:
          match head:
            case "--port":
              run_serve_parse_k(1n, rest, kept, port, has_port)
            case "--watch":
              run_serve_parse_k(0n, rest, kept, port, has_port)
            case "-h":
              run_serve_help()
            case "--help":
              run_serve_help()
            case _:
              run_serve_parse_k(0n, rest, Con{head, kept}, port, has_port)
    case _:
      match args:
        case Nil{}:
          IO.die(Unit, 2, "knot serve: --port requires a value (invalid_option)")
        case Con{+value, rest}:
          match has_port:
            case True{}:
              IO.die(Unit, 2, "knot serve: --port may be supplied only once (duplicate_option)")
            case False{}:
              run_serve_parse_k(0n, rest, kept, value, True{})

def run_serve(args: List<&2, String>) -> IO(Unit):
  run_serve_parse_k(0n, build_expand_args(args), Nil{}, "3000", False{})
def run_build_out(+file: String, rest: List<&2, String>) -> IO(Unit):
  run_build_k(0n, Con{file, build_expand_args(rest)}, "", "", "", "", "", "esm", "", Nil{}, "", "", False{}, False{}, False{}, False{}, False{})

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

def run_args_join(+parts: List<&2, String>, +acc: String, empty: Bool) -> String:
  match parts:
    case Nil{}:
      acc
    case Con{+h, rest}:
      match empty:
        case True{}:
          run_args_join(rest, h, False{})
        case False{}:
          run_args_join(rest, acc ++ "\n" ++ h, False{})

def run_script_result_code_ok(+status: String, +code: U32, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, code, "knot run: script exited with status " ++ status ++ " (script_failed)")

def run_script_result_code(+status: String, code: Maybe<&2, U32>) -> IO(Unit):
  match code:
    case None{}:
      IO.die(Unit, 1, "knot run: invalid script exit status (script_failed)")
    case Some{+code}:
      run_script_result_code_ok(status, code, U32.is_eq(code, 0))

def run_script_result(+status: String) -> IO(Unit):
  run_script_result_code(status, U32.read(status))

def run_script_exec(+dest: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+cmd, rest}:
      do IO<Unit>:
        +args : String = run_args_join(rest, "", True{})
        status : String <- IO.try(String, Os.exec_many(cmd, args, dest))
        run_script_result(status)
    case Nil{}:
      IO.die(Unit, 1, "knot run: empty script (missing_script)")

def run_script_got(+name: String, +pkg: String, +script: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      IO.die(Unit, 1, "knot run: script \"" ++ name ++ "\" is not defined (missing_script)")
    case False{}:
      do IO<Unit>:
        +engine : String <- json_optional_string(pkg, "engines/node")
        u0 : Unit <- check_engine(engine)
        run_script_exec(".", String.split(script, ' '))

def run_script(+name: String, +pkg: String) -> IO(Unit):
  do IO<Unit>:
    +script : String <- json_optional_string(pkg, "scripts/" ++ name)
    run_script_got(name, pkg, script, String.is_empty(script))

def run_run_args(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      IO.die(Unit, 2, "knot run requires a script name (missing_input)")
    case Con{+name, _}:
      do IO<Unit>:
        pkg : String <- read_text("package.json")
        run_script(name, pkg)

def run_run(args: List<&2, String>) -> IO(Unit):
  run_run_args(args)


def upgrade_result_code_ok(+status: String, code: U32, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("knot: upgraded @matheusbbarni/knot")
    case False{}:
      IO.die(Unit, code, "knot --upgrade: npm exited with status " ++ status ++ " (upgrade_failed)")

def upgrade_result_code(+status: String, code: Maybe<&2, U32>) -> IO(Unit):
  match code:
    case None{}:
      IO.die(Unit, 1, "knot --upgrade: invalid npm exit status (upgrade_failed)")
    case Some{+code}:
      upgrade_result_code_ok(status, code, U32.is_eq(code, 0))

def upgrade_result(+status: String) -> IO(Unit):
  upgrade_result_code(status, U32.read(status))

def run_upgrade() -> IO(Unit):
  do IO<Unit>:
    +status : String <- IO.try(String, Os.exec_many("npm", "install\n--global\n@matheusbbarni/knot@latest", "."))
    upgrade_result(status)

def run_upgrade_args(args: List<&2, String>) -> IO(Unit):
  match args:
    case Nil{}:
      run_upgrade()
    case Con{+head, _}:
      IO.die(Unit, 2, "knot --upgrade does not accept argument " ++ head ++ " (unknown_command)")


def snapshot_print_kind(+status: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print(String.drop(status, 3n))
    case False{}:
      publish_status(status)
def snapshot_print(+status: String) -> IO(Unit):
  snapshot_print_kind(status, String.starts_with(status, "ok|"))
def run_snapshot_ready(+outdir: String, +dest: String, missing: Bool) -> IO(Unit):
  match missing:
    case True{}:
      IO.die(Unit, 2, "knot snapshot: --outdir and --to are required (unknown_command)")
    case False{}:
      do IO<Unit>:
        +status : String <- IO.try(String, Fs.publish("snapshot", outdir, dest, "", ""))
        snapshot_print(status)
@unsafe def run_snapshot_k(sel: Nat, args: List<&2, String>, +outdir: String, +dest: String, +head: String, +val: String, outdir_flag: Bool, to_flag: Bool) -> IO(Unit):
  match sel:
    case 0n:
      match args:
        case Nil{}:
          run_snapshot_ready(outdir, dest, Bool.or(String.is_empty(outdir), String.is_empty(dest)))
        case Con{+next, more}:
          run_snapshot_k(1n, more, outdir, dest, next, "", False{}, False{})
    case 1n:
      match args:
        case Nil{}:
          IO.die(Unit, 2, "knot snapshot: missing value (unknown_command)")
        case Con{+next, more}:
          run_snapshot_k(2n, more, outdir, dest, head, next, String.eq(head, "--outdir"), String.eq(head, "--to"))
    case 2n:
      match outdir_flag:
        case True{}:
          run_snapshot_k(0n, args, val, dest, "", "", False{}, False{})
        case False{}:
          run_snapshot_k(3n, args, outdir, dest, head, val, False{}, to_flag)
    case _:
      match to_flag:
        case True{}:
          run_snapshot_k(0n, args, outdir, val, "", "", False{}, False{})
        case False{}:
          IO.die(Unit, 2, "knot snapshot: unknown argument " ++ head ++ " (unknown_command)")
def dispatch_snapshot(+cmd: String, rest: List<&2, String>, is_snapshot: Bool) -> IO(Unit):
  match is_snapshot:
    case True{}:
      run_snapshot_k(0n, rest, "", "", "", "", False{}, False{})
    case False{}:
      dispatch_scan(cmd, rest, String.eq(cmd, "scan"))

def protocol_response(+id: String, +status: String, +code: String, has_code: Bool) -> String:
  match has_code:
    case False{}:
      "{\"protocolVersion\":1,\"id\":" ++ Compiler.json_str(id) ++ ",\"status\":" ++ Compiler.json_str(status) ++ ",\"diagnostics\":[],\"manifest\":null,\"metafile\":null,\"analysis\":null,\"artifacts\":[]}"
    case True{}:
      "{\"protocolVersion\":1,\"id\":" ++ Compiler.json_str(id) ++ ",\"status\":\"error\",\"diagnostics\":[{\"code\":" ++ Compiler.json_str(code) ++ "}],\"manifest\":null,\"metafile\":null,\"analysis\":null,\"artifacts\":[]}"
def protocol_null_error(+code: String) -> String:
  "{\"protocolVersion\":1,\"id\":null,\"status\":\"error\",\"diagnostics\":[{\"code\":" ++ Compiler.json_str(code) ++ "}],\"manifest\":null,\"metafile\":null,\"analysis\":null,\"artifacts\":[]}"
def run_protocol_target(id: String, entry: String, outdir: String, format: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+target, Nil{}}:
      do IO<Unit>:
        u : Unit <- run_build(Con{entry, Con{"--outdir", Con{outdir, Con{"--format", Con{format, Con{"--target", Con{target, Nil{}}}}}}}})
        IO.print(protocol_response(id, "ok", "", False{}))
    case _:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_format(id: String, entry: String, outdir: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+format, rest}:
      run_protocol_target(id, entry, outdir, format, rest)
    case Nil{}:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_outdir(id: String, entry: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+outdir, rest}:
      run_protocol_format(id, entry, outdir, rest)
    case Nil{}:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_entry(id: String, parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+entry, rest}:
      run_protocol_outdir(id, entry, rest)
    case Nil{}:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_build(parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+id, rest}:
      run_protocol_entry(id, rest)
    case Nil{}:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_error(parts: List<&2, String>, +code: String) -> IO(Unit):
  match parts:
    case Con{+id, _}:
      IO.print(protocol_response(id, "error", code, True{}))
    case Nil{}:
      IO.print(protocol_null_error(code))
def run_protocol_kind(+status: String, rest: List<&2, String>) -> IO(Unit):
  match status:
    case "eof":
      IO.pure(Unit, Unit{})
    case "malformed":
      IO.print(protocol_null_error("invalid_option"))
    case "limit":
      IO.print(protocol_null_error("resource_limit"))
    case "bad-version":
      run_protocol_error(rest, "unsupported_interface")
    case "missing":
      run_protocol_error(rest, "invalid_option")
    case "artifacts":
      run_protocol_error(rest, "invalid_option")
    case "ok":
      run_protocol_build(rest)
    case _:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol_fields(parts: List<&2, String>) -> IO(Unit):
  match parts:
    case Con{+status, rest}:
      run_protocol_kind(status, rest)
    case Nil{}:
      IO.print(protocol_null_error("invalid_option"))
def run_protocol() -> IO(Unit):
  do IO<Unit>:
    +fields : String <- IO.try(String, Protocol.request())
    run_protocol_fields(String.split(fields, '|'))
def protocol_ignore(rest: List<&2, String>) -> IO(Unit):
  match rest:
    case Nil{}:
      run_protocol()
    case Con{_, _}:
      IO.die(Unit, 2, "knot protocol does not accept arguments (unknown_command)")
def dispatch_protocol(+cmd: String, rest: List<&2, String>, is_protocol: Bool) -> IO(Unit):
  match is_protocol:
    case True{}:
      protocol_ignore(rest)
    case False{}:
      dispatch_snapshot(cmd, rest, String.eq(cmd, "snapshot"))

def dispatch_serve(+cmd: String, rest: List<&2, String>, is_serve: Bool) -> IO(Unit):
  match is_serve:
    case True{}:
      run_serve(rest)
    case False{}:
      dispatch_protocol(cmd, rest, String.eq(cmd, "protocol"))

def dispatch_build(+cmd: String, rest: List<&2, String>, is_build: Bool) -> IO(Unit):
  match is_build:
    case True{}:
      run_build(rest)
    case False{}:
      dispatch_serve(cmd, rest, String.eq(cmd, "serve"))

def dispatch_run(+cmd: String, rest: List<&2, String>, is_run: Bool) -> IO(Unit):
  match is_run:
    case True{}:
      run_run(rest)
    case False{}:
      dispatch_build(cmd, rest, String.eq(cmd, "build"))

def dispatch_clean(+cmd: String, rest: List<&2, String>, is_clean: Bool) -> IO(Unit):
  match is_clean:
    case True{}:
      run_clean(rest)
    case False{}:
      dispatch_run(cmd, rest, String.eq(cmd, "run"))


def run_help() -> IO(Unit):
  IO.print("Usage: knot <command>\n\nCommands:\n  install      Install dependencies from package.json\n  add          Add a dependency and install\n  remove       Remove a direct dependency\n  update       Re-resolve dependency ranges\n  --upgrade    Upgrade installed Knot through npm\n  run          Execute a package.json script with its Node engine\n  list         Print direct dependencies\n  why          Show why a package is installed\n  fetch        Fill the store from the lockfile\n  store        Inspect the content-addressed store\n  cache clean  Remove the registry metadata cache\n  transpile    Transform TypeScript or JavaScript without bundling\n  scan         Print runtime imports and exports as JSON\n  analyze      Walk import graph from entrypoints as JSON\n  build        Compile entry points; --no-bundle skips graph linking\n  serve        Build and serve a browser application on loopback\n  clean        Remove compiler caches with --build-cache")

def dispatch_version(+cmd: String, rest: List<&2, String>, is_version: Bool) -> IO(Unit):
  match is_version:
    case True{}:
      IO.print("0.0.1")
    case False{}:
      dispatch_clean(cmd, rest, String.eq(cmd, "clean"))

def dispatch_upgrade(+cmd: String, rest: List<&2, String>, is_upgrade: Bool) -> IO(Unit):
  match is_upgrade:
    case True{}:
      run_upgrade_args(rest)
    case False{}:
      dispatch_version(cmd, rest, String.eq(cmd, "--version"))

def dispatch_help(+cmd: String, rest: List<&2, String>, is_help: Bool) -> IO(Unit):
  match is_help:
    case True{}:
      run_help()
    case False{}:
      dispatch_upgrade(cmd, rest, String.eq(cmd, "--upgrade"))



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
