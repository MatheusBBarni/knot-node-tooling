# Compiler examples

Small demos of `knot transpile` / `knot analyze` on `feat/compiler`.

```sh
./scripts/build-knot
```

Generated `examples/**/*.js` and `examples/**/*.js.map` are gitignored — re-run the commands below to recreate them.

## Basic TypeScript strip

Interfaces, type aliases, and annotations erased; value code kept.

```sh
./bin/knot transpile examples/basic/greet.ts
node examples/basic/greet.js
# hello knot
```

## Classic JSX

Lowers to `React.createElement` (nested elements, expression children, self-closing, fragment). Shape demo only — no React runtime required.

```sh
./bin/knot transpile examples/jsx-classic/app.tsx
cat examples/jsx-classic/app.js
```

## Automatic JSX runtime

```sh
./bin/knot transpile --jsx-runtime automatic examples/jsx-automatic/app.tsx
cat examples/jsx-automatic/app.js
```

Emits `jsx` from `react/jsx-runtime` with a `children:` prop for `{label}`.

## Preserve JSX

Types stripped; JSX tags left in place.

```sh
./bin/knot transpile --jsx-runtime preserve examples/jsx-preserve/app.tsx
cat examples/jsx-preserve/app.js
```

## Numeric enum

```sh
./bin/knot transpile examples/enum/color.ts
node examples/enum/color.js
# 1 2
```

## Value namespace

```sh
./bin/knot transpile examples/namespace/math-util.ts
node examples/namespace/math-util.js
# 42
```

## Parameter properties

```sh
./bin/knot transpile examples/param-props/point.ts
node examples/param-props/point.js
# 3,4
```

## `satisfies`

Erased at emit; value remains.

```sh
./bin/knot transpile examples/satisfies/config.ts
node examples/satisfies/config.js
# 3000
```

## Analyze import graph

```sh
./bin/knot analyze examples/analyze-graph/main.ts
```

JSON includes `entries`, `modules`, and the `./util.ts` import edge.

## Linked source map

```sh
./bin/knot transpile examples/sourcemap/tiny.ts
# writes tiny.js + tiny.js.map (sourceMappingURL comment)
```
