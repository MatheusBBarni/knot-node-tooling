# Product requirements document: JavaScript, CSS, and web asset bundler

Status: Draft

Date: 2026-09-17

CLI name: `knot`

Depends on: `package-manager-prd.md` and `ts-compiling-prd.md`

## 1. Summary

`knot` will provide a native production bundler implemented in Bend2.
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
9. Share the package resolver and lockfile with `knot` instead of creating a second package universe.
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
- Keep dynamic imports lazy whenever splitting is enabled.
- Reject dynamic imports with a stable diagnostic when splitting is disabled until a semantics-preserving lazy-wrapper implementation exists.
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
| Determinism | Repeated clean builds produce byte-identical artifacts and manifests and equivalent semantic metafile projections; observational timings and cache counters may differ |
| Atomicity | Fault injection never exposes a mixed output generation |
| Clean JavaScript build | No slower than esbuild by more than 15% on the reference graphs before stable release |
| Clean full web build | Median wall time at most 1.15 times pinned Bun on equivalent HTML, CSS, asset, map, and minify reference graphs |
| Incremental rebuild | An unrelated edit does not parse, link, print, hash, or rewrite unaffected outputs |
| Watch latency | p95 small-application rebuild completes within 100 ms after filesystem notification |
| Memory | Peak RSS at most 4 GiB on the 10,000-module, 1,000-asset CI fixture; ten no-op watch cycles grow steady-state RSS by at most 1% |
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

The author wants ESM and CommonJS distributions with package dependencies externalized, stable output paths, preserved public exports, and a separate declaration-generation command.
Declaration generation is not owned by the bundler.

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

The first `knot` implementation should prefer predictable chunks over a minimum theoretical chunk count.
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
Composition across files creates graph edges, and conflicting declarations require an explicit canonical ordering policy.

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

The bundler must use the shared `knot` resolver and the frozen lockfile.
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
| `knot build <entrypoints...>` | Build JavaScript, CSS, or HTML entry points and write deployable artifacts |
| `knot build --watch <entrypoints...>` | Keep the build context alive and publish affected artifacts after changes |
| `knot analyze <entrypoints...>` | Build graph and chunk plans, then report composition and size metadata |
| `knot build --write=false <entrypoints...>` | Produce artifacts in memory or temporary storage without activating an output directory |
| `knot clean --build-cache` | Remove bundler caches without touching the package store |
| `knot build --show-config` | Print a redacted versioned configuration display and exit |
| `knot snapshot --outdir <managed-root> --to <new-path>` | Validate and atomically export one immutable active generation as a static document root |

`knot build` must not install a missing package.
It must report the unresolved specifier, importer, attempted conditions, and the command needed to restore the package graph.

### 9.2 Required options

- `--target browser|node`
- `--format esm|cjs`
- `--outdir <path>`
- `--outfile <path>`
- `--root <path>`
- `--profile <name>`
- `--durability full|data`
- `--splitting`
- `--min-chunk-size <bytes>`
- `--external <pattern>`
- `--packages bundle|external`
- `--conditions <condition>`
- `--loader <extension=loader>`
- `--alias <specifier=target>`
- `--workspace-packages bundle|external`
- `--preserve-symlinks`
- `--tsconfig <path>`
- `--library-exports <package-json-path>`
- `--entry-naming <template>`
- `--chunk-naming <template>`
- `--asset-naming <template>`
- `--css-naming <template>`
- `--public-path <path-or-url>`
- `--preload none|static`
- `--define <name=value>`
- `--drop debugger|console|<qualified-name>`
- `--ignore-side-effects-annotations`
- `--minify`
- `--minify-syntax`
- `--minify-whitespace`
- `--minify-identifiers`
- `--sourcemap none|linked|external|inline`
- `--sources-content include|exclude`
- `--metafile <path-or->`
- `--manifest <path-or->`
- `--watch`
- `--clear-on-error`
- `--write true|false`
- `--cpu`
- `--gpu`
- `--log-level silent|error|warning|info|debug`
- `--diagnostics text|json`
- `--help`
- `--version`

`--outfile` must be rejected when the build can emit more than one artifact.
Splitting must require ESM output and `--outdir` in the initial release.
The version 1 target-format matrix supports `browser` with `esm` only and `node` with `esm` or `cjs`; `--target browser --format cjs` fails with `unsupported_format` during configuration normalization, before graph scanning or staging, for both build and analyze.
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
- `sourcesContent` defaults to `exclude`.
- The public path defaults to the empty string.
- Preload generation defaults to `none`.
- The default configuration profile is `default`.
- The default log level is `info`.
- The default diagnostic format is `text`.
- `--clear-on-error` defaults to disabled.
- Third-party side-effect annotations are honored by default.
- Writes are enabled.
- Network access is disabled.
- CPU execution is enabled on every platform.

Changing a default is a compatibility event and requires a decision-record update.

### 9.4 CLI behavior

`knot` commands are non-interactive by default.
They must not prompt, install packages, or access the network implicitly.

`-h` and `--help` print concise command help and exit successfully.
`--version` prints the Knot version and exits successfully.
Successful commands exit with status 0.
An invalid invocation or normalized configuration exits with status 2.
A valid build request that fails during resolution, compilation, analysis, or publication exits with status 1.
SIGINT exits 130 and SIGTERM exits 143 after cleanup; neither signal activates an uncommitted generation.

Human diagnostics and progress are written to stderr.
Artifact data from `knot analyze` is written to stdout.
`--diagnostics json` emits versioned diagnostic records in canonical order on stderr.
No command writes progress to stdout.
`knot snapshot` takes no entry points, does not build, run a server, or change the active pointer, and writes one versioned JSON record `{version:1,generation,completeDigest,publicPath}` to stdout after successful export.
An invalid invocation exits 2; missing or tombstoned output uses `publication_error`, a corrupt pointer or completion uses `publication_recovery`, contention uses `publication_busy`, and an incompatible Node.js `.js` destination uses `output_module_type`, all with exit 1 and no partially published destination.

### 9.4.1 CLI value and repetition rules

Options may appear before or after entry points.
Entry-point order is preserved after option parsing.

Scalar options may appear once.
Repeating a scalar option with a different value is an `duplicate_option` configuration error.
List options such as `--external` and `--conditions` append values in command-line order before canonical serialization.
Repeated `--loader` values must target different extensions.
Conflicting mappings for one extension are an `duplicate_option` configuration error.

Boolean options use a bare flag.
`--write` is the only boolean option that requires an explicit `true` or `false` value.
`--cpu` and `--gpu` are mutually exclusive.

Relative input, output, manifest, metafile, and configuration paths resolve from the invocation working directory.
The normalized request stores canonical paths and rejects traversal outside the configured project and output roots.
`--outfile` and `--outdir` are mutually exclusive for one build request.
An output path collision is an error before the first staged write.

`--write=false` still performs resolution, loading, linking, printing, hashing, and validation.
It stages artifacts in temporary storage and removes that storage after the request completes.
It does not publish a manifest or metafile to a filesystem path.
`--manifest -` or `--metafile -` may emit one requested metadata record on stdout.

Environment variables are not an implicit configuration layer.
An environment value affects a build only when an explicit option or documented host policy names it.
The normalized configuration and its digest must not depend on an unrecorded environment read.

### 9.4.2 Machine-readable command records

`--diagnostics json` emits one UTF-8 JSON object per diagnostic on stderr.
The record schema is defined in section 31.1.
`knot analyze` emits one versioned JSON document on stdout unless a future explicit text mode is selected.
Build progress, warnings, and diagnostics never appear on stdout.

### 9.5 Implementation status and compatibility matrix

The following matrix records the current native implementation boundary.
The requirements in this document remain the release contract.

| Area | Implemented behavior | Explicit boundary |
| --- | --- | --- |
| JavaScript and TypeScript | JavaScript, TypeScript, JSX, TSX, ESM, and Node.js CommonJS entry builds; browser CommonJS fails before graph scanning or staging | Target-specific semantics outside the executable fixtures remain unsupported |
| Built-in loaders | JavaScript-family modules, bounded JSON, JSONC, TOML 1.0, and YAML 1.2 core validation with decoded duplicate-key and unsafe-number rejection, JSONC comments and trailing commas, YAML unsupported-schema rejection, byte-validated UTF-8 data and text reads with leading text BOM removal, CSS, SVG, and file assets | Source-range diagnostics for structured data, normalized data limits, and complete custom file loaders are not implemented |
| Custom loaders | `--loader <extension>=text`, `--loader <extension>=json`, and `--loader <extension>=jsonc` | Other loader names fail with `unsupported_loader`; custom loader mappings are not yet part of a normalized request |
| Package policy | Dependencies bundle by default; `--packages external` preserves bare package imports | Package resolution still requires the installed Knot graph |
| Code splitting | Dynamic imports require `--splitting`; path-like external dynamic imports can target independently emitted entries without a synthetic lazy chunk, while other dynamic imports emit deterministic ESM chunks | Splitting is disabled by default; source-range metadata and the complete chunk graph contract remain unfinished |
| Node.js output scopes | Default Node.js extensions are `.mjs` and `.cjs`; explicitly named `.js` entry outputs check their nearest runtime-visible `package.json`, reject symlinked manifest candidates, track absent candidates, and include selected manifest bytes in `configInputs.outputPackages` and `configDigest`; staged Node.js ESM builds and `--write=false` reject an emitted `.js` shared chunk in an incompatible package scope | Emitted `.js` chunk scopes are not yet recorded in `--show-config` or its digest, and generated package manifests are not yet modeled |
| Semantic configuration | `build --show-config` emits a versioned JSON document and padded base64 SHA-256 semantic digest, redacts define values, and displays the effective write policy separately from semantic hashing; `--profile` selects a declarative `[build.<name>]` table for `target`, `format`, `outdir`, and typed `minify` with CLI precedence; `ignoreSideEffectsAnnotations` changes reachability and the digest | Complete normalized native requests, remaining declarative profile fields and TOML syntax, and the native JSON protocol are not implemented |
| Naming | Entry, shared-chunk, and asset templates support the implemented token subset | CSS naming templates, root-relative `[dir]`, and advanced hash collision policies are not implemented |
| Publication | Writes stage output, replaces the destination directory, and supports `--write=false` temporary builds | Pointer-based generations, atomic reader activation, `knot snapshot`, leases, Windows durability, and multi-crash recovery remain unimplemented release contracts; non-writing builds publish no filesystem metadata |
| Source maps | Linked, external, and inline maps are emitted for the implemented JavaScript and CSS paths | Prior-loader map composition, full name preservation, and `sourcesContent=include` are not implemented |
| Metadata | Manifests include byte counts, SHA-256 digests, and `lazy-chunk` or `external-entry` dynamic target kinds for the implemented output paths | Source ranges, full import/export and CSS-association records, removal reasons, and atomic activation of metadata outside the output root remain incomplete |
| Diagnostics and controls | Invalid targets, browser CommonJS, source-map modes, loaders, package policies, and unsupported option values fail explicitly; `--ignore-side-effects-annotations` controls dependency annotation policy | JSON diagnostics, log levels, GPU execution, and raw tsconfig input are not implemented |
| Browser verification | Browser execution is covered by the repository's real-page smoke workflow | The browser matrix is not yet the full CSS, HTML, source-map, and preload release suite |

Adding behavior to a boundary requires an executable acceptance fixture and an update to this matrix.
An explicit boundary is a current implementation status, not a relaxation of the initial stable release contract.
The stable-release gate remains closed until every required goal has an implemented behavior, fixture coverage, and compatible metadata.

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
3. `knot.toml` build profile.
4. Supported transform fields from `tsconfig.json`.
5. Built-in defaults.

The private execution request contains canonical absolute paths and actual transformation values but no unresolved relative paths or implicit environment reads.
`knot build --show-config` displays a safe projection, not the execution request.
Each cache layer projects only fields that affect its result and revalidates current limits on a hit; the portable `configDigest` is not copied wholesale into unrelated layer keys.

Arbitrary JavaScript configuration files are not accepted.
Declarative configuration keeps builds reproducible and avoids requiring a runtime.

### 10.1 Normalized request record

The normalized execution request has schema version `1`.
The CLI, native API, and JSON protocol normalize into this private record; public display and metadata use the separate projections defined below.

| Field | Type | Requirement |
| --- | --- | --- |
| `schemaVersion` | integer | Must be `1` for this contract. |
| `profile` | string | Identifies the selected `knot.toml` build profile. |
| `entries` | ordered string array | Contains canonical entry paths in user-specified order. |
| `cwd` | string | Contains the canonical invocation directory. |
| `root` | string | Contains the canonical project root. |
| `output` | object | Contains either `dir` or `file`, never both. |
| `target` | enum | Is `browser` or `node`. |
| `format` | enum | Is `esm` or `cjs`. |
| `conditions` | ordered string array | Contains deduplicated explicit user conditions. |
| `effectiveConditions` | object | Maps `browserEsm`, `nodeEsm`, and `nodeCjs` to active condition sets used by edge resolution. |
| `external` | ordered string array | Contains explicit external patterns. |
| `packages` | enum | Is `bundle` or `external`. |
| `loaders` | ordered object | Maps extensions to built-in loader names. |
| `aliases` | ordered object | Maps original specifiers to paths, bare specifiers, or `false`. |
| `workspacePackages` | enum | Is `bundle` or `external`. |
| `preserveSymlinks` | boolean | Selects logical rather than realpath module identity. |
| `lockfileDigest` | string or null | Is the frozen lockfile byte digest where a package graph is used. |
| `extensions` | array | Contains declared extension digests and permissions. |
| `library` | object | Declares public subpaths and an optional package manifest for validation. |
| `configInputs` | object | Lists consulted declarative configuration identities and digests. |
| `transforms` | object | Contains compiler, define, drop, and minification settings. |
| `treeShaking` | boolean | Records whether reachability removal is enabled. |
| `splitting` | boolean | Records whether ESM chunk splitting is enabled. |
| `chunkMergeOverhead` | object | Records the percentage and byte floor used for small-chunk merging. |
| `preload` | enum | Is `none` or `static`. |
| `sourceMap` | enum | Is `none`, `linked`, `external`, or `inline`. |
| `sourcesContent` | enum | Is `include` or `exclude`. |
| `naming` | object | Contains entry, chunk, CSS, and asset templates. |
| `publicPath` | string | Contains the canonical public URL prefix. |
| `metadata` | object | Contains manifest, metafile, and source-root settings. |
| `cache` | object | Contains cache mode, canonical directory policy, byte limits, and portability policy. |
| `clearOnError` | boolean | Records whether a failed watch rebuild removes owned outputs. |
| `ignoreSideEffectsAnnotations` | boolean | Records the dependency annotation policy. |
| `diagnostics` | enum | Is `text` or `json`. |
| `logLevel` | enum | Is `silent`, `error`, `warning`, `info`, or `debug`. |
| `write` | boolean | Records whether staged artifacts are activated. |
| `watch` | boolean | Records whether the request owns a watch context. |
| `watchSettings` | object | Contains event coalescing, polling, and overflow policy. |
| `budgets` | object | Contains normalized artifact budget limits. |
| `execution` | object | Records CPU or explicitly requested GPU execution. |
| `limits` | object | Contains every finite resource limit from section 32.2. |
| `security` | object | Contains canonical asset root and strict-root enforcement. |

