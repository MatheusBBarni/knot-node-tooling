# Product requirements document: Bend2 package manager

Status: Draft

Date: 2026-09-17

Working name: `bnpm`

## 1. Summary

`bnpm` is an npm-compatible package manager implemented in Bend2.
It will resolve dependency graphs, fetch packages from npm-compatible registries, verify package integrity, reuse a global content-addressed store, and create an isolated `node_modules` layout that works with Node.js.

The product will use Bend2's automatic parallel execution where the workload is pure and independently divisible.
GPU execution is an optimization, not a product requirement for correctness.
Network requests, filesystem mutation, process execution, and most coordination remain host-side effects.
Every operation must have a CPU path, and GPU dispatch must be disabled when transfer and scheduling overhead would make it slower.

The first public release will focus on reliable installs from npm-compatible registries.
It will not try to match every npm, pnpm, or Bun command.

## 2. Problem

Current JavaScript package managers spend installation time in several different areas:

- Resolving semver ranges and peer dependency contexts.
- Downloading registry metadata and package tarballs.
- Verifying integrity and unpacking archives.
- Writing, cloning, linking, or copying many small files.
- Maintaining a reusable cache without corrupting concurrent installs.
- Running dependency lifecycle scripts safely.

These workloads are not uniformly suitable for a GPU.
HTTP latency and filesystem metadata operations are usually the limiting factors in warm and small installs.
Integrity hashing, package validation, file classification, and independent graph work can provide enough parallel work for Bend2's execution model.
A package manager built around the GPU alone would add transfer overhead to the parts that are already I/O-bound.

The product therefore needs a hybrid pipeline that exposes parallel work without moving effects or sequential coordination onto the GPU.

## 3. Product principles

1. Correct and reproducible installs come before benchmark results.
2. The lockfile is the source of truth for frozen installs.
3. Downloaded bytes are untrusted until their integrity is verified.
4. Dependency lifecycle scripts are denied unless the user explicitly trusts the package.
5. The default linker prevents undeclared, or phantom, dependencies.
6. Cache writes are atomic and safe across concurrent processes.
7. CPU execution is always supported.
8. GPU work is selected by measured cost, not by product branding.
9. The same inputs must produce the same dependency graph and lockfile on every supported backend.
10. A failed install must not leave a project that appears complete.

## 4. Goals

### 4.1 Initial release goals

- Read npm-compatible `package.json` manifests.
- Resolve registry dependencies, dist-tags, semver ranges, optional dependencies, and peer dependencies.
- Fetch abbreviated npm package metadata and package tarballs over HTTPS.
- Support public registries, scoped registries, bearer tokens, basic authentication, proxies, and custom certificate authorities.
- Verify Subresource Integrity values before making package content available.
- Maintain a global content-addressed package store and a separate registry metadata cache.
- Install a strict, isolated `node_modules` layout compatible with Node.js module resolution.
- Use hard links, copy-on-write clones, or copies according to platform and filesystem support.
- Produce a deterministic, reviewable lockfile.
- Support offline and frozen installs.
- Support workspaces from the root `package.json`.
- Run explicitly approved lifecycle scripts with bounded concurrency.
- Recover safely from interruption, cache corruption, and concurrent installs.
- Report enough timing data to show where an install spent its time.
- Run on macOS with Metal, Linux with CUDA where available, and CPU-only systems.

### 4.2 Success measures

Correctness and compatibility are release gates.
Performance targets apply only after the compatibility suite passes.

| Measure | Target |
| --- | --- |
| Clean install compatibility | At least 95% of the selected fixture corpus without per-package patches |
| Frozen install determinism | Byte-identical lockfile and equivalent `node_modules` graph across repeated runs |
| Offline behavior | Zero network requests when the lockfile and store are complete |
| Integrity behavior | Every modified or truncated tarball is rejected before materialization |
| Crash recovery | An interrupted install leaves the previous valid project state or a clearly incomplete staging state |
| Concurrent store safety | Parallel installs never expose partial cache entries or corrupt the store index |
| Warm install performance | No slower than pnpm by more than 10% on the reference corpus |
| Clean install performance | Faster than pnpm on the reference corpus, with Bun included as a comparison rather than a release gate |
| GPU policy | GPU mode must beat CPU mode by at least 15% for the selected stage before it is enabled automatically |
| Resource use | Peak memory remains bounded by configured download and extraction concurrency |

## 5. Non-goals for the initial release

- Publishing, deprecating, tagging, logging in, or managing registry owners.
- A package search experience.
- Global package installation.
- Git, GitHub, local directory, direct tarball, and custom fetcher dependencies.
- npm lockfile, pnpm lockfile, Yarn lockfile, or Bun lockfile migration.
- A hoisted linker.
- Plug'n'Play support.
- Dependency patching.
- An audit service or vulnerability database.
- Automatic package manager version switching.
- Replacing Node.js module resolution.
- Running all package lifecycle scripts by default.
- Requiring a discrete GPU.

