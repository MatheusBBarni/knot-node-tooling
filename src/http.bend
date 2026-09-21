import Base

def Https.get(url: String) -> IO(Result<&1, &1, U32 & String, String>):
  import "./host/https_get.c"
  import "./host/https_get.js"




def http_body.go(s: String, e: Bool, w: U32) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{Chr{a}, t}:
      match e:
        case True{}:
          SCon{Chr{a}, t}
        case False{}:
          +w2 = (w * 256 + a : U32)
          http_body.go(t, U32.is_eq(w2, 218762506), w2)

def http_body(s: String) -> String:
  http_body.go(s, False{}, 0)

def fetch_tail(head: String, m: Socket & Result<&1, &1, U32 & String, String>) -> IO(String):
  (s, r) = m
  do IO<String>:
    tail : String <- IO.pass(String, r)
    Socket.close(s)
    return head ++ tail

def fetch_head(m: Socket & Result<&1, &1, U32 & String, String>) -> IO(String):
  (s, r) = m
  do IO<String>:
    head : String <- IO.pass(String, r)
    rest : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(s, 65535)
    fetch_tail(head, rest)

def fetch_sent(m: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(String):
  (s, r) = m
  do IO<String>:
    IO.pass(Unit, r)
    read : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(s, 65535)
    fetch_head(read)

def extra_line(+extra: String) -> String:
  match extra:
    case SNil{}:
      ""
    case _:
      extra

def http_request(+host: String, +port: String, path: String, +extra: String) -> String:
  "GET " ++ path ++ " HTTP/1.1\r\nHost: " ++ host ++ ":" ++ port ++ "\r\nAccept: application/vnd.npm.install-v1+json\r\n" ++ extra_line(extra) ++ "Connection: close\r\n\r\n"


def take_host(s: String, acc: String) -> String & String:
  match s:
    case SNil{}:
      (acc, "")
    case SCon{':', t}:
      (acc, t)
    case SCon{'/', t}:
      (acc, SCon{'/', t})
    case SCon{h, t}:
      take_host(t, acc ++ SCon{h, SNil{}})

def take_port(s: String, acc: String) -> String & String:
  match s:
    case SNil{}:
      (acc, "/")
    case SCon{'/', t}:
      (acc, SCon{'/', t})
    case SCon{h, t}:
      take_port(t, acc ++ SCon{h, SNil{}})

def strip_http_if(+s: String, ok: Bool) -> Maybe<&2, String>:
  match ok:
    case False{}:
      None{}
    case True{}:
      Some{String.drop(s, 7n)}

def strip_http(+s: String) -> Maybe<&2, String>:
  strip_http_if(s, String.starts_with(s, "http://"))

def http_get_port(+host: String, +port_s: String, path: String, port_m: Maybe<&2, U32>, +etag: String) -> IO(String):
  match port_m:
    case None{}:
      IO.die(String, 1, "knot: bad registry port")
    case Some{port}:
      do IO<String>:
        c : Socket <- IO.try(Socket, TCP.connect(host, port))
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(c, http_request(host, port_s, path, etag))
        fetch_sent(sent)

def http_get_open(+host: String, +port_s: String, path: String, +etag: String) -> IO(String):
  http_get_port(host, port_s, path, U32.read(port_s), etag)

def http_get_after_port(host: String, hp: String & String, +etag: String) -> IO(String):
  (port_s, path) = hp
  http_get_open(host, port_s, path, etag)

def http_get_after_host(host: String, after: String, +etag: String) -> IO(String):
  match after:
    case SNil{}:
      http_get_open(host, "80", "/", etag)
    case SCon{'/', t}:
      http_get_open(host, "80", SCon{'/', t}, etag)
    case other:
      http_get_after_port(host, take_port(other, ""), etag)

def http_get_after_host_pair(hp: String & String, +etag: String) -> IO(String):
  (host, after) = hp
  http_get_after_host(host, after, etag)

def http_get_host(rest: String, +etag: String) -> IO(String):
  http_get_after_host_pair(take_host(rest, ""), etag)

def env_or_empty(r: Result<&1, &1, U32 & String, String>) -> String:
  match r:
    case Fail{_}:
      ""
    case Done{v}:
      v

def auth_line(+token: String) -> String:
  match token:
    case SNil{}:
      ""
    case _:
      "Authorization: Bearer " ++ token ++ "\r\n"

def basic_line(+b64: String) -> String:
  match b64:
    case SNil{}:
      ""
    case _:
      "Authorization: Basic " ++ b64 ++ "\r\n"

def npmrc_take_line(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'\n', _}:
      acc
    case SCon{'\r', t}:
      npmrc_take_line(t, acc)
    case SCon{h, t}:
      npmrc_take_line(t, acc ++ SCon{h, SNil{}})

def npmrc_drop_pre(s: String, pre: String) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{h, st}:
      match pre:
        case SNil{}:
          SCon{h, st}
        case SCon{_, pt}:
          npmrc_drop_pre(st, pt)

def npmrc_hp(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{'/', t}:
      acc
    case SCon{h, t}:
      npmrc_hp(t, acc ++ SCon{h, SNil{}})

def npmrc_scoped_key(+rest: String) -> String:
  "//" ++ npmrc_hp(rest, "") ++ "/:_authToken="

def npmrc_basic_at(hit: Bool, +s: String) -> String:
  match hit:
    case True{}:
      basic_line(npmrc_take_line(String.drop(s, 6n), ""))
    case False{}:
      ""

def npmrc_token_at(hit: Bool, +s: String) -> String:
  match hit:
    case True{}:
      auth_line(npmrc_take_line(String.drop(s, 11n), ""))
    case False{}:
      npmrc_basic_at(String.starts_with(s, "_auth="), s)

def npmrc_pick(hit: Bool, +s: String, +rest: String) -> String:
  match hit:
    case True{}:
      auth_line(npmrc_take_line(npmrc_drop_pre(s, npmrc_scoped_key(rest)), ""))
    case False{}:
      npmrc_token_at(String.starts_with(s, "_authToken="), s)

def npmrc_token_from(+s: String, +rest: String) -> String:
  npmrc_pick(String.starts_with(s, npmrc_scoped_key(rest)), s, rest)

def npmrc_from_body(body: Result<&1, &1, U32 & String, String>, +rest: String) -> String:
  match body:
    case Fail{_}:
      ""
    case Done{v}:
      npmrc_token_from(v, rest)

def npmrc_read_fin(pair: File & Result<&1, &1, U32 & String, String>, +rest: String) -> IO(String):
  (file2, body) = pair
  do IO<String>:
    File.close(file2)
    return npmrc_from_body(body, rest)

def npmrc_from_file(r: Result<&1, &1, U32 & String, File>, +rest: String) -> IO(String):
  match r:
    case Fail{_}:
      IO.pure(String, "")
    case Done{f}:
      do IO<String>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(f, 65535)
        npmrc_read_fin(pair, rest)

def npmrc_token(+rest: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, File> <- File.open(".npmrc", "r")
    npmrc_from_file(r, rest)

def token_or_npmrc(+env: String, +rest: String) -> IO(String):
  match env:
    case SNil{}:
      npmrc_token(rest)
    case _:
      IO.pure(String, auth_line(env))

def npm_token_env(+rest: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("NPM_TOKEN")
    token_or_npmrc(env_or_empty(r), rest)

def knot_or_npm_token(+knot: String, +rest: String) -> IO(String):
  match knot:
    case SNil{}:
      npm_token_env(rest)
    case _:
      IO.pure(String, auth_line(knot))

def http_get_from_tok(+rest: String, +etag: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("KNOT_TOKEN")
    t : String <- knot_or_npm_token(env_or_empty(r), rest)
    http_get_host(rest, t ++ etag)

def http_get_from(m: Maybe<&2, String>, +etag: String) -> IO(String):
  match m:
    case None{}:
      IO.die(String, 1, "knot: registry URL must be http")
    case Some{rest}:
      http_get_from_tok(rest, etag)

def http_get_from_anon(m: Maybe<&2, String>, +etag: String) -> IO(String):
  match m:
    case None{}:
      IO.die(String, 1, "knot: registry URL must be http")
    case Some{rest}:
      http_get_host(rest, etag)

def http_get_resp_anon(+url: String) -> IO(String):
  http_get_from_anon(strip_http(url), "")

def http_is_401(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 401"), String.starts_with(resp, "HTTP/1.0 401"))

def http_is_302(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 302"), String.starts_with(resp, "HTTP/1.0 302"))

def http_is_301(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 301"), String.starts_with(resp, "HTTP/1.0 301"))

def http_is_307(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 307"), String.starts_with(resp, "HTTP/1.0 307"))

def http_is_308(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 308"), String.starts_with(resp, "HTTP/1.0 308"))

def http_is_redirect(+resp: String) -> Bool:
  Bool.or(http_is_302(resp), Bool.or(http_is_301(resp), Bool.or(http_is_307(resp), http_is_308(resp))))

def http_is_429(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 429"), String.starts_with(resp, "HTTP/1.0 429"))

def http_is_503(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 503"), String.starts_with(resp, "HTTP/1.0 503"))

def http_is_408(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 408"), String.starts_with(resp, "HTTP/1.0 408"))

def http_is_500(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 500"), String.starts_with(resp, "HTTP/1.0 500"))

def http_is_502(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 502"), String.starts_with(resp, "HTTP/1.0 502"))

def http_is_504(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 504"), String.starts_with(resp, "HTTP/1.0 504"))

def http_is_retryable(+resp: String) -> Bool:
  Bool.or(http_is_429(resp), Bool.or(http_is_503(resp), Bool.or(http_is_408(resp), Bool.or(http_is_500(resp), Bool.or(http_is_502(resp), http_is_504(resp))))))

def http_get_die_status(auth: Bool) -> IO(String):
  match auth:
    case True{}:
      IO.die(String, 1, "knot: registry authentication failed (auth_failed)")
    case False{}:
      IO.die(String, 1, "knot: registry HTTP error")

def http_is_gzip(+resp: String) -> Bool:
  Bool.or(String.contains(resp, "content-encoding: gzip"), String.contains(resp, "Content-Encoding: gzip"))

def http_decode_gzip(gz: Bool, +body: String) -> IO(String):
  match gz:
    case False{}:
      IO.pure(String, body)
    case True{}:
      IO.pure(String, body)
def http_decode_body(+resp: String) -> IO(String):
  http_decode_gzip(http_is_gzip(resp), http_body(resp))

def http_get_ok_or(+resp: String, ok: Bool) -> IO(String):
  match ok:
    case False{}:
      http_get_die_status(http_is_401(resp))
    case True{}:
      http_decode_body(resp)

def http_get_ok(+resp: String) -> IO(String):
  http_get_ok_or(resp, Bool.or(String.starts_with(resp, "HTTP/1.1 200"), String.starts_with(resp, "HTTP/1.0 200")))

def http_get_https(is_https: Bool, +url: String) -> IO(String):
  match is_https:
    case True{}:
      IO.try(String, Https.get(url))
    case False{}:
      do IO<String>:
        resp : String <- http_get_from(strip_http(url), "")
        http_get_ok(resp)

def http_get(+url: String) -> IO(String):
  http_get_https(String.starts_with(url, "https://"), url)

def http_fail_maybe(auth: Bool) -> IO(Maybe<&2, String>):
  match auth:
    case True{}:
      IO.die(Maybe<&2, String>, 1, "knot: registry authentication failed (auth_failed)")
    case False{}:
      IO.pure(Maybe<&2, String>, Some{SNil{}})

def http_get_ok_maybe(+resp: String, ok: Bool) -> IO(Maybe<&2, String>):
  match ok:
    case False{}:
      http_fail_maybe(http_is_401(resp))
    case True{}:
      do IO<Maybe<&2, String>>:
        body : String <- http_decode_body(resp)
        return Some{body}

def https_get_maybe_fin(r: Result<&1, &1, U32 & String, String>) -> IO(Maybe<&2, String>):
  match r:
    case Fail{_}:
      IO.pure(Maybe<&2, String>, Some{SNil{}})
    case Done{v}:
      IO.pure(Maybe<&2, String>, Some{v})

def http_get_maybe_retry(again: Bool, +url: String, +resp: String) -> IO(Maybe<&2, String>):
  match again:
    case False{}:
      http_get_ok_maybe(resp, Bool.or(String.starts_with(resp, "HTTP/1.1 200"), String.starts_with(resp, "HTTP/1.0 200")))
    case True{}:
      do IO<Maybe<&2, String>>:
        u : Unit <- IO.sleep(0)
        +resp2 : String <- http_get_from(strip_http(url), "")
        http_get_ok_maybe(resp2, Bool.or(String.starts_with(resp2, "HTTP/1.1 200"), String.starts_with(resp2, "HTTP/1.0 200")))

def http_get_maybe_https(is_https: Bool, +url: String) -> IO(Maybe<&2, String>):
  match is_https:
    case True{}:
      do IO<Maybe<&2, String>>:
        r : Result<&1, &1, U32 & String, String> <- Https.get(url)
        https_get_maybe_fin(r)
    case False{}:
      do IO<Maybe<&2, String>>:
        +resp : String <- http_get_from(strip_http(url), "")
        http_get_maybe_retry(http_is_retryable(resp), url, resp)

def http_get_maybe(+url: String) -> IO(Maybe<&2, String>):
  http_get_maybe_https(String.starts_with(url, "https://"), url)

def http_is_304(+resp: String) -> Bool:
  Bool.or(String.starts_with(resp, "HTTP/1.1 304"), String.starts_with(resp, "HTTP/1.0 304"))

def http_get_resp_auth(auth: Bool, +resp: String) -> IO(String):
  match auth:
    case True{}:
      IO.die(String, 1, "knot: registry authentication failed (auth_failed)")
    case False{}:
      IO.pure(String, resp)

def http_get_resp_retry(again: Bool, +url: String, +resp: String, +etag: String) -> IO(String):
  match again:
    case False{}:
      http_get_resp_auth(http_is_401(resp), resp)
    case True{}:
      do IO<String>:
        u : Unit <- IO.sleep(0)
        +resp2 : String <- http_get_from(strip_http(url), etag)
        http_get_resp_auth(http_is_401(resp2), resp2)

def https_ok_resp(+body: String) -> String:
  "HTTP/1.1 200 OK\r\n\r\n" ++ body

def http_get_resp_https(is_https: Bool, +url: String, +etag: String) -> IO(String):
  match is_https:
    case True{}:
      do IO<String>:
        body : String <- IO.try(String, Https.get(url))
        return https_ok_resp(body)
    case False{}:
      do IO<String>:
        +resp : String <- http_get_from(strip_http(url), etag)
        http_get_resp_retry(http_is_retryable(resp), url, resp, etag)

def http_get_resp(+url: String, +etag: String) -> IO(String):
  http_get_resp_https(String.starts_with(url, "https://"), url, etag)