Object keys are serialized in lexicographic order and arrays preserve semantic order.
The public `configDigest` is padded base64 SHA-256 of canonical UTF-8 JSON for the versioned semantic projection described here, not a hash of absolute execution paths or operational settings.
The hashed projection has exactly `{version:1,portable,fields}`, where `fields` contains only the following semantic fields in canonical key order and never contains either digest.
That projection contains `entries`, `target`, `format`, `conditions`, `effectiveConditions`, `external`, `packages`, `loaders`, `aliases`, `workspacePackages`, `preserveSymlinks`, `lockfileDigest`, `extensions`, `library`, `configInputs`, `transforms`, `treeShaking`, `ignoreSideEffectsAnnotations`, `splitting`, `chunkMergeOverhead`, `preload`, `sourceMap`, `sourcesContent`, `naming`, `publicPath`, `metadata.sourceRoot`, `security.assetRoot`, `security.strictAssets`, `security.csp`, and `execution.targetBaseline` and `execution.cssBaseline`.
It also contains `output.file`'s final filename or null for `--outdir`; the physical output parent and `output.dir` are excluded, while the selected package scope for each explicit Node.js `.js` output is recorded in `configInputs.outputPackages`.
Project paths become project-root-relative POSIX identities, installed package paths become lockfile-locator plus package-relative identities, and `root` itself becomes `.`; path-bearing values in nested fields use the same rule.
`cwd`, absolute `root`, physical output and metadata destinations, profile label, cache placement and policy, budgets, limits, write/watch mode, diagnostics, log level, durability, worker count, and selected CPU/GPU backend do not affect successful artifact bytes and are excluded.
Changes to excluded validation limits or budgets may still change whether a build succeeds; a cache hit must pass the current request's validation before publication.
If a semantic input or its consulted configuration file lies outside the project root and frozen package graph, the projection uses its machine-local canonical path identity and sets `portable: false`; otherwise it sets `portable: true`.
The portability marker is part of the hash; cross-machine byte-equivalence claims apply only to portable builds with identical relative inputs and versions.
Public metadata serializes machine-local source identities as stable pseudonyms derived from the private canonical path, never as host absolute paths; the private path remains available only to the local resolver and cache.
The private `executionDigest` hashes the complete canonical execution request for ownership and local bookkeeping; it never enters a portable artifact or user-visible metadata.

`knot build --show-config` prints one canonical JSON document `{version:1,configDigest,portable,config}` on stdout and exits without building.
Its `config` has the normalized request's keys but uses portable path identities where available, a nonportable path marker instead of an absolute path elsewhere, and `"<redacted>"` for every `transforms.define` value or other sensitive string.
The display document is intentionally not a valid build request; clients submit complete unredacted normalized requests to the native or JSON protocol.
Neither the display record nor JSON protocol responses echo private execution values, raw credentials, or host absolute paths.
Unknown configuration keys and unsupported enum values fail before graph scanning.

### 10.2 Configuration file rules

`knot.toml` may contain only declarative values representable in the normalized request.
Unknown keys, duplicate keys, and type mismatches are configuration errors.
`tsconfig.json` contributes only fields explicitly listed as supported compiler transforms.
It must not override bundler fields such as output paths, package policy, splitting, or publication.

CLI flags override the JSON request, the `knot.toml` profile, supported `tsconfig.json` fields, and defaults in that order.
The same field must have the same normalized value regardless of which accepted input layer supplied it.

### 10.3 Profiles and native JSON protocol

The default profile is `[build.default]`.
Named profiles use `[build.<name>]` tables in `knot.toml` and are selected by `--profile`.
Profile names use ASCII letters, digits, hyphens, and underscores.
Profile inheritance is not supported in the initial release.

The native JSON protocol accepts a complete private normalized execution request for `build` and `analyze` and returns only the versioned response projection from section 10.7; it never accepts the redacted `--show-config` document as a build request.
The transport is newline-delimited UTF-8 JSON over a pipe or socket.
Diagnostics are returned in the response and are also eligible for stderr emission by the CLI adapter.
End-of-input stops accepting requests; explicit cancellation aborts an in-flight request without activation.
The protocol never interleaves progress text with JSON records.

With `--write=false`, the CLI validates the complete planned artifact set and emits no artifact bytes by default.
`--manifest -` or `--metafile -` may expose one requested metadata record on stdout.
The two stdout metadata modes are mutually exclusive.
The native API may return staged artifact bytes and metadata directly without activating them.

### 10.4 Version 1 normalized field contracts

The following objects complete the version 1 request in section 10.1.
Every listed key is required after normalization, including nullable keys; unknown keys fail with `invalid_option`.
Byte counts are nonnegative integers; times are positive integer milliseconds.
Canonical paths are absolute for local execution.
The semantic `configDigest` follows section 10.1's portable projection; the local `executionDigest` follows the complete canonical request, including lockfile state and absolute execution paths.
Only approved path identities and actual transformation values enter affected cache keys; raw credentials are not a supported build input.

| Object | Required fields and defaults | Constraints |
| --- | --- | --- |
| `output` | `dir: <root>/dist`, `file: null`, `durability: full` | Exactly one destination is non-null. Durability is `full` or `data`. `--outfile` requires exactly one artifact including maps and metadata. |
| `transforms` | `jsx: automatic`, `jsxFactory: React.createElement`, `jsxFragmentFactory: React.Fragment`, `jsxImportSource: react`, `useDefineForClassFields: true`, `experimentalDecorators: false`, `verbatimModuleSyntax: false`, `importsNotUsedAsValues: remove`, `baseUrl: null`, `paths: {}`, `define: {}`, `drop: []`, `minifySyntax: false`, `minifyWhitespace: false`, `minifyIdentifiers: false`, `cssMinify: false` | `jsx` is `classic`, `automatic`, or `preserve`; bundled JSX cannot use `preserve`. Defines follow section 22. |
| `naming` | `entry: [dir][name]`, `chunk: [name]-[hash]`, `css: [name]`, `asset: [name]-[hash]`, `cssModule: _[local]_[hash]` | Token sets are restricted by sections 18.4.1 and 20.1. |
| `metadata` | `manifest: null`, `metafile: null`, `sourceRoot: ""` | Destinations are absolute paths or `-`; for `write:true`, filesystem destinations must map inside the managed output root and become listed generation artifacts. At most one stdout destination. `sourceRoot` is a relative URL path. |
| `budgets` | `entryJsBytes: null`, `initialRouteBytes: null`, `lazyChunkBytes: null`, `cssBytes: null`, `assetBytes: null`, `totalBytes: null`, `baseline: null`, `maxIncreaseBytes: null` | Numeric budgets are nonnegative integer bytes; `maxIncreaseBytes` requires a canonical version 1 baseline manifest. `null` disables a budget, not a resource limit. |
| `limits` | Twenty-six positive defaults in section 32.2 | Contains every bundler-owned input and execution bound, including structured-data depth and nodes, HTML and CSS depth, package-target recursion, protocol frames, and extension time, memory, and batch size. |
| `execution` | `backend: cpu`, `workers: 0`, `targetBaseline: chromium:153.0.8010.12` for browser or `node:24` for Node.js, `cssBaseline: chromium:153.0.8010.12`, `gpuStages: []` | `workers: 0` means bounded host CPU selection; GPU stages follow section 29.5. Baselines are pinned, not discovered from the host. |
| `watchSettings` | `debounceMs: 50`, `maxDebounceMs: 200`, `pollIntervalMs: 1000`, `overflow: rescan` | `overflow` only accepts `rescan`; `maxDebounceMs` bounds the first pending event. Polling applies only when native events are unavailable or overflow. |
| `cache` | `mode: read-write`, `directory: <root>/.knot/build-cache`, `maxBytes: 4294967296`, `maxRecordBytes: 536870912`, `portable: true` | See section 25 for isolation and cleaning. |
| `chunkMergeOverhead` | `percent: 10`, `floorBytes: 32768`, `minChunkBytes: null` | `null` disables merging; `--min-chunk-size` sets the threshold. |

Other required top-level fields are `aliases: {}`, `preserveSymlinks: false`, `workspacePackages: bundle`, `lockfileDigest: null`, `extensions: []`, `library: {exports: {}, packageJson: null}`, `configInputs: {toml: null, tsconfig: [], libraryManifest: null, outputPackages: []}`, and `security: {assetRoot: <root>, strictAssets: true, csp: null}`.
`aliases` maps exact original specifiers to canonical project paths, bare specifiers, or literal `false`.
`workspacePackages` is `bundle` or `external`; `lockfileDigest` is SHA-256 of exact frozen `knot.lock` bytes and is null only when no package graph is used.
An absent or stale required lockfile fails before graph scanning.
`extensions` contains ordered binary and configuration digests with granted permissions; it is empty without extensions.
Each non-null `configInputs` item except `outputPackages` is `{path,digest}` with SHA-256 over exact file bytes; `tsconfig` follows the resolved `extends` chain in decision order.
`configInputs.outputPackages` is an array sorted by final output-relative path, with one `{output,state,checked,path,digest,type}` record for each explicitly configured Node.js `.js` JavaScript artifact, and is empty when no such output is planned.
`state` is `present` or `absent`; `checked` is the ordered list of absent `package.json` candidate identities from that output's directory toward the filesystem root before the selected manifest, or through the root when none exists.
For `present`, `path` identifies the nearest runtime-visible package manifest, `digest` hashes its exact bytes, and `type` is `module`, `commonjs`, or null when the field is absent; for `absent`, `path`, `digest`, and `type` are all null, while `checked` still records every negative lookup.
Within a managed generation, candidate identities use logical generation-relative paths instead of the opaque generation ID; paths outside the project root or frozen package graph use the machine-local identity and mark the semantic projection nonportable.
Every positive and negative candidate is a tracked dependency for watch invalidation and cache validation; creation of a nearer `package.json`, removal of the selected one, or a changed `type` recomputes this record and its semantic digest before publication.
`security.strictAssets` is always true in version 1; false fails with `invalid_option`.
`security.csp` is null or a literal CSP policy string validated under section 19.3, never executable configuration.
`loaders` keys are lowercase extensions starting with a dot; values are `js`, `jsx`, `ts`, `tsx`, `json`, `jsonc`, `toml`, `yaml`, `text`, `file`, `css`, `html`, `empty`, or `external`.
Default extensions map `.js`, `.mjs`, `.cjs` to `js`; `.jsx` to `jsx`; `.ts`, `.mts`, `.cts` to `ts`; `.tsx` to `tsx`; `.json` to `json`; `.jsonc` to `jsonc`; `.toml` to `toml`; `.yaml`, `.yml` to `yaml`; `.css` to `css`; `.txt` to `text`; `.html` to `html`; and other asset extensions to `file`.
`.module.css` selects CSS Modules before the general `.css` mapping; explicit mappings win by longest matching extension.
Normalized `conditions` contains deduplicated explicit user conditions; `effectiveConditions` lists the active target and import-kind sets from section 23.1.1.
`--minify` sets all four minify booleans; granular flags set only their named JavaScript boolean.
Explicit boolean CLI controls override lower layers; omitted controls do not.

### 10.5 Declarative configuration mapping

`[build.default]` and `[build.<name>]` use the camelCase names of the normalized record, except `entrypoints` maps to `entries`, `outdir` and `outfile` map to `output.dir` and `output.file`, and `sourcemap` maps to `sourceMap`.
Nested tables `.output`, `.transforms`, `.naming`, `.metadata`, `.budgets`, `.limits`, `.execution`, `.watchSettings`, `.cache`, `.library`, and `.security` map field for field; `configInputs` and `effectiveConditions` are derived and cannot be supplied.
Tables `.aliases`, `.loaders`, `.transforms.define`, and `.transforms.paths` are string-keyed; lists retain TOML array order.
No alternative spellings, implicit environment expansion, inheritance, or profile fallback are accepted.
CLI `--alias <specifier=target>` repeats with distinct specifiers; target is a project path, bare specifier, or `false`.
CLI `--tsconfig <path>` selects raw JSON or JSONC `tsconfig.json`; otherwise the nearest project-root tsconfig is used if present.
Local `extends` chains have cycle detection and may reference only the project or frozen installed package graph; remote and executable extends fail.
Only `compilerOptions.baseUrl`, `paths`, `jsx`, `jsxFactory`, `jsxFragmentFactory`, `jsxImportSource`, `useDefineForClassFields`, `experimentalDecorators`, `verbatimModuleSyntax`, and `importsNotUsedAsValues` contribute.
`importsNotUsedAsValues` accepts `remove`, `preserve`, or `error`; `error` rejects value imports used only as types without type checking.
Checker-only options are ignored; unknown emit-affecting options and malformed supported fields fail with `invalid_option`.
`baseUrl` resolves from the declaring config; `paths` targets resolve from the effective base, longest literal prefix winning with declaration order breaking ties.
The content digests and resolved identities of all consulted config files participate in affected cache keys and watch invalidation.

### 10.6 Versioned stage interfaces

Stage records have `version: 1`, immutable value semantics, and UTF-8 byte-offset source ranges `[start,end)`.
Unsupported versions fail with `unsupported_interface`.
Build-wide compact integer IDs are assigned by canonical identity after graph completion and are not stable across builds; compiler-local symbol, import, and part IDs are nonnegative integers stable within one `ModuleIR`.
Cross-stage references use canonical identity or an explicitly scoped local ID, never pointers or output filenames.

| Record | Required version 1 fields | Producer and validation |
| --- | --- | --- |
| `ModuleIR` | `identity`, `sourceDigest`, `sourceBytes`, `loader`, `format` (`esm`, `cjs`, `hybrid`), `syntax`, `symbols` (`id,name,scope,flags,range`), `imports` (`id,kind,specifier,attributes,range`), `exports` (`name,symbolId,sourceImportId,kind`), `parts` (`id,range,declares,references,dependsOnParts,dependsOnImports,effect,initializes`), `flags` (`topLevelAwait,directEval,dynamicExports`), `mappingSegments` | Compiler owns AST and local transforms; IDs are unique per module and every reference must exist. `effect` is `none`, `annotatedPure`, or `unknown`; missing facts default to `unknown`. |
| `ResolveRequest` | `importer`, `specifier`, `kind`, `attributes`, `range`, `target`, `format`, `conditions`, `lockfileDigest`, `preserveSymlinks` | Scanner creates it per edge. Importer identity contains namespace, canonical path/virtual key, loader, package locator, peer context, and semantic query/fragment. |
| `ResolveResult` | `status` (`module`, `external`, `error`), `identity`, `loader`, `format`, `package`, `matchedRule`, `attempts`, `watchPaths`, `diagnostics` | Shared resolver returns tagged result. Identity and loader are required for a module; external identity and rule for an external; errors have no guessed identity. Candidate and watch paths include negative lookups. |
| `LoaderResult` | `identity`, `kind` (`module`, `css`, `html`, `asset`), `loader`, `contentDigest`, `bytes`, `valueTree`, `dependencies`, `watchPaths`, `sourceMap`, `cacheIdentity`, `deterministic`, `diagnostics` | Host loader bounds and validates immutable bytes; `valueTree` is the bounded data-loader value or null for other loaders. |
| `LinkPlan` | `modules`, `symbolRepresentatives`, `resolvedExports`, `retainedParts`, `removedParts`, `orderedEffects`, `roots`, `diagnostics` | Linker consumes complete graph, never filesystem; every part reference exists and records its reason. |
| `ChunkPlan` | `roots`, `chunks`, `crossChunkEdges`, `cssAssociations`, `assetEdges`, `mergeDecisions` | Each chunk has canonical `id`, `kind`, members, root identities, evaluation constraints, imports, exports, and `lazy` flag. Every retained part belongs to one logical chunk unless proved safe to duplicate. Output paths are assigned later. |

Every field listed in the table is required; only fields explicitly described as nullable may contain `null`, and unknown fields or invalid enum members fail with `invalid_interface`.
Canonical identities use `{namespace,path,loader,packageLocator,peerContext,query,fragment,attributes}`; `namespace` and `path` are nonempty strings, `packageLocator` and `peerContext` are strings or null, `query` and `fragment` are normalized strings or null, and `attributes` is a sorted string-to-string map.
Project paths use root-relative POSIX spelling in serialized projections; installed package paths use lockfile locator plus package-relative spelling; an in-memory stage may retain a verified absolute handle path separately.
Digests are padded base64 SHA-256 strings, `sourceBytes` and `bytes` are nonnegative byte counts, and all source ranges are half-open UTF-8 byte intervals within their owning source.

