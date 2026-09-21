# Product requirements document: JavaScript, CSS, and web asset bundler

Status: Draft

Date: 2026-09-17

Working CLI name: `bnpm`

Depends on: `package-manager-prd.md` and `ts-compiling-prd.md`

## 1. Summary

`bnpm` will provide a native production bundler implemented in Bend2.
The bundler will consume the parser, module resolver, transformer, printer, and source-map facilities defined in `ts-compiling-prd.md`.
It will turn JavaScript, TypeScript, JSX, TSX, CSS, HTML, data files, and static assets into a deterministic set of deployable artifacts for browsers and Node.js.

The bundler owns the work that begins after a source file can be parsed:

- Dependency graph discovery.
- Cross-module symbol linking.
- ESM and CommonJS interoperability.
- Side-effect analysis and tree shaking.
- Static and dynamic chunk assignment.
- JavaScript and CSS output coordination.
- HTML entry-point rewriting.
- Static asset copying, hashing, and URL rewriting.
- Output naming, manifests, metadata, caching, and incremental rebuilds.

The bundler will not embed a JavaScript runtime.
It will not execute configuration files, plugins, application code, or generated bundles during a build.

Multicore CPU execution is the default.
Bend2 GPU execution remains optional and must pass an end-to-end performance gate before it can be selected automatically.

## 2. Relationship to the compiler PRD

`ts-compiling-prd.md` currently describes both transpilation and a first bundling layer.
This document makes the bundler boundary explicit and is authoritative when the two documents overlap on graph, linker, chunk, CSS, HTML, asset, and output behavior.

The compiler owns:

- JavaScript, TypeScript, JSX, and TSX lexing and parsing.
- Per-module scopes, symbols, imports, exports, source ranges, and side-effect parts.
- TypeScript syntax removal and runtime TypeScript lowering.
- JSX transformation.
- Local constant folding and target-aware syntax transformation.
- JavaScript printing and JavaScript source-map segments.

The bundler owns:

- Entry-point normalization.
- Resolution work scheduling and graph completion.
- Cross-file symbol relationships.
- Reachability and tree-shaking decisions.
- Module-format wrappers and runtime helpers.
- Chunk boundaries and cross-chunk imports.
- CSS, HTML, data, and asset graphs.
- Artifact naming and publication.
- Build metadata, manifests, incremental state, and bundle analysis.

The parser must not know output file names.
The resolver must not decide tree-shaking reachability.
The linker must not read files.
The printer must not choose chunk membership.
These boundaries keep correctness testable and allow unchanged module IR to be reused across builds.

## 3. Problem

Applications are written as graphs rather than single files.
A production build must convert those graphs into a small, cacheable, executable artifact set without changing observable behavior.

A correct bundler must handle several kinds of relationships at once:

- Static ESM imports and re-exports.
- Dynamic `import()` boundaries.
- CommonJS `require()` and `module.exports` behavior.
- ESM live bindings.
- Circular initialization.
- Top-level await.
- Package export conditions.
- CSS `@import` and `url()` edges.
- CSS Modules class-name exports and composition.
- HTML references to scripts, stylesheets, images, fonts, media, manifests, and workers.
- Assets whose final URLs depend on content hashes and output paths.

Concatenating transformed files is insufficient.
A bundler must preserve initialization order, module identity, live bindings, CommonJS caching, side effects, and lazy-loading boundaries.

Optimization adds another correctness boundary.
Removing an unused declaration is safe only when evaluating it cannot produce an observable effect.
Moving code into a shared chunk is safe only when it does not execute earlier, later, or more often than in the source graph.
Reordering CSS can change the cascade even when every declaration remains present.

Production output also needs operational guarantees.
A failed build must not leave a mixture of old and new chunks.
A content-hashed file name must change when its effective content changes and remain stable when irrelevant scheduling changes.
A manifest must never point to an artifact that was not committed.

## 4. Product principles

1. Preserve program behavior before reducing output size or build time.
2. Treat module resolution and package conditions as semantic decisions.
3. Keep one canonical module identity for every graph node.
4. Make side effects explicit and conservative.
5. Keep lazy code lazy.
6. Never make code eager merely to reduce chunk count.
7. Produce deterministic artifacts from identical inputs and configuration.
8. Commit one complete output generation atomically.
9. Share the package resolver and lockfile with `bnpm` instead of creating a second package universe.
10. Keep JavaScript, CSS, HTML, and asset graphs distinct but connected.
11. Expose every output relationship through a machine-readable manifest.
12. Use multicore module and chunk parallelism before considering GPU work.
13. Require measured end-to-end gains for every automatic GPU path.
14. Avoid a JavaScript runtime dependency in the build process.
15. Make unsupported dynamic behavior fail or remain external instead of guessing.

## 5. Goals

### 5.1 Initial stable release goals

- Bundle JavaScript, TypeScript, JSX, and TSX entry points.
- Consume the immutable module IR defined by `ts-compiling-prd.md` without printing and reparsing intermediate JavaScript.
- Support browser and Node.js targets.
- Emit ESM and CommonJS JavaScript.
- Preserve ESM live bindings, module initialization order, cycles, and top-level await constraints.
- Wrap CommonJS modules with lazy, cached execution semantics.
- Support ESM and CommonJS interoperation under a documented policy.
- Tree-shake unused ESM code using statement-part reachability.
- Honor `package.json` `sideEffects` metadata and recognized pure annotations.
- Provide an option that ignores third-party side-effect annotations without disabling compiler-proven dead-code elimination.
- Support multiple entry points.
- Support shared chunks and dynamic-import chunks for ESM output.
- Keep dynamic imports lazy unless configuration explicitly disables splitting.
- Bundle JSON, JSONC, TOML, YAML, and text imports through built-in loaders.
- Copy unrecognized static assets and replace imports with generated URLs.
- Bundle CSS entry points and CSS imported from JavaScript or HTML.
- Support CSS `@import`, `url()`, source maps, minification, and CSS Modules.
- Build HTML entry points and rewrite supported local asset references.
- Preserve external URLs in HTML and CSS.
- Generate deterministic entry, chunk, CSS, HTML, source-map, and asset names.
- Support a configurable public path.
- Generate a stable JSON manifest and a detailed metafile.
- Support watch mode with dependency-aware invalidation.
- Reuse parsed modules, resolved paths, transformed modules, and unchanged artifact bytes.
- Write outputs through a staging generation and activate them only after the complete build succeeds.
- Run without network access during a build.
- Run on CPU-only systems and on Bend2-supported Metal or CUDA systems.

### 5.2 Success measures

Correctness is a release gate.
Performance results are not valid until semantic, output, and source-map suites pass.

| Measure | Target |
| --- | --- |
| JavaScript semantics | Every supported fixture matches the unbundled reference in its target runtime |
| Module resolution | Every fixture selects the documented package path and conditions |
| Tree shaking | No required side effect is removed in the selected compatibility corpus |
| Code splitting | Lazy and shared chunks preserve execution order and module identity |
| CSS semantics | Bundled cascade, layer order, URL resolution, and module exports match the reference |
| HTML rewriting | Every supported local reference resolves to an emitted artifact |
| Determinism | Repeated clean builds produce byte-identical artifacts, manifests, and metadata |
| Atomicity | Fault injection never exposes a mixed output generation |
| Clean JavaScript build | No slower than esbuild by more than 15% on the reference graphs before stable release |
| Clean full web build | Competitive with current stable Bun on equivalent HTML, CSS, asset, map, and minify settings |
| Incremental rebuild | An unrelated edit does not parse, link, print, hash, or rewrite unaffected outputs |
| Watch latency | p95 small-application rebuild completes within 100 ms after filesystem notification |
| Memory | Peak memory is bounded and documented for a 10,000-module, 1,000-asset graph |
| Cache correctness | Clean and cache-hit builds produce identical artifact bytes |
| GPU policy | Automatic GPU use requires at least 15% end-to-end improvement for the measured workload class |

Benchmark reports must include target, format, entry count, graph shape, code splitting, minification, source maps, cache state, storage medium, CPU count, and GPU transfer time.
A benchmark that omits output-equivalence checks is not acceptable evidence.

## 6. Non-goals for the initial stable release

- Static type checking.
- Type declaration generation.
- A JavaScript runtime or REPL.
- A development server.
- Hot module replacement.
- Standalone executable generation.
- JavaScript bytecode generation.
- Service worker generation.
- Server-side rendering.
- React Server Components or framework-specific graph partitioning.
- Automatic polyfill injection.
- ES5 output.
- Runtime filesystem emulation for arbitrary dynamic imports.
- Remote HTTP or npm imports during a build.
- Implicit package installation.
- Sass, Less, Stylus, or arbitrary PostCSS pipelines.
- Arbitrary JavaScript plugins.
- Bun plugin API compatibility.
- Webpack loader compatibility.
- Rollup plugin API compatibility.
- Native in-process plugins with an unstable ABI.
- Automatic image transcoding or compression.
- Font subsetting.
- HTML template execution.
- HTML minification beyond safe syntax-preserving transformations.
- Property-name mangling in the first stable release.
- Automatic differential serving for legacy browsers.

