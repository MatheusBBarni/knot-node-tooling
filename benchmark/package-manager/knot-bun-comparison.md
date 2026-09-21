# Knot vs bun install

Date: 2026-09-21

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
- Knot binary: `bin/knot` from commit `d818d85`, `--version` prints `0.0.0`
- bun: 1.4.2 (`744846f84`)
- Node used only to launch the timer: v26.8.1

## Method

Workdir: `/tmp/knot-bench-spec-finder` (copy of `package.json` plus each tool's lockfile).

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

No extra flags.

## Results

Cached install after deleting `node_modules`:

| Tool | Packages linked | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| bun 1.4.2 | 29 | 23.4 ms | 26.5 ms | 27.3 ms | 31.6 ms | 9.3 ms |
| knot `d818d85` | 31 | 36.3 ms | 49.2 ms | 48.0 ms | 58.6 ms | 14.6 ms |

Raw Knot runs: 36.32, 42.71, 53.04, 49.23, 58.60 ms.

Raw bun runs: 31.55, 26.54, 30.02, 25.11, 23.43 ms.

On this fixture bun is faster.
Median process wall is about 1.9x (49.2 ms vs 26.5 ms).

## Notes

Knot prints a `+ name@version` line for every package it links.
Bun prints nine top-level lines on this project.
That extra stderr is in the Knot times.

Knot clonefiles unpacked trees from `~/.knot/unpacked` into `node_modules/.knot` and writes isolated symlinks.
Bun uses its own store and linker.
The layouts are not the same, so a faster time is not proof of a better install.

Knot's own timer on the warmup run printed `34ms` while process wall was 51.5 ms.
Use the wall times above if you are comparing tools.

## Not measured

- Cold caches
- First resolve from the registry
- `--offline`
- Lifecycle scripts
- Workspaces with more than this package.json
- CPU-only vs GPU (Knot install is CPU)
