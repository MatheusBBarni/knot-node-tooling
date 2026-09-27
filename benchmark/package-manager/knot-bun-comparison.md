# Knot vs bun install

Date: 2026-09-26

This is a cached rematerialize comparison, not a resolver or download comparison.

## Fixture

Project: a copy of [spec-finder](https://github.com/MatheusBBarni/spec-finder) `package.json` (spec-finder 0.5.2).

Direct dependencies: `@agentclientprotocol/sdk@1.2.1`, `@opentui/core@^0.4.5`, `@opentui/react@^0.4.5`, `react@^19.2.7`, `yaml@^2.8.1`, `zod@^4.4.3`.

Dev dependencies: `@types/bun`, `@types/react@^19.2.7`, `typescript@^5.9.3`.

Knot used the existing `knot.lock` (31 packages).
Bun used the existing `bun.lock` (29 packages).

The two lockfiles do not pin the same versions.
Knot resolved `@opentui/core@0.5.11` and a native `@opentui/core-darwin-arm64` package.
Bun kept `@opentui/core@0.4.5`.
Do not treat the times as same-graph.

## Machine

- Host: Darwin 25.6.0, arm64
- CPU: Apple M5
- Disk: APFS
- Knot binary: `bin/knot` from the working tree after the parallel rematerialization change, `--version` prints `0.0.0`
- bun: 1.4.2
- Node used only to launch the timer: v26.8.1

## Method

Workdir: separate temporary directories containing a copy of `package.json` plus each tool's lockfile.

Caches were already warm (`~/.knot` for Knot, bun's install cache for bun).

Sequence for each tool:

1. Untimed `rm -rf node_modules` and one `install` (warmup, discarded).
2. Eleven timed runs of `rm -rf node_modules` then `install`.
3. One extra `install` with `node_modules` already present (no-op).

Times are process wall from spawn to exit, measured with Python `time.perf_counter`.
That includes binary startup.
It is not the number bun prints in `[Nms]` or the number Knot prints after `packages installed`.

Commands:

```text
rm -rf node_modules
<tool> install
```

Default Knot and bun use no extra flags.

## Results

Cached install after deleting `node_modules`:

| Tool | Packages linked | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| bun 1.4.2 | 29 | 22.14 ms | 25.35 ms | 25.16 ms | 28.24 ms | 9.20 ms |
| knot default | 31 | 24.37 ms | 24.71 ms | 24.80 ms | 25.91 ms | 7.56 ms |

Raw bun runs: 25.35, 24.19, 26.58, 23.07, 22.14, 27.39, 27.40, 22.83, 26.83, 28.24, 22.74 ms.

Raw Knot runs: 24.86, 24.57, 24.93, 24.90, 24.37, 24.47, 24.76, 24.70, 25.91, 24.63, 24.71 ms.

Knot's median is 0.64 ms, or about 2.5%, below bun's median in this run.
That difference is small enough to call the tools effectively tied on this fixture.
Knot linked two more packages, but the lock graphs differ, so this is not a same-work comparison.
Before package materialization was parallelized, the same investigation measured Knot at 36.83 ms median and bun at 28.72 ms median over seven runs.
The optimization reduced Knot's measured median by about 33%.

## Notes

The locked-install host adapter parses the lockfile once, rematerializes independent packages across at most eight worker threads, then emits progress in lockfile order.
The bounded worker count avoids serial `clonefile` and package-layout work without making terminal output nondeterministic.

`--backend hardlink` creates hardlinks (`nlink > 1` on materialized files).
On APFS, recursive per-file hardlink is much slower than directory `clonefile`, which remains the default / `auto` / `clone` path.
Prefer `clone` or `auto` on macOS; use `hardlink` where CoW clone is unavailable, which includes typical Linux installs.

Knot clonefiles unpacked trees from `~/.knot/unpacked` into `node_modules/.knot` and writes isolated symlinks.
Bun uses its own store and linker.
The layouts are not the same, so a faster time is not proof of a better installer overall.

## Not measured

- Cold caches
- First resolve from the registry
- `--offline`
- Lifecycle scripts
- Workspaces with more than this package.json
- CPU-only vs GPU (Knot install is CPU)
