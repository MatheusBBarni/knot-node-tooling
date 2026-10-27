# Bend2 capability gate

Date: 2026-10-27

Pinned compiler: Bend 2.0.39 (Apache-2.0)

Artifacts:

| Target | URL | SHA-256 |
| --- | --- | --- |
| `darwin-arm64` | `https://github.com/bendlang/bend/releases/download/v2.0.39/bend-2.0.39-darwin-arm64.tar.gz` | `d4aaef68de545727429ce83b9e88ff3273bf068df599e3542e446755b5f3d83a` |
| `linux-x64` | `https://github.com/bendlang/bend/releases/download/v2.0.39/bend-2.0.39-linux-x64.tar.gz` | `6cf462fd8f70b094a4950ebb709a9c4ffd8f1d1189d9cedf1fd63cd5d041c7ab` |

Install the artifact matching the runner target.

The pin lives in `toolchain.json`.
Tests set `BEND_NO_TELEMETRY=1` so the launcher does not self-update.

## Commands

| Command | Result |
| --- | --- |
| `bend version` | Prints `bend 2.0.39` |
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
On Bend 2.0.39, `TCP.recv` returns `Maybe<String>` (`None` at EOF). A failed `TCP.send` includes unsent bytes that can be resumed with `TCP.send_bytes`.


Knot host adapters now in `src/host/`:

- argv via `KNOT_ARG_*` from `bin/knot` (Bend binaries steal argv for `--threads`/`--gpu`)
- Registry metadata GET is Bend `TCP.connect`/`send`/`recv`, same shape as `demos/io_http_fetch`
- `TCP.listen` and `TCP.accept` predate 2.0.39; that release adds no higher-level server effect. The native `Server.run` adapter stays in C for root-confined `openat`/`O_NOFOLLOW` reads and build-process supervision.

- Native host effects use generated CIDs such as `CID_Server_run` and Bend 2.0.39's two-argument `io_eff(cid, run)` registration.

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