Within `ModuleIR`, `symbols` is ordered by local `id`; each symbol has a UTF-8 `name`, nonnegative local `scope` (`0` is module scope), a set of `imported`, `exported`, `mutable`, `hoisted`, `captured`, or `typeOnly` flags, and a valid `range`.
`imports` is ordered by source range and local `id`, uses section 12.2 edge kinds, and has a literal `specifier`, sorted string-to-string `attributes`, and `range`.
`exports` contains `{name,symbolId,sourceImportId,kind}`, where `kind` is `local`, `reexport`, `star`, or `default`; `local` and local `default` require a local symbol ID, while `reexport` and `star` require a local import ID, with the other field null.
`parts` contains local ID and range, ordered arrays of local symbol IDs in `declares` and `references`, local part IDs in `dependsOnParts`, local import IDs in `dependsOnImports`, the stated effect enum, and boolean `initializes`.
`flags` has exactly three booleans; `mappingSegments` is an ordered array of `{generatedStart,originalStart,originalEnd,name}`, with nonnegative transformed-local generated offset, valid original offsets, and nullable original name.

`ResolveRequest` uses one canonical importer identity, literal specifier, section 12.2 kind, sorted attributes, valid importer range, normalized target and format, ordered active condition names, padded lockfile digest or null, and boolean symlink policy.
`ResolveResult` has nullable identity, loader, format, package identity, and matched rule according to its status; `attempts` is an ordered array of `{candidate,found,basis}`, `watchPaths` is an ordered array of canonical positive or negative lookup parents, and `diagnostics` is an array of section 31.1 records.
An `error` result requires at least one error diagnostic and no selected identity, while `module` requires identity, loader, and format; `external` requires a matched explicit rule, external loader, package policy, or Node built-in reason, with a canonical target identity for path-like edges and the original specifier for bare or built-in edges.
`LoaderResult.bytes` is the immutable source or generated byte sequence with its digest; `dependencies` is an ordered array of `{kind,specifier,attributes,range}`, `watchPaths` follows resolver path rules, `sourceMap` is a validated version 3 map or null, `cacheIdentity` is a digest or null, and `deterministic` is boolean.

`LinkPlan.modules` is an array of canonical identities; `symbolRepresentatives` is an ordered array of `{module,symbolId,representativeModule,representativeSymbolId}`, and `resolvedExports` is an ordered array of `{module,name,symbolModule,symbolId}` for nonambiguous exports.
`retainedParts` and `removedParts` are disjoint arrays of `{module,part,reasons}`; retained reasons are `entry`, `import`, `export`, or `effect`, and removed reasons use section 24.3's enum.
`orderedEffects` is an ordered array of `{module,part}` constrained by ESM evaluation; `roots` is an ordered array of `{identity,kind,requestedExports}` where kind is `entry` or `dynamic` and requestedExports is an ordered name array with `*` meaning every export.
`ChunkPlan.roots` has the same root shape; each `chunks` item has `{id,kind,members,roots,evaluationBefore,imports,exports,lazy}` with kind `entry`, `shared`, or `dynamic`, members as ordered `{module,part}` references, and `evaluationBefore` as ordered chunk IDs that must instantiate first.
`crossChunkEdges` is an ordered array of `{from,to,kind,importer,importId}`, `cssAssociations` of `{owner,css}` with `css` an ordered list of stylesheet identities, and `assetEdges` of `{owner,asset}`; `mergeDecisions` has section 24.3's shape using canonical chunk IDs, not output paths.
No chunk contains an output filename before naming.

`ModuleIR.syntax` is an opaque compiler-owned AST handle, never serialized into a public protocol.
Serialized IR caches use an independently versioned compiler codec; extensions and public API cannot submit AST handles.
The public stage projection contains only structural facts and source ranges.
Duplicate identities, dangling references, or incompatible field types fail with `invalid_interface`.

### 10.7 Native API and JSON protocol version 1

The stable native boundary uses the platform C calling convention and the following exact version 1 signatures:

```c
typedef struct KnotBuildContext KnotBuildContext;
KnotBuildContext *knot_context_new_v1(void);
void knot_context_drop_v1(KnotBuildContext *context);
int32_t knot_build_v1(KnotBuildContext *context, const uint8_t *request, uint64_t request_len, uint8_t **response, uint64_t *response_len);
int32_t knot_cancel_v1(KnotBuildContext *context);
void knot_free_v1(KnotBuildContext *context, uint8_t *response, uint64_t response_len);
```

`knot_build_v1` takes a single protocol request JSON object without a terminal newline and returns a single response object; lengths count bytes.
It returns `0` for a completed protocol response even when the build status is `error`, `1` for transport or allocation failure, and `2` for unsupported protocol version; on nonzero return output pointers are null and zero.
Null context, pointers, or oversized requests fail with `1`; a null response pointer is never passed to `knot_free_v1`.
The caller owns request bytes; the context owns response bytes until freed; contexts are not concurrently reentered, but cancellation is thread-safe and cannot activate canceled output.
`knot_context_new_v1` returns null on allocation failure; `knot_cancel_v1` returns `0` when it requests cancellation of an active operation, `1` when no operation is active, and `2` for a null context.
`knot_context_drop_v1` cancels and joins active work and releases any still-owned responses; callers must not invoke it concurrently with `knot_build_v1` or `knot_free_v1`.
No Bend object, AST handle, or allocator-owned pointer crosses this ABI; it is not a plugin ABI.
JSON protocol version 1 uses one newline-delimited UTF-8 frame per request and response; `limits.protocolFrameBytes` defaults to and cannot exceed the wire hard cap of 64 MiB.
A request is `{"protocolVersion":1,"id":"caller-id","operation":"build","config":{...},"returnArtifacts":false}`; `operation` is `build`, `analyze`, or `cancel`, and cancellation refers to an in-flight `id` without `config`.
`returnArtifacts` defaults to false, is permitted only for native `write:false` builds, and fails with `invalid_option` otherwise; the correlation `id` is at most 256 UTF-8 bytes.
A response is `{"protocolVersion":1,"id":"caller-id","status":"ok","diagnostics":[],"manifest":null,"metafile":null,"analysis":null,"artifacts":[]}`; status is `ok`, `error`, or `cancelled`.
An artifact is `{path,kind,bytes,digest,contentBase64}`, with an output-relative `path`; contents are present only for native `write:false` requests explicitly requesting bytes.
If a response including returned artifact bytes would exceed `limits.protocolFrameBytes`, the operation returns a complete minimal `error` response with `resource_limit` and no partial artifacts.
Every accepted request has exactly one terminal response; malformed frames respond with `id:null` and a versioned diagnostic.
The protocol is a local authenticated pipe, Unix domain socket, or Windows named pipe, never a network-listening service; a request may contain necessary absolute host paths and explicitly supplied public definition values, which are not logged or retained as protocol evidence.
Responses omit raw secrets and host paths by default, and stderr diagnostics apply section 31.1 redaction.
The `id` is a correlation key, not a cache identity or authorization token.

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

Version 1 rejects non-literal `import()` and non-literal `require()` inside bundled modules with `dynamic_specifier` at the expression range.
A Node.js external CommonJS module may use its native non-literal require outside the build graph; this is not a bundler fallback.

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

Literal `require.resolve()` of a bundled module fails with `require_resolve_bundled` unless that module has its own emitted file; in that case Node.js CommonJS output returns its final output filesystem path, never the source path.
External literal `require.resolve()` remains a native Node.js CommonJS call; browser output rejects it with `unsupported_runtime_api`.
Access to `require.cache`, `require.extensions`, `require.main`, or `module.paths` from bundled code fails with `unsupported_runtime_api` because Knot's wrapper cache is not the host's filesystem cache.
Direct `eval` preserves its lexical scope only when the compiler disables hoisting, renaming, and removal of bindings visible in that scope; otherwise it fails with `dynamic_scope`.
Indirect `eval` and `new Function` retain target-runtime global semantics; string contents are not parsed for imports or rewritten.
An import reached only through a string is the application's runtime responsibility and cannot resolve a bundled-only module.
Unshadowed `process` and `Buffer` remain Node.js globals on the Node target; reachable unshadowed browser references fail with `unsupported_runtime_api` unless explicitly replaced by a user definition or imported implementation.
Knot injects no browser Node.js polyfills.

### 13.4 ESM and CommonJS interoperation

Knot uses the following interoperation policy.

An ESM default import from CommonJS evaluates to the CommonJS module's final `module.exports` value.
The static CommonJS name set includes only unshadowed `exports.name`, `module.exports.name`, literal bracket keys on those objects, data-property keys in a statically visible `module.exports = { ... }` object literal, and unshadowed `Object.defineProperty(exports, "name", {value: ...})`.
Computed or spread keys, inherited keys, getters, and mutations through unknown aliases do not add names; static scanning never evaluates user expressions.
An unknown named import fails with `missing_export` at the import site.
After evaluation each candidate reads its own final `module.exports` property once; the value is a snapshot, and an absent own property produces `undefined`.
If the static scanner observes accessor definitions or unbounded descriptor mutation for a requested name, it fails with `cjs_named_accessor` rather than invoking a getter at an undocumented point; default-only import preserves original descriptors.
The synthetic namespace is a cached sealed null-prototype object with `Symbol.toStringTag` `"Module"`; `default` and recognized named properties are enumerable, nonconfigurable, read-only data properties whose values are snapshots taken after evaluation.
It does not mutate the underlying CommonJS value or invoke a candidate accessor at an undocumented time.
The candidate name `default` never overrides the synthetic default; dynamic import of CommonJS produces the same namespace shape asynchronously.

`require()` of synchronous ESM returns its namespace object.
`require()` of ESM that depends on top-level await fails with `top_level_await` rather than returning a promise.
An ESM namespace exposed to CommonJS uses live getters for its named exports and `default` where present.
The `__esModule` property is an ordinary exported or assigned property and does not change the default-import rule.

`import.meta.url` is the final module URL for browser output and the final file URL for Node.js output.
Literal `import.meta.resolve()` is preserved only for explicitly external Node.js ESM specifiers or absolute browser URLs, using the emitted module as referrer.
Bundled, non-literal, browser relative or bare, and CommonJS cases fail with `import_meta_resolve` rather than resolving against a relocated caller.
`__filename` and `__dirname` are supplied only in CommonJS wrappers.
The linker derives module format from package metadata and parsed syntax rather than a file extension alone.

Top-level await is allowed in ESM output.
It is rejected when synchronous CommonJS `require()` would cross the await boundary.
Bundled modules follow these interop rules; preserved external edges retain the selected runtime's native namespace and require semantics, and incompatible external formats fail with `external_format` before publication.

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

A live non-external `import("./module.js")` creates a lazy chunk boundary under ESM splitting; a path-like external dynamic import instead targets the independently emitted entry described in section 23.1.1.
The returned promise must resolve to the expected module namespace.
Errors must remain asynchronous.

When splitting is disabled, a dynamic import requires the later lazy-module-wrapper implementation and otherwise fails with `unsupported_split`.
The module must not execute until the import expression runs.

A dynamic import whose containing code is removed by tree shaking must not force output.

### 15.3.1 Dynamic chunk runtime contract

The initial ESM implementation uses native browser or Node.js dynamic import to load a generated chunk.
It does not inject a JavaScript runtime loader.
The rewritten specifier resolves from the importing artifact's public URL and preserves the configured public path semantics.

Each dynamic edge maps to one manifest output record.
The record contains the importer, source range, resolved module identity, output path, public URL, and full artifact digest.
The dynamic chunk is not emitted when tree shaking removes its importing expression.

Chunk-load failures remain asynchronous promise rejections.
The bundler must not convert a failed load into a synchronous throw or a successful empty namespace.
The generated chunk must not execute before its dynamic import is evaluated.
Module evaluation and namespace caching follow the selected ESM runtime.

Dynamic chunks are not preloaded by default.
Preload generation is enabled only by an explicit option and must obey the public path, cross-origin, integrity, and CSP rules in section 15.6.

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

Chunk size is measured from uncompressed emitted JavaScript bytes after transforms and minification and before source-map sidecar bytes.
The initial overhead cap is the greater of 10 percent of that root's uncompressed JavaScript bytes and 32 KiB.
The cap is evaluated independently for every initial root and is recorded in normalized configuration and metadata.
Candidates below the configured threshold are considered in canonical chunk-path order.
The planner repeats consideration until no eligible merge remains.
The manifest and metafile record each considered candidate as `{candidate,into,addedBytesByRoot,reason}`, including rejected candidates with `into: null` and a stable reason.

### 15.6 Browser module preload

`--preload none` is the default.
`--preload static` emits `modulepreload` links only for statically reachable ESM chunks of HTML entries.
The initial release does not emit dynamic-import preloads.
Preload links are deterministic, deduplicated by final public URL, and inserted after the complete chunk plan is known.

Existing `crossorigin`, `referrerpolicy`, and `nonce` attributes are preserved where they originate from a source tag.
Generated preloads inherit only attributes from their owning module script; Knot invents neither a nonce nor an inline CSP hash.
Local SRI uses SHA-256 over final bytes, and external SRI remains unchanged.
If a generated URL or missing nonce cannot satisfy the source or configured CSP, `html_csp` fails before publication.

## 16. Output formats and targets

### 16.1 Browser ESM

Browser ESM is the default and the only browser output format in version 1; browser CommonJS fails with `unsupported_format` rather than emitting code that depends on an unavailable CommonJS runtime.
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

Node.js ESM output uses `.mjs` and Node.js CommonJS output uses `.cjs` by default, including chunks.
An explicitly configured Node.js `.js` artifact must resolve to `type: module` for ESM, or `type: commonjs` or null for CommonJS; no `package.json` is valid only for CommonJS, and every selected or absent scope is recorded in `configInputs.outputPackages`.
Knot neither generates nor modifies `package.json`; output-relative internal imports include the actual emitted extension.
Scope checks use the output layout Node.js will actually load, including a package manifest deliberately emitted among the generation's artifacts when present; a closer newly emitted manifest cannot be ignored in favor of an older ancestor.
External bare package imports remain bare and are resolved at runtime from the deployed output location.

### 16.3.1 Target baseline

The `browser` target means an evergreen browser with native ESM, dynamic import, URL resolution, and the browser APIs exercised by the acceptance fixtures.
The supported browser baseline is the exact Chromium build pinned by the repository toolchain until a versioned browser-target option is added.
The `node` target means Node.js 24 LTS semantics and built-ins.
The repository `toolchain.json` must pin the browser engine version and Node.js major version used for acceptance.
The selected baseline version is included in normalized configuration, cache keys, metafiles, and benchmark reports.
Running without the pinned browser for browser verification is an infrastructure failure, not a supported baseline.
The build must not inspect the host Node.js version to change target output.
Unsupported syntax or runtime behavior outside the selected baseline fails explicitly instead of receiving an implicit polyfill.

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

Duplicate JSON and JSONC keys are errors.
Malformed input fails with a source range and `syntax_error`.
JSONC accepts only `//` comments, `/* */` comments, and trailing commas in positions accepted by the JSON grammar.
JSONC does not accept identifiers, expressions, directives, or arbitrary JavaScript.

Data-loader modules expose only a default export; named imports fail with `missing_export`.
JSON and JSONC numbers outside the finite IEEE-754 range or the safe integer range fail with `data_number`, rather than silently losing integer precision.
The parsed value tree contains only null, booleans, strings, finite numbers including negative zero, arrays, and plain objects with own enumerable data properties.
Keys such as `__proto__` remain own data properties, not object-literal setters.

### 17.3 TOML and YAML

TOML uses TOML 1.0 syntax.
YAML uses YAML 1.2 core-schema scalars, mappings, and sequences without aliases, anchors, tags, custom types, merge keys, or implicit executable values.
TOML and YAML duplicate keys are errors.
Unsupported numeric forms fail with a source range; excessive nesting or aggregate values fail with `resource_limit`.
JSON, JSONC, TOML, YAML, and Web App Manifest parsing use `limits.dataDepth` and `limits.dataNodes`, counted during parsing before constructing the next value; these bounds are in the normalized `limits` object, not in a loader-name mapping.