A later development server may consume the incremental build API.
It must not be built into the linker or required for production builds.

## 7. Users and jobs

### Application developer

The developer wants one command to produce a browser deployment from HTML, TypeScript, CSS, and assets.
The output must load correctly from the configured base path and remain debuggable through source maps.

### Node.js service developer

The developer wants one or more Node.js bundles while controlling which packages remain external.
The output must preserve Node.js module behavior and must not inject browser shims silently.

### Library author

The author wants ESM and CommonJS distributions with package dependencies externalized, stable output paths, preserved public exports, and separate declaration generation.

### Monorepo maintainer

The maintainer wants workspace-aware resolution, parallel builds, shared cache records, and invalidation limited to affected graph regions.

### Frontend platform engineer

The engineer wants manifests, content hashes, public-path control, size metadata, and enforceable asset budgets.

### Framework author

The author wants a typed extension boundary for virtual modules and custom loaders without requiring the bundler to embed a JavaScript runtime.

### CI owner

The owner wants deterministic artifacts, no network access, frozen package resolution, stable diagnostics, and atomic output replacement.

### Bend2 contributor

The contributor wants graph, reachability, hashing, and chunk workloads that expose useful parallelism while keeping branch-heavy parsing and graph coordination on the backend that measures best.

## 8. Research findings

The findings in this section describe Bun, esbuild, Rollup, Lightning CSS, Node.js, and source-map documentation reviewed on 2026-09-17.
The linked sources form part of the decision record because these tools continue to evolve.

### 8.1 Bun treats bundling as a graph pipeline

Bun begins from one or more entry points.
It resolves imports, loads files, parses modules, records imports and exports, links symbols, removes unreachable parts, computes chunks, prints code, and writes artifacts.

Bun's current source tree separates graph data, parse tasks, linker context, chunk computation, cross-chunk dependencies, symbol renaming, JavaScript generation, CSS generation, HTML generation, source maps, metadata, and output writing.
This separation is more useful to this project than Bun's implementation language or internal type names.

Sources:

