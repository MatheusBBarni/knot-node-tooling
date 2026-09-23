# Bend2 capability gate

Date: 2026-09-17

Pinned compiler: Bend 2.0.24 (Apache-2.0)

Artifact (darwin-arm64): `https://github.com/bendlang/bend/releases/download/v2.0.24/bend-2.0.24-darwin-arm64.tar.gz`

SHA-256: `b17380ac7b8fce5c5c0250d23c9bb6d99cc9737bfca8a9e5428e051325926e1e`

Install: download the pinned release asset for your OS/arch, or `curl -fsSL https://bend-lang.com/install.sh | sh` and confirm `bend version` matches `toolchain.json`.

The pin lives in `toolchain.json`.
Tests set `BEND_NO_TELEMETRY=1` so the launcher does not self-update.

## Commands

| Command | Result |
| --- | --- |
| `bend version` | Prints `bend 2.0.24` |
| `bend <file.bend>` | Checks, then runs `main` on the JS backend |
| `bend <file.bend> -o <bin>` | Checks, then builds a native CPU binary |
| `bend <file.bend> -o <file.c>` | Emits C |
| `bend <file.bend> -o <file.js>` | Emits JS |
| `bend <file.bend> --checkup` | Checks and runs each import alone |
| `bend PROOF.bend` | Fails while any law is open or false |

A file with no `main` prints `All terms check.` and exits 0.
A false or open proof exits 1.

Native CPU builds need clang 14 or newer.
GPU builds need clang 19 or newer (Apple clang 17).
On this Mac, `/usr/bin/clang` cannot link because the Xcode license is unsigned.
`scripts/cc` uses Homebrew `llvm@21` and `lld@21` instead.

Set `CC` to `scripts/cc` for native builds until Apple clang works.

## Effects in Base

Present:

- `IO.print`, `IO.write`, `IO.print_err`
- `IO.get_env`, `IO.sleep`, `IO.now`
- `IO.spawn`, `IO.fork`, `IO.join`, `Chan.*` (in-process tasks, not OS processes)
- `File.open` / `read` / `read_bytes` / `write` / `close` (`r`, `w`, `a`)
- `TCP.listen` / `accept` / `connect` / `send` / `recv`
- `UDP.bind` / `send_to` / `recv_from` / `poll`

Knot host adapters now in `src/host/`:

- argv via `KNOT_ARG_*` from `bin/knot` (Bend binaries steal argv for `--threads`/`--gpu`)
- Registry metadata GET is Bend `TCP.connect`/`send`/`recv`, same shape as `demos/io_http_fetch`
- `Http.get_file` remains C: `TCP.recv` decodes UTF-8, so gzip tarball bytes cannot round-trip a String
- `Fs.mkdir_p` remains C: Base `File.open` does not create parent directories
- `Tar.extract` remains C: gzip inflate is not in Base
- `Hash.sha512_b64` and `Json.query` are still C; both are expressible in Bend and should move next


Still missing:

- TLS
- OS process creation, wait, and process-tree kill
- User signal handlers (`SIGPIPE` is ignored)
- `unlink`, `rename`, `symlink`, `clonefile`, directory listing, permissions
- SQLite or any other database

## Backend notes

`bend file.bend` runs on JavaScript.
`bend file.bend -o bin` builds a native binary.
`f!(x)` in a native binary is the GPU lane; `--gpu 1GB` enables it.
The same `add1!(41)` program printed `42` on CPU and Metal on this machine.
The CPU acceptance gate does not require a GPU.

## Acceptance driver

Node.js 24 LTS and `node:test` launch Bend and `knot`.
The focused command is `node --test <file>`.
The fast command is `node --test`.
Use Node.js 24, not 26.
Do not use `bun test`; it is not the acceptance driver.