TOML integers outside the safe JavaScript integer range and TOML `inf` or `nan` fail with `data_number`.
TOML offset date-times, local date-times, dates, and times become canonical ISO-style strings without host-timezone conversion.
YAML 1.2 core nulls, booleans, integers, and floats use the same finite safe-number policy.
YAML `.nan`, `.inf`, aliases, explicit tags including binary, merge keys, and implicit date coercion fail with `data_schema`.
Duplicate decoded keys fail with `duplicate_key`; source insertion order is retained, subject to JavaScript integer-index enumeration rules.
Binary bytes belong to the file loader; data and text files require valid UTF-8.

### 17.4 Text

The text loader exports a JavaScript string.
Source bytes must be valid UTF-8.
An initial UTF-8 BOM is removed before export.
Invalid byte sequences fail with an `invalid_encoding` diagnostic.

### 17.5 File assets

The file loader copies source bytes without transformation.
The browser file-loader export is the final public URL string.
For Node.js ESM, the export is the runtime string expression `new URL(relativeAssetUrl, import.meta.url).href`; for Node.js CommonJS, it is `pathToFileURL(join(__dirname, relativeAssetPath)).href` using `node:path` and `node:url`.
Both forms resolve after deployment relative to the emitted module and asset, never to the build machine or browser public path.

Asset identity includes source content, loader behavior, and naming settings.
Two inputs with identical bytes may share one emitted asset only when their public semantics are identical.
The manifest must retain every source-to-output relationship even when bytes are deduplicated.

Only `.json` accepts `with { type: "json" }`; the attribute is removed when bundling that JSON and preserved on external Node.js JSON imports.
Missing attributes for a known external JSON import, mismatched types, duplicate or additional attributes, and attributes on other loaders fail with `import_attribute`.
Loader selection uses the resolved filename extension before URL suffixes; `?raw`, `?url`, and other query conventions are not implicit loaders.
Queries or fragments on JavaScript, CSS, and data module specifiers fail with `import_suffix`.
File-loader specifiers may carry suffixes, which are preserved on the public URL but do not change the asset's source bytes or digest.

### 17.6 Explicit empty and external loaders

A declarative `empty` loader may replace a configured module with an empty namespace.
It must be explicit and appear in metadata because it can hide target incompatibilities.

An `external` loader preserves a runtime import without reading, parsing, or copying target bytes.
For a path-like JavaScript import, it may resolve target identity only to enforce the relocation rule in section 23.1.1.

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

A cycle of local CSS `@import` edges fails with `css_cycle` and reports the lexicographically first shortest canonical cycle; external imports are not part of that graph.

### 18.3 CSS transformations

The initial stable CSS pipeline supports:

- Standards-based parsing.
- Explicit target validation without implicit legacy lowering.
- Prefix decisions defined by the fixed version 1 compatibility matrix.
- Safe constant simplification only where cascade and fallback order remain unchanged.
- Whitespace and syntax minification.
- Source maps.

The browser target model must be explicit and shared with JavaScript output metadata.
JavaScript and CSS need not support identical legacy targets, but a build must report both effective target sets.

A Lightning CSS port or compatible design is preferred over inventing a second CSS semantics model.
License and maintenance implications must be reviewed before adopting source.

Version 1 targets the exact Chromium 153.0.8010.12 baseline pinned in `toolchain.json`; it does not consume Browserslist, a host CSS database, or arbitrary older browser versions.
The compatibility matrix is:

| CSS family | Version 1 syntax and prefix policy | Minification boundary |
| --- | --- | --- |
| Selectors, declarations, custom properties, `var()` | CSS Syntax Level 3 and syntax accepted by the pinned Chromium baseline; no synthetic prefixes | Remove redundant whitespace and safe delimiters only; retain selector and declaration order. |
| `@charset`, `@import`, `@layer`, `@namespace` | Preserve their standards-defined placement, nesting, and conditions; no synthetic prefixes | Never move or merge across rule boundaries. |
| `@media`, `@supports`, `@font-face`, `@keyframes` | Preserve rules accepted by pinned Chromium; do not generate legacy `-webkit-` rules | Remove redundant tokens without changing fallback and animation order. |
| Unknown non-executable at-rules | Preserve only when they contain no local asset or import edges | Do not minify internally. |

Sass, Less, Stylus, arbitrary PostCSS syntax, and unknown executable at-rules fail with `css_target`.
Parsing nested rules and functions is bounded by `limits.cssNestingDepth` per stylesheet; excessive nesting fails with `resource_limit` before recursive expansion.
Version 1 inserts no vendor prefixes and performs no browser-target downleveling because the sole supported baseline is the pinned Chromium build; adding an older browser target requires a separate versioned compatibility dataset, normalized setting, fixtures, and release pin.
Version 1 minification never merges rules, reorders declarations, evaluates custom properties, or substitutes values.
Custom property names, `var()` fallbacks, case, and cascade order are preserved without hashing or prefix mutation.
Any declaration not safely representable for the selected baseline fails with `css_target` instead of emitting a guessed transformation.


### 18.4 CSS Modules

Files ending in `.module.css` use local class and animation names by default.
The loader exports an object from original local names to generated class strings.

Generated names must be:

- Unique within the build.
- Stable across identical builds.
- Independent of worker order and absolute machine paths.
- Source-mapped where tooling expects original names.
- Configurable through a restricted naming template.

### 18.4.1 CSS Module naming and exports

The version 1 default local name is `_<local>_<hash>`.
`hash` is the first eight URL-safe base64 characters of SHA-256 over the project-root-relative POSIX path, a zero byte, the original local name, and the compiler version.
The prefix extends deterministically when two generated names collide.
Custom names must use only the original local name, normalized relative path, and content identity.

`:local(...)` and `:global(...)` scope only their contained selectors.
Bare local classes and bare local `@keyframes` names in `.module.css` are hashed; global selectors and keyframes remain unchanged.
Only unambiguously parsed local names in `animation-name` and `animation` are rewritten; ambiguous shorthand fails with `css_module_syntax`.
Custom properties and `var()` names remain unscoped, unhashed, and unexported.
`composes` accepts local names in the same file, a quoted relative `.module.css` file, or names `from global`; computed and package specifiers fail with `css_module_syntax`.
The default JavaScript export is a frozen, null-prototype object mapping each original local class to a space-joined string with its generated class first and transitive compositions in source declaration order, deduplicated by final generated name.
There are no named JavaScript exports or public array-valued exports.
Cross-file composition includes the stylesheet's CSS and asset edges; an unknown class fails with `css_module_missing`, and a composition cycle fails with `css_module_cycle`.
Conflicting CSS declarations retain source order and warn with `css_order`; Knot does not choose one winner.

### 18.5 CSS imported from JavaScript

A JavaScript entry that imports CSS produces one or more ordered CSS artifacts unless CSS is intentionally inlined by a later option.
The JavaScript artifact metadata lists every associated CSS artifact in load order.

Multiple JavaScript entries may share a CSS chunk only when enabling CSS chunking and preserving load order.
CSS chunking is disabled in the first implementation until multi-entry ordering fixtures pass.

The bundler must not inject styles at runtime because the product has no runtime helper for DOM mutation and separate CSS permits parallel browser downloads.

### 18.6 CSS assets

Local `url()` values are resolved relative to the containing stylesheet.
Fragments and query strings are preserved after path rewriting.
External HTTP(S) URLs remain unchanged; `javascript:`, `vbscript:`, and `file:` in `url()` fail with `css_url_scheme`.
Data URLs are never fetched and remain unchanged only for `image/png`, `image/jpeg`, `image/gif`, `image/webp`, `image/avif`, `font/woff`, and `font/woff2` MIME types within the asset limit; other data URLs fail with `css_url_scheme`.

Copied assets use the asset naming policy.
The CSS printer receives the final public URL before output hashing is finalized.

## 19. HTML bundling

### 19.1 HTML parser

HTML entry points must use a standards-aware parser or streaming rewriter.
Regular expressions are prohibited for document structure.

The parser must preserve doctype, comments, attribute quoting where practical, inline scripts and styles, template contents, and unknown elements.
It may normalize syntax only under a documented HTML formatting policy.

HTML5 tree construction determines recovery from malformed but parseable HTML, including implicit elements and misnested formatting tags.
Knot scans the recovered tree but retains original source text outside explicitly rewritten attributes and generated tags.
Unterminated quoted attributes or malformed URL escapes on supported references fail with `html_syntax`; exceeding `limits.htmlDepth` or `limits.htmlReferences` fails with `resource_limit` before the next node or edge is created.
Template contents are inert and not rewritten; supported local references inside a template fail with `html_template_reference` rather than publishing dangling URLs.
Inline SVG is preserved as foreign content; local `href` and `xlink:href` asset references are rewritten from the source document, while fragments and external URLs remain unchanged.
Local references in unsupported SVG or MathML URL-bearing attributes fail with `html_reference`; other foreign content is preserved without semantic rewriting.

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

HTTP(S), `mailto:`, protocol-relative, and fragment-only references remain external.
`javascript:`, `vbscript:`, `file:`, `ftp:`, and unknown explicit schemes in supported URL attributes fail with `html_url_scheme`.
`blob:` is preserved only for non-executable image and media attributes; script, stylesheet, preload, and manifest references using it fail with `html_url_scheme`.
Data URLs are never fetched and remain unchanged only in image and media attributes for `image/png`, `image/jpeg`, `image/gif`, `image/webp`, `image/avif`, `audio/mpeg`, `audio/ogg`, `audio/wav`, `video/mp4`, or `video/webm`.
Their decoded payload must fit `limits.assetBytes`, and malformed MIME, percent encoding, or base64 fails with `html_url_scheme`; executable `data:` payloads including HTML, SVG, JavaScript, CSS, manifests, and worker references fail with `html_url_scheme`.

### 19.2.1 Workers and non-script assets

`link[rel="preload"][as="worker"]` discovers and rewrites a local worker only when its bytes are copied unchanged as an asset.
A worker needing a module graph must be an explicit entry; a preload intended for that worker must resolve to the emitted worker entry or fail with `html_worker_entry`.
The bundler does not infer `new Worker()` graphs or synthesize service workers.

### 19.2.2 Web app manifests

A local `link[rel="manifest"]` loads a bounded UTF-8 JSON Web App Manifest as a graph node, not an opaque copied asset.
Malformed JSON, duplicate keys, unsafe URL schemes, or out-of-root paths fail with `html_manifest`.
Local `icons[].src`, `screenshots[].src`, and `shortcuts[].icons[].src` become copied asset edges and are rewritten relative to the final manifest URL using the same public-path and hash rules as HTML assets.
External URLs remain unchanged; unknown manifest members are preserved without invented asset edges.
The manifest's `id`, `start_url`, and `scope` are navigation identities, not asset files; rewrite their local relative forms to equivalent root-relative URLs only when the original document base and configured public origin determine the same origin and path.
If relocation or an ambiguous relative public path would change a navigation identity, fail with `html_manifest` rather than publish a broken manifest.
The final JSON uses canonical key ordering and UTF-8 encoding, and its final-byte digest participates in the HTML reference and SRI checks.


### 19.3 Script behavior

Module scripts become browser ESM roots.
Local classic scripts are copied byte-for-byte as classic-script assets and retain document order and `async` or `defer`; they are not transformed into ESM or IIFE.
A local classic script containing module declarations or top-level await fails with `html_script_format`.

Script attributes such as `async`, `defer`, `crossorigin`, `integrity`, `referrerpolicy`, and `nonce` must be preserved unless an output transformation has a documented reason to replace them.
Existing local `integrity` attributes are replaced with a SHA-256 SRI value over final referenced bytes; malformed or unsupported source integrity syntax fails with `html_integrity`.
Existing external integrity attributes remain unchanged.
Knot never invents a nonce or executable inline text and never changes source inline hashes.
When a source CSP meta policy or explicitly configured CSP policy disallows a rewritten script, stylesheet, or generated preload URL, the build fails with `html_csp` instead of weakening the policy.
Unsupported CSP syntax preventing this check also fails with `html_csp` when a URL changes.


Inline scripts and styles are preserved without parsing for build edges or changing their bytes.
An inline module script with a local import fails with `html_inline_import`; absolute external imports remain runtime imports.

### 19.4 Stylesheet behavior

Local stylesheet links become CSS roots.
The final `href` is rewritten to the CSS artifact.
Media, disabled, title, integrity, crossorigin, referrer policy, and nonce attributes are preserved.

Inline style elements are preserved by default.
An explicit extraction option may be added later.

### 19.5 URL rewriting

Local references without a `<base>` resolve relative to the physical HTML source file.
A nonempty `<base href>` is supported only when it is a normalized root-relative URL under the configured public path; the URL is applied before mapping the resulting local reference into the configured project root.
External, relative, duplicate, or otherwise unresolvable `<base href>` with local references fails with `html_base`; with no local references it remains unchanged.
Query and fragment suffixes attach to rewritten URLs and never select another source file.

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
- `[ext]` for the emitted extension without a dot.
- `[dir]` for the project-root-relative POSIX parent path including a trailing slash when nonempty.
- `[hash]` for the minimum content-identity prefix.
- `[hash:N]` for a prefix length `N` from 4 through 43 inclusive.

Separate templates exist for entries, chunks, CSS, and assets.
Source-map names always append `.map` to the owning artifact's final name.

Unknown tokens are configuration errors.
A template that can escape the output directory is rejected.

### 20.1.1 Default templates

Version 1 defaults are:

| Artifact | Template |
| --- | --- |
| Entry JavaScript and HTML | `[dir][name]` |
| Shared and dynamic chunks | `[name]-[hash]` |
| CSS | `[name]` |
| Copied assets | `[name]-[hash]` |

`[dir]` is empty for an entry at the project root, and paths outside the project root cannot use `[dir]` unless their package-relative identity is explicitly substituted.
The emitted extension is `.js` for browser JavaScript, `.mjs` for Node.js ESM, `.cjs` for Node.js CommonJS, `.css` for CSS, `.html` for HTML, and the preserved source extension for copied assets.
If a template omits `[ext]`, Knot appends `.<ext>`; if it includes `[ext]`, the template must supply its desired dot.
The normalized template cannot contain `..`, an absolute segment, or a path separator introduced by `[name]`.
Two artifacts with the same normalized output path are an `output_collision` error; CSS naming never silently adds a directory or hash.
Every output path is validated component by component under a verified output-root directory handle before creating staging files.
Empty components, `.`, `..`, NUL, absolute and drive/UNC roots, Windows reserved device names, and trailing spaces or dots on Windows fail with `invalid_path`.
File/directory conflicts, metadata collisions, and case-folded collisions on case-insensitive destinations fail with `output_collision`.
No component may be a symlink, junction, reparse point, or newly replaced non-directory ancestor; a changed root or path identity at commit fails with `path_traversal`.

### 20.2 Hash contract

The filename `[hash]` is a URL-safe unpadded base64 prefix of SHA-256 over a canonical filename identity: printed bytes before generated source-map trailers with each generated artifact URL represented by its canonical reference identity, the semantic map projection computed over those symbolic reference spans when maps are enabled, output target and format, public-path semantics, and relevant printer/minifier versions.
For a cycle, the reference identity is SHA-256 over ordered member identities, canonical printed symbolic bytes, and outgoing reference identities of its strongly connected chunk component; the component is computed before any path substitution.
The map semantic projection contains version, sourceRoot, sources, names, mappings against symbolic reference spans, and optional sourcesContent in final canonical order but excludes `file`, which depends on the owner's filename.
This filename identity is distinct from the manifest `digest`, which is SHA-256 over the complete final published artifact bytes encoded as RFC 4648 padded base64.
`[hash]` starts at eight characters and `[hash:N]` starts at `N` characters; conflicting truncated names with different full identities all extend one character at a time until unique.
Equal filename identities may share a physical artifact only when their complete final bytes and public semantics also match; otherwise the build fails with `output_collision`.
Map names derive from the owner's final name with `.map`; compute symbolic identities, resolve all names and collisions, substitute final URLs, then recompute final map segments and `file`, trailer, and final byte digests without a hash fixed point.
A collision with a non-hash template, metadata, or map path fails with `output_collision`, never a scheduling-dependent counter.

