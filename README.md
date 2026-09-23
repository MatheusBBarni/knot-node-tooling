<div align="center">

# Knot

**A native JavaScript toolchain built in Bend2.**

[Overview](#overview) · [Commands](#commands) · [Architecture](#architecture) · [Roadmap](#roadmap) · [Design documents](#design-documents)

</div>

Knot is a native JavaScript toolchain written in Bend2.
The package manager runs from this repository.
The compiler can transpile a TypeScript subset, scan runtime imports and exports, and run `build --no-bundle`.
The native coordinator uses an external JavaScript runtime only when generated code or tests need to execute.

> [!IMPORTANT]
> There is no installable release yet.
> Build `bin/knot` from this repository with `./scripts/build-knot`.
> `knot install`, `knot transpile`, `knot scan`, `knot analyze`, and a first `knot build` path (including `--watch`) run today.
> The test runner is still design-only.
> Transpilation does not type-check and does not emit `.d.ts` files.
> The Bend2 pin is [`toolchain.json`](./toolchain.json) (Bend 2.0.4).
> Host-effect notes are in [Bend2 capability](./docs/bend2-capability.md).

## Overview

Knot aims to provide one small command for the common JavaScript workflow:

```text
knot install
knot build
knot test
```

The project is split into four connected systems:

- An npm-compatible package manager with verified downloads, a `knot.lock` file, an isolated `node_modules` layout, and a global store under `~/.knot`.
- A JavaScript and TypeScript compiler for syntax transformation, JSX lowering, module resolution, source maps, and incremental rebuilds.
- A production bundler for JavaScript, CSS, HTML, and static assets.
- A Jest-style test runner coordinated by a native process and executed in isolated Node.js workers.

Knot does not embed V8, JavaScriptCore, Node.js, or another JavaScript runtime.
Builds produce code for browsers and Node.js.
Tests run through an external Node.js installation.

## Design goals

- Correct behavior and reproducible output before benchmark wins.
- Deterministic lockfiles, build artifacts, reports, and cache identities.
- Safe recovery from interruption, crashes, corrupt caches, and concurrent processes.
- Strict package visibility that prevents undeclared dependencies by default.
- Atomic activation of complete install and build generations.
- Full functionality on CPU-only systems.
- Multicore and GPU execution only where measurements show a real end-to-end gain.

## Commands

`knot install`, `knot add`, `knot remove`, `knot fetch`, `knot why`, `knot transpile`, `knot scan`, `knot analyze`, and `knot build` (including `--no-bundle` and `--watch`) run in this tree.
The test runner is still a product plan.

| Command | Status | Purpose |
| --- | --- | --- |
| `knot install` | works in this repo | Resolve, fetch, verify, and materialize project dependencies |
| `knot add <spec>` | works in this repo | Add and install a direct dependency |
| `knot remove <name>` | works in this repo | Remove a direct dependency |
| `knot fetch` | works in this repo | Populate the package store without creating project links |
| `knot why <name>` | works in this repo | Explain why a package exists in the graph |
| `knot update [name]` | planned | Update dependencies within declared ranges |
| `knot transpile <files...>` | works for a TypeScript subset | Strip types and emit JavaScript plus a source map next to each file |
| `knot scan <files...>` | works for a TypeScript subset | Print runtime imports and exports as JSON |
| `knot analyze <entrypoints...>` | works for a TypeScript subset | Walk the import graph and print entries/modules/missing as JSON |
| `knot build --no-bundle <files...>` | works for a TypeScript subset | Same no-bundle transform as `transpile` |
| `knot build <entrypoints...>` | works for a JavaScript/TypeScript subset | Resolve, tree-shake, and emit application outputs (see flags below) |
| `knot test [filters...]` | planned | Discover, compile, isolate, and execute tests |

> [!NOTE]
> Older PRDs still say `bnpm`.
> The CLI name is `knot`.
> Config is `knot.toml`, the lockfile is `knot.lock`, the project store is `node_modules/.knot`, and the future test API is `knot:test`.

## Package management

`knot install` talks to npm-compatible registries, writes `knot.lock`, and materializes packages under `node_modules/.knot` with root symlinks in `node_modules`.
Verified tarballs live in `~/.knot/cas`.
Extracted trees live in `~/.knot/unpacked`.
Registry metadata lives in `~/.knot/cache`.
`--store-dir` overrides the store root.

A later `knot install` after `rm -rf node_modules` clonefiles from the unpacked store and relinks.
Lifecycle scripts stay off unless the project opts in.

Cached rematerialize times against bun, npm, and pnpm are in [`benchmark/package-manager/`](./benchmark/package-manager/).
On the spec-finder fixture, bun is still faster on default backends (~1.4x median wall after the 2026-09-23 rematerialize pass).
Knot is faster than npm 11 and pnpm 11 on that same machine and method.
The notes in those files list versions, the mismatched lock graphs, and what was not measured.

## Compilation and bundling
`knot transpile` and `knot build --no-bundle` strip type annotations and lower JSX/TSX (classic `React.createElement` by default; `--jsx-runtime automatic|preserve` and `--jsx-factory` / `--jsx-fragment` / `--jsx-import-source`), `interface` and `type` declarations, `import type`, and `as` assertions, and lower numeric `enum` declarations, value `namespace`s, constructor parameter properties, and `satisfies` expressions.
`--sourcemap linked|external|none` controls map emit (default `linked`).
`--minify-whitespace` inserts spaces only between identifiers and numbers.
`--minify-identifiers` keeps exported function names and shortens other identifiers.
`knot build <entry> --outfile out.js` follows relative `./` imports, `require("./file.ts")`, `tsconfig.json` `compilerOptions.paths` aliases including `@app/*` wildcards, and bare specifiers via `package.json` `exports` or `main` (honoring `--conditions` and `sideEffects`), then `index.js`/`index.ts`, drops unused `function` declarations from non-entry modules, writes a content-hashed `.js` chunk for `import("./file.ts")`, writes `require()` targets next to the bundle as `.js`, and can write a JSON `--metafile`.
Successful emits write `.knot/build-cache/v1` and the source used for the last emit. A later `build --no-bundle` of unchanged source reuses that record and does not rewrite JavaScript.
`knot clean --build-cache` deletes `.knot/build-cache/v1` and leaves JavaScript output in place.
`knot build --watch --no-bundle <file.ts>` rebuilds that file when its contents change.
`knot build --watch <entry.ts> --outfile out.js` rebuilds the bundle when any file in the import graph changes or a new file appears in the entry directory.
`knot analyze <entry.ts>` prints the reachable import graph as JSON.
Unsupported syntax must fail with `syntax_error` and must not write JavaScript.

Known transpile limits in this tree:
- `import fs = require("x")` lowers to a default ESM import (`import fs from "x"`), not `import * as fs`, because the type eraser also strips the `as` keyword.
- CSS, HTML, and static-asset bundling are still ahead.

It will support broader browser and Node.js targets, ESM and CommonJS output, richer tree shaking, code splitting, CSS, HTML, and static assets.

Builds will not access the network or install missing packages implicitly.
A failed build will not expose a mixture of old and new artifacts.

## Test runner

`knot test` will use a native Bend2 coordinator and external Node.js worker processes.
One process per test file is the default isolation boundary.

The planned runner includes:

- JavaScript, TypeScript, JSX, TSX, ESM, and CommonJS tests.
- Nested suites, hooks, assertions, mocks, spies, fake time, and snapshots.
- File-level parallelism, deterministic sharding, retries, and seeded randomization.
- Hard deadlines and process-tree cleanup.
- Source-mapped V8 coverage.
- Console, dots, JUnit XML, GitHub Actions, and JSON Lines reporters.
- Dependency-aware watch selection.

Tests are trusted project code, not sandboxed workloads.
The native coordinator remains responsible for deadlines, cleanup, event validation, and the final process status.

## Architecture

```text
package.json + knot.toml + knot.lock
                 |
                 v
       manifest and configuration
                 |
        +--------+---------+
        |                  |
        v                  v
 package resolver    compiler resolver
        |                  |
        v                  v
 verified store      immutable module IR
        |                  |
        v          +-------+--------+
 isolated links    |                |
                   v                v
              build graph       test graph
                   |                |
                   v                v
          staged artifacts   Node.js workers
                   |                |
                   v                v
          atomic activation   validated reports
```

Filesystem, network, process, signal, and terminal work stays at explicit effect boundaries.
Pure graph, parsing, hashing, validation, and planning work can use Bend2 parallel execution.
Every required feature keeps a CPU path.

## Development model

Knot uses test-driven development for every behavioral change.
Each cycle covers one observable behavior through an agreed public seam:

1. Write one failing acceptance test.
2. Confirm that it fails because the behavior is missing.
3. Implement the smallest working path.
4. Exercise the real executable, generated output, or browser surface.
5. Refactor while the focused and related checks remain green.

Node.js 24 LTS and `node:test` are the independent acceptance driver.
The driver will launch the real `knot` process, create temporary projects, host local registries, execute generated JavaScript, and inspect observable results.
Bend2 laws and proofs supplement these tests for pure invariants.

## Development

Use Node.js 24 LTS.
Install Bend 2.0.4 from the pin in `toolchain.json`.
Native builds need `CC` set to `scripts/cc` on this Mac.

```text
./scripts/build-knot
node --test
```

## Roadmap

1. Pin Bend 2.0.4 and prove check, proof, and CPU compile on the JS and native paths.
2. Deliver a deterministic npm-compatible resolver, verified store, isolated linker, and secure package lifecycle.
3. Deliver JavaScript and TypeScript parsing, transpilation, module resolution, source maps, and incremental compilation.
4. Deliver JavaScript linking, tree shaking, code splitting, CSS, HTML, assets, and atomic production output.
5. Deliver the isolated Node.js test runner, assertions, reporting, snapshots, coverage, and watch mode.
6. Tune multicore execution and enable GPU stages only when equivalent output and end-to-end gains are demonstrated.

## Product boundaries

The initial product does not include:

- A JavaScript runtime or REPL.
- Static TypeScript type checking or declaration generation.
- A development server or hot module replacement.
- Arbitrary JavaScript plugins inside the native process.
- Implicit network access during builds.
- Package lifecycle scripts enabled by default.
- A GPU requirement.

Unsupported behavior must fail with a clear diagnostic rather than silently falling back to another tool.

## Design documents

| Document | Scope |
| --- | --- |
| [Package manager PRD](./docs/package-manager-prd.md) | Registry resolution, lockfile, verified store, isolated linking, security, and recovery |
| [Compiler PRD](./docs/ts-compiling-prd.md) | JavaScript and TypeScript parsing, transformations, resolution, source maps, and incremental compilation |
| [Bundler PRD](./docs/bundler-prd.md) | JavaScript linking, code splitting, CSS, HTML, assets, caching, and atomic publication |
| [Test runner PRD](./docs/test-runner-prd.md) | Discovery, isolated execution, assertions, snapshots, coverage, reporting, and watch mode |
| [TDD plan](./tdd-plan.md) | Public test seams, red-green-refactor workflow, fixtures, CI levels, and initial vertical slices |
| [Bend2 capability](./docs/bend2-capability.md) | Pinned toolchain, commands, effects, and host adapters |
| [npm distribution](./docs/npm-distribution.md) | Scoped npm packages, platform binaries, and the release gate for publishing `knot` |
| [Knot vs bun](./benchmark/package-manager/knot-bun-comparison.md) | Cached `install` after deleting `node_modules` |
| [Knot vs npm](./benchmark/package-manager/knot-npm-comparison.md) | Same method against npm 11 |
| [Knot vs pnpm](./benchmark/package-manager/knot-pnpm-comparison.md) | Same method against pnpm 11 |

The dedicated PRD for a subsystem is authoritative when documents overlap.
The bundler PRD owns graph, linker, chunk, CSS, HTML, asset, and output behavior.
The TDD plan owns the verification process.
