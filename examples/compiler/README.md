# Compiler examples

These examples demonstrate the public `knot transpile` and `knot analyze` commands.

Run commands from the repository root.

```sh
./scripts/build-knot
```

Generated JavaScript and source maps are ignored by Git.

## TypeScript erasure

The basic example removes interfaces, type aliases, and annotations while keeping executable code.

```sh
./bin/knot transpile examples/compiler/basic/greet.ts
node examples/compiler/basic/greet.js
# hello knot
```

## Runtime TypeScript features

The enum example lowers a numeric enum and prints its members.

```sh
./bin/knot transpile examples/compiler/enum/color.ts
node examples/compiler/enum/color.js
# 1 2
```

The namespace example lowers a value namespace and preserves its runtime object.

```sh
./bin/knot transpile examples/compiler/namespace/math-util.ts
node examples/compiler/namespace/math-util.js
# 42
```

The parameter-properties example emits constructor assignments.

```sh
./bin/knot transpile examples/compiler/param-props/point.ts
node examples/compiler/param-props/point.js
# 3,4
```

The `satisfies` example erases the type constraint while preserving the value.

```sh
./bin/knot transpile examples/compiler/satisfies/config.ts
node examples/compiler/satisfies/config.js
# 3000
```

## JSX modes

Classic JSX lowers to `React.createElement` without requiring a React runtime.

```sh
./bin/knot transpile examples/compiler/jsx-classic/app.tsx
cat examples/compiler/jsx-classic/app.js
```

Automatic JSX emits imports from `react/jsx-runtime`.

```sh
./bin/knot transpile --jsx-runtime automatic examples/compiler/jsx-automatic/app.tsx
cat examples/compiler/jsx-automatic/app.js
```

Preserve JSX strips TypeScript types and leaves JSX tags in place.

```sh
./bin/knot transpile --jsx-runtime preserve examples/compiler/jsx-preserve/app.tsx
cat examples/compiler/jsx-preserve/app.js
```

## Import graph analysis

The analyze example reports the entry module and its relative import edge.

```sh
./bin/knot analyze examples/compiler/analyze-graph/main.ts
```

## Source maps

The source-map example emits JavaScript with a linked map and a `sourceMappingURL` comment.

```sh
./bin/knot transpile examples/compiler/sourcemap/tiny.ts
```