### 20.3 Public path

The public path prefixes emitted references from JavaScript, CSS, and HTML.
It may be a relative path, root-relative path, or absolute URL.
The prefix must not contain a username, password, query, or fragment; credential-bearing and signed URLs fail with `invalid_option` instead of entering generated artifacts or `complete.json`.

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

Every emitted map uses source-map version `3` and contains `file`, `sourceRoot`, `sources`, `names`, `mappings`, and optional `sourcesContent`.
`file` is the owning output-relative artifact path.
`sources` are canonical project-relative or package-relative paths with forward slashes.
`sourceRoot` is empty unless a normalized configuration explicitly supplies a relative root.
`mappings` is the canonical VLQ string produced from ordered generated segments.
`sourcesContent` follows the normalized `sourcesContent` policy and is omitted rather than populated with host paths.
Inline maps use the same schema after base64 encoding.

A map is correct only when real Node.js, browser, and CSS tooling can map breakpoints and errors to the expected source locations.

`none` emits neither a map nor a comment; `linked` emits a `.map` and one relative percent-encoded `sourceMappingURL` basename trailer; `external` emits the same `.map` without a trailer; `inline` emits no sidecar and appends one base64 `data:application/json;charset=utf-8` source-map trailer.
The trailer uses the JavaScript or CSS comment syntax of its owner and is its last non-whitespace content.
Linked map URLs contain no absolute paths, public-path guess, query, or credentials.
Input maps must pass bounded JSON, VLQ, segment ordering, and ECMA-426 source-path validation before composition; malformed, out-of-root, and remote map URLs fail with `invalid_source_map` without a network request.
Sources use project-relative or package-identity-relative POSIX paths; names preserve original identifier spellings where valid, sorted by first mapped occurrence with stable ties.
An original source outside those roots fails with `source_map_path`.
`sourcesContent: exclude` omits the field even when input maps contain content.
`include` embeds only validated original UTF-8 source bytes from the project root or frozen installed package graph, never virtual, remote, generated, or out-of-root content; unavailable or disallowed sources fail with `source_map_content`.
Changes to source mappings, names, source identity, or embedded content alter the symbolic map semantic projection, map bytes, map digest, and a hashed owner's filename; changes only to generated URL spelling or resulting generated offsets change final map and artifact digests but not their semantic filename identity.

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
Definitions are public build literals and may be printed into generated JavaScript; credentials must not be supplied through `--define` or declarative build configuration.

Dropping `console` calls also drops argument evaluation under Bun-compatible behavior.
Because this can remove side effects, diagnostics and documentation must state it clearly.
Dropping `debugger` removes debugger statements without changing surrounding control flow.

`--define` accepts assignments of the form `identifier-or-property-path=literal`.
The left side is an ASCII identifier followed by zero or more dot-separated identifiers.
The right side is `null`, `true`, `false`, a finite JSON number, or a JSON string with JSON escapes.
Arrays, objects, calls, operators, environment expansion, and arbitrary JavaScript expressions are invalid.
The replacement is applied to matching syntax nodes before reachability analysis; actual definition values enter the private execution request and semantic `configDigest`, while `--show-config` masks every definition value.

`--drop debugger` removes debugger statements.
`--drop console` removes calls whose callee is the unshadowed global `console` object.
`--drop <qualified-name>` removes only direct calls whose statically resolved callee matches the normalized qualified name.
An invalid or shadowed drop target is a configuration or resolution error and is never treated as a global side-effect-free function.

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

An external bare package or Node.js built-in specifier stays unchanged and is resolved at runtime from the deployed output location.
A path-like external JavaScript import is instead subject to the section 23.1.1 emitted-target rule; if the selected output format cannot represent an external edge, the build fails rather than inventing a global.

External patterns use this grammar:

- `name` matches one exact package name.
- `name/subpath` matches one exact package subpath.
- `name/*` matches any subpath below that package.
- `./` or `/` prefixes match normalized project-relative or absolute paths.

The initial release does not support negated patterns, regular expressions, or unescaped wildcard characters in package names.
Patterns are matched against the original specifier before resolution and against the canonical resolved identity after resolution.
The first matching explicit `--external` pattern wins in command-line order.
Package policy is applied only when no explicit pattern matched.

Aliases are exact original-specifier matches after original-specifier explicit external matching and before package resolution.
An alias to `false` selects an explicit empty module; a path target stays inside the project or permitted workspace root; a bare target resolves from the original importer with lockfile dependency visibility unchanged.
Only one alias replacement is allowed; a repeated match or cycle fails with `invalid_alias`, never an alias chain.
Resolved-path external matching follows alias and resolution; the alias and external rule are recorded separately.

### 23.1.1 Resolution precedence and conditions

The bundler delegates package resolution to the shared Knot resolver.
It must not implement a second package-resolution algorithm.

For every package, `exports` is evaluated before `main`, `module`, or other legacy entry fields.
Package `imports` is evaluated for internal `#` specifiers before filesystem fallback.
Package self-references use the same `exports` map as external package references.
An absent matching `exports` or `imports` target is an error and must not silently fall through to an unrelated path.

The active condition names are `browser`, `import`, explicit user conditions, `default` for browser ESM; `node`, `import`, user conditions, `default` for Node.js ESM; and `node`, `require`, user conditions, `default` for Node.js CommonJS.
At each nested conditional `exports` or `imports` object, properties are tested in declared JSON key order and the first active property wins; `default` matches at its declared position.
Condition names are case-sensitive; repeated explicit conditions are deduplicated by first occurrence, and built-in names cannot be removed.
The normalized record lists active sets, while edge metadata records the selected branch sequence and original package key order.

String `exports` targets must begin with `./`, remain within the package root after normalization, and resolve to an existing file without extension or directory probing; `imports` may also target a locked package bare specifier.
Absolute paths, traversal, invalid percent escapes, unsupported URL schemes, and non-string scalar targets fail with `invalid_package_target`.
A `null` target blocks the subpath with `package_export`.
Array targets are visited left to right, selecting the first resolvable valid target; a blocked `null` or invalid target fails immediately, and no successful target fails with `package_export`.
Nested condition and array evaluation is bounded by `limits.packageTargetDepth`, initially 64 frames; excess depth fails with `package_export` and reports the configured limit.
For packages without `exports`, browser targets try the browser field's string entry, then `module`, `main`, and `index`; Node.js ESM tries `module`, `main`, and `index`; Node.js CommonJS tries `main`, then `index`.
An absent field or nonexistent candidate advances to the next candidate, but an invalid path, unsupported format, or blocked browser mapping fails without advancing.
A browser-field object substitutes an exact relative package path or bare dependency specifier before legacy probing; `false` selects an explicit empty module, object substitutions cannot chain, and no browser-field replacement overrides a selected `exports` target.
All selected paths remain inside the package root and use the same bounded file probing below.
Relative project imports try the exact named file first, then `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.json` in that order, then the same extensions under `index` for an explicit directory.
An explicit extension is never substituted except local `.js` to `.ts` and `.jsx` to `.tsx` when the generated output location is identical.
Path-like external JavaScript specifiers, including static and dynamic ESM imports and literal CommonJS `require()` calls, must identify an exact target file with an explicit runtime extension; no directory or extension probing applies, except the documented local `.js` to `.ts` or `.jsx` to `.tsx` substitution when the output identity is unchanged.
Resolution determines only the target identity and validates permitted roots; external matching never reads or bundles its bytes.
The target must also be independently rooted and emitted as a JavaScript artifact in the same generation, with a runtime-compatible extension and format, before the external edge is accepted.
The linker rewrites the external specifier relative to the emitted importer's final path and the emitted target's final path, preserving supported import attributes; metafile `edges.output` names that target artifact.
A dynamic external edge uses a separate entry rather than a synthetic lazy chunk; it still requires `--splitting`, remains a runtime `import()`, and uses the manifest's `external-entry` target kind.
An absent, non-JavaScript, incompatible, or un-emitted target fails with `external_format` before publication; Knot neither copies it implicitly nor leaves a relative specifier pointing into the source tree.
Absolute browser URLs, bare package specifiers, and Node.js built-ins keep their existing external behavior; generated relative specifiers always start with `./` or `../` and use forward slashes.
Every candidate is recorded as a positive or negative resolution dependency.


The resolver records the effective condition order in normalized configuration and edge metadata.
The browser field may replace or exclude a package path only for the browser target and only after `exports` has been considered.
Node.js built-ins remain external in Node.js output.
Browser output rejects a reachable built-in unless an explicit external rule or alias supplies its behavior.

External matching is applied first to the original specifier and then to the resolved identity.
An explicit `--external` rule has precedence over package policy.
`--packages external` applies when no explicit rule matched and preserves the original bare specifier.
The selected rule and the match phase are recorded on the edge.

Every package lookup starts from the importing lockfile package identity and peer-context snapshot, never an ancestor `node_modules` scan.
Missing required peers, undeclared dependencies, missing optional snapshots when imported, broken workspace links, and lockfile/manifests that disagree fail with `package_graph` naming the importer and specifier.
An optional dependency absent from the installed frozen graph may remain absent until imported; importing it is an error, not a network request.
An `npm:` alias is accepted only when the alias name is already an installed locked dependency; the lockfile's target package and peer context define its identity.
Workspaces resolve by declared name to locked workspace identities, with `workspacePackages: bundle` by default and `external` explicitly preserving bare names.
With `preserveSymlinks: false`, physical paths identify files but package and peer-context identities remain distinct; with `true`, logical link paths are distinct even when physical targets coincide.
Both modes reject links escaping the project, installed package graph, or permitted workspace roots with `symlink_escape`; no symlink launders an undeclared dependency.

### 23.2 Package externalization

`--packages external` leaves bare package imports external while continuing to bundle relative and absolute project imports.
This mode is useful for Node.js libraries and services.

Workspace packages are source packages and bundle by default, even under `--packages external`.
`--workspace-packages external` leaves their bare specifiers to the runtime, while the frozen graph still validates their identities.

### 23.2.1 Package identity and lockfile integration

Every resolved package identity contains its name, version, integrity, lockfile locator, package-root identity, and peer-context identity when applicable.
The package-manager lockfile digest is part of the normalized configuration and every resolved-edge cache key.
The bundler may read the installed package graph and content store but must not mutate them or resolve a package version outside the frozen lockfile.
Workspace symlinks retain their package identity while their resolved source path remains canonicalized under the configured symlink policy.
Two package instances with different peer contexts remain distinct even when their package paths are identical.

The normalized `library` object has `exports`, a map of public subpath keys (`.` or `./name`) to canonical source entry paths, and `packageJson`, a canonical `package.json` path or null.
`--library-exports` sets `packageJson`; `[build.<name>.library]` supplies either field.
A nonempty `exports` map requires Node target, `--packages external`, and one explicit format per invocation; every listed source must be an entry and each public subpath must map to one planned output.
When `packageJson` is set, Knot reads its `exports` and `type`, records its byte digest, and requires the selected `import` or `require` branch for each configured subpath to equal the generated output path with compatible extension and package type.
Missing, extra, or incompatible selected public exports fail with `library_exports` before publication; other target/format branches are validated by their own builds.
Knot does not create or edit the author's `package.json`, build both formats implicitly, or emit declarations.

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

### 24.3 Canonical record schemas

All machine-readable records are UTF-8 JSON documents.
The top-level `version` field is an integer schema version and is independent of the Knot tool version.
Unknown required fields and unsupported schema versions are errors.
Optional fields may be added only when consumers can ignore them without changing interpretation.

The deployment manifest has exactly the required top-level keys `version`, `entries`, `outputs`, and `mergeDecisions`.
`entries` maps each canonical source-entry identity to an output-relative path.
`outputs` maps every application output-relative path, including sidecar maps, to the following record; self-referential manifest, metafile, completion, and pointer records are excluded from this map and from application byte budgets.

| Field | Required type and meaning |
| --- | --- |
| `kind` | `js`, `css`, `html`, `asset`, or `map`. |
| `bytes`, `digest` | Nonnegative final byte count and full SHA-256 over final published bytes in padded RFC 4648 base64. |
| `entry` | Canonical entry identity or `null` for a non-entry artifact. |
| `publicUrl` | Final URL of the file under the configured public path, separate from its physical path. |
| `sourceMap` | Output-relative map path, `"inline"` for inline maps, or `null` for none; map outputs always use `null`. |
| `imports` | Ordered array of `{kind,output,publicUrl}` for static artifact relationships; `kind` is `static`, `preload`, or `css-import`. |
| `exports` | Ordered array of public JavaScript export-name strings; empty on other kinds. |
| `css` | Ordered array of distinct output-relative CSS paths in actual load and cascade order, never a scalar. |
| `dynamicImports` | Ordered array of `{importer,source,range,resolved,output,publicUrl,lazy,targetKind}`. `lazy` is always true. `targetKind` is `lazy-chunk` when `output` names a retained dynamic chunk, or `external-entry` when a path-like external import names an independently emitted JavaScript entry; in the latter case `resolved` is that entry's canonical identity and `entries[resolved]` equals `output`. Both kinds refer to an existing `outputs` key and retain runtime `import()` behavior. |
| `assets` | Ordered array of `{source,output,publicUrl,bytes,digest}`; each source-to-output relationship remains even when output bytes are shared. |
| `references` | Ordered array of `{kind,source,range,originalUrl,output,publicUrl}` for rewritten local HTML references. |

All fields are present, with empty arrays when no relationships exist.
`mergeDecisions` is an ordered top-level array of `{candidate,into,addedBytesByRoot,reason}`; rejected candidates have `into: null` and a stable reason, and `addedBytesByRoot` maps each affected root to nonnegative byte counts.
Bare package, built-in, and external URL references are not output edges and are recorded only in the metafile; a path-like external JavaScript reference mapped to a separately emitted target in section 23.1.1 is an output relationship in both records, using `imports` for static edges and `dynamicImports` with `targetKind: external-entry` for dynamic edges.
A CSS artifact needed only by a lazy chunk belongs to that lazy output's `css` array, not the initial importer's array.
Every non-null output path in a relationship, map association, or `entries` value is a key of `outputs` and exists in the completed generation.
Map outputs have `entry: null`, `sourceMap: null`, and empty relationship arrays.
All paths use output-root-relative POSIX segments; source identities use canonical project-relative or lockfile package identities, or section 10.1's machine-local pseudonyms for nonportable inputs, never host paths.
Ranges use zero-based UTF-8 byte offsets, one-based lines and UTF-16 columns, and half-open ends in the original source.
Collections with evaluation or cascade semantics preserve that order; other arrays sort by canonical identity, source start, and output path.
Manifest serialization uses lexicographically sorted object keys, canonical UTF-8 JSON without insignificant whitespace, and one terminal LF.

The metafile has exactly the required top-level keys `version`, `toolVersion`, `configDigest`, `portable`, `inputs`, `edges`, `modules`, `removed`, `outputs`, `chunks`, `mergeDecisions`, `cache`, `timings`, `execution`, and `warnings`.
`toolVersion` identifies the Knot binary, `configDigest` is section 10.1's portable semantic digest, and `portable` is its boolean portability marker.
Nested schemas are:

