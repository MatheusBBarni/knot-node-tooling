<div align="center">

# Knot

**A native JavaScript toolchain built in Bend2.**

[Overview](#overview) · [Planned commands](#planned-commands) · [Architecture](#architecture) · [Roadmap](#roadmap) · [Design documents](#design-documents)

</div>

Knot is a planned package manager, TypeScript compiler, production bundler, and test runner for JavaScript projects.
The native coordinator is written in Bend2 and uses external JavaScript runtimes only when generated code or tests need to execute.

> [!IMPORTANT]
> There is no installable release yet.
> The Bend2 capability gate in the [TDD plan](./tdd-plan.md#slice-0-bend2-capability-gate) has passed for Bend 2.0.4.
> The pin is in [`toolchain.json`](./toolchain.json).
> Details and missing host effects are in [Bend2 capability](./docs/bend2-capability.md).

## Overview

Knot aims to provide one small command for the common JavaScript workflow:

```text
knot install
knot build
knot test
```

The project is split into four connected systems:

- An npm-compatible package manager with verified downloads, deterministic lockfiles, an isolated `node_modules` layout, and a global content-addressed store.
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

## Planned commands

The command surface is still subject to prototype evidence, but the current product plans define these core workflows:

| Command | Purpose |
| --- | --- |
| `knot install` | Resolve, fetch, verify, and materialize project dependencies |
| `knot add <spec>` | Add and install a direct dependency |
| `knot remove <name>` | Remove a direct dependency |
| `knot update [name]` | Update dependencies within declared ranges |
| `knot fetch` | Populate the package store without creating project links |
| `knot why <name>` | Explain why a package exists in the graph |
| `knot transpile <files...>` | Transform JavaScript, TypeScript, JSX, or TSX without following imports |
| `knot build <entrypoints...>` | Compile and bundle application or library entry points |
| `knot analyze <entrypoints...>` | Report graph, artifact, and size information |
| `knot test [filters...]` | Discover, compile, isolate, and execute tests |

> [!NOTE]
> The current PRDs were written under the earlier working name `bnpm`.
> `Knot` is the selected product and CLI name.
> New implementation and public documentation should use `knot`, `knot.toml`, `knot.lock`, `node_modules/.knot`, and `knot:test`.

## Package management

Knot will consume npm-compatible registries while using its own deterministic lockfile and storage model.
Downloaded package bytes remain untrusted until their Subresource Integrity digest is verified.

The planned installer includes:

- Semver, dist-tag, optional dependency, peer dependency, and workspace resolution.
- HTTPS registry access with scoped registries, authentication, proxies, and custom certificate authorities.
- Offline and frozen installs.
- A per-file content-addressed global store.
- Clone, reflink, hard-link, and copy materialization backends.
- An isolated project store under `node_modules/.knot`.
- Lifecycle scripts denied by default and enabled through explicit approval.
- Transactional state changes that preserve the previous valid installation after failure.

## Compilation and bundling

The compiler will parse JavaScript, TypeScript, JSX, and TSX once per build generation.
It will remove type-only syntax and transform TypeScript constructs that have runtime meaning.
It will not type-check programs or emit declaration files in the initial release.

The bundler will consume the compiler's immutable module representation directly.
It will support browser and Node.js targets, ESM and CommonJS output, tree shaking, code splitting, source maps, CSS, HTML, and static assets.

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

The dedicated PRD for a subsystem is authoritative when documents overlap.
The bundler PRD owns graph, linker, chunk, CSS, HTML, asset, and output behavior.
The TDD plan owns the verification process.
