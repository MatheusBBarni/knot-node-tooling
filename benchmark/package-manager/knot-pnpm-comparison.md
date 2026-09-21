# Knot vs pnpm install

Date: 2026-09-21

This is a cached rematerialize comparison, not a resolver or download comparison.

## Fixture

Project: a copy of [spec-finder](https://github.com/MatheusBBarni/spec-finder) `package.json` (spec-finder 0.5.2).

Direct dependencies: `@agentclientprotocol/sdk@1.2.1`, `@opentui/core@^0.4.5`, `@opentui/react@^0.4.5`, `react@^19.2.7`, `yaml@^2.8.1`, `zod@^4.4.3`.

Dev dependencies: `@types/bun`, `@types/react@^19.2.7`, `typescript@^5.9.3`.

Knot used the existing `knot.lock` (31 packages).
pnpm created `pnpm-lock.yaml` during warmup and reused it (29 packages added).

The graphs are not identical.
Knot resolved `@opentui/core@0.5.11` plus `@opentui/core-darwin-arm64`.
pnpm kept `@opentui/core@0.4.5` and reported `Packages: +29`.

## Machine

- Host: Darwin 25.6.0, arm64
- CPU: Apple M5
- Disk: APFS
- Knot binary: `bin/knot` from commit `d818d85`, `--version` prints `0.0.0`
- pnpm: 11.0.5

## Method

Workdir: `/tmp/knot-bench-spec-finder`.

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

No extra flags.
pnpm's warmup on this copy printed `Done in 3s` while it filled the store (`reused 7, downloaded 22`).
Timed runs used the new lockfile and the filled store.

## Results

Cached install after deleting `node_modules`:

| Tool | Packages reported | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| knot `d818d85` | 31 | 36.3 ms | 49.2 ms | 48.0 ms | 58.6 ms | 14.6 ms |
| pnpm 11.0.5 | 29 | 521.2 ms | 596.4 ms | 589.3 ms | 659.7 ms | 474.7 ms |

Raw Knot runs: 36.32, 42.71, 53.04, 49.23, 58.60 ms.

Raw pnpm runs: 548.71, 659.68, 596.44, 620.69, 521.15 ms.

On this fixture Knot is faster.
Median process wall is about 12x (49.2 ms vs 596.4 ms).

pnpm's no-op with `node_modules` already present was 474.7 ms.
That is close to its rematerialize times on this machine.

## Notes

Both tools use a content-addressed store and an isolated project layout, but they are not the same layout.
pnpm links from its store.
Knot clonefiles from `~/.knot/unpacked` into `node_modules/.knot`.

pnpm printed progress lines on stdout during the runs.
Those writes are in the wall times.

This is not a claim that Knot matches pnpm's peer resolution, hoisting, or `pnpm-workspace.yaml` behavior.

## Not measured

- Cold pnpm store
- `pnpm install --offline`
- Workspaces
- Lifecycle scripts
- A shared lockfile (the formats differ)