| Collection | Required nested fields and constraints |
| --- | --- |
| `inputs` | Map identity to `{loader,format,bytes,digest,package,imports,exports,sideEffects}`. `package` is a lockfile identity or null. `imports` is an array of edge indices; `exports` contains names; `sideEffects` is `{state,basis}` with state `known-effectful`, `proven-pure`, `annotation-pure`, or `unknown` and basis `compiler`, `package`, `configuration`, or `conservative`. |
| `edges` | Ordered array of `{importer,kind,specifier,range,resolved,conditions,lazy,externalRule,output}`. `kind` is any kind from section 12.2, `resolved`, `externalRule`, and `output` may be null; `conditions` is ordered by actual decision branch; each index is stable in the canonical array. A path-like external edge mapped to an emitted target records that output, while bare and URL externals have null output. A successful generation has no unresolved required edge. |
| `modules` | Map module identity to `{input,format,package,imports,exports,retainedParts,removedParts,outputs}`. `input` exists in `inputs`; `imports` are edge indices; part IDs are disjoint nonnegative module-local integers; `outputs` are emitted output paths. |
| `removed` | Ordered array of `{module,part,reasons,retainedEffects}`. `module` and `part` identify an existing removed module part; `retainedEffects` is boolean; `reasons` is a nonempty subset of `compiler-proof`, `package-metadata`, `pure-annotation`, `explicit-configuration`. |
| `outputs` | Map output path to every required field of the corresponding manifest `outputs` record, plus `contributions`. The extra field maps input identities and reserved `$generated` to nonnegative emitted byte counts whose sum equals final `bytes`; `publicUrl`, `dynamicImports`, `assets`, and `references` must match the manifest, not be inferred from paths. |
| `chunks` | Map emitted chunk path to `{roots,modules,imports,exports,bytes,digest}`; roots and members use canonical identities and every referenced emitted path exists in `outputs`. |
| `mergeDecisions` | Same ordered candidate decision records as the manifest, including rejected candidates that have no emitted chunk path. |
| `cache` | Map each cache layer name to `{hits,misses,invalid,keys}`. Counters are nonnegative; `keys` contains ordered `{key,result}` with result `hit`, `miss`, or `invalid` and only non-secret full cache-key digests. `invalid` is a rebuilt corrupt lookup and counts separately from `misses`. |
| `timings` | Map `scan`, `resolve`, `load`, `parse`, `transform`, `link`, `shake`, `chunk`, `css`, `html`, `print`, `map`, `hash`, `write`, `cache`, `total` to nonnegative monotonic elapsed microseconds; unentered stages are zero, and overlapping stage totals need not sum to wall time. |
| `execution` | `{requested,selected,device,workers,stages,fallbacks}`. `requested` is `cpu` or `gpu`, `selected` is `cpu`, `metal`, or `cuda`; `device` is null for CPU; `workers` is positive; `stages` maps entered stage names to actual backend; each fallback is `{stage,from,to,reason}`. |
| `warnings` | Ordered array of complete version 1 diagnostic records, never strings. |

The manifest is deterministic byte-for-byte for identical semantic inputs and configuration.
The semantic metafile projection excludes `cache`, `timings`, `execution`, and volatile watch-generation data; those observational values may differ between clean and cache-hit builds.
For `portable: true`, determinism checks compare that projection, manifest, output bytes, and stable diagnostic identities across project relocations and supported backends, not raw elapsed-time records.
For `portable: false`, the same comparison applies only with identical machine-local paths and dependencies.
`knot analyze` emits a version 1 object with `configDigest`, `portable`, ordered `entries`, `modules`, `edges`, `chunks`, `outputs`, `budgets`, and `warnings`; it describes plans and estimated sizes without inventing emitted digests or claiming activation.

### 24.4 Budget checks

Version 1 budgets use uncompressed final application-artifact bytes, excluding manifest, metafile, completion, and pointer records; maps are included in `totalBytes` and associated with their owner for route calculations.
`entryJsBytes` limits each emitted JavaScript entry; `lazyChunkBytes` each lazy JavaScript chunk; `cssBytes` each CSS output; `assetBytes` each copied asset.
`initialRouteBytes` limits each HTML entry's own bytes plus its transitively reachable eager JavaScript, CSS, and local asset bytes, counting a shared artifact once per route and excluding lazy chunks.
`totalBytes` limits the sum of all emitted application and map output bytes, counting shared files once across all entries.
`baseline` selects a validated version 1 manifest for comparison, and `maxIncreaseBytes` limits the signed increase in the current `totalBytes` over that baseline's same artifact set; a missing baseline or incompatible schema fails with `invalid_option`.
Budget checks occur after artifact planning and final byte measurement but before `complete.json` or output activation.
Version 1 does not report gzip or Brotli estimates; adding them requires a pinned compression algorithm and settings in normalized configuration.

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
A cache payload is canonical for its layer:

| Layer | Payload |
| --- | --- |
| Source content | UTF-8 bytes, encoding, line index, and content digest. |
| Parsed or transformed IR | Versioned immutable module records with canonical integer identities. |
| Resolution | Ordered resolved identity, conditions, package identity, and external decision. |
| Linked graph | Canonical modules, symbols, parts, edges, roots, and removal reasons. |
| Chunk plan | Ordered chunk identities, membership, imports, exports, and merge decisions. |
| Printed artifact | Final bytes, source-map bytes or identity, output identity, and full digest. |
| Copied asset | Source identity, emitted bytes or content digest, output path, and public URL. |

Layer names are `source`, `parse`, `resolve`, `transform`, `link`, `chunk`, `print`, and `asset` in the order above.
Keys are SHA-256 over a length-delimited canonical tuple prefixed by cache schema and layer name, never ambiguous concatenated strings.
All layers include their producing schema version and transitive declared extension binary, permission, and configuration identities when an extension contributes.
The `source` key includes canonical source identity, content digest, encoding, and line-index algorithm; mtime and inode alone never authorize reuse.
The `parse` key includes source digest, compiler/IR schema, loader, grammar mode, and TypeScript/JSX parse flags, but not output naming.
The `resolve` lookup key includes importer context, original specifier, attributes, active conditions, target, symlink policy, package and lockfile digests, aliases, external policy, resolver version, and workspace/peer context; it does not include the selected branch or lookup outcome.
The cached result stores the selected branch, positive and negative candidates, and consulted metadata as dependencies; a hit revalidates each mutable filesystem and package candidate before reuse, so a negative lookup cannot hide a newly created file.
The `transform` key includes parsed IR identity, compiler schema, target baseline, JSX lowering, define digests, drop rules, and local minification.
The `link` key includes reachable transformed IR and resolved-edge identities, roots, target baseline, format, interop and side-effect policies, and linker version.
The `chunk` key includes linked identity, roots, retained parts, splitting, CSS ordering, preload and merge settings, and planner version.
The `print` key includes chunk identity, target baseline, printer/minifier/map versions, format, output names, public path, map mode, and referenced artifact identities.
The `asset` key includes source digest and allowed-root identity, loader, target-specific asset semantics, naming, and public path.
CPU and GPU records share a key only after byte-equivalence for that stage is established; otherwise backend identity is in that stage and downstream key, and automatic GPU use is disabled.
Undeclared extension effects make affected records and descendants non-cacheable.
Changing naming does not invalidate parse or local transform records; changing a relevant lockfile, peer context, baseline, or source invalidates dependent downstream layers.


### 25.1 Cache record envelope

Each record is a single file with eight ASCII magic bytes `KNOTBC01`, a big-endian unsigned 32-bit JSON header length, that many canonical UTF-8 JSON header bytes, a big-endian unsigned 64-bit payload length, exactly that many payload bytes, and no trailing bytes.
The header has exactly `{version,kind,key,toolVersion,dependencies,portable,payloadDigest}`; the payload is framed bytes, not a duplicate JSON field.
`version` is integer `1`; `kind` is one of the eight layer names; `key` and `payloadDigest` are complete padded base64 SHA-256 values; `dependencies` is an ordered array of `{kind,identity,digest}`.
The key domain includes schema version, kind, portability, and producer schema identities.
The record path is `<cache.directory>/v1/<kind>/<first-two-lowercase-hex-key-digits>/<full-lowercase-hex-key>.record`; caller strings never become path components.
Before allocation or decoding, reject a header above 1 MiB, total record above `maxRecordBytes`, unsupported versions, noncanonical JSON, invalid key path or dependencies, incorrect exact file length, and mismatched payload digest.
Validate layer payload types, lengths, graph indices, source identities, paths, and portable-path policy; source records rehash their payload and compare it with the current source snapshot, and every cached artifact passes normal publication validation.
The digest detects accidental corruption, not a writer able to forge both payload and metadata; private cache ancestry must exclude untrusted writers, and builds under a principal shared with an adversary must disable persistent caching or isolate that principal.
Corrupt or incomplete records become misses, with one `cache_corrupt` debug diagnostic per key, never published output.
Cache files use POSIX mode `0600` and directories `0700`; Windows ACLs grant only the build principal and required system principals.
Reject symlink, junction, reparse-point, or shared-writable cache ancestry.
Create temporary records exclusively with owner-only permissions in the same directory, flush them, and atomically publish without replacement; readers open only the validated final record.
Machine-portable payloads contain no absolute source paths and machine-local records explicitly set `portable: false`.

### 25.2 Cache policy and concurrency

The normalized `cache` object contains `mode` (`read-write`, `read-only`, or `disabled`), `directory`, `maxBytes`, `maxRecordBytes`, and `portable`.
The default mode is `read-write`.
The default maximum cache size is 4 GiB and the default maximum record size is 512 MiB.
The configured directory is canonicalized and checked for safe ownership before use; its absolute location does not enter semantic cache keys or portable metadata.

Eviction runs only after a successful build and only when the cache exceeds `maxBytes`.
It removes least-recently-used complete records, with canonical key order as the tie breaker.
It never removes a record currently held open by a reader or writer.
`read-only` mode never mutates records or eviction metadata.
`disabled` mode neither reads nor writes cache records.

Concurrent writers write a temporary record and publish it with an atomic no-replace operation.
If another writer wins the same key, the loser validates the winner and discards its temporary record.
Cache cleaning takes a lock that excludes record deletion but does not invalidate an active build.
Interrupted locks are recoverable only after owner identity and liveness checks; an unverified lock is retained and reported as `cache_busy`.

`knot clean --build-cache` addresses only the configured build cache and never traverses symlinks, junctions, or reparse-point descendants.
Cleaning takes the maintenance lock, snapshots complete records, and deletes only records without an active reader or writer lease.
An active build may continue using open validated records and publishing new records; cleaning must not block output activation or remove the package store, lockfile, active output generation, or unrelated files.
A lock records host, PID, process start identity, and unpredictable nonce; liveness must match process start rather than PID alone.
An unverifiable owner or unsupported locking filesystem yields `cache_busy` without breaking the lock.
A failed cache write in `read-write` mode continues uncached with a debug diagnostic; `read-only` and `disabled` never write.

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

`package.json`, `tsconfig.json`, `knot.toml`, `knot.lock`, symlink, directory, and extension changes must invalidate their dependent decisions.

A failed rebuild keeps the previous successful generation unless `--clear-on-error` is set.
Diagnostics must state that outputs are stale.

Long-running contexts must release unreachable source generations, AST arenas, graph nodes, and artifact buffers.
A no-op rebuild must not grow retained memory.

### 26.1 Watch lifecycle and concurrency

Each rebuild receives a monotonically increasing generation number.
Only the newest generation may activate.
An older generation may finish pure work, but it must discard staged output when a newer generation has superseded it.

Events are coalesced for 50 ms after the most recent relevant event, capped at 200 ms after the first; both values are recorded in normalized configuration.
The watcher must process create, modify, close-write, rename, delete, directory, symlink, package metadata, lockfile, and configuration events.
Duplicate events for one path and generation are collapsed before invalidation.

At most one generation owns publication for a build context.
A new change during publication waits for the activation decision and then starts from the activated generation.
Cancellation must terminate child work, release temporary resources, and preserve the last successful generation.

`--clear-on-error` activates an explicit empty-generation tombstone after reporting the failure; it never deletes an unowned file or an artifact still held by a reader lease.
Without that flag, consumers continue to see the previous complete generation and diagnostics identify it as stale.
Closing a watch context explicitly stops event delivery, cancels pending work, closes host handles, and exits 0 unless the context itself failed; signals use section 26.1's statuses.

An event without a reliable filename, queue overflow, watcher restart, or directory rename discards queued path hints and triggers a complete tracked-dependency-directory rescan, including negative lookup parents, before further publication; `watch_overflow` reports a queue overflow once per rescan.
The rescan uses content digests and package/config identities, not timestamps alone.
When native watching is unavailable or unreliable, polling every `watchSettings.pollIntervalMs` scans all tracked dependency directories; registration failure switches that directory to polling with `watch_unavailable` or fails the context when polling cannot cover it.
The 100 ms notification-latency target applies to native event delivery; polling latency is separately reported and does not masquerade as a passing native-watch result.
An active build superseded by changes finishes no activation and queues one new generation.
SIGINT and SIGTERM stop intake, cancel uncommitted work and extension process trees, remove owned staging, release locks, and exit 130 and 143 respectively; a second signal terminates promptly.
If a signal arrives after the atomic activation point, recovery treats the new generation as committed.
Explicit watch-context close without a signal exits 0 after cleanup; readiness is reported only after initial success or diagnostic failure.

## 27. Atomic output publication

An `--outdir` output root is a managed generation container on one filesystem, not a collection of files overwritten in place.
`generations/<opaque-id>/` contains immutable complete artifacts and `complete.json`; `active.json` is the single atomically replaced active-generation pointer.
No source or extension path may name `active.json`, `previous.json`, `complete.json`, `gc.lock`, `leases`, or the managed generations directory.
All planned paths, including metadata and map paths, are validated before writing; staging on another volume is `publication_error`, not a copy-and-swap fallback.
`complete.json` is canonical JSON `{version:1,generation,configDigest,toolVersion,target,format,publicPath,tombstone,outputs:[{path,bytes,digest}]}`, with output paths sorted and relative to the generation root, byte sizes as nonnegative integers, and padded base64 SHA-256 digests; `tombstone` is false for a successful build and true only for an empty-generation clear-on-error record with no outputs.
`active.json` is canonical JSON `{version:1,generation,completeDigest}`, where `completeDigest` hashes the exact complete-record bytes; it is written to an exclusive temporary file before atomic replacement.
`previous.json` contains the same versioned pointer schema for the last validated active generation immediately before activation, and is flushed according to policy.

The default `output.durability: full` flushes every artifact and metadata file, completion record, generation directory and parent, pointer file, and pointer parent before reporting success.
`data` flushes files and pointers but may skip directory metadata flushes; it guarantees process-crash visibility, not power-loss persistence.
If the selected mode cannot perform a required flush or atomic pointer replacement, publication fails with `publication_error` instead of reducing durability silently.
The activation linearization point is replacement of `active.json`: failures before it leave the previous pointer; failures after it leave the new pointer, subject to recovery validation.
A post-commit flush failure reports `publication_error`, keeps both generations and the pointer, and lets recovery validate the committed selection without a guessed rollback.
On startup, validate `active.json` and its completed generation; if invalid, recover only the validated generation named by `previous.json`, otherwise expose none and report `publication_recovery`.
Complete orphan staging is never selected just because it exists; incomplete or invalid staging is ignored and removed only after ownership validation.
Retired generations remain until all deployment/read leases release them; garbage collection deletes only generations named in the output root's verified ownership index and unprotected by a live lease.
`--clear-on-error` atomically replaces the active pointer with a completed, explicit empty-generation tombstone after reporting failure, then retires previously owned artifacts when no leases remain.

The shipped static-deployment reader is `knot snapshot`, specified in section 27.2; it pins one verified active generation and exports only its listed artifact bytes into a new immutable destination.
An external HTTP server serves that exported directory as its document root, not the managed `--outdir` root; Knot does not start a server.
With one live release, a static server may expose a single export after deployment switches its document root atomically.
For overlapping releases, the operator must build with a distinct immutable `publicPath` for each release, route each old and new URL prefix to its retained export, and retire an export only after old page and asset requests drain.
Without such URL versioning, the operator must wait for old traffic to drain before switching the document root; merely reusing the same artifact URL across overlapping generations is not snapshot pinning.
Public URLs name files inside the selected export; Knot does not expose managed generation directories at those URLs implicitly.
Windows uses the same pointer scheme as POSIX and requires neither replacement of a populated directory nor junction swaps.
`--outfile` is limited to a single artifact and instead uses an exclusive same-directory temporary file and one atomic replacement of the named file; it cannot use multi-artifact manifest, maps, or generation pointer publication.
`--write=false` validates into temporary storage without changing a pointer or named output.

