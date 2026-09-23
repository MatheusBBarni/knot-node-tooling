# Knot vs npm install

Date: 2026-09-23

This is a cached rematerialize comparison, not a resolver or download comparison.

## Fixture

Project: a copy of [spec-finder](https://github.com/MatheusBBarni/spec-finder) `package.json` (spec-finder 0.5.2).

Direct dependencies: `@agentclientprotocol/sdk@1.2.1`, `@opentui/core@^0.4.5`, `@opentui/react@^0.4.5`, `react@^19.2.7`, `yaml@^2.8.1`, `zod@^4.4.3`.

Dev dependencies: `@types/bun`, `@types/react@^19.2.7`, `typescript@^5.9.3`.

Knot used the existing `knot.lock` (31 packages).
npm created `package-lock.json` during warmup and reused it (29 packages added).

## Machine

- Host: Darwin 25.6.0, arm64
- CPU: Apple M5
- Disk: APFS
- Knot binary: `bin/knot` from commit `KNOT_SHA`, `--version` prints `0.0.0`
- npm: 11 (Homebrew)
- Node used only to launch the timer: v26.8.1

## Method

Workdir: `/tmp/knot-bench-spec-finder-p0` for Knot; `/tmp/knot-bench-npm-warm` for npm.

Caches were already warm (`~/.knot` for Knot, npm's default cache for npm).

Sequence for each tool:

1. Untimed `rm -rf node_modules` and one `install` (warmup, discarded).
2. Five timed runs of `rm -rf node_modules` then `install`.
3. One extra `install` with `node_modules` already present (no-op).

Times are process wall from spawn to exit, measured with Python `time.perf_counter`.

Commands:

```text
rm -rf node_modules
<tool> install
```

No extra flags for the table below (Knot default backend).

## Results

Cached install after deleting `node_modules`:

| Tool | Packages reported | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| knot `KNOT_SHA` | 31 | 42.2 ms | 42.8 ms | 43.4 ms | 45.4 ms | 9.9 ms |
| npm 11 | 29 | 578.0 ms | 628.4 ms | 613.1 ms | 639.1 ms | 441.2 ms |

Raw Knot runs: 42.68, 42.81, 42.22, 45.40, 43.93 ms.

Raw npm runs: 639.11, 628.90, 628.37, 591.17, 578.04 ms.

On this fixture Knot is faster.
Median process wall is about 15x (42.8 ms vs 628.4 ms).

## Notes

Graphs are not identical across tools.
npm's warmup was the first lockfile write on this copy.

## Not measured

- Cold caches
- First resolve from the registry
- Lifecycle scripts
- Same-graph lockfiles across tools
