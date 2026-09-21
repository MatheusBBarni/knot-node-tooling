# Product requirements document: TypeScript compilation and bundling

Status: Draft

Date: 2026-09-17

Working CLI name: `bnpm`

## 1. Summary

`bnpm` will expand from a package manager into a JavaScript and TypeScript toolchain implemented in Bend2.
This PRD covers the first step after package management: a fast TypeScript transpiler and JavaScript bundler without a JavaScript runtime.

The tool will parse `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `.mts`, and `.cts` files.
It will remove TypeScript syntax, transform TypeScript constructs that have runtime meaning, compile JSX, resolve modules, build an import graph, tree-shake unused code, split bundles, generate source maps, and write JavaScript for browsers or Node.js.

It will not type-check TypeScript in the initial release.
Calling this work a compiler is common, but the precise term is transpiler when the command processes one file without semantic type analysis.
The bundler adds graph resolution, linking, optimization, chunking, and output generation around that transpiler.

Bend2's parallel execution should be used across independent modules and output chunks.
GPU execution is experimental and must not sit on the default critical path until end-to-end measurements show a gain.

## 2. Product direction

The package manager in `package-manager-prd.md` establishes registry access, package resolution, a lockfile, and an isolated `node_modules` layout.
This PRD reuses those components to locate package entry points and build application code.

The longer-term product is a native JavaScript toolchain with these layers:

1. Package management.
2. TypeScript and JSX transpilation.
3. JavaScript and CSS bundling.
4. Watch mode and development-server integration.
5. Formatting, linting, testing, and other tooling only after the compiler core is stable.

A JavaScript runtime is not part of the plan.
The product will generate code for Node.js and browsers, then leave execution to those runtimes.
It will not embed JavaScriptCore, V8, or another general-purpose JavaScript virtual machine.

The `bnpm` name fits the package-manager phase but may be too narrow for a general toolchain.
Commands in this PRD use `bnpm` for continuity.
The public suite name must be settled before the build tool leaves preview.

## 3. Problem

TypeScript source cannot run in ordinary browsers and cannot run directly in every supported Node.js configuration.
Projects need several operations before deployment:

- Remove type-only syntax.
- Convert TypeScript constructs that emit runtime JavaScript.
- Convert JSX into function calls.
- Resolve local and package imports.
- Join modules while preserving ESM and CommonJS semantics.
- Remove unreachable or unused code without changing side effects.
- Produce source maps that map generated JavaScript back to the original source.
- Rebuild only affected outputs after a file changes.

A fast parser alone does not solve this problem.
Module resolution performs many filesystem queries.
Linking must preserve live bindings, cycles, re-exports, CommonJS behavior, package conditions, and side-effect order.
Minification must preserve JavaScript semantics under `eval`, getters, proxies, decorators, and other dynamic behavior.

The compiler also needs a clear TypeScript compatibility contract.
Some syntax can be erased as if it were whitespace.
Other syntax, including enums, namespaces with values, parameter properties, and decorators, requires emitted JavaScript.
A file-by-file transpiler does not have the type information available to the TypeScript compiler, so some TypeScript programs require `isolatedModules`-style restrictions.

## 4. Product principles

1. Preserve JavaScript behavior before optimizing output size or build time.
2. Parse TypeScript syntax without pretending to provide type safety.
3. Keep parsing, resolution, linking, and printing as separate contracts.
4. Compile independent modules in parallel.
5. Keep the serial graph and symbol-linking boundary small and explicit.
6. Reuse immutable work across watch rebuilds.
7. Produce deterministic output for identical inputs and configuration.
8. Keep Node.js and browser targets separate.
9. Make unsupported syntax and semantics fail clearly.
10. Require measured gains before adding GPU work to the default path.
11. Avoid a JavaScript runtime dependency in the compiler process.
12. Share package resolution rules with the `bnpm` package manager rather than creating a second resolver.

## 5. Goals

### 5.1 Initial release goals

- Transpile JavaScript, TypeScript, JSX, and TSX into JavaScript.
- Support current stable ECMAScript syntax and current stable TypeScript syntax covered by the compatibility corpus.
- Remove type annotations, interfaces, type aliases, ambient declarations, and type-only imports and exports.
- Transform enums, namespaces with runtime values, parameter properties, import assignments, export assignments, JSX, and supported decorators.
- Parse each source file once per build generation.
- Expose import and export scanning without full output generation.
- Bundle ESM and CommonJS dependency graphs.
- Target modern browsers and supported Node.js versions.
- Emit ESM and CommonJS.
- Support tree shaking, dead-code elimination, constant folding, compile-time defines, and granular minification.
- Support code splitting for ESM output.
- Generate linked, external, or inline source maps.
- Support `tsconfig.json` path aliases and JSX settings.
- Respect `package.json` exports, imports, conditions, type, main, module, browser, and sideEffects fields where relevant.
- Support no-bundle transpilation for library and migration workflows.
- Support watch mode with dependency-aware invalidation.
- Emit machine-readable build metadata and diagnostics.
- Integrate with packages installed by `bnpm` without requiring another package manager.
- Run on CPU-only machines and on Bend2-supported Metal or CUDA systems.

### 5.2 Success measures

Correct output is a release gate.
Performance measurements are invalid until semantic and source-map suites pass.

| Measure | Target |
| --- | --- |
| TypeScript syntax compatibility | 100% pass rate for the selected supported corpus |
| JavaScript semantics | Output matches the reference program for every runtime fixture |
| Module resolution | Matches the documented Node.js or browser resolution contract for every fixture |
| Source maps | Generated positions map to the correct original file, line, column, and name |
| Determinism | Byte-identical output and metadata across repeated clean builds |
| No-bundle throughput | Competitive with current stable Bun and esbuild on the published corpus |
| Bundle throughput | No slower than esbuild by more than 15% on the reference graphs before stable release |
| Incremental rebuild | Unrelated file changes do not parse or print unaffected modules |
| Watch latency | p95 rebuild completes within 100 ms for the small reference application after filesystem notification |
| Memory | Peak memory is bounded and documented for a 10,000-module graph |
| GPU policy | Automatic GPU use requires at least 15% end-to-end improvement for that workload class |

The stable release does not require beating Bun on every benchmark.
It requires a published explanation for material gaps and no hidden difference in targets, minification, source maps, or cache state.

## 6. Non-goals for the initial release

- Static type checking.
- Type inference.
- `.d.ts` declaration generation.
- A language server.
- A JavaScript runtime or REPL.
- Executing TypeScript source directly.
- Standalone executable generation.
- JavaScript bytecode generation.
- CSS, HTML, image, WebAssembly, or native-addon bundling.
- A development server or hot module replacement.
- Arbitrary JavaScript plugins.
- Babel plugin compatibility.
- TypeScript compiler API compatibility.
- ES5 output.
- Automatic polyfill injection.
- Framework-specific compilation such as Angular AOT or React Compiler transforms.
- Legacy decorator metadata emission in the first stable release.
- Source transforms that depend on cross-file type information.
- Importing packages from the network during a build.

A later declaration emitter or type checker must be designed as a separate semantic phase.
It must not be implied by the success of syntax transpilation.

## 7. Users and jobs

### Application developer

The developer wants one command to turn a TypeScript application into browser or Node.js JavaScript.
The developer expects a source-mapped stack trace to point to the original TypeScript.

### Library author

The author wants per-file ESM and CommonJS output without bundling dependencies.
Declaration generation remains a separate TypeScript compiler step until `bnpm` has a real semantic type system.

### Monorepo maintainer

The maintainer wants workspace-aware resolution, parallel compilation, stable caches, and rebuilds limited to affected graph regions.

### Framework author

The author wants loader and resolver extension points without requiring the compiler to embed a JavaScript runtime.
The first release will provide a constrained protocol rather than Bun-compatible JavaScript plugins.

### CI owner

The owner wants deterministic output, a frozen package graph, build metadata, and cache keys that do not depend on machine-local paths.

### Bend2 contributor

The contributor wants a compiler workload that exercises parallel graph processing while keeping branch-heavy parsing on the backend that actually wins.

## 8. Research findings

The findings in this section describe Bun documentation and source reviewed on 2026-09-17.
Bun changes quickly, so the linked sources are part of the decision record.

### 8.1 Bun has its own TypeScript parser

Bun does not invoke `tsc` when it runs or builds a TypeScript file.
Bun's maintainer describes it as having its own JavaScript parser with TypeScript and JSX support.
Bun's license states that its JavaScript transpiler, CSS lexer, and Node.js module resolver are ports of esbuild source.

The historical implementation was primarily in Zig.
The current repository contains Rust workspace crates for `src/js_parser`, `src/js_printer`, `src/transpiler`, `src/bundler`, `src/ast`, `src/resolver`, and `src/sourcemap`.
The current parser crate exposes separate lexer, parser, scan, TypeScript, lowering, folding, and visit modules.
The printer translates the shared AST back to source text and participates in source-map generation and renaming.

This architecture matters more than the implementation language.
Bun owns a native parser, AST, transforms, resolver, linker, and printer instead of passing source text through the TypeScript compiler.

Sources:

- [Bun maintainer explanation of the parser](https://github.com/oven-sh/bun/discussions/14758)
- [Bun license and esbuild credit](https://github.com/oven-sh/bun/blob/main/LICENSE.md)
- [Bun current Rust workspace](https://github.com/oven-sh/bun/blob/main/Cargo.toml)
- [Bun current parser crate](https://github.com/oven-sh/bun/tree/main/src/js_parser)
- [Bun current printer crate](https://github.com/oven-sh/bun/tree/main/src/js_printer)

### 8.2 TypeScript is transpiled, not type-checked

Bun selects a loader from the file extension.
The `ts` loader handles `.ts`, `.mts`, and `.cts`.
It removes TypeScript syntax and then applies the JavaScript transform pipeline.
The `tsx` loader also converts JSX.
Bun does not type-check and does not generate declaration files.

Bun recommends a separate TypeScript configuration with `noEmit: true` for editor and checker use.
The bundler documentation explicitly says it is not a replacement for `tsc` type checking or declaration generation.

This separation gives Bun speed and permits per-file parallelism.
It also means checker options such as `strict`, `noImplicitAny`, and `noUncheckedIndexedAccess` do not change emitted JavaScript.

Sources:

- [Bun file types and loaders](https://bun.sh/docs/runtime/file-types)
- [Bun TypeScript configuration](https://bun.sh/docs/runtime/typescript)
- [Bun bundler](https://bun.sh/docs/bundler)

### 8.3 Bun exposes a single-file transpiler

`Bun.Transpiler` exposes four useful operations:

- `transformSync()` converts one source string into JavaScript on the caller's thread.
- `transform()` runs transforms through Bun's worker thread pool.
- `scan()` returns imports, exports, and metadata.
- `scanImports()` returns imports through a faster, slightly less accurate path.

The transform API does not resolve modules, execute code, or build a bundle.
Type-only imports and exports do not appear as runtime dependencies.
Bun recommends the synchronous operation unless the caller has many large files because thread-pool overhead can cost more than the transform.

The API accepts a loader, target, compile-time definitions, JSX-related tsconfig settings, export elimination or replacement, import trimming, whitespace minification, and constant inlining.

Source: [Bun transpiler API](https://bun.sh/docs/runtime/transpiler).

### 8.4 Bundling adds a graph pipeline

Bun's bundler begins from one or more entry points.
It resolves imports, reads modules, parses TypeScript and JavaScript, records imports and exports, links symbols, removes unused code, creates chunks, prints output, and emits source maps and metadata.

The documented bundler behavior includes:

- Browser, Node.js, and Bun targets.
- ESM, CommonJS, and IIFE output formats, with current maturity differences.
- JSX classic and automatic runtimes.
- Multiple entry points and optional code splitting.
- External import patterns and package externalization.
- Compile-time `define` replacement.
- Syntax, whitespace, and identifier minification.
- Linked, external, inline, or disabled source maps.
- Deterministic output naming patterns.
- A metafile with input, output, import, export, and byte contribution data.
- Watch mode through the CLI.
- A no-bundle mode for file-level transpilation.

Bun's JavaScript files are parsed and transformed even when no TypeScript syntax exists.
The bundler performs tree shaking and dead-code elimination but generally does not down-convert modern JavaScript syntax to older language targets.

Source: [Bun bundler reference](https://bun.sh/docs/bundler).

### 8.5 Resolution is part of compilation correctness

Bun supports extensionless imports, TypeScript extension substitution, ESM and CommonJS, package exports and imports maps, conditional exports, tsconfig paths, and target-specific conditions.
The exact extension search order changes by import kind and whether the source is inside `node_modules`.

For package imports, the selected export depends on the target and import kind.
Browser builds prioritize browser conditions.
Node.js builds prioritize Node.js conditions.
Bun runtime builds may use Bun-specific conditions, but that target does not apply to this product because `bnpm` has no runtime.

A build tool that parses syntax correctly but selects the wrong package entry point is incorrect.
The resolver must therefore be shared with package metadata and tested independently from the parser.

Source: [Bun module resolution](https://bun.sh/docs/runtime/module-resolution).

### 8.6 TypeScript compatibility has hard edges

Most TypeScript syntax can be erased, including interfaces, type aliases, generic annotations, ambient declarations, and explicit type-only imports and exports.
Some TypeScript syntax has runtime behavior and must be transformed.
Examples include enums, value namespaces, parameter properties, import assignments, export assignments, and decorators.

A per-file compiler cannot always determine whether an imported symbol is a type or a runtime value.
Projects should use explicit `import type` and `export type`, and the compatibility contract should follow `isolatedModules` and `verbatimModuleSyntax` principles.

Decorator output needs an explicit mode.
Bun has had version-specific differences between TC39 decorators and legacy TypeScript decorators, including a reported case where `experimentalDecorators` did not select legacy output.
`emitDecoratorMetadata` requires semantic type information and must not be promised by a syntax-only compiler.

Sources:

- [TypeScript `erasableSyntaxOnly`](https://www.typescriptlang.org/tsconfig/erasableSyntaxOnly.html)
- [Bun decorator compatibility report](https://github.com/oven-sh/bun/issues/27575)
- [esbuild TypeScript behavior and isolated compilation](https://esbuild.github.io/content-types/#typescript)

### 8.7 Bun and esbuild use a small number of integrated passes

Bun credits esbuild for its transpiler and resolver lineage.
Esbuild documents a scan phase that parses independent files in parallel and a compile phase that links and prints the result.
Its parser augments JavaScript parsing with TypeScript syntax instead of using a separate TypeScript frontend.
Most type syntax is skipped, while runtime TypeScript constructs are lowered to JavaScript.

Esbuild combines work to reduce full-AST traversals:

1. Lexing, parsing, scope setup, and symbol declaration.
2. Identifier binding, definitions, constant folding, syntax lowering, and mangling.
3. Printing and source-map generation.

This is a useful model for `bnpm`, but it is not a requirement to copy esbuild's exact AST or pass structure.
Bend2 data representation, ownership, and backend behavior must drive the implementation.

Source: [esbuild architecture](https://github.com/evanw/esbuild/blob/master/docs/architecture.md).

### 8.8 GPU parsing is not an assumed advantage

Lexing and parsing are branch-heavy and have sequential dependencies within one source file.
Independent files provide good module-level parallelism on CPU cores without moving source text and AST data across a device boundary.

Bend2's published Apple M4 Max benchmark lists its lexer at 2.470 seconds on one Bend core, 0.218 seconds on sixteen cores, and 1.706 seconds on the GPU.
The published GPU result is about 7.8 times slower than the sixteen-core result for that workload.
The benchmark fixtures and build settings were not independently reproduced for this PRD.

The result does not prove that every GPU compiler pipeline will be slower.
It is enough to reject GPU-first lexing as a product assumption.

Source: [Bend2 landing page benchmark data](https://github.com/VictorTaelin/bend2-landing/blob/1c8258ea8464b56758854e7ac5cfdb470bb185a6/index.html).

## 9. Product scope

### 9.1 Required commands

| Command | Behavior |
| --- | --- |
| `bnpm transpile <files...>` | Transform each input independently and preserve the module boundary |
| `bnpm build <entrypoints...>` | Resolve, bundle, optimize, and emit one or more outputs |
| `bnpm build --no-bundle <files...>` | Run the build transform and printer without following imports |
| `bnpm build --watch` | Keep the build graph alive and rebuild affected outputs after changes |
| `bnpm scan <files...>` | Print runtime imports, exports, and source metadata as JSON |
| `bnpm analyze <entrypoints...>` | Produce bundle composition and dependency metadata without executing output |
| `bnpm clean --build-cache` | Remove compiler caches without touching the package store |

`bnpm build` must not install missing packages implicitly in the initial release.
It must report the missing dependency and the exact `bnpm install` command needed to restore the frozen graph.
This keeps network activity out of builds.

### 9.2 Required options

- `--target browser|node`
- `--format esm|cjs`
- `--outdir <path>`
- `--outfile <path>`
- `--root <path>`
- `--bundle`
- `--no-bundle`
- `--splitting`
- `--external <pattern>`
- `--packages bundle|external`
- `--conditions <condition>`
- `--platform-version <version-or-query>`
- `--jsx-runtime classic|automatic|preserve`
- `--jsx-factory <name>`
- `--jsx-fragment <name>`
- `--jsx-import-source <package>`
- `--define <name=value>`
- `--drop debugger|console|<qualified-name>`
- `--minify`
- `--minify-syntax`
- `--minify-whitespace`
- `--minify-identifiers`
- `--sourcemap none|linked|external|inline`
- `--tsconfig <path>`
- `--metafile <path>`
- `--watch`
- `--cpu`
- `--gpu`
- `--log-level silent|error|warning|info|debug`
- `--diagnostics text|json`

`--outfile` must be rejected when a build can produce more than one artifact.
Code splitting must require ESM output in the initial release.

## 10. Functional requirements

### 10.1 Loader selection

The compiler must select a loader from the exact file extension unless the caller overrides it.

| Extension | Loader | Behavior |
| --- | --- | --- |
| `.js`, `.mjs`, `.cjs` | `js` | Parse JavaScript and preserve or convert module format as configured |
| `.jsx` | `jsx` | Parse JavaScript plus JSX |
| `.ts`, `.mts`, `.cts` | `ts` | Parse TypeScript, remove types, and lower runtime constructs |
| `.tsx` | `tsx` | Parse TypeScript plus JSX |

`.mts` and `.mjs` must be treated as ESM.
`.cts` and `.cjs` must be treated as CommonJS.
For `.ts`, `.tsx`, `.js`, and `.jsx`, the nearest package `type` field and the selected output mode influence module interpretation without changing the accepted grammar.

### 10.2 Lexer

The lexer must support current JavaScript tokens, JSX lexical modes, TypeScript contextual keywords, hashbangs, Unicode identifiers, numeric separators, regular-expression literals, templates, comments, and source ranges.
It must distinguish division from regular expressions and JSX tags from comparison operators using parser context.
It must validate malformed UTF-8 according to the source-input policy and preserve enough byte-offset information for source maps.

The lexer must not allocate a heap object for every token.
The parser should request tokens on demand so context-sensitive lexing does not require a second tokenization pass.

Diagnostics must include stable error codes, file, byte range, line, column, and a concise recovery hint when one exists.
Error recovery may continue within a file for diagnostics, but no JavaScript may be emitted from a module with a syntax error.

### 10.3 Parser and AST

The parser must use one JavaScript grammar extended with TypeScript and JSX modes.
It must produce:

- Statements and expressions.
- Bindings, scopes, and symbol declarations.
- Import and export records.
- Comments needed for licenses, pure annotations, and source maps.
- Per-node source ranges where output mappings require them.
- Side-effect and tree-shaking parts at a useful granularity.
- Flags for ESM, CommonJS, top-level await, direct eval, and runtime TypeScript constructs.

The AST must be compact, arena-backed or otherwise bulk-reclaimable, and safe to share immutably across a build generation.
Source slices should refer to owned source buffers where possible rather than copying text.
Symbols must use stable internal identities instead of string equality throughout linking.

The parser must not perform filesystem access or package resolution.
It reports import records to the graph scanner.

### 10.4 TypeScript transform contract

The initial stable release must support these erasable forms:

- Type annotations.
- Type aliases.
- Interfaces.
- Generic parameter and argument syntax.
- `as`, `satisfies`, and non-null assertions.
- Ambient and `declare` forms that have no runtime output.
- Explicit type-only imports and exports.
- Overload signatures without bodies.

The initial stable release must transform these runtime forms:

- Numeric and string enums.
- Const enums according to the documented isolated-file policy.
- Namespaces and internal modules containing values.
- Constructor parameter properties.
- `import x = require("x")` where the selected module format supports it.
- `export =` where the selected module format supports it.
- TypeScript class fields according to `useDefineForClassFields` policy.
- Standard TC39 decorators.
- Legacy TypeScript decorators when explicitly selected and covered by fixtures.

`emitDecoratorMetadata` is unsupported until the compiler has semantic type information.
The compiler must reject it with a specific diagnostic instead of silently ignoring it.

The compiler must publish a syntax compatibility matrix by TypeScript release.
Parser support is tied to syntax features, not to installing a particular `typescript` npm package.

### 10.5 JSX transform

The compiler must support:

- JSX elements and fragments.
- Classic factory and fragment transforms.
- Automatic JSX runtime imports.
- Development and production output modes.
- Configurable import source.
- JSX preservation in no-bundle mode when requested.

JSX settings may come from `bnpm.toml`, the selected `tsconfig.json`, or CLI flags.
CLI flags take precedence.
The resolved settings must be part of the build-cache key.

### 10.6 Module resolver

The resolver must be shared with the package manager where package identity and filesystem layout overlap.
It must not duplicate semver or package-store logic.

The build resolver must support:

- Relative and absolute file imports.
- Exact extensions and documented extension substitution.
- Directory index files only where the selected resolution mode permits them.
- `node_modules` lookup through the isolated `.bnpm` layout.
- Workspace packages.
- `package.json` exports and imports maps.
- Import and require conditions.
- Browser and Node.js target conditions.
- Main, module, browser, and type fields according to the selected compatibility policy.
- `tsconfig.json` baseUrl and paths.
- Symlink identity according to a documented preserve-symlinks policy.
- External package and path patterns.

Resolution results must include the selected path, module kind, package identity, conditions used, side-effect metadata, and a trace suitable for diagnostics.
Filesystem query results must be cached within a build generation.
Negative lookups need invalidation in watch mode.

The initial release must not fetch packages from the network.

### 10.7 Graph scan

The scanner starts from all entry points and maintains a concurrent work queue of unresolved modules.
Each resolved module is loaded and parsed at most once for a given content digest and parse configuration.
Imports discovered during parsing add work to the queue.
The scan completes when no queued or in-flight module can add another dependency.

The graph must record:

- Static ESM imports and re-exports.
- Dynamic imports.
- CommonJS `require()` and `require.resolve()` calls with string literals.
- External imports.
- Import attributes.
- Top-level side effects.
- Entry-point reachability.
- Package sideEffects metadata.

Non-literal dynamic imports and requires must remain runtime operations or fail under a strict option.
The default behavior must be documented per target.

### 10.8 Binding and local transforms

A module transform must:

- Bind identifiers to symbols after all declarations in the module are known.
- Preserve JavaScript hoisting and temporal dead zone behavior.
- Remove type-only syntax and imports.
- Lower supported TypeScript runtime constructs.
- Lower JSX according to resolved settings.
- Substitute compile-time definitions.
- Fold constants only when the result is semantics-preserving.
- Mark statements and expressions for tree shaking.
- Lower syntax only when the target contract requires and supports it.

The implementation should combine compatible traversals after profiling confirms that fewer passes improve real builds.
Pass fusion must not make correctness changes impossible to review.

### 10.9 Linking

The linker must distinguish ESM, CommonJS, and hybrid modules.
It must preserve:

- ESM live bindings.
- Re-export and star-export behavior.
- Module initialization order.
- Circular dependency behavior.
- CommonJS `module.exports` identity.
- ESM and CommonJS default import interoperability according to the selected target.
- Top-level await restrictions.
- Direct eval scope behavior.

The linker must merge imported and exported symbol identities where static ESM linking permits it.
CommonJS modules that cannot be analyzed statically must retain runtime wrappers.

Tree shaking starts from entry-point side effects and requested exports.
A statement may be removed only when the compiler proves that the statement and its required dependencies are side-effect free under the documented model.
`package.json` sideEffects declarations and pure annotations may inform this model.
Users need an escape hatch to ignore incorrect third-party annotations.

### 10.10 Code splitting

ESM code splitting must support:

- Shared chunks across multiple entry points.
- Lazy chunks for dynamic imports.
- Stable content hashes.
- Relative or public-path-prefixed chunk imports.
- Deterministic chunk membership independent of worker completion order.
- Source maps for every JavaScript chunk.
- Manifest metadata mapping entry points and dynamic imports to output files.

Chunk generation must account for side effects and initialization order.
The initial release may prioritize correctness over minimum chunk count.

### 10.11 Printer

The printer must generate valid JavaScript for the selected format and target.
It must preserve directive prologues, hashbang policy, license comments, and semicolon safety.
It must support readable and minified output through the same semantic printer.

The printer must avoid intermediate full-file strings when it can write directly to a growable output buffer.
It must expose generated offsets to the source-map builder.
Output buffers should be sized from source and transform estimates to avoid repeated allocation.

### 10.12 Source maps

Supported modes:

- `none` emits no map.
- `linked` writes a separate map and adds `sourceMappingURL`.
- `external` writes a separate map without linking it in generated code.
- `inline` embeds a base64 map in generated code.

Maps must follow Source Map revision 3.
They must include normalized source paths, optional sourcesContent, names where available, and mappings at token-level positions needed for stack traces and breakpoints.

Source-map composition is required when an extension transform supplies an input map.
Path normalization must not leak a developer's home directory in reproducible CI output.

### 10.13 Minification

Minification must have independent controls for:

- Whitespace.
- Syntax.
- Local identifiers.
- Optional property names in a later release.

Identifier minification must respect scopes, labels, direct eval, with statements where accepted, exported names, function and class name preservation, and reflection-sensitive options.
Syntax minification must not reorder side effects or change number, string, regular expression, class, async, generator, or module semantics.

Every minifier rewrite requires a focused semantic fixture.
Output size alone is not evidence of correctness.

### 10.14 Build cache

The compiler cache must be separate from the package content store.
Its format must be versioned.

A parsed-module cache key must include:

- Compiler version and cache schema.
- Source content digest.
- Loader.
- Parse-affecting configuration.
- Relevant TypeScript and JSX mode.

A transformed-module cache key must also include target, format-independent transforms, defines, and minifier analysis settings.
A linked output cache key must include the full reachable graph identity, linker settings, entry-point identity, target, format, splitting, external rules, and output naming.

Cache records must not contain absolute paths unless the record is machine-local and the key marks it as such.
Cache corruption must cause a rebuild rather than incorrect output.

### 10.15 Watch mode

Watch mode must keep source buffers, immutable parse results, resolver caches, and graph indexes alive between builds.
It must subscribe to directories rather than creating an unbounded watcher per file where the platform supports directory watches.

On change, the watcher must:

1. Coalesce duplicate events for a short bounded interval.
2. Invalidate the changed path and affected negative resolution entries.
3. Re-read and re-parse only changed modules.
4. Update graph edges.
5. Re-link only affected entry points and chunks.
6. Atomically replace changed outputs.
7. Delete outputs that are no longer part of the graph.

A failed rebuild must leave the last successful outputs available unless `--clear-on-error` is set.
Diagnostics must describe whether outputs are stale.

### 10.16 Build metadata

The metafile must include:

- Compiler version and normalized build configuration.
- Inputs with byte sizes, loaders, imports, exports, package identity, and side-effect status.
- Outputs with byte sizes, kind, entry point, imports, exports, source map, and content hash.
- Per-input byte contribution to each output.
- Timings by pipeline phase.
- Cache hit and miss counts.
- CPU and GPU stages actually used.

JSON is the required stable format.
A human-readable summary may be added without becoming a compatibility contract.

## 11. Configuration

`bnpm.toml` is the product configuration file.
`tsconfig.json` remains the TypeScript editor and checker configuration file and a source for supported transform settings.

The compiler reads only a documented subset of `compilerOptions`:

- `baseUrl`
- `paths`
- `jsx`
- `jsxFactory`
- `jsxFragmentFactory`
- `jsxImportSource`
- `useDefineForClassFields`
- `experimentalDecorators`
- `verbatimModuleSyntax`
- `importsNotUsedAsValues` only where compatibility requires it

Checker-only options must not affect emitted code.
Unknown checker options are ignored.
Unknown emit-affecting options must produce a warning or error according to strict configuration mode.

Configuration precedence:

1. CLI flags.
2. Explicit build API options.
3. Project `bnpm.toml`.
4. Selected `tsconfig.json` transform fields.
5. Built-in defaults.

The final normalized configuration must be printable through `bnpm build --show-config`.

## 12. Extension model without a runtime

Bun plugins are JavaScript objects executed by Bun's runtime.
That design is not available because this product intentionally excludes a JavaScript runtime.

The initial stable release will ship only built-in loaders and declarative aliases, externals, defines, and conditions.
It will not claim Bun plugin compatibility.

A later extension protocol should use long-lived subprocesses or WASI components with versioned, typed messages.
The protocol should support batched equivalents of resolve, load, and end hooks.
Per-import process startup is prohibited.
Extension output must include content, loader, dependencies, and an optional source map.
The build cache key must include the extension binary digest and declared configuration.

Native in-process plugins are deferred until memory safety, ABI versioning, and compiler crash isolation have a design.

## 13. Bend2 execution model

### 13.1 Host effects

The following work remains in Bend2 IO or narrow host adapters:

- Filesystem reads, writes, watches, realpath calls, and atomic renames.
- Package and tsconfig discovery.
- Environment access.
- Terminal and JSON diagnostics.
- Extension subprocess or WASI hosting.
- Device discovery and dispatch.

### 13.2 Pure compiler work

The following work should be expressed as pure or bounded computations:

- Lexing and parsing one module.
- Scope construction and symbol binding within one module.
- TypeScript and JSX transforms.
- Import and export scanning.
- Side-effect analysis.
- Per-module constant folding.
- Graph reachability and tree-shaking marks.
- Chunk membership calculation.
- Identifier-frequency reduction.
- Printing one independent chunk.
- Source-map segment generation.
- Content hashing.

### 13.3 Parallel scheduling

The graph scanner should expose independent module work as soon as imports are resolved.
Parsing one module must not wait for unrelated modules.
Printing independent chunks should proceed concurrently after linking fixes their symbol and chunk assignments.

The first implementation should target Bend2 multicore CPU execution.
One large source file is not assumed to parse in parallel.
Parallelism comes primarily from many independent modules.

### 13.4 GPU candidates

| Stage | Initial backend | GPU decision |
| --- | --- | --- |
| UTF-8 validation | CPU | Experiment only when buffers are already batched and large |
| Source hashing | CPU | Candidate for large batches, but include transfer time |
| Lexing | Multicore CPU across files | Do not use GPU by default |
| Parsing | Multicore CPU across files | Keep branch-heavy per-file parsing on CPU |
| Local AST transforms | Multicore CPU across files | GPU only after an AST representation and benchmark justify transfer |
| Symbol linking | CPU | Shared graph coordination is a poor initial GPU target |
| Tree-shaking reachability | CPU | Benchmark large graphs later |
| Identifier frequency counting | CPU | Possible GPU reduction experiment after correctness |
| Printing | Multicore CPU across chunks | GPU is unlikely to help variable-length output |
| Source-map encoding | CPU | Keep near the printer to avoid another transfer |
| Content compression | CPU library | Benchmark separately from compiler logic |

### 13.5 Dispatch policy

`--gpu` is a diagnostic and benchmarking control until a workload class passes the automatic-dispatch gate.
It must not force stages with no GPU implementation.
The command must report exactly which stages ran on which backend.

CPU and GPU implementations must produce byte-identical compiler outputs or equivalent canonical intermediate results before printing.
A backend difference in scheduling must not change symbol names, chunk names, diagnostics order, or source-map IDs.

If GPU execution fails before output activation, the build may retry that stage on CPU.
The retry must be visible in debug diagnostics and build metadata.

## 14. Architecture

```text
entrypoints + bnpm.toml + tsconfig.json + bnpm.lock
                         |
                         v
              normalized build config
                         |
                         v
                  concurrent scanner
                 /        |        \
                v         v         v
            resolver    loader    source cache
                \         |         /
                 \        v        /
                  parser and scanner
                         |
                         v
            immutable per-module IR
                         |
                         v
       binding + TS/JSX lowering + local folding
                         |
                         v
                 module graph linker
              /          |           \
             v           v            v
       tree shaking   chunking    format interop
              \          |           /
               \         v          /
            parallel printer + source maps
                         |
                         v
             atomic outputs + metafile