Fault injection covers every write, map, manifest, flush, completion, pointer temp, pointer replacement, parent flush, process death, recovery, and garbage-collection boundary on POSIX and Windows.
At every boundary, a pointer-aware consumer sees one complete prior or new generation, or a validated empty tombstone, never mixed artifacts.

### 27.1 Publication ownership

An output root has at most one active publishing process.
The publisher acquires an exclusive ownership lock in the verified root containing canonical output-root identity, host identity, PID, process start identity, unpredictable nonce, generation identity, and the private `executionDigest`.
Another process targeting the same root fails before staging activation with `publication_busy`.
Watch generations in one process use the context ownership rule instead of taking a second process lock.

A lock is stale only when the same-host PID and matching process-start identity are proved dead, or the owner host has been positively fenced by deployment infrastructure; elapsed time is not proof.
Take a proven stale lock with an atomic compare-and-replace of nonce and root identity; an unverifiable or changed record stays locked with `publication_busy`.
Root, parent, and pointer identities are checked through no-follow handles at commit; a symlink, junction, reparse point, or redirected component fails with `path_traversal`.
Recovery verifies completion and pointer digests before deleting any owned staging or retired generation, never unowned files.

### 27.2 Snapshot reader, leases, and export

`knot snapshot` accepts a verified managed `--outdir` root and an absent `--to` path; an existing path, symlink, junction, or reparse-point component fails without overwrite.
The publisher's long-lived ownership lock is distinct from a short-lived, process-released advisory `gc.lock` on the verified root; a filesystem without reliable interprocess locking fails with `publication_busy` rather than publishing or exporting.
Under `gc.lock`, the reader validates the root and active pointer through no-follow handles, validates the completed generation and all declared relative paths, then creates `leases/<generation>/<nonce>` exclusively before releasing the GC lock; it verifies artifact bytes and digests while holding that lease.
The publisher also holds `gc.lock` when replacing `active.json` and when recording the retired generation; it does not hold this lock throughout a build or exported-copy operation.
Each owner-only lease records root identity, generation, host, PID, process-start identity, and unpredictable nonce; only the creating process or a positively fenced recovery agent can remove a live lease.
GC must take `gc.lock`, recheck the pointer, ownership index, and leases, and never delete a generation while a matching live or unverifiably stale lease exists.
A lease is stale only when its same-host PID and matching start identity are proved dead or its host is positively fenced; elapsed time alone never expires one.
The reader opens each listed regular artifact with no-follow handles, copies it to an exclusive owner-only staging directory adjacent to the destination, and verifies bytes and digest; hardlinks are permitted only when the source and destination share a filesystem and immutability and digest are verified before publication.
Cross-volume export copies and verifies into that adjacent destination staging directory; this does not relax the same-volume atomicity requirement for build publication.
Before exporting Node.js `.js` artifacts, the reader checks the package scope the exported files will actually see, including any `package.json` in the verified staged export and then already-published destination ancestors; it revalidates that scope before rename and fails with `output_module_type` on a format mismatch.
The snapshot export always uses `full` durability independently of the build's selected durability: it flushes copied files and stage directories, uses an atomic exclusive no-replace rename to the absent destination, then flushes its parent directory; an unsupported atomic rename or required flush fails with `publication_error`.
The reader releases its lease after export owns independent copies or hardlinks; GC may then retire the managed generation, but it never deletes a published export.
Before rename, cancellation, crash, or validation failure cannot publish the destination; after rename, a parent-flush failure reports `publication_error` but retains the complete exported directory for recovery rather than deleting a potentially observed release.
The exported document root contains exactly the listed artifacts, not `active.json`, `previous.json`, `complete.json`, or internal leases.
`publicPath` routing and old export retention remain deployment-operator responsibilities as described above.
The export and managed output containers remain writable only to the build principal; an external static server runs under that trusted principal or receives explicit read-only access to an export, never write access to managed pointers or leases.

## 28. Extension model without a JavaScript runtime

The initial stable release ships built-in loaders and declarative aliases, externals, defines, conditions, and loader mappings.
It does not claim Bun, Rollup, Webpack, Vite, or esbuild plugin compatibility.

Executable extensions are not enabled in the initial stable release; configured declarative aliases and loader mappings require no extension process.
The reserved extension protocol version 1 is a long-lived isolated subprocess over newline-delimited canonical UTF-8 JSON; request and response frames are bounded by `limits.extensionRequestBytes` and `limits.extensionResponseBytes`, initially 16 MiB each.
Each request is `{protocolVersion:1,id,hook,items,configDigest}`, where `hook` is `start`, `resolve`, `load`, `transform`, `inspect`, or `end`, `items` is an ordered array bounded by `limits.extensionBatchItems`, and `id` is a unique request correlation string.
`start` receives the normalized non-secret configuration projection; `resolve` items contain the section 10.6 `ResolveRequest`; `load` items contain canonical module identities; `transform` items contain immutable input bytes as base64 plus loader and digest; `inspect` items contain only finalized artifact identity and digest; `end` contains a status.
Each response is `{protocolVersion:1,id,status,items,diagnostics}`, with `status` `ok` or `error`, exactly one response per request, and one result per input item in the same order.
Resolve results use the version 1 `ResolveResult`; load and transform results use `{namespace,identity,loader,contentBase64,contentDigest,dependencies,watchPaths,sourceMap,deterministic,cacheIdentity}` with no host file handle, and inspect results may contain diagnostics only.
Returned dependencies and watch paths are canonical permitted-root paths; maps, identities, diagnostics, and bytes are validated as untrusted input.
The extension handshake contains executable digest, protocol version, declared permission grants, environment-input digests, and configuration digest before any hook is called.
Unknown versions, hooks, fields, missing results, invalid framing, or undeclared dependencies fail with `extension_protocol`; an extension crash or timeout fails the build, not the host process.
Extensions are never started per import.
The host enforces `limits.extensionBatchItems`, `limits.extensionDependencies`, `limits.extensionRequestBytes`, and `limits.extensionResponseBytes` before allocating a batch; `limits.extensionTimeoutMs` and `limits.extensionMemoryBytes` bound each process batch, initially 30 seconds and 256 MiB.
Network, arbitrary process creation, environment and secret reads, untracked filesystem reads, and direct writes to output, cache, or package store are denied by default.
An explicit per-extension grant may authorize a named read-only root or named non-secret environment key; network and process grants are not supported by protocol version 1.
The host must enforce these restrictions in an OS sandbox or WASI capability host; if unavailable, executable extensions fail with `extension_permission` rather than running unsandboxed.
Extension identity, input grants, and declared deterministic inputs enter affected cache keys; undeclared time, randomness, or filesystem input makes affected results non-cacheable and forbids a reproducible-build claim.
Cancellation terminates the complete extension process tree and discards uncommitted responses.
Native in-process plugins remain unsupported.

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
entrypoints + knot.toml + tsconfig.json + knot.lock
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

### 31.1 Diagnostic record and code registry

`--diagnostics json` writes one canonical UTF-8 JSON object and LF per diagnostic on stderr, never an array, progress text, or a partial object.
Version 1 requires exactly `{version,code,severity,phase,identity,location,related,chain,message,suggestion,generation}`.
`identity` is `{kind,value}` with kind `project`, `package`, `virtual`, or `output` and a canonical portable value, or `null` for a global configuration or host failure without an owning source.
`location` is `{path,start,end}` when a source range exists and `null` otherwise; identity remains required even without a range, except for global failures.
`start` and `end` each contain `{offset,line,column}` with zero-based UTF-8 byte offsets, one-based lines and UTF-16 columns; end is exclusive.
`related` is an ordered array of `{label,identity,location}`, `chain` is an ordered array of `{kind,specifier,importer,resolved}` with `resolved: null` for an unsuccessful lookup, and `suggestion` is `null` or an ordered array of strings.
`generation` is null outside watch mode or the monotonically increasing watch generation integer.
`severity` is `error`, `warning`, or `info`.
`phase` is `config`, `scan`, `resolve`, `load`, `parse`, `transform`, `link`, `shake`, `chunk`, `css`, `html`, `print`, `map`, `hash`, `cache`, `write`, `publish`, `recover`, `watch`, or `extension`.
Diagnostics sort by that phase order, identity kind and value with null first, location start with null first, code, and chain; exact duplicate records are coalesced.
`--log-level silent` suppresses informational and warning records but not error diagnostics or nonzero exit status; `error`, `warning`, and `info` progressively include those severities.
`debug` additionally emits bounded stage entry and completion events as version 1 `info` diagnostic records with code `stage_trace` and the relevant phase and identity; JSON mode applies the same filter and emits no plain-text prefixes.
An unsuccessful watch rebuild retaining prior output emits `stale_output` with the prior generation identity, in addition to the failing generation's diagnostics.
Secrets, credentials, authorization headers, signed URLs, and home paths are redacted from all diagnostics and metadata; text output escapes untrusted terminal controls.

The initial stable code registry is:

| Category | Codes |
| --- | --- |
| Configuration and loading | `invalid_option`, `duplicate_option`, `unsupported_option`, `unsupported_interface`, `invalid_interface`, `unsupported_loader`, `unsupported_target`, `unsupported_format`, `invalid_path`, `unsupported_split`, `invalid_encoding`, `invalid_integrity`, `import_attribute`, `import_suffix`, `data_number`, `data_schema`, `duplicate_key` |
| Resolution | `unresolved_import`, `missing_export`, `ambiguous_export`, `invalid_package_conditions`, `invalid_package_target`, `package_export`, `package_graph`, `invalid_alias`, `symlink_escape`, `external_format`, `library_exports` |
| JavaScript semantics | `syntax_error`, `unsupported_interop`, `top_level_await`, `dynamic_specifier`, `require_resolve_bundled`, `unsupported_runtime_api`, `dynamic_scope`, `cjs_named_accessor`, `import_meta_resolve`, `output_module_type` |
| CSS and HTML | `css_cycle`, `css_order`, `css_module_cycle`, `css_module_missing`, `css_module_syntax`, `css_target`, `css_url_scheme`, `html_reference`, `html_syntax`, `html_template_reference`, `html_url_scheme`, `html_base`, `html_worker_entry`, `html_manifest`, `html_script_format`, `html_integrity`, `html_csp`, `html_inline_import` |
| Outputs and resources | `asset_root`, `output_collision`, `path_traversal`, `invalid_source_map`, `source_map_path`, `source_map_content`, `sourcemap_error`, `budget_exceeded`, `resource_limit`, `publication_error`, `publication_busy`, `publication_recovery` |
| Cache, watch, and extensions | `cache_corrupt`, `cache_busy`, `watch_overflow`, `watch_unavailable`, `extension_protocol`, `extension_permission`, `extension_timeout`, `extension_crash` |
| Warnings and debug | `side_effect_annotation`, `stale_output`, `cache_miss`, `stage_trace` |

Codes are never reused for a different meaning.
New codes are additive.
An implementation must use the nearest existing code rather than embedding an unstable message in place of a code.

## 32. Security and reliability

### 32.1 Threat boundaries and required controls

Project sources, installed package metadata, HTML and CSS URLs, data files, maps, cache bytes, and extension replies cross from attacker-controlled input into a developer or CI build.
An attacker may change project inputs or supply cache bytes from a shared, untrusted location; the default rejects such cache ancestry, and a process with the trusted build principal's own rights is outside this isolation boundary.
Assets at risk are deployed artifact integrity, project/build secrets, writable output roots, and CPU, memory, and disk availability.

| Abuse path | Boundary and impact | Release control |
| --- | --- | --- |
| Poisoned cache record injects code or metadata | Cache bytes to compiler/linker IR or publication; high-impact integrity loss | Reject shared-writable ancestry, verify framing, key, source and dependency snapshots, strict payload schemas and digests, then normal artifact validation; disable persistent caching if the principal itself is untrusted. |
| Concurrent symlink or source replacement | Project/HTML/CSS reference to filesystem handle; high-impact root escape | Resolve relative to owning source, reject encoded traversal and forbidden schemes, open handle-relative with no-follow checks, and verify final root containment and file identity. |
| Template or extension-generated output path traverses root | Untrusted name to publisher; high-impact overwrite | Validate each component, reserve metadata names, reject reparse points and case-folded collisions, create exclusively below the verified staging handle. |
| Executable extension reads secrets, spawns children, or writes outputs | Untrusted executable to host effects; high-impact exfiltration or corruption | Deny executable extensions until a permissioned isolated host exists; enforce section 28 grants and never give direct write access to publication or cache state. |
| YAML, input maps, data URLs, or CSS/HTML graphs expand unboundedly | Structured input to allocator; medium-impact denial of service | Enforce the finite limits in section 32.2 before allocation and during expansion. |
| Publication pointer or lock is replaced concurrently | Output container to deployment reader; high-impact mixed generation | Verified handles, atomic pointer, completion digests, PID start identity and nonce, plus consumer snapshot pinning. |
| Forged or raced snapshot export | Managed generation to external document root; high-impact mixed content or unowned overwrite | Pin a verified pointer under the GC lock, hold a verified lease while copying, verify every artifact, publish only by exclusive same-directory rename, and reject unsafe destination ancestry. |

No build executes application code, evaluates definitions as JavaScript, loads executable configuration, follows remote imports, or implicitly accesses the network.
Decode URL escapes exactly once, reject encoded separators and traversal, and never reinterpret accepted references with a different normalizer.
An HTML or CSS local reference is resolved relative to its owning file and remains under the configured project or asset root; external URLs are preserved but never fetched.
Static asset inputs must be regular files; devices, sockets, FIFOs, directories, unresolved symlinks, and links leaving the allowed root are rejected.
Asset size is checked before allocation and again before publication.
Strict asset-root confinement is the default, not an opt-in rule.
The output container must be owned by the build principal and not group/world writable; POSIX staging and generation directories use `0700`, generated files `0644` after activation only where the containing generation remains protected, and pointer, lock, and temporary files `0600`.
On Windows equivalent ACLs grant writes only to the build principal and required system principals; a shared-writable root or unsupported access check fails with `publication_error`.
No temporary file, pointer, or manifest is followed through a symlink, junction, or reparse point.
Host credentials and absolute paths are not injected into portable artifacts or user-visible metadata, and terminal controls from untrusted diagnostics are escaped; explicit source and `define` literals are public output data, not a secret channel.

### 32.2 Resource limit defaults

Every bundler-owned finite resource bound appears in normalized `limits`, except cache byte caps already in `cache` and CLI/watch timing fields in their own normalized objects.
These bounds are enforced before allocation where the relevant input size is known and during incremental parsing or traversal.
Exceeding a size, depth, count, or memory bound produces `resource_limit` with the key and configured value; a batch deadline produces `extension_timeout`, and excessive package-target recursion retains `package_export` with the same limit evidence.

