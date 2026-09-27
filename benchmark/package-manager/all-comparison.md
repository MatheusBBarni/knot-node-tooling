# Knot package manager comparison

Date: 2026-09-27

This is a cached rematerialize comparison across Knot, Bun, pnpm, and npm.

It measures install process wall time after deleting `node_modules`.

It does not measure first resolution, registry downloads, lifecycle scripts, or cold caches.

## Fixture

All tools used the same package manifest based on spec-finder 0.5.2.

Direct dependencies were `@agentclientprotocol/sdk@1.2.1`, `@opentui/core@^0.4.5`, `@opentui/react@^0.4.5`, `react@^19.2.7`, `yaml@^2.8.1`, and `zod@^4.4.3`.

Dev dependencies were `@types/bun@latest`, `@types/react@^19.2.7`, and `typescript@^5.9.3`.

Each package manager generated or reused its own lockfile.

The resolved graphs are not identical across tools.

## Machine and tools

- Host: Darwin 25.6.0, arm64
- CPU: Apple M5
- Knot: `bin/knot` version `0.0.1`
- Bun: `1.4.2`
- pnpm: `11.0.5`
- npm: `11.19.0`

## Method

Caches were warm before timed runs.

For each tool, one untimed warmup install ran first.

Five timed runs deleted `node_modules` before executing the default install command.

One additional install ran with `node_modules` already present for the no-op measurement.

Commands were:

```text
rm -rf node_modules
<tool> install
```

Times are process wall time measured with Python `time.perf_counter`.

## Results

| Tool | Packages linked | min | median | mean | max | no-op |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Knot 0.0.1 | 31 | 42.80 ms | 46.45 ms | 50.09 ms | 58.91 ms | 19.18 ms |
| Bun 1.4.2 | 29 | 34.19 ms | 39.38 ms | 38.04 ms | 42.25 ms | 20.48 ms |
| pnpm 11.0.5 | 29 | 521.56 ms | 550.56 ms | 590.55 ms | 696.64 ms | 339.88 ms |
| npm 11.19.0 | 29 | 838.98 ms | 915.21 ms | 929.12 ms | 1129.00 ms | 288.44 ms |

Raw Knot runs: 58.91, 46.45, 42.80, 44.27, 58.03 ms.

Raw Bun runs: 34.71, 34.19, 39.68, 39.38, 42.25 ms.

Raw pnpm runs: 521.56, 642.04, 550.56, 541.96, 696.64 ms.

Raw npm runs: 1129.00, 918.61, 915.21, 843.82, 838.98 ms.

These results are a combined view of one package manifest, not a same-lockfile comparison.

The separate lockfiles resolve different versions and optional platform packages.