- [Bun bundler documentation](https://bun.sh/docs/bundler)
- [Bun bundler source tree](https://github.com/oven-sh/bun/tree/main/src/bundler)
- [Bun bundler crate structure](https://github.com/oven-sh/bun/blob/main/src/bundler/lib.rs)

### 8.2 Bun supports more than JavaScript

Bun has built-in loaders for JavaScript, TypeScript, JSX, TSX, JSON, JSONC, TOML, YAML, XML, text, CSS, HTML, assets, WebAssembly, and native addons.
Data loaders turn source data into JavaScript module exports.
The file loader copies an asset and replaces the import with its generated URL.
The HTML loader scans supported element attributes, promotes scripts and stylesheets into build graph entries, copies referenced assets, and rewrites paths.

This product should not copy every Bun loader at once.
It should establish one typed loader contract and add formats in phases.

Sources:

- [Bun loader documentation](https://bun.sh/docs/bundler/loaders)
- [Bun HTML and static-site documentation](https://bun.sh/docs/bundler/html-static)

### 8.3 Linking is not concatenation

Esbuild documents separate scan and compile phases.
The scan phase uses a parallel worklist to discover the complete graph.
The compile phase links imports and exports, performs reachability analysis, determines chunks, prints code, and emits source maps.

Static ESM modules can use scope hoisting because imports and exports have analyzable symbol relationships.
CommonJS modules need lazy wrappers because execution and export mutation are dynamic.
Hybrid modules need a defined interoperation policy.

Sources:

- [esbuild architecture](https://github.com/evanw/esbuild/blob/master/docs/architecture.md)
- [Rollup tree-shaking overview](https://rollupjs.org/introduction/#tree-shaking)

### 8.4 Tree shaking is graph reachability over code parts

Esbuild divides a module into top-level statement parts.
A part declares symbols, references symbols, depends on other parts or modules, and carries side-effect information.
Tree shaking starts from entry-point behavior and requested exports, then marks every required part through symbol and side-effect edges.

This model is safer than deleting declarations solely because their names appear unused.
Property access, getters, computed keys, decorators, class static initialization, and unknown calls can be observable.
The automatic side-effect model must therefore remain conservative.

Package `sideEffects` metadata and `/* @__PURE__ */` annotations may permit additional removal.
Incorrect annotations can break applications, so users need a compatibility escape hatch.

Source: [esbuild tree-shaking architecture](https://github.com/evanw/esbuild/blob/master/docs/architecture.md#tree-shaking).

### 8.5 Code splitting is repeated reachability plus chunk linking

Esbuild models each static entry point and each dynamic import target as an entry root.
Running reachability from every root yields a set of roots that require each part.
Parts with the same root set become chunk candidates.
The bundler then creates cross-chunk imports and exports for symbols that cross those boundaries.

Bun adds practical policies around that model.
It can omit dynamic-import chunks whose importing code is itself removed.
It can fold small side-effect-free chunks into chunks loaded by a superset of importers without making lazy effects eager.
It can emit module-preload links for browser HTML entry points.

The first `bnpm` implementation should prefer predictable chunks over a minimum theoretical chunk count.
Small-chunk merging may be added only after the base splitting semantics are proven.

Sources:

- [esbuild code-splitting architecture](https://github.com/evanw/esbuild/blob/master/docs/architecture.md#code-splitting)
- [Bun splitting and module preload](https://bun.sh/docs/bundler#splitting)

### 8.6 Bun's output surface informs compatibility, not exact cloning

Bun supports browser, Node.js, and Bun targets, plus ESM, CommonJS, and IIFE formats.
This product has no runtime, so it needs only browser and Node.js targets.
ESM and CommonJS are required for stable release.
IIFE can wait until export naming, external globals, and top-level await restrictions have an explicit design.

Bun supports entry, chunk, and asset naming templates, public-path prefixes, external imports, package externalization, source-map modes, defines, granular minification, banners, footers, metadata, and watch mode.
Those concepts are useful compatibility points even when exact flag spelling differs.

Source: [Bun bundler reference](https://bun.sh/docs/bundler).

### 8.7 CSS has its own dependency and ordering semantics

Bun's CSS implementation is based on Lightning CSS and uses an esbuild-inspired bundling model.
It supports `@import`, `url()`, browser-target transformations, vendor prefixes, minification, and CSS Modules.

CSS `@import` is not equivalent to JavaScript module evaluation.
An imported stylesheet participates at the location and under the conditions specified by CSS.
Ordering, cascade layers, media queries, supports conditions, charset rules, and duplicate imports require CSS-specific handling.

CSS Modules produce both CSS and a JavaScript-visible export map.
Composition across files creates graph edges, and composition with conflicting declarations has undefined ordering in the common CSS Modules model.

Sources:

- [Bun CSS documentation](https://bun.sh/docs/bundler/css)
- [Lightning CSS documentation](https://lightningcss.dev/docs.html)
- [esbuild CSS content types](https://esbuild.github.io/content-types/#css)

### 8.8 HTML turns a document into a multi-content entry point

Bun's HTML loader scans local references from scripts, stylesheets, images, source sets, fonts, media, icons, manifests, and worker-related links.
It builds referenced JavaScript and CSS, copies assets, preserves external URLs, and rewrites the document to final artifact paths.

An HTML file is not merely text with string replacement.
URL parsing, base paths, fragments, query strings, `srcset`, module scripts, classic scripts, preload relationships, and inline content need structured handling.

The production bundler does not need Bun's development server, HMR, browser console relay, or full-stack runtime manifest.

Source: [Bun HTML and static-site documentation](https://bun.sh/docs/bundler/html-static).

### 8.9 Package metadata changes graph semantics

Node.js package `exports`, `imports`, `type`, conditional exports, and module format rules affect which file enters the graph and how it is interpreted.
The browser field may replace package entry points or selected files for browser builds.
The `sideEffects` field affects whether unused imports may be removed.

The bundler must use the shared `bnpm` resolver and the frozen lockfile.
A bundler-local package resolver would create correctness differences between installed and bundled programs.

Sources:

- [Node.js package documentation](https://nodejs.org/api/packages.html)
- [Package browser field specification](https://github.com/defunctzombie/package-browser-field-spec)
- [Bun module resolution](https://bun.sh/docs/runtime/module-resolution)

### 8.10 Source maps are a cross-stage contract

ECMA-426 defines the current source-map format.
JavaScript and CSS generated columns use UTF-16 code units.
A bundler must compose input maps from prior transforms, preserve normalized source identities, and emit mappings for generated chunks rather than merely concatenating per-file map strings.

Source: [ECMA-426 source-map specification](https://tc39.es/ecma426/).

### 8.11 GPU-first linking is not justified

Graph discovery mixes filesystem effects, hash lookups, parsing completion, and dynamic work creation.
Symbol linking and chunk construction involve irregular graph traversal and shared coordination.
Printing produces variable-length output.
These are poor initial GPU targets.

Independent module analysis, independent CSS parsing, content hashing, large graph bitset operations, and independent chunk printing can expose parallel work.
The first implementation should use multicore CPU execution and measure any GPU candidate with transfer, synchronization, and fallback costs included.

## 9. Product scope

### 9.1 Required commands

| Command | Behavior |
| --- | --- |
| `bnpm build <entrypoints...>` | Build JavaScript, CSS, or HTML entry points and write deployable artifacts |
| `bnpm build --watch <entrypoints...>` | Keep the build context alive and publish affected artifacts after changes |
| `bnpm analyze <entrypoints...>` | Build graph and chunk plans, then report composition and size metadata |
| `bnpm build --write=false <entrypoints...>` | Produce artifacts in memory or temporary storage without activating an output directory |
| `bnpm clean --build-cache` | Remove bundler caches without touching the package store |
| `bnpm build --show-config` | Print normalized build configuration and exit |

`bnpm build` must not install a missing package.
It must report the unresolved specifier, importer, attempted conditions, and the command needed to restore the package graph.

### 9.2 Required options

- `--target browser|node`
- `--format esm|cjs`
- `--outdir <path>`
- `--outfile <path>`
- `--root <path>`
- `--splitting`
- `--min-chunk-size <bytes>`
- `--external <pattern>`
- `--packages bundle|external`
- `--conditions <condition>`
- `--loader <extension=loader>`
- `--entry-naming <template>`
- `--chunk-naming <template>`
- `--asset-naming <template>`
- `--css-naming <template>`
- `--public-path <path-or-url>`
- `--define <name=value>`
- `--drop debugger|console|<qualified-name>`
- `--ignore-side-effects-annotations`
- `--minify`
- `--minify-syntax`
- `--minify-whitespace`
- `--minify-identifiers`
- `--sourcemap none|linked|external|inline`
- `--sources-content include|exclude`
- `--metafile <path>`
- `--manifest <path>`
- `--watch`
- `--clear-on-error`
- `--write true|false`
- `--cpu`
- `--gpu`
- `--log-level silent|error|warning|info|debug`
- `--diagnostics text|json`

`--outfile` must be rejected when the build can emit more than one artifact.
Splitting must require ESM output and `--outdir` in the initial release.
HTML entry points must require browser target.
CommonJS output must reject top-level await when no semantics-preserving transform exists.

### 9.3 Defaults

- Target defaults to `browser`.
- Format defaults to `esm`.
- Package dependencies default to `bundle`.
- Tree shaking is enabled.
- Splitting is disabled.
- Minification is disabled.
- Source maps default to `none`.
- Writes are enabled.
- Network access is disabled.
- CPU execution is enabled on every platform.

Changing a default is a compatibility event and requires a decision-record update.

## 10. Build request and normalized configuration

A build request contains:

- Ordered entry points.
- Working directory.
- Project root.
- Output destination.
- Target and format.
- Loader map.
- Resolver conditions.
- External patterns.
- Package bundling policy.
- Transform settings inherited from `ts-compiling-prd.md`.
- Tree-shaking, splitting, minification, source-map, naming, and metadata settings.
- Environment definitions explicitly permitted for inlining.
- Cache and watch settings.

Configuration precedence is:

1. CLI flags.
2. A typed build request supplied through the native API or JSON protocol.
3. `bnpm.toml` build profile.
4. Supported transform fields from `tsconfig.json`.
5. Built-in defaults.

The normalized configuration must contain no unresolved relative paths or implicit environment reads.
It must be printable through `bnpm build --show-config`.
The normalized configuration digest is part of every affected cache key.

Arbitrary JavaScript configuration files are not accepted.
Declarative configuration keeps builds reproducible and avoids requiring a runtime.

## 11. Entry points and module identity

### 11.1 Entry-point kinds

Supported entry points are:

- JavaScript, TypeScript, JSX, or TSX modules.
- CSS stylesheets.
- HTML documents.
- Supported data files when explicitly named.

A directory is not an entry point unless a later explicit directory-entry feature defines its behavior.
Glob expansion may be performed by the shell or a future declarative glob option, but the core build request receives an ordered list of concrete entries.

### 11.2 Canonical module identity

Every graph node must have one canonical identity containing:

- Namespace.
- Canonical resolved path or virtual identifier.
- Loader.
- Import attributes that affect interpretation.
- Package identity and peer context where applicable.
- Query or fragment components only when the loader contract declares them semantic.

The same file reached through symlinks must follow the configured preserve-symlinks policy.
Case normalization must follow filesystem semantics without making a case-sensitive build silently case-insensitive.

Two imports that resolve to the same canonical identity must share one module instance.
Two virtual modules with different namespaces must remain distinct even when their path text matches.

### 11.3 Entry naming and collision checks

The default project root is the common ancestor of all file entry points.
An explicit root overrides it.

Output planning must detect all collisions before writing:

- Two entry points mapping to the same output path.
- An entry output colliding with a chunk, CSS file, map, asset, manifest, or metadata file.
- A case-only collision on a case-insensitive destination.
- A file output colliding with a required directory.
- A normalized path escaping the output directory.

A collision is a build error.
The bundler must not silently append counters that make artifact names scheduling-dependent.

## 12. Graph scan

### 12.1 Concurrent worklist

The graph scanner begins with normalized entry points.
Each unresolved graph edge enters a concurrent work queue.
Resolution, loading, parsing, and local analysis may run in parallel for independent modules.

A module is parsed at most once for a given canonical identity, content digest, loader, and parse configuration.
Parsing may discover more edges.
The scan completes only when no queued or in-flight task can add another edge.

### 12.2 Edge kinds

The graph must distinguish:

- Static ESM import.
- Static ESM re-export.
- Dynamic ESM import.
- CommonJS `require()`.
- CommonJS `require.resolve()`.
- CSS `@import`.
- CSS `url()`.
- CSS Modules composition.
- HTML script.
- HTML stylesheet.
- HTML asset.
- Data-loader dependency.
- Extension-declared dependency.
- External edge.

An edge records original specifier, importer, source range, import attributes, resolution conditions, resolved identity, external status, and whether the edge is eager or lazy.

### 12.3 Non-literal imports

Static imports and literal `import()` or `require()` calls are resolved at build time.

The initial release preserves non-literal dynamic imports and requires only when the target runtime can resolve the emitted expression correctly.
Otherwise it emits a diagnostic with the expression range and a suggestion to use an explicit import map or external package.

The initial release does not scan the filesystem to guess a glob from string concatenation.
A later explicit glob-import feature must bound its root and expose every matched file in metadata and watch dependencies.

### 12.4 Graph limits

Configurable limits must bound:

- Total modules.
- Total graph edges.
- Maximum import depth.
- Maximum source bytes.
- Maximum asset bytes.
- Maximum HTML references.
- Maximum CSS imports.
- Maximum generated artifacts.

Limit failures must report the configured limit and the graph path that reached it.

## 13. JavaScript linking

### 13.1 Symbol linking

Each module IR exposes stable local symbol identities.
The linker creates a build-wide symbol table without rewriting the immutable parsed AST.

Static ESM imports merge with the selected exported symbols.
Re-export chains and star exports must resolve according to ECMAScript ambiguity rules.
Ambiguous star exports must not be selected by accident.
Missing exports must produce a diagnostic at the import site.

A union-find-like structure is suitable for merged symbol representatives, but the implementation is not required to use one.
The observable requirement is stable symbol identity and deterministic representative selection.

### 13.2 ESM semantics

The linker must preserve:

- Live imported bindings.
- Immutable import assignments.
- Namespace object identity.
- Re-export behavior.
- Module instantiation before evaluation.
- Depth-first evaluation constraints.
- Circular dependency behavior.
- Top-level await dependency propagation.
- `import.meta` behavior supported by the selected target.

Scope hoisting may merge ESM module bodies into a chunk when it preserves these semantics.
Hoisting must not expose local bindings globally or create identifier collisions.

### 13.3 CommonJS semantics

A CommonJS module must execute lazily on first require unless an eager import requires earlier evaluation.
Its wrapper must cache the module before evaluating its body so cycles observe a partially initialized export object.
Repeated requires must return the same `module.exports` identity.
Assigning a new value to `module.exports` must replace the exported value.

Statically analyzable CommonJS exports may improve interoperation and tree shaking, but analysis must not change runtime behavior.
A CommonJS module with dynamic export mutation remains wrapped and conservative.

### 13.4 ESM and CommonJS interoperation

The compatibility policy must define:

- Default import from CommonJS.
- Named import from statically analyzable CommonJS.
- `require()` of ESM for Node.js targets.
- Namespace wrapping.
- `__esModule` handling.
- Top-level await restrictions.

Target-specific behavior must be covered by executable Node.js and browser fixtures.
The linker must not choose an interoperation mode from file name alone when package type and parsed syntax provide stronger evidence.

### 13.5 Runtime helper library

Format wrappers, CommonJS caches, namespace conversion, export getters, dynamic import helpers, and lowered compiler features may need helper code.

Helpers must live in an internal synthetic module.
They must participate in tree shaking so unused helpers are omitted.
Helper versions must be part of the compiler version and cache identity.
Application code cannot shadow or import the private helper namespace.

## 14. Tree shaking

### 14.1 Part graph

Each JavaScript module is divided into top-level parts suitable for independent reachability decisions.
A part records:

- Declared symbols.
- Referenced symbols.
- Dependencies on other parts.
- Dependencies on other modules.
- Whether evaluation may produce side effects.
- Whether it is required by module initialization.
- Source range for diagnostics and metadata.

The bundler starts from entry-point side effects, requested entry exports, preserved public exports, and effects of required external imports.
It traverses symbol and side-effect edges until no new part becomes reachable.
Only reachable parts are printed.

### 14.2 Conservative effect model

The bundler must retain expressions whose evaluation may:

- Call unknown code.
- Invoke a getter, proxy trap, or user conversion.
- Throw.
- Read or write mutable global state.
- Evaluate a decorator or class static block.
- Register a custom element or polyfill.
- Mutate an export object.
- Depend on direct eval or a `with` scope where supported.

A local literal or declaration may be removed only under the compiler's documented effect model.
New optimizations require semantic fixtures rather than output-size comparisons alone.

### 14.3 Annotations

The bundler recognizes documented pure annotations on supported call and construction expressions.
Arguments remain independently effectful even when the annotated call result is removable.

The bundler recognizes `package.json` `sideEffects: false` and side-effect file patterns.
CSS files are side-effectful by default.
A package must not accidentally drop CSS because its metadata omitted CSS patterns.

`--ignore-side-effects-annotations` disables package and pure annotations from dependencies.
It does not disable effects proven absent by the compiler itself.

The metafile must state whether each removed module or part was removed by compiler proof, package metadata, or a pure annotation.

### 14.4 Dynamic import result analysis

The bundler may retain only statically observed exports from a dynamic import when all uses of the namespace are analyzable.

If the namespace is passed to unknown code, returned, spread, enumerated, indexed with an unknown key, captured by direct eval, or otherwise escapes, every export must be retained.
The imported module's required side effects always remain.

This optimization must not be required for the first stable release.
If implemented, it needs its own compatibility flag and fixtures.

## 15. Chunking

### 15.1 Roots and reachability sets

Every static entry point is a chunk root.
Every live literal dynamic import target is a lazy root when splitting is enabled.

The chunk planner computes which roots reach each retained part.
Parts with equivalent reachability sets are candidates for the same chunk.
The planner must also account for module-format wrappers, top-level await, side-effect order, CSS association, and target constraints.

Chunk assignment is based on canonical root identities, never worker completion order.

### 15.2 Shared chunks

Code used by multiple entries may move to a shared chunk when:

- The selected format supports cross-chunk imports.
- Moving it preserves execution order.
- The chunk can expose every required symbol.
- The change does not make lazy side effects eager.
- The result does not introduce an unsupported cycle.

A shared chunk containing only declarations may load earlier than its original consumer only if declaration initialization is proven safe.
Effectful parts must keep an equivalent execution point.

### 15.3 Dynamic chunks

A live `import("./module.js")` creates a lazy chunk boundary under ESM splitting.
The returned promise must resolve to the expected module namespace.
Errors must remain asynchronous.

When splitting is disabled, the target may be bundled behind an internal lazy module wrapper while `import()` remains asynchronous.
The module must not execute until the import expression runs.

A dynamic import whose containing code is removed by tree shaking must not force output.

### 15.4 Chunk cycles

Cross-chunk cycles must preserve ESM instantiation and evaluation semantics.
The planner must reject a chunk arrangement that cannot represent the cycle in the selected output format.
It may merge chunks to restore correctness.

Chunk file names and hashes must not require a nondeterministic fixed-point loop when chunks reference one another.
The hashing design must assign canonical identities to strongly connected chunk components before final path substitution.

### 15.5 Small-chunk merging

`--min-chunk-size` is disabled by default.
When enabled, the planner may merge a small side-effect-free chunk into a chunk loaded by a superset of its roots.

The merge must not:

- Make a lazy effect eager.
- Increase any initial entry's uncompressed JavaScript by more than the documented overhead cap.
- Duplicate a stateful module.
- Change entry export namespaces.
- Break long-term cache stability without a reported reason.

The metadata must report each merge and estimated bytes added to each affected root.

### 15.6 Browser module preload

For browser HTML entries with ESM splitting, the bundler may emit `modulepreload` links for static chunk dependencies.
Dynamic-import helpers may preload transitive static dependencies before starting the import.

Preload generation must account for public paths, integrity metadata when available, cross-origin mode, and an explicitly configured CSP nonce source.
It must be possible to disable preloads.

The first stable implementation may support static entry preloads before dynamic-import preloads.

## 16. Output formats and targets

### 16.1 Browser ESM

Browser ESM is the default.
Node.js built-ins must not be bundled, polyfilled, or replaced silently.
A browser build that reaches an unsupported Node.js built-in must fail unless the import is external or a configured alias supplies a browser implementation.

Browser resolution uses browser conditions and supported browser-field replacements.
The selected condition order must appear in normalized configuration and metadata.

### 16.2 Node.js ESM

Node.js ESM output must preserve supported external import specifiers and Node.js built-ins.
Generated relative imports must include extensions required by Node.js.
Package conditions prioritize `node`, `import`, and explicit user conditions according to the documented order.

### 16.3 Node.js CommonJS

CommonJS output must preserve `require`, `module`, `exports`, `__filename`, and `__dirname` behavior where the selected wrapper supports them.
External ESM dependencies that cannot be required synchronously must produce a build diagnostic or remain behind dynamic `import()`.

### 16.4 IIFE

IIFE output is deferred.
Adding it requires explicit global names for exports and external dependencies, a policy for dynamic imports, and a clear top-level await error.
It must not be treated as ESM with the import statements removed.

## 17. Built-in loaders

### 17.1 JavaScript-family loaders

The `js`, `jsx`, `ts`, and `tsx` loaders are supplied by `ts-compiling-prd.md`.
The bundler consumes their module IR directly.

### 17.2 JSON and JSONC

JSON and JSONC loaders emit a default JavaScript export representing the parsed value.
Named-property tree shaking may be added only when object identity, key order, and getter-free semantics remain correct.

Duplicate JSON keys follow a documented parser policy.
Malformed input fails with a source range.
JSONC permits documented comments and trailing commas but does not silently accept arbitrary JavaScript.

### 17.3 TOML and YAML

TOML and YAML loaders emit a default JavaScript export from a bounded data model.
They must reject aliases, tags, numeric forms, or duplicate keys that the supported subset cannot represent safely and deterministically.

The exact supported language versions must be documented.
Parsing limits must prevent alias expansion and deeply nested input from exhausting memory.

### 17.4 Text

The text loader exports a JavaScript string.
Source bytes must be valid under the configured text encoding policy.
The default is UTF-8 with a specific diagnostic for invalid input.

### 17.5 File assets

The file loader copies source bytes without transformation.
The JavaScript-visible value is the final public URL.

Asset identity includes source content, loader behavior, and naming settings.
Two inputs with identical bytes may share one emitted asset only when their public semantics are identical.
The manifest must retain every source-to-output relationship even when bytes are deduplicated.

### 17.6 Explicit empty and external loaders

A declarative `empty` loader may replace a configured module with an empty namespace.
It must be explicit and appear in metadata because it can hide target incompatibilities.

An `external` loader preserves the runtime import.
It must not copy or inspect the target file.

## 18. CSS bundling

### 18.1 CSS graph

CSS entry points, JavaScript CSS imports, and HTML stylesheet links create CSS roots.
The CSS scanner records:

- `@import` edges with layer, supports, and media conditions.
- `url()` asset edges.
- Source maps from prior preprocessors.
- CSS Modules imports and composition edges.
- Charset and namespace constraints.

CSS modules are parsed independently where possible.
Ordering is resolved only after the complete CSS graph is known.

### 18.2 Import semantics

The bundler must preserve CSS import order and conditions.
It must not deduplicate an import when doing so changes cascade behavior.
It must preserve valid `@charset`, `@layer`, `@namespace`, media, and supports ordering constraints.

External CSS imports remain `@import` rules when configured as external.
Local imports are inlined or assigned to CSS chunks according to the selected output plan.

Cycles must produce a stable diagnostic or a documented standards-compatible result.
They must not recurse without a bound.

### 18.3 CSS transformations

The initial stable CSS pipeline supports:

- Standards-based parsing.
- Browser-target syntax lowering.
- Required vendor prefixes.
- Safe constant simplification.
- Whitespace and syntax minification.
- Source maps.

The browser target model must be explicit and shared with JavaScript output metadata.
JavaScript and CSS need not support identical legacy targets, but a build must report both effective target sets.

A Lightning CSS port or compatible design is preferred over inventing a second CSS semantics model.
License and maintenance implications must be reviewed before adopting source.

### 18.4 CSS Modules

Files ending in `.module.css` use local class and animation names by default.
The loader exports an object from original local names to generated class strings.

Generated names must be:

- Unique within the build.
- Stable across identical builds.
- Independent of worker order and absolute machine paths.
- Source-mapped where tooling expects original names.
- Configurable through a restricted naming template.

The implementation supports `:local`, `:global`, and `composes` under a published compatibility matrix.
A `composes` declaration must follow the supported simple-class rules.
Composition cycles are errors.
Cross-file composition with conflicting declarations must warn that order is undefined or reject under strict mode.

### 18.5 CSS imported from JavaScript

A JavaScript entry that imports CSS produces an associated CSS artifact unless CSS is intentionally inlined by a later option.
The JavaScript artifact metadata must name its CSS artifact.

Multiple JavaScript entries may share a CSS chunk only when enabling CSS chunking and preserving load order.
CSS chunking is disabled in the first implementation until multi-entry ordering fixtures pass.

The bundler must not inject styles at runtime because the product has no runtime helper for DOM mutation and separate CSS permits parallel browser downloads.

### 18.6 CSS assets

Local `url()` values are resolved relative to the containing stylesheet.
Fragments and query strings are preserved after path rewriting.
Data URLs and external URLs remain unchanged.

Copied assets use the asset naming policy.
The CSS printer receives the final public URL before output hashing is finalized.

## 19. HTML bundling

### 19.1 HTML parser

HTML entry points must use a standards-aware parser or streaming rewriter.
Regular expressions are prohibited for document structure.

The parser must preserve doctype, comments, attribute quoting where practical, inline scripts and styles, template contents, and unknown elements.
It may normalize syntax only under a documented HTML formatting policy.

### 19.2 Supported references

The initial HTML loader discovers local references from:

- `script[src]`.
- `link[rel="stylesheet"][href]`.
- `link[rel="modulepreload"][href]`.
- `link[rel="preload"][href]` for supported asset kinds.
- `link[rel="icon"][href]` and Apple touch icons.
- `link[rel="manifest"][href]`.
- `img[src]` and `img[srcset]`.
- `source[src]` and `source[srcset]`.
- `video[src]` and `video[poster]`.
- `audio[src]`.
- Supported font and worker preload links.

External HTTP, HTTPS, data, blob, mail, and fragment-only URLs remain unchanged.
Protocol-relative URLs are external.

### 19.3 Script behavior

Module scripts become browser ESM roots.
Classic scripts remain classic scripts and require an output format that preserves classic-script execution.
The first stable HTML build may reject local classic scripts that contain module syntax instead of guessing.

Script attributes such as `async`, `defer`, `crossorigin`, `integrity`, `referrerpolicy`, and `nonce` must be preserved unless an output transformation has a documented reason to replace them.

Inline scripts are preserved by default.
An explicit option may promote inline module scripts into generated entries in a later release.

### 19.4 Stylesheet behavior

Local stylesheet links become CSS roots.
The final `href` is rewritten to the CSS artifact.
Media, disabled, title, integrity, crossorigin, referrer policy, and nonce attributes are preserved.

Inline style elements are preserved by default.
An explicit extraction option may be added later.

### 19.5 URL rewriting

URL resolution must follow document base URL rules.
If a local `<base href>` makes deterministic filesystem resolution impossible, the build must require an explicit public base or emit a diagnostic.

`srcset` must be parsed as a candidate list.
String replacement is not sufficient because URLs may contain spaces, commas, descriptors, escaping, or data URLs.

Rewritten paths use the final public path and are escaped for HTML attribute context.

### 19.6 Output HTML

Each HTML entry produces one HTML artifact.
Its referenced JavaScript, CSS, maps, and assets are part of the same output generation.

Hashed references are inserted only after final artifact identities are known.
HTML content hashes therefore depend on the final referenced URLs.

The first stable release does not create a development fallback route, start a server, or inject HMR code.

## 20. Asset naming, hashing, and public paths

### 20.1 Naming templates

Supported template tokens are:

- `[name]` for the source base name without extension.
- `[ext]` for the emitted extension.
- `[dir]` for the path relative to project root.
- `[hash]` for the minimum content-identity prefix.
- `[hash:N]` for an explicitly supported prefix length.

Separate templates exist for entries, chunks, CSS, and assets.
Source-map names derive from their owning artifact unless explicitly configured.

Unknown tokens are configuration errors.
A template that can escape the output directory is rejected.

### 20.2 Hash contract

Artifact hashes use a documented algorithm and canonical byte input.
The initial implementation should use SHA-256 and a collision-extended prefix rather than a process-seeded hash.

The full artifact identity includes:

- Printed bytes before the source-map URL when that URL is derived from the same identity.
- Referenced artifact semantic identities.
- Output format and target where they affect behavior.
- Public-path behavior.
- Relevant printer and minifier versions.

If two truncated names collide with different full hashes, every conflicting name must extend deterministically until unique.
The manifest records the full digest.

### 20.3 Public path

The public path prefixes emitted references from JavaScript, CSS, and HTML.
It may be a relative path, root-relative path, or absolute URL.

Joining must preserve URL semantics rather than filesystem separator semantics.
Queries and fragments on original references remain attached to the rewritten target when valid.

The public path affects output bytes and cache keys but not the physical output destination.

## 21. Source maps

JavaScript and CSS source maps must conform to ECMA-426.
Supported modes are `none`, `linked`, `external`, and `inline`.

The source-map pipeline must:

- Compose loader input maps.
- Carry mappings through transforms and linking.
- Offset mappings as module parts are printed into chunks.
- Use UTF-16 generated and original columns where required.
- Preserve original names where available.
- Normalize source paths relative to project root.
- Avoid leaking home-directory paths in reproducible builds.
- Support optional `sourcesContent` omission.
- Associate external maps with artifacts through stable debug identifiers.

CSS and JavaScript maps are independent artifacts.
HTML rewriting does not require a source map in the initial release.

A map is correct only when real Node.js, browser, and CSS tooling can map breakpoints and errors to the expected source locations.

## 22. Minification and compile-time replacement

The compiler PRD owns local JavaScript minification rules.
The bundler coordinates build-wide identifier frequency, cross-module symbol names, tree shaking, and chunk output.

Minification controls remain independent:

- Syntax.
- Whitespace.
- JavaScript local identifiers.
- CSS syntax and whitespace.

Property-name mangling is deferred.
Exported names, external contracts, function and class names under keep-name policy, direct eval scopes, and reflection-sensitive bindings must remain safe.

`define` replacements accept only parsed literals, identifiers, or property paths under the documented grammar.
They are not evaluated as JavaScript.
Secret values marked by configuration must be redacted from logs and metadata while still affecting cache identity.

Dropping `console` calls also drops argument evaluation under Bun-compatible behavior.
Because this can remove side effects, diagnostics and documentation must state it clearly.
Dropping `debugger` removes debugger statements without changing surrounding control flow.

## 23. Externals and package policy

### 23.1 External matching

External rules may match:

- Exact package names.
- Package subpaths.
- Path prefixes.
- Documented glob patterns.
- Node.js built-ins.

Matching occurs against both the original specifier and resolved path under explicit rules.
Metadata must state which rule externalized each edge.

An external import is preserved in a format valid for the selected output.
If the selected format cannot represent it, the build fails instead of inventing a global.

### 23.2 Package externalization

`--packages external` leaves bare package imports external while continuing to bundle relative and absolute project imports.
This mode is useful for Node.js libraries and services.

Workspace packages follow an explicit policy.
The default treats them as source packages and bundles them because they belong to the project graph.
A configuration option may externalize workspace packages by package name.

### 23.3 Native addons and WebAssembly

Native `.node` addons are copied or externalized for Node.js builds.
They are not parsed or embedded into JavaScript.
Browser builds reject them unless an explicit alias replaces them.

WebAssembly is copied as an asset in the initial release.
Automatic wrapper generation and streaming instantiation are deferred.

## 24. Manifest, metafile, and analysis

### 24.1 Deployment manifest

The stable JSON manifest maps:

- Source entry to output entry.
- HTML entry to referenced JavaScript and CSS artifacts.
- JavaScript entry to static chunks, lazy chunks, and CSS.
- Dynamic import source range to lazy artifact.
- Source asset to emitted asset URL.
- Every artifact to full content digest, byte size, and source map.

The manifest uses output-relative paths plus the configured public URL.
Key ordering is canonical.

### 24.2 Metafile

The detailed metafile includes:

- Tool version and normalized configuration digest.
- Inputs with byte sizes, loader, format, package identity, imports, exports, and side-effect state.
- Edges with kind, original specifier, resolution result, conditions, and external rule.
- Retained and removed parts with reason categories.
- Outputs with kind, bytes, digest, imports, exports, entry identity, CSS association, and source map.
- Per-input byte contribution to every output.
- Chunk roots and reachability sets.
- Cache hits and misses by stage.
- Timings by scan, resolve, load, parse, link, shake, chunk, print, map, hash, and write.
- CPU and GPU stages actually used.
- Warnings that affected optimization.

JSON is the stable machine format.
A human report may be generated from JSON but is not a second compatibility contract.

### 24.3 Budget checks

The analyzer may enforce configured limits for:

- Entry JavaScript bytes.
- Initial route bytes.
- Lazy chunk bytes.
- CSS bytes.
- Individual asset bytes.
- Total emitted bytes.
- Change from a checked-in or CI baseline.

Budget failures occur after artifact planning but before output activation.
They must report gzip or Brotli estimates only when the exact compression configuration is stated.

## 25. Build cache

The build cache is separate from the package content store.
Its schema is versioned.

Cache layers are:

1. Source content and line index.
2. Parsed module IR.
3. Resolved import result.
4. Locally transformed module IR.
5. Linked graph analysis.
6. Chunk plan.
7. Printed artifact bytes and source map.
8. Copied asset identity.

A parsed module key includes compiler version, content digest, loader, and parse-affecting configuration.
A resolved edge key includes importer identity, specifier, attributes, conditions, package metadata identities, filesystem policy, and resolver version.
A linked result key includes the reachable graph identities, target, format, external policy, side-effect policy, and linker version.
A chunk plan key includes entry roots, live parts, splitting policy, and chunk planner version.
A printed artifact key includes chunk identity, printer options, minifier options, naming dependencies, public path, and source-map mode.

Machine-portable cache records must not contain absolute source paths.
Machine-local records must say so in their schema.
Cache corruption becomes a miss and a diagnostic in debug mode.
It must never become output.

## 26. Watch mode and incremental rebuilds

A build context owns normalized configuration, file identities, source buffers, immutable module IR, resolution caches, graph indexes, package metadata, artifact plans, and the last successful generation.

The watcher subscribes to directories where the platform supports it.
It tracks both successful and failed resolution candidates.

On change, the context must:

1. Coalesce duplicate filesystem events for a short bounded interval.
2. Re-stat or re-read affected paths.
3. Invalidate positive and negative resolution entries.
4. Reparse only changed modules whose content digest changed.
5. Update graph edges and reachable nodes.
6. Recompute side-effect reachability for affected roots.
7. Replan only affected chunks and associated CSS or HTML.
8. Reprint and rehash only changed artifacts.
9. Stage a complete new generation.
10. Atomically activate the generation and delete obsolete outputs.

Package manifest, tsconfig, bnpm configuration, lockfile, symlink, directory, and extension changes must invalidate their dependent decisions.

A failed rebuild keeps the previous successful generation unless `--clear-on-error` is set.
Diagnostics must state that outputs are stale.

Long-running contexts must release unreachable source generations, AST arenas, graph nodes, and artifact buffers.
A no-op rebuild must not grow retained memory.

## 27. Atomic output publication

The bundler writes artifacts to a staging location on the same filesystem as the destination when possible.
It validates all planned paths before the first write.

Activation requires:

- Every required artifact was generated.
- Every digest and size was finalized.
- Manifest and metadata refer only to staged artifacts.
- Budget checks passed.
- Staged files were flushed according to the configured durability policy.

Activation swaps the generation into place using atomic rename operations where the platform permits them.
Platforms that cannot atomically replace a non-empty directory need a generation-directory plus pointer-manifest design.

Obsolete outputs from the previous generation are removed only after the new generation is active.
Files not owned by the prior manifest are never deleted.

A process crash must leave either the previous valid generation, the next valid generation, or a clearly identified staging directory that is ignored by consumers.

## 28. Extension model without a JavaScript runtime

The initial stable release ships built-in loaders and declarative aliases, externals, defines, conditions, and loader mappings.
It does not claim Bun, Rollup, Webpack, Vite, or esbuild plugin compatibility.

A later extension protocol may use long-lived subprocesses or WASI components.
The versioned protocol should support batched forms of:

- Build start.
- Resolve.
- Load.
- Transform before parse.
- Artifact inspection after link.
- Build end.

An extension response includes namespace, canonical identity, loader, contents or file handle, dependencies, watch paths, diagnostics, optional source map, determinism declaration, and cache identity.

Per-import process startup is prohibited.
The host must bound response bytes, execution time, memory, and dependency count.
Extension crashes fail the affected build without corrupting the compiler process.

An extension that reads time, randomness, network, environment, or untracked files must declare the build non-reproducible or provide those inputs as cache identities.

Native in-process plugins are deferred until memory safety, ABI versioning, and crash isolation have a design.

## 29. Bend2 execution model

### 29.1 Host effects

The following work remains in Bend2 IO or narrow host adapters:

- Filesystem reads, writes, watches, stats, realpath calls, and atomic renames.
- Package and configuration discovery.
- Environment reads explicitly permitted by configuration.
- Extension subprocess or WASI hosting.
- Terminal and JSON diagnostics.
- Device discovery and dispatch.

### 29.2 Pure or bounded work

The following work should be pure or bounded where practical:

- Per-module import and export analysis.
- Symbol and part graph construction.
- Reachability propagation.
- Root-set calculation.
- Chunk candidate grouping.
- Cross-chunk dependency calculation.
- CSS parsing and local transforms.
- HTML reference scanning and rewriting from finalized URLs.
- Data-loader parsing.
- Asset hashing.
- Identifier frequency reduction.
- Independent chunk printing.
- Source-map segment generation and encoding.
- Manifest and metafile serialization from canonical records.

### 29.3 Parallel scheduling

Graph scanning exposes module work as imports resolve.
Independent parsing and local analysis proceed concurrently.

Global linking establishes symbol representatives and required ordering.
Reachability may operate over compact adjacency lists and bitsets after graph completion.
Independent chunks print concurrently after symbol names and paths are fixed.
CSS roots and independent assets process concurrently with JavaScript linking where their dependencies permit it.

Work stealing must not change observable ordering.
Canonical sort keys are applied at every serialized boundary.

### 29.4 GPU candidates

| Stage | Initial backend | GPU policy |
| --- | --- | --- |
| Filesystem scan | CPU and host IO | Not a GPU target |
| Module parsing | Multicore CPU across files | Keep branch-heavy per-file work on CPU |
| Symbol linking | CPU | Shared graph coordination is a poor first target |
| Reachability bitsets | CPU | Benchmark GPU only on very large dense root sets |
| Chunk grouping | CPU | Irregular maps and sorting stay on CPU initially |
| CSS parsing | Multicore CPU across files | Do not use GPU by default |
| HTML scanning | Multicore CPU across entries | Do not use GPU by default |
| Content hashing | CPU | Benchmark large existing device-resident batches only |
| Identifier frequency | CPU reduction | Optional GPU experiment after correctness |
| Printing | Multicore CPU across chunks | Variable-length output is unlikely to benefit |
| Source-map encoding | CPU beside printer | Avoid another transfer |
| Compression estimates | CPU library | Benchmark separately from bundling |

### 29.5 Dispatch policy

`--gpu` is a benchmarking and diagnostic control until a workload class passes the automatic-dispatch gate.
It cannot force a stage with no GPU implementation.

CPU and GPU paths must produce byte-identical canonical results before printing.
Scheduling differences must not change symbols, chunks, paths, diagnostics, metadata, or maps.

A GPU failure before activation may retry on CPU.
The retry must appear in debug diagnostics and the metafile.

## 30. Architecture

```text
entrypoints + bnpm.toml + tsconfig.json + bnpm.lock
                         |
                         v
               normalized build request
                         |
                         v
                concurrent graph scan
              /           |            \
             v            v             v
        resolver      source loader    cache
              \           |            /
               \          v           /
                compiler module IR
                         |
                         v
                 canonical module graph
                 /         |          \
                v          v           v
          symbol links  part graph  CSS/HTML graphs
                \          |           /
                 \         v          /
                  reachability marking
                         |
                         v
                    chunk planning
                /          |           \
               v           v            v
        JavaScript      CSS chunks    assets
           chunks           |            |
               \           |            /
                \          v           /
               paths + digests + public URLs
                         |
                         v
             HTML rewrite + manifests + maps
                         |
                         v
                  staged output generation
                         |
                         v
                     atomic activation
```

Core boundaries are:

- `BuildRequest` contains normalized, deterministic configuration.
- `ModuleIRProvider` supplies immutable compiler IR.
- `Resolver` maps graph edges to canonical module or external identities.
- `GraphScanner` owns work discovery and deduplication.
- `ModuleGraph` stores typed nodes and edges.
- `Linker` establishes cross-module symbols, wrappers, and part dependencies.
- `ReachabilityEngine` marks retained parts for every root.
- `ChunkPlanner` assigns retained parts and assets to artifact candidates.
- `CssBundler` resolves CSS order, modules, transforms, and assets.
- `HtmlBundler` discovers and rewrites structured references.
- `ArtifactPlanner` assigns canonical paths, URLs, and digests.
- `ArtifactPrinter` generates bytes and source maps.
- `GenerationWriter` stages and activates one complete output generation.

These names describe contracts, not an object-oriented implementation requirement.
Bend2 representations should remain direct and compact.

## 31. Diagnostics

Every diagnostic must include:

- Stable code.
- Severity.
- Build phase.
- Module or asset identity.
- Primary source range when one exists.
- Optional labeled secondary ranges.
- Import or asset-reference chain.
- Human-readable message.
- Recovery suggestion when one is known.

Important diagnostics include:

- Unresolved import with attempted conditions.
- Missing or ambiguous export.
- Unsupported ESM and CommonJS interoperation.
- Top-level await incompatible with output format.
- Non-analyzable dynamic import.
- Incorrect package side-effect metadata warning.
- CSS import cycle or invalid ordering.
- CSS Modules composition cycle.
- HTML local reference that cannot be resolved.
- Output path collision or traversal.
- Asset outside an allowed root.
- Source-map composition failure.
- Extension timeout or crash.
- Output budget failure.

Text diagnostics show source context and use color only on interactive terminals.
JSON diagnostics use byte offsets plus one-based lines and columns.
Diagnostic ordering is canonical across CPU count and backend.

The scanner should continue after independent failures to report a useful batch.
No new generation may activate when any required artifact has an error.

## 32. Security and reliability

- Treat source files, package metadata, source maps, data files, HTML, CSS, assets, cache records, and extension output as untrusted.
- Bound parsing depth, graph size, symbol count, part count, chunk count, source-map segments, and output bytes.
- Reject output path traversal after full normalization.
- Reject symlink escapes from configured asset roots under strict mode.
- Never execute application code during a build.
- Never evaluate definitions as JavaScript.
- Never load arbitrary JavaScript configuration.
- Disable network access during builds.
- Do not follow remote HTML or CSS imports.
- Redact configured secret definitions from diagnostics and metadata.
- Treat malformed cache records as misses.
- Stage all outputs before activation.
- Preserve prior successful outputs after a failed watch rebuild.
- Record extension identity in every extension diagnostic.
- Prevent zip, YAML alias, or recursive-data expansion attacks in loaders.
- Avoid embedding absolute user paths in portable artifacts.

## 33. Performance design

### 33.1 Avoidable work

The implementation should avoid:

- Printing transformed JavaScript before linking.
- Parsing the same source under the same settings more than once.
- Re-resolving identical imports within one generation.
- Re-reading package manifests for each edge.
- Repeating failed filesystem lookups.
- Copying source bytes between workers.
- Serializing ASTs between CPU workers.
- Traversing full ASTs for facts already collected during parsing.
- Rehashing unchanged files with trustworthy identity.
- Reprinting unchanged chunks.
- Rewriting unchanged HTML after referenced URLs remain stable.
- Copying an asset when the destination already contains the verified digest.
- Loading entire large assets merely to copy them when streaming hashing is available.
- Sorting by source strings repeatedly when compact stable IDs exist.

### 33.2 Data layout

Modules, symbols, parts, edges, roots, chunks, and artifacts should use compact integer identities.
Hot graph traversals should use contiguous adjacency ranges where practical.

Per-module AST and analysis storage should be bulk-reclaimable.
Chunk planning should operate on compact retained-part records rather than syntax trees.
Strings should be interned with a bounded build-context lifetime.

Bitsets are appropriate for root reachability when the root count and density justify them.
Sparse sets are better for many roots with narrow reachability.
The implementation should select from measured graph shapes rather than fixing one representation globally.

### 33.3 Determinism

Canonical ordering is required for:

- Entry roots.
- Module IDs.
- Package identities.
- Import edges.
- Export names.
- Symbol representative ties.
- Reachability root sets.
- Chunk membership.
- Cross-chunk imports and exports.
- CSS order.
- HTML rewritten attributes where generated.
- Artifact paths.
- Collision extension.
- Source-map sources and names.
- Manifest and metadata keys.
- Diagnostics.

No observable output may depend on pointer addresses, hash-map iteration order, thread count, worker index, task completion order, CPU architecture, or GPU scheduling.

## 34. Delivery plan

### Phase 0: Boundary extraction

Deliverables:

- Extract bundler-owned requirements from `ts-compiling-prd.md` into implementation contracts.
- Freeze compiler module IR needed for linking.
- Define canonical module, symbol, part, edge, root, chunk, and artifact identities.
- Define normalized build request and metadata schemas.
- Build a graph-only prototype over compiler fixtures.

Exit criteria:

- The same source graph produces identical canonical records across repeated schedules.
- Parser and resolver interfaces do not depend on output naming.
- Linker fixtures can be expressed without filesystem access.

### Phase 1: Single-chunk JavaScript bundler

Deliverables:

- Concurrent graph scan.
- ESM symbol linking and scope hoisting.
- CommonJS wrappers and caches.
- ESM and CommonJS interoperation.
- Part-level tree shaking.
- Browser and Node.js targets.
- ESM and CommonJS output.
- Externals, package policy, definitions, metadata, and atomic output.

Exit criteria:

- Runtime semantic fixtures match unbundled references.
- ESM and CommonJS cycles pass.
- Tree shaking retains every required effect.
- Clean builds are deterministic under randomized worker schedules.

### Phase 2: Code splitting and incremental context

Deliverables:

- Multiple entries.
- Dynamic import chunks.
- Shared chunks.
- Cross-chunk symbol links.
- Content-hashed naming.
- Build cache.
- Watch mode.
- Deployment manifest.

Exit criteria:

- Lazy code remains lazy.
- Shared module identity is preserved across entries and chunks.
- One-file edits rebuild only affected artifacts.
- Clean, cached, and watch builds produce identical bytes.

### Phase 3: Data and asset loaders

Deliverables:

- JSON and JSONC.
- TOML and YAML supported subsets.
- Text.
- File assets.
- Public paths.
- Asset deduplication.
- Manifest asset relationships.

Exit criteria:

- Malformed and resource-exhausting inputs fail safely.
- Rewritten URLs resolve to emitted bytes.
- Asset naming and collision behavior are deterministic.

### Phase 4: CSS bundler

Deliverables:

- CSS parser and graph.
- `@import` and `url()`.
- Browser-target transforms and prefixes.
- CSS minification and source maps.
- CSS imported from JavaScript.
- CSS Modules and composition.

Exit criteria:

- Cascade and layer fixtures match browser references.
- CSS assets resolve correctly under relative and absolute public paths.
- CSS Modules exports match generated selectors.
- JavaScript entries identify associated CSS in the manifest.

### Phase 5: HTML entry points

Deliverables:

- Standards-aware HTML scanning.
- Script, stylesheet, image, media, icon, manifest, font, and source-set references.
- Structured URL rewriting.
- Browser ESM scripts.
- Module preload for static dependencies.
- Atomic multi-content output generations.

Exit criteria:

- Built pages load successfully from root-relative, relative, and CDN public paths.
- Every rewritten local URL exists in the output generation.
- External URLs and preserved attributes remain unchanged.
- No server or runtime dependency is required.

### Phase 6: Chunk quality and extensions

Deliverables:

- Small-chunk merging.
- CSS chunking when ordering is proven.
- Bundle budgets and reports.
- Typed subprocess or WASI extensions.
- Selected GPU experiments.

Exit criteria:

- Chunk merges never make effects eager.
- CSS chunking passes ordering and route fixtures.
- Extension crashes remain isolated.
- GPU paths beat CPU end to end for enabled workload classes and produce identical outputs.

## 35. Validation plan

### 35.1 JavaScript semantic fixtures

Compile and execute source and bundled forms in the selected runtime.
Compare observable output, thrown errors, side effects, import order, module namespace values, and timing boundaries around dynamic imports.

Required categories include:

- ESM imports, re-exports, and star ambiguity.
- Live bindings.
- Cycles.
- Top-level await.
- CommonJS export mutation and replacement.
- Repeated require identity.
- ESM and CommonJS interoperation in both directions.
- Dynamic imports with and without splitting.
- Multiple entries sharing stateful and stateless modules.
- Direct eval deoptimization.
- Package conditions and browser replacements.
- Incorrect side-effect metadata escape hatch.

### 35.2 Tree-shaking fixtures

Every removable and retained form needs a paired semantic fixture.
The suite must cover getters, proxies, computed keys, class fields, decorators, static blocks, pure annotations, argument effects, package sideEffects patterns, CSS imports, and re-export-only modules.

A test that only checks for a shorter string is insufficient.
The built program must demonstrate equivalent behavior.

### 35.3 Chunk fixtures

Verify:

- Root reachability sets.
- Shared chunk membership.
- Lazy chunk boundaries.
- Cross-chunk live bindings.
- Side-effect order.
- Cyclic chunks.
- Stable names and hashes.
- Removed dynamic imports producing no artifact.
- Small-chunk merging limits.
- Module preload relationships.

Run fixtures with randomized worker completion order.

### 35.4 CSS fixtures

Render source-reference and bundled pages in real browsers and compare computed styles or screenshots where visual behavior is the contract.

Cover:

- Nested imports.
- Duplicate imports.
- Media and supports conditions.
- Cascade layers.
- Namespace and charset rules.
- URL fragments, queries, data URLs, and external URLs.
- Browser-target transforms.
- Minification.
- CSS Modules local and global names.
- Local and cross-file composition.
- Composition cycles and conflicting properties.

### 35.5 HTML fixtures

Load real built pages in a browser.
Verify scripts execute, styles apply, images and media load, source sets select valid candidates, icons and manifests resolve, and module preloads point to real chunks.

Cover relative, root-relative, and absolute public paths.
Cover multiple HTML entries with shared and route-specific assets.

### 35.6 Source-map fixtures

Place breakpoints and throw errors from code in entry, shared, and lazy chunks.
Verify original file, line, column, and symbol name through Node.js and browser consumers.

For CSS, inspect original source locations in browser developer tools.
Cover composed input maps, Unicode, CRLF, tabs, minification, and concatenated module parts.

### 35.7 Watch fixtures

Drive the real filesystem watcher with create, write, atomic replace, rename, delete, directory move, symlink change, package manifest change, configuration change, and lockfile change operations.

Run or load the rebuilt outputs after every successful generation.
Verify that a failed generation leaves the previous outputs usable.
Do not validate watch behavior only by invoking invalidation functions directly.

### 35.8 Fault injection

Inject failures during parse, link, print, source-map encoding, asset copy, manifest write, flush, rename, and obsolete-output cleanup.

After each failure, verify that consumers see one complete generation and that recovery does not delete unowned files.

### 35.9 Differential testing

Use Bun, esbuild, Rollup, Node.js, and browsers as differential references where their documented contracts overlap.
A difference is not automatically a defect because targets and compatibility policies differ.
Every difference must be classified as intended, unsupported, or defective.

Fuzz source graphs, module syntax, CSS, HTML references, naming templates, and source-map composition.
Reduce failures to permanent minimal fixtures.
Execute untrusted fuzz output only in a sandbox.

### 35.10 Performance matrix

Measure:

- One large entry.
- Many small modules.
- Deep and wide graphs.
- ESM-heavy and CommonJS-heavy graphs.
- One, ten, and one hundred entries.
- Static, shared, and dynamic chunks.
- Asset-heavy sites.
- CSS-heavy sites.
- Multiple HTML pages.
- Readable, minified, mapped, and unmapped output.
- Clean, cached, no-op, and one-file watch builds.

Compare equivalent current stable Bun and esbuild builds.
Use Rollup for output-quality comparisons where appropriate.

Report scan, resolve, load, parse, link, shake, chunk, print, CSS, HTML, map, hash, write, cache, CPU utilization, peak memory, GPU execution, and transfer time separately.

## 36. Risks and mitigations

| Risk | Effect | Mitigation |
| --- | --- | --- |
| ESM and CommonJS interoperation differs from target runtime | Bundled applications behave differently | Publish one policy per target and maintain executable fixtures |
| Tree shaking removes an effect | Production-only behavior breaks | Use conservative analysis, annotations as explicit trust, and behavior fixtures |
| Incorrect package sideEffects metadata | Required initialization disappears | Provide an ignore-annotations option and report removal reasons |
| Chunk planning changes initialization order | Split builds fail while single bundles work | Model effect order explicitly and merge unsafe chunks |
| Content hashes depend on each other cyclically | Names become unstable or require retries | Hash canonical chunk components before path substitution |
| CSS order changes | Visual regressions appear | Use a CSS-specific graph and verify in real browsers |
| HTML rewriting corrupts URLs or attributes | Deployed pages reference missing assets | Use structured parsers and browser E2E fixtures |
| Resolver differs from package manager | Installed code and bundled code select different files | Share package identity, lockfile, and resolver implementation |
| Watch invalidation misses a negative lookup | New files remain unresolved | Track failed candidates and containing directories |
| Output activation is partial | Deployment serves incompatible chunks | Stage and atomically activate complete generations |
| Plugin compatibility expands scope | Runtime dependency and nondeterminism return | Ship built-ins first and use a typed isolated protocol later |
| Linker becomes a serial bottleneck | Parsing scales but total builds do not | Keep analysis local, use compact graph records, and profile serial fractions |
| GPU work adds transfer overhead | Builds slow down | Keep CPU default and gate every automatic GPU stage on end-to-end results |
| Data loaders accept resource bombs | Memory or CPU exhaustion | Bound nesting, aliases, aggregate nodes, and output size |
| Metadata leaks local paths or secrets | Reproducibility and security fail | Normalize paths and redact marked definitions |

## 37. Open questions

1. Which Bend2 collection layout gives the best compact adjacency lists and immutable per-module IR?
2. Can the linker update symbol representatives without copying large immutable tables?
3. Which HTML parser or streaming rewriter can be adopted with an acceptable license and host boundary?
4. Should the CSS implementation port Lightning CSS concepts, call a host library, or implement a smaller initial standards subset?
5. What browser target syntax should `bnpm.toml` accept, and should it consume Browserslist data without executing JavaScript?
6. Which hash implementation is efficient and portable across Bend2 CPU, Metal, and CUDA backends?
7. How should cyclic chunk components derive names while keeping hashes content-addressed and stable?
8. Should Node.js builds bundle packages by default in stable release, or change to external-by-default before compatibility freezes?
9. Which CommonJS named-export analysis is safe enough for stable support?
10. Should HTML inline module scripts remain inline permanently or become optional virtual entry points?
11. Which CSS import cycles should warn, fail, or follow browser behavior?
12. Can CSS shared chunks preserve route and cascade order without a runtime loader?
13. What stable native or JSON build API should framework tools consume without a JavaScript runtime?
14. What output-generation activation strategy works atomically on Windows as well as POSIX filesystems?
15. Which graph sizes, if any, make GPU bitset reachability beat optimized multicore CPU execution end to end?

These questions do not permit undefined behavior in a release.
Unresolved behavior must remain unsupported with a stable diagnostic.

## 38. Initial stable release criteria

The bundler is ready for initial stable release when all of the following are true:

- Compiler module IR is consumed without intermediate JavaScript text.
- Browser ESM, Node.js ESM, and Node.js CommonJS semantic suites pass.
- ESM live bindings, cycles, CommonJS caching, and supported interoperation are correct.
- Tree shaking passes all effect fixtures.
- Multiple entries, shared chunks, and dynamic chunks preserve behavior.
- JSON, JSONC, TOML, YAML, text, and file loaders pass malformed-input and determinism fixtures.
- CSS imports, assets, transforms, maps, and CSS Modules pass browser verification.
- HTML entries rewrite every supported local reference to an emitted artifact.
- Public paths work for relative, root-relative, and absolute URL deployments.
- Source maps work through real Node.js and browser consumers.
- Manifests and metafiles are stable and complete.
- Watch mode invalidates positive and negative dependencies correctly.
- Fault injection cannot expose a mixed output generation.
- Clean and cached builds produce identical bytes.
- Repeated builds are deterministic across worker counts.
- CPU-only systems support every required feature.
- Automatic GPU dispatch is disabled unless its workload class meets the measured gate.
- Documentation states unsupported dynamic imports, plugin limits, target behavior, and side-effect trust clearly.

## 39. Decision record

### Build on compiler IR instead of chaining tools through text

Printing transformed JavaScript and parsing it again wastes CPU, memory, source fidelity, and source-map accuracy.
The compiler and bundler will share stable module IR.

### Use a scan phase and a link phase

Graph discovery is dynamic and highly parallel across modules.
Cross-module symbol linking requires the completed relevant graph.
Separating these responsibilities keeps filesystem effects outside the linker.

### Tree-shake statement parts, not names alone

Names do not express evaluation effects or cross-file dependencies.
A part graph connects declarations, references, module effects, and entry behavior directly.

### Preserve ESM and wrap CommonJS

Static ESM supports symbol linking and scope hoisting.
Dynamic CommonJS needs lazy cached wrappers.
Using both representations provides better output without pretending CommonJS is statically analyzable.

### Start with deterministic code splitting

A predictable correct chunk plan is more valuable than the smallest possible number of requests.
Small-chunk merging and CSS chunking come after base semantics pass.

### Give CSS and HTML dedicated graphs

JavaScript import semantics do not describe the CSS cascade or HTML URL references.
Shared artifact planning connects the graphs without collapsing their rules into one model.

### Keep production building separate from serving

The requested product excludes a JavaScript runtime.
A production bundler can emit static artifacts and manifests without owning HTTP, HMR, routing, or browser sessions.

### Use built-in loaders before extensions

A runtime-free plugin protocol needs process isolation, cache identities, source-map composition, and determinism rules.
Shipping core loaders first avoids freezing a weak extension ABI.

### Stage complete output generations

Content-hashed chunks and manifests are mutually dependent deployment artifacts.
Atomic generation activation prevents clients from observing incompatible old and new files.

### Parallelize modules and chunks on CPU first

Module parsing, local analysis, CSS processing, asset hashing, and chunk printing provide independent work.
Irregular graph coordination and variable-length output do not justify a GPU-first architecture.

### Keep GPU use evidence-based

The product must remain complete on CPU-only systems.
GPU execution is enabled automatically only when equivalent output and an end-to-end gain are both demonstrated.