| Normalized key | Scope | Default |
| --- | --- | ---: |
| `modules` | Graph nodes | 100,000 |
| `edges` | Graph edges | 500,000 |
| `importDepth` | Longest import path | 1,024 |
| `sourceBytes` | Total source bytes | 1,073,741,824 |
| `assetBytes` | Individual asset bytes | 268,435,456 |
| `dataDepth` | Nested JSON, JSONC, TOML, YAML, Web App Manifest, or input-map values per document | 128 |
| `dataNodes` | Parsed scalar, array, and object values per structured document | 1,000,000 |
| `htmlDepth` | Nested HTML elements per document | 256 |
| `htmlReferences` | References per HTML entry | 100,000 |
| `cssNestingDepth` | Nested CSS rules and functions per stylesheet | 256 |
| `cssImports` | Imports per CSS graph | 10,000 |
| `packageTargetDepth` | Nested exports or imports condition and array frames | 64 |
| `artifacts` | Generated application artifacts | 100,000 |
| `mapSegments` | Segments per source-map artifact | 10,000,000 |
| `stagedBytes` | Total staged output bytes | 4,294,967,296 |
| `diagnosticBytes` | Total diagnostic evidence bytes | 8,388,608 |
| `watchEvents` | Pending watcher events | 100,000 |
| `cacheHeaderBytes` | One cache envelope header | 1,048,576 |
| `protocolFrameBytes` | One native JSON request or response frame, at most 67,108,864 and at least 4,096 | 67,108,864 |
| `extensionRequestBytes` | One extension request frame, at most 16,777,216 and at least 4,096 | 16,777,216 |
| `extensionResponseBytes` | One extension response frame, at most 16,777,216 and at least 4,096 | 16,777,216 |
| `extensionBatchItems` | Hook items per extension batch | 10,000 |
| `extensionDependencies` | Paths returned by one extension batch | 10,000 |
| `extensionTimeoutMs` | Wall time per extension batch | 30,000 |
| `extensionMemoryBytes` | Process memory per extension batch | 268,435,456 |
| `diagnosticRecords` | Total records per build | 10,000 |

The protocol-frame hard cap applies before a request can be parsed; the normalized lower bound applies after the request is decoded and to every response.
An override may lower a protocol or extension frame cap but cannot raise its wire maximum; other overrides must be below the host hard limit and participate in the configuration's execution identity.
Zero, negative, and unbounded sentinel values are invalid.

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

For `portable: true`, artifact bytes, manifest, stable diagnostic identity and ranges, and the semantic metafile projection must not depend on pointer addresses, map iteration, worker index, CPU count, scheduling, architecture, GPU dispatch, or the build machine's absolute project and output paths.
For `portable: false`, determinism is required for repeated requests with the same machine-local identities; observational timings, cache counts, backend, device, worker count, fallback events, and debug timestamps are excluded from byte-determinism claims.

### 33.4 Verification and benchmark contract

The independent acceptance driver is Node.js 24 LTS with `node:test`.
Browser acceptance requires the exact Chromium build pinned in `toolchain.json` before it can serve as a release gate; an unpinned browser is not evidence of a pinned baseline.
The browser fixture must load the emitted page through HTTP and observe script execution, CSS application, local asset loads, source-map references, and public-path behavior.

The release matrix must contain deterministic fixtures for:

- ESM bindings, re-exports, cycles, and top-level await.
- CommonJS caching, mutation, and ESM interoperation.
- Package exports, imports, browser replacements, conditions, workspaces, and built-ins.
- Tree shaking, side-effect metadata, pure annotations, and removal reasons.
- Static entries, shared chunks, dynamic chunks, chunk cycles, and preload policy.
- JSON, JSONC, TOML, YAML, text, CSS, CSS Modules, HTML, and static assets.
- Linked, external, inline, and composed source maps.
- Watch invalidation, cache reuse, cancellation, recovery, and atomic publication.
- Resource limits, malformed inputs, path traversal, symlink escapes, and decompression or recursive-data bounds.

Every fixture observes public artifacts, runtime behavior, diagnostics, or state transitions.
Tests must not assert private helper calls or incidental formatting.
Every release candidate runs the CPU path and any supported Metal or CUDA path with canonical output-equivalence checks.

Benchmarks run only after the relevant correctness suite is green.
Each report records the toolchain version, backend, hardware, target, format, entries, graph shape, source-map mode, minification settings, cache state, storage medium, worker count, and GPU transfer time.
Performance claims without byte-equivalence and runtime-equivalence evidence are invalid.

`toolchain.json` pins Bend 2.0.24 with platform archives, Node major 24, Chromium 153.0.8010.12 with darwin-arm64/linux-x64/windows-x64 archive digests, LLVM Clang 21.1.8 source identity, and exact Bun 1.4.2, esbuild 0.28.2, and Rollup 4.63.5 reference versions.
The Chromium archive digests were computed from the versioned official downloads; the compiler source pin does not by itself freeze the installed compiler binary or CI image, and npm package wrappers do not pin all native optional binary packages.
Before comparative release jobs, freeze each CI host image, installed Clang binary and linker provenance, optional native reference packages, and exact reference commands; do not silently use host `clang`, browser, or global tools.
A missing required compiler, browser, compatibility tool, or fixture is an infrastructure failure, never a skipped passing gate.
The planned release fixture entry point is Node.js 24 `node --test tests/acceptance/bundler/` using the actual `knot` process and deterministic fixtures under `tests/fixtures/bundler/`; those paths must be created before the release command is claimed as runnable.
Fixtures cover the full section 33.4 matrix plus multi-CSS manifest relationships, nested metafile invariants, JSON diagnostic filtering, poisoned cache/active clean, watcher overflow/poll, signals, Windows `knot snapshot` export and leases, symlink races, and crash recovery.
Browser fixtures serve the exported immutable snapshot over local HTTP and observe scripts, computed styles, asset loads, maps, preload, public-path behavior, and overlapping releases with distinct URL prefixes.

The planned reproducible benchmark command is `node benchmark/bundler/run.mjs --fixture tests/fixtures/bundler/performance/<case> --backend cpu --cache clean --json`; it is a required future release fixture, not an existing command.
Each comparison uses the real Knot executable and pinned reference tools with matching target, format, entries, splitting, minification, maps, CSS, HTML, and assets; non-equivalent cases fail validation and cannot support a speed claim.
Each case runs three warmups and ten measured runs on fixed input bytes and normalized configuration; cold cache is cleared between samples and warm cache is prepopulated separately.
One-file watch latency is measured from delivered filesystem event to pointer activation; a no-op means unchanged bytes, no output rewrite, and no activation.
Reports include exact commands, binary and fixture digests, redacted normalized configuration display and semantic digest, OS image, CPU and cores, RAM, storage filesystem and medium, power profile, device/transfer time, peak RSS, median, p95, minimum, maximum, and all raw wall-time samples.
Clean JavaScript median must be at most 1.15 times pinned esbuild, clean full-web median at most 1.15 times pinned Bun, small-app one-file watch p95 at most 100 ms, and eligible automatic GPU workloads require at least 15% end-to-end median improvement with byte-equivalent outputs.
Fast CPU/schema/security fixtures gate pull requests; full Node/browser/Windows and recovery fixtures gate merges; comparative performance runs on isolated dedicated hardware and blocks stable release when a required gate fails.
Shared pull-request runners do not gate performance, and a changed fixture, tool, OS image, hardware, or config starts a new explicit baseline.

The release CI matrix is:

| Gate | Host and backend | Required evidence |
| --- | --- | --- |
| Pull request fast | Ubuntu 24.04 linux-x64 image, CPU, Node 24, Bend 2.0.24, Clang 21.1.8 | CLI, schema, cache, loader, security, and deterministic CPU fixtures. |
| Merge full web | Ubuntu 24.04 linux-x64 and macOS 15 darwin-arm64 images, CPU, pinned Chromium | Node runtime plus real HTTP browser CSS/HTML/map/preload and watch/recovery fixtures. |
| Merge Windows publication | Windows Server 2022 windows-x64 image with a verified native Knot binary and pinned Chromium | Pointer-aware consumer, ACL, symlink/reparse, cancellation, and multi-crash recovery fixtures; absent native build support is infrastructure failure. |
| Optional backend equivalence | macOS 15 Metal host or Ubuntu 24.04 CUDA host when supported | CPU versus device byte-equivalent artifacts, maps, manifest, and semantic metafile projection. |
| Scheduled release performance | Dedicated Ubuntu 24.04 bare-metal host with Intel Xeon Gold 6430, 16 pinned physical cores, 64 GiB RAM, and local NVMe ext4; separate Mac mini M4 Pro or NVIDIA A100 hosts only for eligible GPU claims | Warm/cold and watch distributions, raw samples, runtime equivalence, and resource caps. |

Performance fixture definitions are:

| Case | Fixed graph and measured operation |
| --- | --- |
| `single-large` | One 1 MiB TypeScript ESM entry with 10,000 live declarations; cold parse, transform, print, and Node execution. |
| `many-small-10000` | One ESM entry with 9,999 statically imported 1 KiB modules; cold scan, link, print, and 4 GiB RSS gate. |
| `deep-wide` | A 100-level ESM spine with ten unique leaves per level; cold resolution, linking, and deterministic output. |
| `esm-cjs-mix` | 500 ESM and 500 CommonJS modules, including 50 fixed cross-format cycles; cold execution order and cache identity. |
| `multi-entry-1-10-100` | One, ten, and 100 ESM entries over the same 200-module shared subgraph; measure each as a separate case. |
| `static-shared-lazy` | Four ESM entries, 200 statically shared modules, and 200 modules behind literal lazy edges; splitting and demand loading. |
| `assets-1000` | 1,000 valid 1 KiB image assets referenced by an entry; copy, hashing, URL rewriting, and browser loads. |
| `css-html` | One HTML entry, 5,000 cascade-ordered CSS rules, 100 local assets, and one module script; full browser output. |
| `watch-one-file` | A 100-module ESM graph with one edited leaf restored between runs; event-to-pointer latency and no-op stability. |

Each case has fixed source bytes, normalized target/options, runtime oracle, and source-tree digest in a checked-in fixture manifest.
Exact image digest, pinned linker and native reference binaries, fixture manifests, and benchmark runner are not present yet and must be checked into the release configuration before a performance result can gate release.

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
- Declarative extension-boundary validation; executable extension hosting remains outside the stable release.
- Selected GPU experiments.

Exit criteria:

- Chunk merges never make effects eager.
- CSS chunking passes ordering and route fixtures.
- Declarative loader and alias mappings are validated without executing code.
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
- The browser target with `--format cjs` fails with `unsupported_format` before graph scanning or staging for both build and analyze; the three supported target-format combinations run executable reference fixtures.
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
- Dynamic external imports to independently emitted entries preserve lazy execution and use `targetKind: external-entry`, while bundled lazy chunks use `targetKind: lazy-chunk`.
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
Export fixtures run `knot snapshot` against an active generation during concurrent watch activation and GC, verify its completed digests, then execute Node.js output or serve the exported page with a real browser.
They inject reader death before and after lease creation, per-artifact copy, flush, and destination rename; an existing or raced destination must never be overwritten, and a stale lease must not be reclaimed merely because time elapsed.
One fixture switches overlapping release routes while an old page still requests assets, proves its old URL prefix continues to serve old bytes, then retires the old export only after the request completes.
Configuration fixtures compare build output and `configDigest` after relocating the same portable source tree and changing cache paths, worker counts, limits, and output directories with equivalent Node.js package scope; independently changing a semantic define or the dependency side-effect annotation policy must change that digest when the resulting bundle changes.
Node.js `.js` fixtures cover an absent `package.json` under CommonJS, an existing manifest without `type`, creation of a nearer manifest, removal or change of the selected manifest, and ESM rejection without `type: module`; positive and negative scope changes must invalidate a cached or watched build.
They verify that `--show-config`, native response metadata, and metafiles expose no host paths or definition literals, and that over-limit data, HTML, CSS, and protocol inputs fail with their documented codes; reserved extension bounds are schema-validated while executable extensions remain disabled.
External-import fixtures run emitted ESM and CommonJS entries relocated away from sources, check rewritten paths to separately emitted targets, and require `external_format` with no active pointer change for an un-emitted target; an ESM dynamic external import must point to the separately emitted entry in both manifest and metafile and execute only when called.

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
| Metadata leaks local paths or secrets | Reproducibility and security fail | Hash portable semantic identities separately from private execution settings; mask display values, prohibit credential definitions, and pseudonymize machine-local metadata paths |

## 37. Remaining implementation research

The following questions concern implementation technique, not release semantics:

1. Which Bend2 collection layout gives the best compact adjacency lists and immutable per-module IR?
2. Can the linker update symbol representatives without copying large immutable tables?
3. Which standards-aware HTML parser or rewriter has an acceptable license and host boundary?
4. Should CSS behavior be implemented by a port or an isolated compatible library?
5. Which SHA-256 implementation is efficient across supported CPU and optional GPU backends?
6. Can CSS shared chunks preserve route and cascade order without a runtime loader? Until proven, sharing is disabled.
7. Which graph sizes, if any, justify optional GPU reachability? CPU remains the release default.

The semantic choices previously listed here are fixed in sections 10.6-10.7, 13.3-13.4, 18.2-18.4, 19.3, 20.2, 23.1.1, and 27.
Browserslist execution is unsupported; version 1 uses only the exact pinned browser baseline, not host-dependent browser target queries.
Inline module scripts remain inline under section 19.3; local imports from them fail explicitly.
Windows publication uses the pointer-aware generation protocol, not an atomic populated-directory replacement.
Executable extensions are deferred with a reserved wire schema; no unsupported implementation technique authorizes an unspecified release behavior.

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
- Browser CommonJS fails before scanning, semantic digests distinguish side-effect annotation policies, and manifest dynamic edges distinguish emitted entries from lazy chunks.
- Watch mode invalidates positive and negative dependencies correctly.
- Node.js `.js` output verifies present and absent package scopes and invalidates cached or watched output when a nearer `package.json` appears.
- `knot snapshot` verifies and exports one completed generation through a live lease, including on Windows, and static-server fixtures retain old public-path releases until related requests drain.
- Relocated portable projects keep the same semantic `configDigest`, manifest, and output bytes across operational changes; public records never expose host paths or private execution values.
- External relative JavaScript imports either target an emitted artifact with runtime-correct rewritten spelling or fail before publication.
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

### Use SHA-256 for artifact identity

`[hash]` uses the SHA-256 identity of symbolic pre-reference printed bytes, semantic map facts, and referenced artifact identities; manifest `digest` uses final published bytes.
Final URL spelling, map `file`, and source-map trailers are added after owner names are fixed, so cyclic references cannot create a filename hash fixed point.

### Parse HTML structure before rewriting references

HTML comments, scripts, styles, attributes, and `srcset` candidates have different lexical rules.
The implementation uses parser state rather than global string replacement so non-document text remains unchanged.

### Parallelize modules and chunks on CPU first

Module parsing, local analysis, CSS processing, asset hashing, and chunk printing provide independent work.
Irregular graph coordination and variable-length output do not justify a GPU-first architecture.

### Keep GPU use evidence-based

The product must remain complete on CPU-only systems.
GPU execution is enabled automatically only when equivalent output and an end-to-end gain are both demonstrated.

### Bundle dependencies by default

The initial stable release bundles package dependencies by default for both browser and Node.js builds.
`--packages external` is the explicit opt-out for bare package imports.
This keeps deployment output self-contained while preserving an intentional externalization path for Node.js libraries and services.

### Separate portable semantics from local execution

Absolute paths, publication settings, budgets, and resource limits belong to the private execution request, not the semantic digest placed in a portable metafile.
A versioned path-identity projection gives relocation-stable output identity; nonportable dependencies are marked explicitly and public metadata never reveals their host paths.

### Export immutable snapshots instead of serving managed roots

The managed output root requires pointer validation, verified completion, GC coordination, and reader leases, which ordinary static servers do not provide.
`knot snapshot` provides one bounded read and atomic export without embedding an HTTP server; overlapping live releases still require versioned URLs and operator retention.

### Reject dangling external relative paths

Preserving a source-relative import after moving its importer into an output generation can resolve the wrong file or none.
Require an independently emitted target, rewrite against final paths, and fail otherwise instead of copying an undeclared file.

### Freeze version 1 interfaces and conservative semantics

The normalized configuration, immutable compiler facts, resolver, loader, linker/chunk plan, native JSON/C ABI, and reserved extension protocol have version 1 shapes in section 10.
Non-literal module loading and runtime APIs without relocation-safe semantics fail explicitly instead of guessing.
CommonJS named exports are conservative snapshots; CSS import cycles fail; data and URL loaders reject ambiguous or executable inputs.
The manifest is a deployment graph and the metafile separates deterministic semantics from observed timing and cache state.
Publication uses a verified generation pointer on all platforms, and consumers must pin one generation across related requests.
