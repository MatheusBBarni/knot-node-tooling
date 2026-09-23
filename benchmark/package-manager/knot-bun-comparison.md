# Knot vs bun install

Date: 2026-09-23

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
- Knot binary: `bin/knot` from commit `04afe15`, `--version` prints `0.0.0`
- bun: 1.4.2
- Node used only to launch the timer: v26.8.1

## Method

Workdir: `/tmp/knot-bench-spec-finder-p0` (copy of `package.json` plus each tool's lockfile).

Caches were already warm (`~/.knot` for Knot, bun's install cache for bun).

Sequence for each tool:

1. Untimed `rm -rf node_modules` and one `install` (warmup, discarded).
2. Five timed runs of `rm -rf node_modules` then `install`.
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
Additional Knot rows use `--reporter silent` and/or `--backend hardlink`.

## Results

Cached install after deleting `node_modules`:

| Tool | Packages linked | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| bun 1.4.2 | 29 | 28.2 ms | 29.7 ms | 30.7 ms | 33.6 ms | 10.2 ms |
| knot default (`04afe15`) | 31 | 42.2 ms | 42.8 ms | 43.4 ms | 45.4 ms | 9.9 ms |
| knot `--reporter silent` | 31 | 42.9 ms | 43.3 ms | 43.4 ms | 44.2 ms | 10.3 ms |
| knot `--backend hardlink` | 31 | 544.3 ms | 554.0 ms | 552.8 ms | 559.8 ms | 10.4 ms |
| knot silent + hardlink | 31 | 555.8 ms | 558.5 ms | 560.8 ms | 566.7 ms | 12.6 ms |

Raw bun runs: 29.65, 28.18, 33.20, 33.56, 28.75 ms.

Raw Knot default runs: 42.68, 42.81, 42.22, 45.40, 43.93 ms.

Raw Knot silent runs: 42.96, 43.79, 43.26, 42.93, 44.19 ms.

Raw Knot hardlink runs: 554.01, 550.64, 544.30, 559.81, 555.14 ms.

On this fixture bun is still faster on the default backends.
Median process wall is about 1.4x (42.8 ms vs 29.7 ms), down from about 1.9x on 2026-09-21 (49.2 ms vs 26.5 ms).

## Notes

`--reporter silent` removes per-package `+ name@version` lines on the native offline path.
On this fixture that did not move median wall time meaningfully versus default.

`--backend hardlink` does create hardlinks (`nlink > 1` on materialized files).
On APFS, recursive per-file hardlink is much slower than directory `clonefile`, which remains the default / `auto` / `clone` path.
Prefer `clone` or `auto` on macOS; use `hardlink` where CoW clone is unavailable (typical Linux installs).

Knot clonefiles (by default) unpacked trees from `~/.knot/unpacked` into `node_modules/.knot` and writes isolated symlinks.
Bun uses its own store and linker.
The layouts are not the same, so a faster time is not proof of a better install.

## Not measured

- Cold caches
- First resolve from the registry
- `--offline`
- Lifecycle scripts
- Workspaces with more than this package.json
- CPU-only vs GPU (Knot install is CPU)
