# Transpiler examples

Fixtures for `knot transpile` on `feat/compiler`.

```sh
./scripts/build-knot
```

Generated `.js` / `.js.map` under `examples/` are gitignored — re-run the commands below to recreate them.

## Basic TypeScript strip

```sh
./bin/knot transpile examples/basic/greet.ts
node examples/basic/greet.js
# hello knot
```

## Classic JSX

```sh
./bin/knot transpile examples/jsx-classic/app.tsx
cat examples/jsx-classic/app.js
```

Emits `React.createElement(...)` with nested elements, `{name}`, `<br />`, and fragments.

## Automatic JSX runtime

```sh
./bin/knot transpile --jsx-runtime automatic examples/jsx-automatic/app.tsx
cat examples/jsx-automatic/app.js
```

Emits `jsx` from `react/jsx-runtime`. This fixture uses a self-closing element; prefer classic mode when you need expression children (`children: expr` still collides with the type stripper).
