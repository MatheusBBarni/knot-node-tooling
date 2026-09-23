# Knot vs pnpm install

Date: 2026-09-23

This is a cached rematerialize comparison, not a resolver or download comparison.

## Fixture

Project: a copy of [spec-finder](https://github.com/MatheusBBarni/spec-finder) `package.json` (spec-finder 0.5.2).

Direct dependencies: `@agentclientprotocol/sdk@1.2.1`, `@opentui/core@^0.4.5`, `@opentui/react@^0.4.5`, `react@^19.2.7`, `yaml@^2.8.1`, `zod@^4.4.3`.

Dev dependencies: `@types/bun`, `@types/react@^19.2.7`, `typescript@^5.9.3`.

Knot used the existing `knot.lock` (31 packages).
pnpm created `pnpm-lock.yaml` during warmup and reused it (29 packages added).

## Machine

- Host: Darwin 25.6.0, arm64
- CPU: Apple M5
- Disk: APFS
- Knot binary: `bin/knot` from commit `04afe15`, `--version` prints `0.0.0`
- pnpm: 11.0.5
- Node used only to launch the timer: v26.8.1

## Method

Workdir: `/tmp/knot-bench-spec-finder-p0` for Knot; `/tmp/knot-bench-pnpm-warm` for pnpm.

Caches were already warm (`~/.knot` for Knot, pnpm's content-addressable store for pnpm).

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
| knot `04afe15` | 31 | 42.2 ms | 42.8 ms | 43.4 ms | 45.4 ms | 9.9 ms |
| pnpm 11.0.5 | 29 | 585.8 ms | 610.4 ms | 610.8 ms | 633.6 ms | 295.8 ms |

Raw Knot runs: 42.68, 42.81, 42.22, 45.40, 43.93 ms.

Raw pnpm runs: 585.80, 623.20, 633.61, 610.39, 601.16 ms.

On this fixture Knot is faster.
Median process wall is about 14x (42.8 ms vs 610.4 ms).

## Notes

Graphs are not identical across tools.
pnpm's warmup on this copy filled the store before timed runs.

## Not measured

- Cold caches
- First resolve from the registry
- Lifecycle scripts
- Same-graph lockfiles across tools