These features may be added after registry installs and the store format are stable.

## 6. Users and jobs

### Application developer

The developer wants `bnpm install` to create a working project from `package.json` and a committed lockfile.
The developer expects repeated installs to be fast and changes to be easy to review.

### Monorepo maintainer

The maintainer wants one deterministic dependency graph across workspaces, filtered installs, strict dependency visibility, and safe concurrent CI jobs.

### CI and container author

The author wants a lockfile-only fetch step, an offline materialization step, stable cache keys, and failures when manifests disagree with the lockfile.

### Security-conscious team

The team wants verified package bytes, registry pinning, release-age controls, and an explicit allow list for lifecycle scripts.

### Bend2 contributor

The contributor wants a real systems workload that shows where automatic CPU and GPU parallelism helps and where host effects remain the right choice.

## 7. Research findings

The findings in this section describe the current documented behavior reviewed on 2026-09-17.
Implementation details may change between releases, so the source links are part of the decision record.

### 7.1 npm registry protocol

An npm-compatible install begins by requesting package metadata from `GET /<package-name>`.
The registry supports an abbreviated install document through the `Accept: application/vnd.npm.install-v1+json` header.
The abbreviated response includes dist-tags, versions, dependency fields, platform constraints, `dist.tarball`, and `dist.integrity`.
This avoids downloading full readmes and other metadata that are not required for installation.

The selected version's tarball is downloaded from `dist.tarball`.
The package manager verifies the tarball against `dist.integrity`, normally an SRI string such as `sha512-<base64>`, before trusting it.
`dist.shasum` is a legacy SHA-1 fallback and must not replace an available stronger integrity value.