```

Core interfaces:

- `SourceLoader` returns immutable bytes, content identity, loader, and optional input map.
- `Parser` returns module IR, symbols, parts, imports, exports, flags, and diagnostics.
- `Resolver` maps an import record plus importer and conditions to a module identity or external identity.
- `GraphScanner` owns work discovery and deduplication.
- `LocalTransformer` produces transformed immutable module IR.
- `Linker` produces linked chunks and final symbol assignments.
- `Printer` produces JavaScript bytes and source-map segments.
- `ArtifactWriter` commits complete output generations atomically.

These interfaces describe boundaries, not required object-oriented implementation.
Bend2 data types and effects should remain direct and boring.

## 15. Diagnostics

Every diagnostic must have:

- Stable code.
- Severity.
- Phase.
- File or package identity.
- Primary source range.
- Optional labeled secondary ranges.
- Human-readable message.
- Optional recovery suggestion.

Text diagnostics must show source context and use color only on an interactive terminal.
JSON diagnostics must use byte offsets and one-based line and column fields.
The same error must keep the same code across CPU, Metal, and CUDA backends.

The compiler should continue after independent module errors to report a useful batch.
It must not emit final outputs when any required module has an error.
Watch mode may preserve the previous successful outputs.

## 16. Security and reliability

- Treat source files, source maps, package metadata, and extension output as untrusted input.
- Bound source size, nesting depth, parser recursion or its iterative equivalent, symbol count, graph edges, and source-map segment count.
- Detect path traversal in output naming.
- Never write outside the normalized output directory unless `--outfile` names an explicit destination.
- Write outputs to staging and activate them only after all required artifacts succeed.
- Do not execute built source code during compilation.
- Do not evaluate compile-time definitions as JavaScript.
- Do not load arbitrary JavaScript configuration files.
- Redact environment values used in defines from diagnostics and metadata when marked secret.
- Make build-cache corruption a cache miss.
- Detect compiler crashes in extension processes and report the responsible extension.
- Keep package installation and build network access disabled unless a later explicit policy adds it.

## 17. Performance design

### 17.1 Avoidable work

The implementation should avoid:

- Tokenizing a file into a separate full token array before parsing unless measurement proves it faster.
- Copying source strings for type removal.
- Serializing ASTs between CPU workers.
- Printing intermediate JavaScript and parsing it again between stages.
- Traversing the full AST for information that can be collected during parse or binding.
- Re-reading package manifests for every import.
- Repeating failed filesystem lookups within one generation.
- Re-hashing unchanged source files after reliable filesystem identity confirms reuse.

### 17.2 Memory

Each source buffer and parse result should have one clear owner for the build generation.
Per-module arenas should be reclaimable when a changed module is replaced in watch mode.
Long-lived caches must not retain old source generations through graph references.

The linker should refer to symbols and modules through compact integer identities.
String interning must have bounded lifetime and deterministic serialization behavior.

### 17.3 Determinism under parallelism

Workers may discover modules and finish parses in any order.
Stable output requires canonical ordering at observable boundaries:

- Module identities.
- Diagnostics.
- Symbol-renaming frequency ties.
- Chunk assignment.
- Metafile maps.
- Output naming.
- Source-map source and name tables.

No observable value may depend on pointer addresses, hash-map iteration order, worker index, CPU count, or GPU scheduling.

## 18. Delivery plan

### Phase 0: Bend2 compiler substrate

Deliverables:

- Confirm efficient byte buffers, arenas, strings, maps, file IO, and multicore scheduling in the public Bend2 release.
- Implement source loading, UTF-8 handling, line maps, stable diagnostics, and content hashing.
- Build a lexer spike for a useful JavaScript and TypeScript subset.
- Benchmark one core, all CPU cores, Metal, and CUDA where available.
- Decide whether filesystem watching and compression require host adapters.

Exit criteria:

- The lexer handles the lexical fixture corpus without crashes.
- Multicore module batching shows useful scaling.
- GPU lexer results are documented whether they win or lose.
- Memory use and source ownership are understood before AST design is frozen.

### Phase 1: No-bundle TypeScript transpiler

Deliverables:

- JavaScript, TypeScript, JSX, and TSX parser.
- Compact AST, scopes, symbols, and import records.
- Erasable syntax removal.
- Runtime TypeScript lowering.
- JSX transforms.
- JavaScript printer.
- External and inline source maps.
- `bnpm transpile`, `bnpm scan`, and `bnpm build --no-bundle`.

Exit criteria:

- Supported syntax fixtures match expected runtime behavior in Node.js and browsers.
- Unsupported syntax fails with stable diagnostics.
- Source-map fixtures map transformed output back to TypeScript.

### Phase 2: Resolver and module graph

Deliverables:

- Shared package/build resolver.
- tsconfig paths.
- package exports, imports, conditions, and sideEffects.
- Concurrent graph scan.
- Workspace and isolated-store support.
- External patterns.

Exit criteria:

- Resolution fixtures match the documented browser and Node.js contracts.
- Every resolved edge can explain its selected path and conditions.
- Builds never access the network.

### Phase 3: Linker and bundler

Deliverables:

- ESM linking and live bindings.
- CommonJS wrappers and interop.
- Cycles and top-level await handling.
- Tree shaking.
- Compile-time definitions and constant folding.
- ESM and CommonJS output.
- Metafile.

Exit criteria:

- Real programs behave like their unbundled references.
- Side-effect and cycle fixtures pass.
- Output is deterministic under randomized worker schedules.

### Phase 4: Splitting, minification, and cache

Deliverables:

- ESM code splitting.
- Syntax, whitespace, and identifier minification.
- Versioned build cache.
- Content-hashed naming.
- Source-map composition.

Exit criteria:

- Lazy and shared chunks preserve initialization order.
- Minified output passes the semantic corpus.
- Clean and cached builds produce identical bytes.

### Phase 5: Watch mode

Deliverables:

- Cross-platform watcher adapter.
- Graph invalidation.
- Incremental parse, link, and print.
- Atomic output-generation switching.
- Stale-output diagnostics on failed rebuilds.

Exit criteria:

- Unrelated edits do not rebuild unrelated entry points.
- Rename, delete, new file, package manifest, tsconfig, and negative-lookup cases invalidate correctly.
- Long watch sessions do not grow memory without bound.

### Phase 6: Extension protocol and GPU experiments

Deliverables:

- Versioned subprocess or WASI extension protocol.
- Batched resolve and load hooks.
- Extension cache identities and source-map composition.
- Benchmarks for selected GPU candidates.
- Automatic dispatch only for workload classes that pass the gate.

Exit criteria:

- Extension crashes do not crash or corrupt the compiler.
- Extension output is deterministic or explicitly marked non-cacheable.
- GPU-enabled paths beat CPU end to end and produce identical outputs.

## 19. Validation plan

### 19.1 Syntax corpus

The corpus must cover every accepted ECMAScript and TypeScript production, including ambiguity boundaries:

- Generic arrows in TSX.
- JSX tags versus comparison operators.
- Type arguments versus shift operators.
- Regular expressions versus division.
- Async arrows.
- Decorators.
- Enums and namespaces.
- Parameter properties.
- Type-only imports and exports.
- Import attributes.
- Explicit resource management.
- Top-level await.
- Hashbangs and directives.

The corpus must include valid and invalid examples.
Every regression fixture must defend a grammar or output behavior rather than a source-code implementation detail.

### 19.2 Semantic fixtures

Compile and execute fixtures in the target runtime.
Compare observable output, thrown errors, import order, live bindings, cycle behavior, and side effects.

Required categories:

- ESM to ESM.
- CommonJS to CommonJS.
- ESM and CommonJS interop in both directions.
- Dynamic imports.
- Multiple entry points.
- Package condition selection.
- Tree-shaking with getters and side effects.
- Direct eval deoptimization.
- Decorator modes.
- Enums and namespace merging.
- JSX classic and automatic runtimes.

### 19.3 Differential testing

Use `tsc`, Bun, and esbuild as differential references where their documented contracts overlap.
A difference is not automatically a bug because targets and semantics differ.
Every difference must be classified as intended, unsupported, or defective.

Fuzz generated syntax trees and source text.
Reduce crashes and semantic differences to permanent minimal fixtures.
Do not execute untrusted fuzz output outside a sandboxed test environment.

### 19.4 Source-map testing

Place breakpoints and throw errors from transformed constructs.
Verify original file, line, column, and name through Node.js and browser source-map consumers.
Test CRLF, Unicode, tabs, comments, multiline templates, JSX, minification, code splitting, and composed input maps.

### 19.5 Watch testing

Drive the real watcher with file create, write, atomic replace, rename, delete, directory move, symlink change, package manifest change, and tsconfig change operations.
Verify rebuilt outputs by running them.
Do not validate watch mode only by calling the invalidation function directly.

### 19.6 Performance matrix

Measure:

- One-file no-bundle transpilation.
- 100, 1,000, and 10,000 independent files.
- Deep dependency chains.
- Wide dependency graphs.
- Large modules.
- React applications.
- CommonJS-heavy server applications.
- Clean, cached, no-op, and one-file watch rebuilds.
- Readable, source-mapped, minified, and split output.

Compare current stable `tsc`, Bun, esbuild, and `bnpm` where the commands perform equivalent work.
Report parser time, resolver time, linker time, printer time, source-map time, IO time, cache time, peak memory, CPU utilization, GPU execution, and transfer time.

## 20. Risks and mitigations

| Risk | Effect | Mitigation |
| --- | --- | --- |
| TypeScript grammar changes quickly | Valid new syntax fails or is misparsed | Maintain a syntax-version matrix and import upstream conformance fixtures with license review |
| Syntax-only emit is mistaken for type safety | Users ship type errors | Use `transpile` terminology, emit a clear note in docs, and keep `check` out of the command surface until real |
| ESM and CommonJS interop is wrong | Bundles behave differently from source | Maintain runtime semantic fixtures for every interop rule |
| Parser error recovery emits code | Broken source becomes misleading output | Never emit a module with syntax errors |
| GPU-first design slows builds | Transfer and divergence outweigh compute | Start with multicore CPU module batching and gate every GPU path on measurements |
| Bend2 allocation behavior is unsuitable for a large AST | Memory use or compile time becomes unacceptable | Settle byte-buffer and arena strategy in Phase 0 before completing the grammar |
| Linker becomes a serial bottleneck | Parsing scales but builds do not | Keep module analysis local, use compact identities, and profile the actual serial fraction |
| Watch invalidation misses an edge | Stale output is served | Track positive and negative resolution dependencies and exercise real filesystem operations |
| Minifier changes behavior | Production-only failures | Require semantic fixtures for every rewrite and support granular minification switches |
| Source maps are almost correct | Debugging points to wrong code | Test with real Node.js and browser consumers at transformed boundaries |
| Arbitrary plugins require a runtime | Scope expands into building a VM | Use built-ins first and later use a process or WASI protocol |
| Package and build resolvers diverge | Installed package differs from bundled package | Share package metadata, condition, and filesystem identity code |
| `bnpm` name limits general-tooling positioning | Users perceive only a package manager | Settle suite branding before stable build-tool release |

## 21. Open questions

1. Which byte-buffer and arena patterns are efficient in the released Bend2 compiler and runtime?
2. Can Bend2 preserve source slices without copying when values move between parallel tasks?
3. Which parser strategy best fits Bend2's data model while keeping error recovery maintainable?
4. Should TypeScript enums and namespaces be supported immediately or require an erasable-syntax mode first?
5. Which legacy decorator semantics are required for the first compatibility corpus?
6. Should `bnpm transpile` preserve JSX by default or always produce JavaScript?
7. What minimum Node.js version and browser baseline define supported output syntax?
8. Should the first CommonJS output be bundled-only, or should no-bundle per-file CommonJS ship at the same time?
9. How will package exports condition ordering be exposed and tested?
10. Which source-map consumer defines column and name compatibility when consumers disagree?
11. Should build caches be global, project-local, or split between reusable module transforms and project-linked outputs?
12. Can the package manager store provide content digests directly to the compiler without re-hashing files?
13. Which filesystem watcher APIs need a host adapter on macOS, Linux, and Windows?
14. Is a WASI extension protocol practical with Bend2's released FFI and byte-buffer support?
15. Which stages, if any, show a repeatable Metal or CUDA advantage after transfer costs?
16. Should the broader suite retain `bnpm`, use a new umbrella name, or make `bnpm` only the package-management subcommand?

## 22. Release criteria

The initial TypeScript build release is ready when all of the following are true:

- Every supported syntax fixture parses or fails with the expected diagnostic.
- No syntax-error module produces JavaScript.
- Semantic fixtures behave correctly in the declared Node.js and browser targets.
- ESM and CommonJS interop, cycles, side effects, and top-level await fixtures pass.
- Source maps point to the correct original locations through real consumers.
- Clean builds are deterministic under randomized task scheduling.
- Cached builds produce the same bytes as clean builds.
- Watch mode correctly handles create, update, rename, delete, manifest, and tsconfig events.
- Missing packages fail without network access or implicit installation.
- Build output is activated atomically.
- Compiler cache corruption causes a rebuild rather than incorrect output.
- Peak memory stays within the published limit for the 10,000-module corpus.
- Benchmarks describe exact versions, hardware, commands, target, format, minification, source-map mode, and cache state.
- CPU-only systems support the complete product.
- GPU metadata reports only stages that actually ran on the GPU.
- Documentation states that transpilation does not type-check or generate declarations.

## 23. Decision record

### Start with transpilation, not type checking

Type checking requires a whole-program semantic model, type inference, declaration resolution, and a much larger compatibility surface.
A syntax transpiler and bundler can deliver useful tooling while keeping that work honest and separate.

### Use one JavaScript parser with TypeScript and JSX modes

TypeScript is a JavaScript superset with contextual ambiguities.
A shared parser avoids separate AST conversion and lets type stripping, import scanning, and JavaScript transforms share source ranges and symbols.

### Parallelize across modules first

Modules are naturally independent during parse and local transformation.
This offers useful multicore work without splitting one branch-heavy parse or moving AST data to a GPU.

### Keep resolution outside the parser

The parser should turn source bytes into syntax, symbols, and import records.
Filesystem and package policy belong to a resolver that can be tested, cached, and shared with the package manager.

### Build a native linker instead of chaining tools through text

Printing intermediate JavaScript and parsing it again wastes CPU, memory, source fidelity, and source-map accuracy.
The parser, transformer, linker, and printer should share one internal representation.

### Do not embed a JavaScript runtime for plugins

The product direction explicitly excludes a runtime.
Built-in features cover the first release, and later extensions can use a typed process or WASI boundary.

### Keep GPU use optional and evidence-based

The published Bend2 lexer benchmark favors multicore CPU over GPU for that workload.
The design therefore treats the GPU as a stage-level experiment rather than the defining implementation strategy.