Source: [npm package metadata specification](https://github.com/npm/registry/blob/main/docs/responses/package-metadata.md).

### 7.2 Bun

Bun separates registry resolution, its global package cache, and project materialization.
Its default global cache is `~/.bun/install/cache`, with package directories named from package name and version.
Bun can reuse a compatible version already present in the cache instead of downloading it again.
It also checks an existing `node_modules` before doing install work.

Bun uses filesystem-specific materialization backends.
It uses hard links by default on Linux and Windows, `clonefile` copy-on-write clones on macOS, and regular copying as a fallback.
Its isolated linker creates a project store under `node_modules/.bun` and symlinks direct dependencies into the root `node_modules`.
Peer dependency sets are encoded in isolated store paths so different peer contexts can coexist.

Bun writes the text-based `bun.lock` lockfile.
It supports frozen, offline, prefer-offline, dry-run, production, workspace, and lockfile-only modes.
Bun does not run arbitrary dependency lifecycle scripts by default.
Packages must be allowed through `trustedDependencies`, subject to Bun's documented built-in trust list behavior.

Useful Bun decisions:

- Check whether the installed tree already satisfies the lockfile before rebuilding it.
- Select the fastest safe filesystem primitive at runtime.
- Keep registry metadata caching separate from extracted package caching.
- Make dependency scripts opt-in.
- Offer both isolated and hoisted layouts, while using isolation for new workspace projects.

Risks to avoid:

- A cache named only by package name and version is not a sufficient trust identity across multiple registries.
- Hard links allow writes through one path to affect every path sharing the inode.
- A global cache needs explicit concurrency and corruption semantics.

Sources:

- [Bun global cache](https://bun.sh/docs/pm/global-cache)
- [Bun install](https://bun.sh/docs/pm/cli/install)
- [Bun lockfile](https://bun.sh/docs/pm/lockfile)
- [Bun isolated installs](https://bun.sh/docs/pm/isolated-installs)
- [Bun lifecycle scripts](https://bun.sh/docs/pm/lifecycle)

### 7.3 pnpm

pnpm uses a content-addressable store and an isolated virtual store under `node_modules/.pnpm`.
Package files in the virtual store are hard-linked or reflinked from the global store where the filesystem permits it.
Symlinks connect each package to its declared dependencies and expose direct dependencies at the project root.
This layout keeps filesystem depth bounded while allowing Node.js to resolve the correct dependency graph.

A package with peer dependencies can appear in multiple virtual-store entries.
Each entry represents a distinct resolved peer set.
Packages without peer dependencies may still need multiple peer-context snapshots when their transitive dependencies have peers.

pnpm's `fetch` command can populate the virtual store from the lockfile without reading project manifests.
A later offline install materializes dependencies without contacting the registry.
This split is useful for container layers and remote cache workflows.

pnpm 11 replaced per-package JSON store indexes with one SQLite index in WAL mode.
The index stores MessagePack values and bundled package manifests, reducing small-file reads and system calls.
The content store still addresses package files by digest.
Its metadata client uses conditional requests, and tarball handling verifies integrity before adding files to the store.

pnpm also demonstrates the operational details a content store needs:

- Store status detects modified content.
- Store pruning removes unreferenced content.
- Cross-filesystem installs fall back to copying because hard links cannot cross device boundaries.
- Windows may require junctions where directory symlinks are unavailable.
- Build scripts are denied unless allowed.
- Release-age and registry-origin policies reduce supply-chain exposure.

Useful pnpm decisions:

- Separate immutable content from the dependency graph that links it together.
- Give peer contexts distinct installation identities.
- Keep direct dependencies visible and transitive dependencies isolated.
- Support a lockfile-only fetch phase and a network-free install phase.
- Store package index data in a transactional database rather than millions of metadata files.

Costs to accept or manage:

- The symlink graph is more complex than a hoisted tree.
- Peer contexts can multiply virtual-store entries.
- Compatibility breaks when packages import dependencies they did not declare.
- Store and project placement affects whether links, reflinks, or full copies are possible.

Sources:

- [pnpm symlinked `node_modules` structure](https://pnpm.io/symlinked-node-modules-structure)
- [pnpm peer resolution](https://pnpm.io/how-peers-are-resolved)
- [pnpm fetch](https://pnpm.io/cli/fetch)
- [pnpm store management](https://pnpm.io/cli/store)
- [pnpm filesystem behavior](https://pnpm.io/faq)
- [pnpm 11 store design](https://pnpm.io/blog/releases/11.0#store-v11)
- [pnpm supply-chain security](https://pnpm.io/supply-chain-security)

### 7.4 Comparison

| Concern | Bun | pnpm | `bnpm` decision |
| --- | --- | --- | --- |
| Registry metadata | Cached manifests | Cached abbreviated metadata with conditional requests | Abbreviated metadata cache with ETag and Last-Modified revalidation |
| Package identity | Primarily name and version in documented cache layout | Content-addressed files plus package index | Registry origin plus SRI digest, never name and version alone |
| Global store | Extracted package cache | Per-file content-addressable store | Per-file content-addressable store |
| Project store | `node_modules/.bun` in isolated mode | `node_modules/.pnpm` | `node_modules/.bnpm` |
| Materialization | Hardlink, clonefile, copyfile, or symlink | Hardlink, reflink, or copy | Clone or reflink first, then hardlink, then copy |
| Dependency layout | Hoisted or isolated | Isolated by default | Isolated only in the initial release |
| Peer dependencies | Peer context in isolated path | Peer context in virtual-store identity | Canonical peer-context hash in snapshot identity |
| Lockfile | Text `bun.lock` | YAML `pnpm-lock.yaml` | Deterministic text `bnpm.lock` |
| Offline flow | Offline and prefer-offline install | Separate fetch and offline install | Both `fetch` and `install --offline` |
| Lifecycle scripts | Trust allow list | Build allow list | Deny by default, explicit allow list |
| Store index | Bun-specific cache metadata | SQLite WAL with bundled manifests in pnpm 11 | SQLite WAL if Bend2 FFI is safe, otherwise a transactional host adapter |
| GPU use | Not a package-manager design goal | Not a package-manager design goal | Optional acceleration for measured pure batch stages |

## 8. Product scope

### 8.1 Required commands

| Command | Behavior |
| --- | --- |
| `bnpm install` | Resolve if needed, fetch missing content, materialize the graph, link binaries, run approved scripts, and write the lockfile |
| `bnpm install --frozen-lockfile` | Fail if manifests and lockfile disagree, and never rewrite the lockfile |
| `bnpm install --offline` | Make no network requests and fail with a list of missing cache entries |
| `bnpm install --prefer-offline` | Use valid cached metadata and content first, then fetch missing data |
| `bnpm fetch` | Populate the store using the lockfile without creating the project links |
| `bnpm add <spec>` | Add a direct dependency, resolve the graph, install it, and update manifest and lockfile transactionally |
| `bnpm remove <name>` | Remove a direct dependency and update manifest, graph, and links |
| `bnpm update [name]` | Re-resolve dependencies within declared ranges, or only the named package when supplied |
| `bnpm list` | Print the installed direct graph and report missing or invalid links |
| `bnpm why <name>` | Show every path and peer context that requires a package |
| `bnpm store path` | Print the active global store path |
| `bnpm store status` | Verify indexes and sampled or full content according to flags |
| `bnpm store prune` | Remove unreferenced content with a safe mark-and-sweep pass |
| `bnpm cache clean` | Remove registry metadata without deleting verified package content |

### 8.2 Required flags

- `--production`
- `--frozen-lockfile`
- `--offline`
- `--prefer-offline`
- `--ignore-scripts`
- `--cpu`
- `--gpu`
- `--backend auto|clone|hardlink|copy`
- `--filter <workspace-selector>`
- `--registry <url>`
- `--store-dir <path>`
- `--network-concurrency <n>`
- `--script-concurrency <n>`
- `--reporter default|append-only|json|silent`
- `--dry-run`

`--gpu` must fail with a useful diagnostic when no supported backend is available.
Automatic mode may choose CPU even when a GPU exists.

## 9. Functional requirements

### 9.1 Manifest and workspace discovery

The installer must locate the workspace root without walking above a filesystem boundary unless configured.
It must parse `dependencies`, `devDependencies`, `optionalDependencies`, `peerDependencies`, `peerDependenciesMeta`, `engines`, `os`, `cpu`, `bin`, and `scripts`.
It must discover workspace packages from the root `workspaces` field and reject duplicate package names.
Workspace packages must be linked directly to their source directories.
The initial release must reject unsupported dependency protocols before changing the lockfile or `node_modules`.

### 9.2 Resolution

The resolver must treat package name, registry origin, exact version, artifact integrity, dependency graph, and peer context as separate concepts.
It must resolve tags and ranges according to npm semver behavior.
It must prefer versions that satisfy configured release-age, engine, operating-system, CPU, deprecation, override, and trust policies.
It must resolve optional dependency failures without hiding failures in required dependencies.
It must detect graph cycles without recursive stack growth proportional to graph depth.
It must assign a stable identity to each peer-context snapshot.
The identity must be independent of traversal order and map iteration order.

Resolution must produce an immutable plan before any project links are changed.
The plan must list required metadata, artifacts, store objects, virtual-store snapshots, root links, binary links, and lifecycle scripts.

### 9.3 Metadata fetch

The client must request abbreviated npm metadata.
It must support gzip or Brotli response compression, HTTP keep-alive, HTTP/2 where available, redirects with credential stripping across origins, proxy configuration, and scoped registry selection.
It must deduplicate concurrent requests for the same registry and package.
It must cap global and per-origin concurrency.
It must retry idempotent requests only for connection failures, timeouts, `408`, `429`, and retryable `5xx` responses.
It must honor `Retry-After` and apply bounded exponential backoff with jitter.
It must not retry authentication or integrity failures.

The metadata cache key must include normalized registry origin, package name, and response representation.
Credentials must never be part of a path, log line, lockfile, or cache payload.
Cached metadata must record ETag, Last-Modified, fetch time, and response digest.
Online refreshes should use conditional requests.
Offline mode must not perform DNS resolution or open a socket.

### 9.4 Tarball fetch

The fetcher must download the exact URL recorded in the resolution plan.
It must stream to a private temporary file while computing the expected SRI digest.
It must reject missing integrity for registry packages unless an explicit compatibility policy permits the legacy SHA-1 shasum.
It must validate compressed-size and unpacked-size limits before and during extraction.
It must detect truncated bodies, decompression bombs, path traversal, absolute paths, invalid UTF-8 path handling, duplicate entries, and unsafe symlink targets.
It must never extract outside the staging directory.

A verified artifact must be committed atomically under its integrity identity.
A losing concurrent writer must validate and reuse the winner's object rather than overwrite it.
Temporary files must be private to the process and removable after crashes.

### 9.5 Content-addressed store

The default store path must follow platform conventions and be configurable.
The store identity must include a format version.
Package content must be immutable after commit.

The store must contain:

- Verified artifact records keyed by SRI digest.
- File blobs keyed by strong digest.
- Package indexes mapping normalized paths to blob digest, mode, size, and link metadata.
- Bundled manifest fields needed during resolution and materialization.
- Reference data used for pruning.

The index should use SQLite in WAL mode if Bend2 can call it safely after release.
The database must not store package bytes.
If SQLite integration is unavailable, the implementation must use a small host adapter with equivalent transaction, locking, crash-recovery, and migration guarantees.
A directory full of mutable per-package JSON indexes is not an acceptable fallback.

Store writes must follow this sequence:

1. Download into process-local staging.
2. Verify artifact integrity.
3. Parse and validate the archive.
4. Hash regular files and prepare the package index.
5. Insert missing blobs with create-if-absent semantics.
6. Commit the package index transaction.
7. Delete staging data.

`store status` must detect missing blobs, size mismatches, invalid package indexes, and modified hard-linked content.
`store prune` must take a consistent snapshot of known projects and store entries before deletion.
It must not remove content referenced by an active install transaction.

### 9.6 Project virtual store

The project virtual store must live at `node_modules/.bnpm`.
Every snapshot directory must include package identity and a bounded hash of its peer context.
The actual package tree must be materialized once per snapshot.
Declared dependencies must be represented by relative links from that snapshot's `node_modules` directory.
Direct dependencies must be linked from the project or workspace root `node_modules`.
Command binaries must be linked into the relevant `.bin` directory using platform-correct wrappers.

Materialization backend priority:

1. Directory or file clone and reflink where the filesystem supports safe copy-on-write behavior.
2. Hard links when store and project are on the same filesystem.
3. Full copies as the compatibility fallback.

The implementation must not mutate a hard-linked package file when applying metadata or scripts.
A package approved to run a build script must receive a private writable copy before the script runs.
This prevents a project build from changing shared cache content.

The installer must build a new virtual-store generation in staging.
It must switch root links and installation metadata only after the generation is complete.
It must preserve enough state to remove abandoned generations on the next run.

### 9.7 Lockfile

The lockfile name is `bnpm.lock`.
It must be text, deterministic, merge-friendly, and versioned.
A generated lockfile must not depend on object insertion order, filesystem traversal order, network completion order, CPU count, or GPU scheduling.

The lockfile must record:

- Format version and package-manager compatibility range.
- Normalized settings that affect resolution or layout.
- Every workspace importer and declared specifier.
- Exact registry origin and package version.
- Tarball URL and SRI integrity.
- Runtime constraints and deprecation information used during selection.
- Regular, optional, and peer dependencies.
- Peer-context snapshot identities.
- Approved lifecycle-script policy inputs.

Secrets must never be written to the lockfile.
Frozen mode must validate all resolution-affecting manifest and configuration fields.
It must fail before network or filesystem mutation when the lockfile is stale.

### 9.8 Lifecycle scripts

Dependency scripts must be denied by default.
Users may approve package names and optional version ranges in a project configuration file.
Approval must be scoped to registry-origin packages so a local or future Git dependency cannot impersonate a trusted registry package.

Approved scripts must run after the package receives a private writable project copy.
Scripts must receive a documented, minimal environment.
Secrets used for registry authentication must not be inherited.
Script output must identify package, version, lifecycle stage, and workspace.
Failures in required dependencies must fail the install.
Failures in optional dependencies may remove that optional snapshot and continue with a warning.

Sandboxing is out of scope for the initial release.
The CLI must say clearly that approval permits arbitrary code execution as the current user.

### 9.9 Offline and CI behavior

`bnpm fetch --frozen-lockfile` must read only the lockfile and configuration needed for registry and store access.
It must not require workspace source files after the lockfile is available.
`bnpm install --offline --frozen-lockfile` must materialize entirely from the store.
Missing entries must be reported together in one error rather than one failure per rerun.

The CLI must detect common CI environments but must not silently enable frozen mode.
A separate `bnpm ci` alias may be added later after clean-install semantics are specified.

## 10. Bend2 execution model

### 10.1 Host and pure-compute boundary

The package manager should be one Bend2 program when the released language and runtime expose the required IO and foreign-function interfaces.
The architecture must still keep effects at the edge.

Host-side responsibilities:

- DNS, TLS, HTTP, proxy, and credential handling.
- Filesystem reads, writes, links, clones, permissions, and atomic renames.
- SQLite calls and transaction boundaries.
- Process creation for lifecycle scripts.
- Terminal reporting and signal handling.
- GPU availability checks and dispatch decisions.

Pure or bounded-compute responsibilities:

- Semver parsing and range matching.
- Candidate filtering and deterministic ordering.
- Dependency and peer-context graph transforms.
- SRI decoding and digest comparison.
- Batched file hashing.
- Archive-entry validation after headers are parsed.
- Package index construction.
- Lockfile ordering and canonical serialization inputs.

This boundary allows the same pure functions to run on CPU, Metal, or CUDA without changing observable results.

### 10.2 GPU candidates

| Stage | Initial backend | GPU policy |
| --- | --- | --- |
| Metadata JSON parsing | CPU | Benchmark after release, because variable-length parsing and transfer may dominate |
| Semver candidate filtering | CPU and multicore Bend2 | GPU only for unusually large batched resolution sets |
| Peer graph resolution | CPU and multicore Bend2 | Keep coordination on CPU until deterministic speedup is demonstrated |
| Tarball SHA-512 | CPU streaming | GPU only for a sufficiently large in-memory batch |
| Gzip decompression | CPU library | Do not move to GPU in the initial release |
| Tar header parsing | CPU | Keep sequential archive parsing on CPU |
| Extracted file hashing | Bend2 parallel CPU | Primary GPU experiment because files are independent after parsing |
| File validation and classification | Bend2 parallel CPU | Batch with hashing when transfer cost is already paid |
| Filesystem materialization | Host CPU | Never dispatch filesystem calls to GPU |
| Lockfile rendering | CPU | GPU provides no expected benefit |

### 10.3 Dispatch policy

Automatic dispatch must use input size, item count, prior calibrated throughput, available device memory, and current backend availability.
It must include host-to-device and device-to-host transfer in its cost estimate.
The first run may perform a short calibration and save non-sensitive device statistics in the user cache.
Users must be able to force `--cpu` or `--gpu` for debugging and benchmarking.

GPU failure before project mutation may fall back to CPU with a warning.
GPU failure after mutation begins must abort the transaction and leave the previous project generation active.
The same stage must produce byte-identical outputs on CPU, Metal, and CUDA.

## 11. Data model

### Package identity

`PackageId = registry_origin + package_name + exact_version + artifact_integrity`

The registry origin is part of identity to prevent one registry from substituting the same name and version from another origin.
The integrity value binds the identity to exact bytes.

### Snapshot identity

`SnapshotId = PackageId + canonical_peer_context + resolution_settings_hash`

The peer context is a sorted mapping from peer name to resolved package identity.
The settings hash includes only settings that change dependency visibility or materialized content.

### Blob identity

`BlobId = algorithm + digest`

SHA-512 is the default for new store objects.
The package index records path, blob identity, size, executable bit, and safe link metadata.

### Install generation

An install generation records the lockfile digest, importer set, snapshot set, root links, binary links, materialization backend, and completion state.
A generation is visible only after its completion record is durable.

## 12. Configuration

Project configuration should use `bnpm.toml`.
Registry authentication remains compatible with the relevant `.npmrc` subset so teams do not need to duplicate secrets.

Required project settings:

- Registry mappings by scope.
- Store path override.
- Link backend.
- Network and script concurrency.
- Proxy and certificate settings.
- Release-age threshold and exceptions.
- Lifecycle-script allow list.
- Engine and peer strictness.
- GPU policy: `auto`, `cpu`, or `gpu`.

Configuration precedence must be documented and deterministic:

1. CLI flags.
2. Environment variables.
3. Project `bnpm.toml`.
4. User configuration.
5. Built-in defaults.

Credentials must be resolved separately from ordinary configuration and redacted before diagnostics are built.

## 13. Security requirements

- Require HTTPS for registry and tarball URLs unless the user explicitly configures an insecure local registry.
- Strip authorization headers when a redirect changes origin.
- Bind scoped packages to their configured registry in the lockfile.
- Prefer SRI SHA-512 and reject mismatches without retrying another mirror silently.
- Deny dependency lifecycle scripts by default.
- Apply a configurable minimum release age during fresh resolution.
- Reject exotic transitive protocols in the initial release.
- Normalize archive paths before writing and reject traversal or absolute paths.
- Reject special device files, sockets, and unsupported archive entry types.
- Bound compressed bytes, unpacked bytes, file count, path length, and compression ratio.
- Create cache files and auth configuration with user-only permissions.
- Never log credentials, authorization headers, signed query parameters, or full proxy URLs containing secrets.
- Use atomic commits for store entries, lockfiles, manifests, and install generations.
- Treat cache contents as untrusted on every index-to-blob boundary.
- Keep a machine-readable security event in JSON reporter mode for blocked scripts and integrity failures.

## 14. Reliability and concurrency

The global store must support multiple `bnpm` processes and multiple projects at once.
Long global locks are prohibited.
Content blobs use immutable create-if-absent writes.
Index updates use short transactions.
Project generation switching uses a project-local lock.

Signal handling must stop new work, allow in-flight atomic operations to finish or roll back, and remove process-owned staging files.
A later invocation must detect abandoned staging directories by owner metadata and age.
It must never delete staging data that belongs to a live process without proving the process identity is stale.

Network failures must retain verified store content already committed during the run.
They must not commit a partial lockfile or project generation.

## 15. User experience

Default output should show five stable phases:

1. Resolve.
2. Fetch.
3. Verify and index.
4. Link.
5. Build approved packages.

Repeated progress updates must stay on one terminal region when the terminal supports it.
Append-only and JSON reporters must not emit control sequences.
Errors must name the failed package, source, stage, and actionable recovery command without exposing secrets.

A successful install summary must report:

- Added, reused, downloaded, and removed package counts.
- Bytes downloaded and bytes reused.
- Materialization backend.
- CPU or GPU stages used.
- Blocked or executed lifecycle scripts.
- Time by phase.

The summary must not claim GPU acceleration when GPU initialization occurred but no stage was dispatched.

## 16. Architecture

```text
package.json + bnpm.toml + bnpm.lock
                  |
                  v
        manifest and config loader
                  |
                  v
       resolver and peer snapshotter
          |                   |
          | cache hit         | metadata miss
          |                   v
          |          npm registry metadata client
          |                   |
          +-------------------+
                  |
                  v
          immutable install plan
                  |
         +--------+--------+
         |                 |
         v                 v
  artifact fetcher     store lookup
         |                 |
         +--------+--------+
                  |
                  v
       integrity and archive pipeline
         CPU / Metal / CUDA batches
                  |
                  v
       content store + transactional index
                  |
                  v
       project generation materializer
                  |
                  v
      binary links + approved scripts
                  |
                  v
        atomic generation activation
```

The resolver, store, and linker must communicate through immutable value types.
No stage may infer missing information from a path name when the information belongs in the plan or index.

## 17. Delivery plan

### Phase 0: Bend2 capability spike

This phase starts against the public Bend2 release expected on 2026-09-18.

Deliverables:

- Confirm filesystem, sockets, TLS, process execution, environment access, signals, and FFI support.
- Confirm how one binary selects CPU, Metal, and CUDA backends.
- Measure host-device transfer and dispatch overhead on representative Apple and NVIDIA hardware.
- Implement one end-to-end read-only experiment: fetch an npm tarball, verify its SRI, parse entries, and print a package index.
- Decide whether SQLite and HTTP run directly through Bend2 IO or through a narrow host adapter.
- Freeze the minimum Bend2 compiler and runtime version.

Exit criteria:

- The experiment verifies a real registry tarball on CPU.
- Metal or CUDA executes at least one pure batch stage where supported.
- The CPU result and GPU result are byte-identical.
- Missing runtime capabilities and required adapters are documented before the store format is fixed.

### Phase 1: Deterministic resolver and lockfile

Deliverables:

- Manifest parser.
- Abbreviated metadata client and cache.
- Semver and dist-tag resolution.
- Optional, platform, engine, and peer resolution.
- Immutable install plan.
- Deterministic `bnpm.lock` writer and frozen validation.

Exit criteria:

- Fixture graphs match expected exact versions and peer contexts.
- Reordered manifests and randomized network completion produce the same lockfile.

### Phase 2: Verified store

Deliverables:

- Streaming tarball download.
- SRI verification.
- Safe extraction.
- Content-addressed blobs.
- Transactional package index.
- Concurrent writer handling.
- Store status and prune.

Exit criteria:

- Corruption, traversal, truncation, archive bombs, and interrupted writes are rejected without poisoning the store.
- Parallel processes can fetch the same and different packages safely.

### Phase 3: Isolated linker

Deliverables:

- `node_modules/.bnpm` snapshots.
- Dependency and root symlinks.
- Clone, reflink, hardlink, and copy backends.
- Binary links.
- Workspace links.
- Atomic project generations.

Exit criteria:

- Node.js loads direct and transitive dependencies in the correct peer contexts.
- Undeclared dependencies are inaccessible in strict mode.
- Cross-filesystem and Windows fallback behavior passes the compatibility matrix.

### Phase 4: Secure builds and complete CLI

Deliverables:

- Lifecycle-script approvals.
- Private writable build copies.
- `add`, `remove`, `update`, `list`, `why`, and `fetch`.
- Offline and prefer-offline behavior.
- Reporters and diagnostics.

Exit criteria:

- Common native packages install only after explicit approval.
- Auth tokens do not reach scripts or logs.
- Fetch followed by offline install makes no network calls.

### Phase 5: Performance and GPU policy

Deliverables:

- Stage-level tracing.
- CPU, Metal, and CUDA benchmark harness.
- Calibrated automatic dispatch.
- Memory and concurrency tuning.

Exit criteria:

- All success measures in section 4.2 pass on the published reference corpus and hardware.
- GPU dispatch is enabled only for stages with repeatable end-to-end gains.

## 18. Validation plan

### Compatibility corpus

The corpus must include:

- Small applications with no peers.
- React applications with multiple peer contexts.
- TypeScript monorepos with workspace links.
- Packages with optional platform binaries.
- Packages with approved native build scripts.
- Scoped packages from a private test registry.
- Deep, wide, cyclic, and conflicting dependency graphs.
- Packages containing many small files and a few large files.

Each fixture must run an actual Node.js program that imports its direct and transitive dependencies.
Checking only directory shape is insufficient.

### Failure injection

Inject failures after every durable boundary:

- Metadata response received.
- Tarball chunk written.
- Integrity completed.
- Blob created.
- Index transaction opened and committed.
- Virtual store staged.
- Root links switched.
- Lifecycle script started.

After restart, the store and project must be valid or clearly recoverable without manual deletion.

### Security fixtures

Include malicious archives with traversal paths, absolute paths, symlink escapes, duplicate entries, device files, oversized declarations, excessive file counts, and decompression bombs.
Include redirects across registry origins and logs containing synthetic credentials to verify redaction.

### Performance matrix

Measure cold, warm, offline, and no-op installs.
Run each case on CPU-only, Apple Metal, and NVIDIA CUDA configurations where available.
Report median, p95, downloaded bytes, files created, peak memory, CPU time, GPU time, transfer time, and filesystem operations.
Compare against current stable Bun and pnpm versions with equivalent lifecycle and linker policies.
Do not compare an isolated install against an unsafe or materially different configuration without labeling the difference.

## 19. Risks and mitigations

| Risk | Effect | Mitigation |
| --- | --- | --- |
| Bend2 IO or FFI is incomplete at release | Core host operations cannot be implemented directly | Keep adapters narrow, typed, and replaceable; settle this in Phase 0 |
| GPU overhead exceeds useful work | Slower installs and higher energy use | CPU default for small batches; enable automatic GPU dispatch only after calibration |
| Package manager is I/O-bound | Compute optimization does not improve wall time | Optimize request reuse, conditional metadata, store hits, and filesystem operation count first |
| Peer resolution is incorrect | Runtime loads the wrong dependency | Use canonical peer contexts and execute real Node.js compatibility fixtures |
| Store corruption spreads across projects | Multiple projects fail or consume modified bytes | Immutable CAS, transactional index, status verification, private build copies, and atomic writes |
| Hard-linked files are mutated | Shared cache content changes | Prefer copy-on-write clones and copy before any writable build step |
| SQLite blocks GPU-oriented purity | Architecture becomes coupled to host effects | Keep store index behind a small effectful interface and pure values on both sides |
| Lifecycle scripts compromise the host | Supply-chain attack during install | Deny by default, redact secrets, require explicit approval, and document arbitrary-code risk |
| Strict layout breaks broken packages | Adoption suffers | Give exact phantom-dependency diagnostics; defer hoisted mode until core correctness is stable |
| Cache format changes after release | Users must delete large stores | Version the store and support explicit migrations before declaring the format stable |
| Cross-platform link semantics differ | Installs work only on the developer's machine | Detect capabilities at runtime and maintain clone, hardlink, and copy fallbacks |

## 20. Open questions

These questions must be answered during Phase 0 or before the named phase begins.

1. Which Bend2 APIs provide HTTP, TLS, files, processes, signals, and environment access?
2. Can a single executable choose CPU, Metal, or CUDA at runtime?
3. Does Bend2 support streaming byte buffers without avoidable copies across the host boundary?
4. Can Bend2 call SQLite and platform clone or reflink syscalls directly and safely?
5. What is Bend2's stable representation for byte strings, maps, and large immutable graphs?
6. How are GPU out-of-memory and device-loss errors surfaced?
7. Which SHA-512 implementation is fastest on each backend, including transfer cost?
8. Should the first stable store retain verified tarballs for repair, or only file blobs and package indexes?
9. What minimum Node.js versions and Windows modes form the compatibility contract?
10. Which configuration fields belong in `bnpm.toml`, and which `.npmrc` fields must remain compatible?
11. Should release-age filtering be enabled by default, and what default avoids surprising first-time users?
12. Which package corpus and machines will define public performance claims?

## 21. Release criteria

The initial release is ready when all of the following are true:

- A clean machine can install the compatibility corpus from npm-compatible registries.
- A warm machine can repeat the install without downloading package content.
- A fetched lockfile can be installed offline with no DNS or socket activity.
- Frozen mode rejects every tested manifest or resolution-setting mismatch before mutation.
- Integrity, path traversal, archive bomb, redirect credential, and lifecycle-script tests pass.
- Two concurrent installs sharing a store complete without corruption.
- Killing the process at each injected boundary leaves recoverable state.
- Real Node.js programs load the expected packages and peer versions from the isolated layout.
- CPU, Metal, and CUDA produce identical pure-stage outputs where those backends are supported.
- Published benchmarks include commands, versions, hardware, cache state, policy differences, and raw results.
- Unsupported protocols and commands fail explicitly rather than falling back to npm or another package manager.

## 22. Decision record

### Use an isolated layout first

An isolated layout prevents phantom dependencies and gives each peer context an explicit identity.
This is harder to implement than a flat tree, but it avoids making a compatibility shortcut part of the permanent store model.

### Use a per-file content-addressed store

A per-file store can reuse unchanged files across package versions and makes file integrity explicit.
Its index must avoid the millions-of-small-metadata-files problem, so the design requires a transactional consolidated index.

### Keep registry origin in package identity

Name and version do not identify bytes or trust origin.
Registry origin plus integrity prevents silent substitution across public and private registries.

### Deny scripts by default

Lifecycle scripts execute arbitrary code and are a common supply-chain entry point.
Packages that need a build step remain supported through explicit approval and private writable copies.

### Publish the knot command as scoped npm packages

The unscoped npm name `knot` is already taken.
The distribution plan publishes a scoped wrapper whose `bin` is the `knot` command, plus optional platform packages selected with `os`, `cpu`, and `libc`.
The plan, the release gate, and the gaps in Knot's own installer live in `docs/npm-distribution.md`.

### Treat GPU execution as a stage-level optimization

A package manager cannot move sockets, filesystem mutation, or process creation to a GPU usefully.
Bend2 is most relevant where independent pure computations are already present.
This decision keeps the product useful on CPU-only systems and makes every GPU claim measurable.