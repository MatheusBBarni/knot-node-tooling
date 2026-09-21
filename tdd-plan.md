# Test-driven development plan

Status: Draft

Date: 2026-09-17

Applies to: `docs/package-manager-prd.md`, `docs/ts-compiling-prd.md`, `docs/bundler-prd.md`, and `docs/test-runner-prd.md`

## 1. Decision

This project will use test-driven development for every behavioral change.
Each implementation cycle starts with one failing test at an agreed public seam.
The cycle ends only after the focused test passes through the real executable path.

The initial test driver will be Node.js 24 LTS and its built-in `node:test` module.
It will launch the `bnpm` executable as a black box, create temporary projects, run local services, and inspect observable results.
The product's future `bnpm test` command will be tested by this independent driver rather than trusted to verify itself.

Bend2 laws and proofs will supplement executable tests after a public toolchain is available and pinned.
They will be used for pure invariants that are suitable for proof.
They will not replace runtime tests for filesystems, networks, processes, JavaScript behavior, or crashes.

Lean is not part of the initial development stack.
A Lean model would be useful only if a property cannot be expressed adequately in Bend2 and the project can also maintain a credible correspondence between the Lean model and the Bend2 implementation.
Without that correspondence, a Lean proof says nothing about the shipped binary.

## 2. Current constraint

The Bend2 capability gate has passed.
The pin is `toolchain.json`: Bend 2.0.4 from `https://bend-lang.com/dl/2.0.4.tar.gz`, Apache-2.0, SHA-256 `dff7d7e7b42a4572c79d3084093521d198a93af4684d4a10fe8322c265481734`.
Details are in `docs/bend2-capability.md`.

Frozen commands:

- `bend --version` prints `bend 2.0.4`.
- `bend <file.bend>` checks and runs `main` on the JS backend.
- `bend <file.bend> -o <bin>` builds a native CPU binary.
- A false or open proof exits 1.
- Missing `bend` fails the acceptance driver.

The external Node.js 24 `node:test` driver remains the root acceptance runner.
Bend2 has no product test runner of its own.
Lean is not used.

Host gaps that later slices must cover with adapters: argv, TLS, HTTP, OS processes, mkdir/unlink/rename/symlink, and SQLite.

## 3. Testing seams

Tests will target observable behavior through public boundaries.
Private functions, internal field copies, task counts, allocation choices, and incidental formatting are not test seams.

The following seams are proposed as the project contract.
They must be accepted before the first test is written.

### 3.1 CLI seam

The primary seam is the `bnpm` process.

A CLI test may observe:

- Exit status.
- Standard output.
- Standard error.
- Stable diagnostic codes and source locations.
- Files and directories created under the test workspace.
- Network requests received by a local server.
- Child processes launched through a controlled fixture.
- The behavior of generated JavaScript when executed by Node.js.
- The behavior of generated web output in a real browser.

A CLI test must not inspect private in-memory structures.

### 3.2 Pure Bend seam

Pure algorithms will expose small executable adapters for test input and output.
The adapters will accept a canonical serialized request and return a canonical serialized response.
They exist only where the same public behavior would otherwise require a slow or ambiguous CLI setup.

Candidate adapters include:

- Semver parsing, comparison, and range membership.
- Dependency graph resolution.
- Peer context construction.
- Path normalization and archive path validation.
- Integrity metadata parsing.
- JavaScript tokenization and parsing.
- Module resolution.
- Source-map encoding.
- Chunk planning.
- Snapshot serialization.

The protocol is the seam.
Internal Bend data representation remains private.

### 3.3 Law and proof seam

A Bend2 law may protect an invariant when all relevant inputs and effects can be represented in the language.

Initial law candidates include:

- Reordering equivalent manifest input does not change the canonical lockfile.
- A normalized archive path cannot escape its extraction root.
- Every resolved version satisfies its selected range.
- Frozen resolution cannot change the graph represented by the lockfile.
- A cache entry key equals the digest of its bytes.
- Parser and source-map ranges remain within source bounds.
- Every emitted chunk dependency refers to an emitted chunk.
- CI shards are complete and pairwise disjoint.

A proof failure blocks the same way as a failed test.
A law must describe product behavior rather than an implementation representation.

### 3.4 Runtime compatibility seam

Generated JavaScript will be tested by executing it in the supported runtime.
String comparison of emitted code is insufficient when runtime behavior is the contract.

Runtime observations include:

- Return values.
- Exceptions.
- Standard output and error.
- Import and side-effect order.
- ESM live bindings.
- CommonJS cache identity.
- Dynamic import boundaries.
- Process exit status.

### 3.5 Browser seam

Browser-targeted bundles, CSS, HTML, source maps, and watch behavior will be tested in a real browser.
DOM parsing, computed styles, resource URLs, module execution, console failures, and network requests are observable behavior.

Source text alone is not evidence that a page works.

## 4. Test stack

### 4.1 External acceptance driver

Node.js 24 LTS with `node:test` is the root test driver.
It is independent of the product under test and requires no third-party test framework.

The driver will provide:

- Direct process spawning without a shell.
- Temporary workspaces with automatic cleanup.
- A local npm-compatible registry server.
- A controllable HTTP and HTTPS server.
- Fixture package publication.
- Deterministic environment construction.
- Timeouts and process-tree cleanup.
- Canonical file-tree inspection.
- Stable stdout and stderr normalization.
- Node.js execution of generated files.
- Browser launch for browser-facing fixtures.

### 4.2 Bend checks

Every changed Bend source file must pass the released Bend checker.
Every changed law and proof must pass the proof checker.
Unsafe or incomplete proof escape hatches are forbidden in production modules.

The exact commands will be frozen only after the capability spike.
No script may silently skip Bend checks because the compiler is missing.

### 4.3 Bend executable tests

Small Bend programs will test pure modules through their public adapters.
The external driver will compile and execute each program and validate its structured result.

A Bend executable test must fail through a nonzero process status or an unambiguous structured failure record.
Success must not depend on matching an informal log message.

### 4.4 Golden fixtures

Golden files are appropriate for stable, reviewable artifacts:

- Lockfiles.
- Diagnostics.
- Parsed or lowered public representations.
- Transpiled JavaScript.
- Source maps.
- Bundle manifests.
- JUnit XML.
- JSON Lines events.

A golden test must still defend an observable contract.
Snapshots of private state are prohibited.
Golden updates require review of the complete semantic difference.

### 4.5 Differential tests

Differential references will be used only where contracts overlap.

References include:

- npm, pnpm, and Bun for package behavior.
- TypeScript, Bun, and esbuild for compiler behavior.
- Node.js for module resolution and JavaScript semantics.
- Bun, Jest, Vitest, and Node's test runner for test behavior.

A reference difference is evidence to classify, not an automatic product defect.
Each difference must be labeled intended, unsupported, reference-specific, or defective.

### 4.6 Fault tests

Fault injection will exercise durable and process boundaries.
It will interrupt downloads, writes, index transactions, link activation, worker execution, snapshot publication, coverage publication, and report publication.

A fault test must verify the state after restart.
A process exit alone is not enough.

## 5. The development loop

Each cycle covers one behavior and one seam.
Horizontal batches of speculative tests are prohibited.

### 5.1 Select one behavior

Write a short story with:

- The user-visible behavior.
- The selected public seam.
- The input fixture.
- The independent expected result.
- The plausible defect the test would catch.
- The smallest implementation boundary involved.

If the expected result is derived by repeating the implementation algorithm, the oracle is invalid.

### 5.2 Red

Write one test.
Run only that test through the real seam.
Record the failure mode.

A valid red result fails for the missing behavior.
Syntax errors, missing imports, broken fixture setup, and unavailable tools do not count as red.

The test is revised until its failure demonstrates the intended missing capability.

### 5.3 Green

Implement the smallest behavior that makes the focused test pass.
Do not add adjacent features, extension points, aliases, fallback modes, or speculative abstractions.

Run:

1. The focused external test.
2. The relevant Bend executable test, if one exists.
3. The relevant laws and proofs.
4. The smallest related regression set.

The cycle is green only when the real output or side effect is observed.

### 5.4 Review and refactor

Refactoring happens in a separate review step while all relevant tests are green.

The review checks:

- Naming and module boundaries.
- Duplicate logic.
- Unnecessary allocations and copies.
- Effectful work inside pure modules.
- Hidden nondeterminism.
- Error and cleanup paths.
- Test sensitivity to the intended behavior.

Run the focused and related regression sets after each refactor.
No new behavior is added during this step.

### 5.5 Complete the increment

An increment is complete when:

- The original test passes.
- The test would fail under the plausible defect it protects against.
- Applicable laws pass.
- Related regression tests pass.
- The behavior has been exercised through the real surface.
- Temporary scripts and debug output are removed.
- Documentation is updated only when the public contract changed.

A focused commit may be created when requested.

## 6. Test quality rules

A permanent test must protect behavior, a boundary, an invariant, a state transition, precedence, or a real failure.

Permanent tests must not assert:

- Private function calls.
- Internal field forwarding.
- Exact task or worker counts unless part of a public option.
- Source text when runtime behavior is the contract.
- That output is merely nonempty.
- That a call does not throw without checking its result.
- Mock values returned unchanged by the same mock.
- Incidental formatting outside a documented format.

Use a throwaway smoke program when a behavior needs demonstration but does not justify permanent maintenance.
Keep a regression test when a plausible future defect would make it fail.

Mocks are allowed only at true external boundaries such as HTTP servers, time, process launch, or platform capability probes.
Internal collaborators are not mocked.

## 7. Fixture design

Fixtures will be small enough that their expected behavior can be understood without running the implementation.
Each fixture owns its inputs and expected outputs.
Fixtures must not share writable state.

Recommended layout:

```text
tests/
  acceptance/
    cli/
    package-manager/
    compiler/
    bundler/
    test-runner/
  fixtures/
    registries/
    packages/
    compiler/
    bundler/
    test-runner/
    failures/
  golden/
  differential/
  fault/
  support/
    process.mjs
    workspace.mjs
    registry.mjs
    assertions.mjs
laws/
proofs/
```

The names are proposed contracts.
They should be created only as the first test in each category needs them.
Empty directory scaffolding is prohibited.

Fixture rules:

- No public network access in correctness tests.
- No dependency on wall-clock ordering unless time is the subject.
- No dependency on global machine caches.
- No fixed ports.
- No absolute paths in expected artifacts.
- No locale-dependent output.
- No unseeded randomness.
- No test may require a GPU unless marked for the backend matrix.

## 8. First vertical slices

The implementation order follows user-visible capabilities rather than internal layers.
Each slice includes its own red test, minimal implementation, and observable verification.

### Slice 0: Bend2 capability gate

Behavior:

A pinned Bend2 toolchain can check a valid source file, reject an invalid proof, compile a program, and run it on the CPU in CI.

Test seam:

The published Bend CLI and resulting process status.

Exit conditions:

- The compiler source or artifact is reproducibly obtainable.
- A valid program checks and executes.
- An invalid law or proof returns a nonzero status.
- Tool absence is a hard failure.
- The toolchain version is recorded in one project file.

No product implementation begins before this gate passes.

### Slice 1: Executable shell

Behavior:

`bnpm --version` exits successfully and prints the exact project version to standard output.
An unknown command exits unsuccessfully with a stable diagnostic code.

Test seam:

The real `bnpm` process.

Purpose:

This establishes the compiler invocation, executable publication, Node driver, timeout handling, and diagnostic envelope without inventing domain architecture.

### Slice 2: One package install

Behavior:

`bnpm install` downloads one package with no dependencies from a local registry, verifies its integrity, installs it, and allows Node.js to import it.

Red test:

The external driver creates a manifest, starts the local registry, runs `bnpm install`, and executes a Node.js import that initially fails.

Minimum green path:

- Parse one manifest dependency.
- Fetch one metadata document.
- Select one exact version.
- Fetch one tarball.
- Verify SRI.
- Extract safe regular files.
- Materialize the package.
- Let Node.js import the package.

The slice does not include peers, workspaces, lifecycle scripts, offline mode, or GPU work.

### Slice 3: Integrity rejection

Behavior:

A tarball whose bytes do not match its SRI is rejected before any store entry or project generation becomes visible.

This slice establishes the first security boundary and the first durable-state failure assertion.
A Bend law should connect a published content key to the digest of its bytes when the released language can express it.

### Slice 4: Deterministic resolution and lockfile

Behavior:

Two equivalent manifests with different key ordering produce the same resolved graph and byte-identical `bnpm.lock`.

Add semver, transitive dependencies, peer contexts, frozen validation, and failure cases one behavior at a time.
The resolver executable adapter becomes justified when CLI fixtures become too broad to isolate a graph defect.

### Slice 5: One TypeScript transpilation

Behavior:

`bnpm transpile input.ts` removes a type annotation, emits JavaScript and a source map, and the JavaScript produces the expected result in Node.js.

Expand with one syntax or semantic boundary per cycle.
Invalid syntax fixtures must assert diagnostic code and source range rather than prose alone.

### Slice 6: One module graph

Behavior:

The compiler resolves two local ESM modules, preserves an imported live binding, and emits code that behaves like the untransformed reference in Node.js.

This slice establishes canonical module identity and executable semantic comparison before bundling.

### Slice 7: One bundle

Behavior:

`bnpm build` combines a two-module ESM graph into one browser or Node.js artifact whose observable behavior matches the unbundled graph.

Tree shaking, CommonJS, splitting, CSS, assets, and HTML are added through separate cycles.
Every optimization test must execute the built artifact.

### Slice 8: One test file

Behavior:

`bnpm test` discovers one `.test.ts` file, reports one passing test, reports one failing assertion, and returns the correct process status.

The independent Node driver verifies both runs.
The product test runner is not allowed to declare itself correct based solely on its own summary.

### Slice 9: Process isolation

Behavior:

A global mutation in one test file is not visible in another file.
A worker that loops forever is terminated by the native coordinator and causes a nonzero run result.

This slice establishes the default process-per-file isolation contract before parallel scheduling.

## 9. Product workstreams after the backbone

After the first vertical slices pass, work proceeds in the PRD order within each product.
Only one behavior is active in a TDD cycle.

### 9.1 Package manager

Order:

1. Exact and ranged version selection.
2. Transitive graph resolution.
3. Peer contexts.
4. Optional and platform dependencies.
5. Deterministic lockfile and frozen mode.
6. Content-addressed store and concurrent writers.
7. Safe archive extraction.
8. Strict isolated linker.
9. Workspaces.
10. Approved lifecycle scripts.
11. Offline and recovery behavior.

Every install fixture ends by executing a real Node.js import when runtime visibility is part of the behavior.

### 9.2 Compiler

Order:

1. Lexer boundaries.
2. Parser productions and ambiguities.
3. TypeScript removal.
4. JSX transforms.
5. Scope and symbol binding.
6. Module resolution.
7. Semantic lowering.
8. Printing and source maps.
9. Incremental caching.
10. Watch invalidation.

Every semantic transform fixture compares runtime behavior with an independent reference.

### 9.3 Bundler

Order:

1. ESM graph linking.
2. CommonJS and interoperation.
3. Effect-preserving tree shaking.
4. Dynamic imports and code splitting.
5. Incremental rebuilds.
6. Data and asset loaders.
7. CSS graph and ordering.
8. HTML entry points.
9. Chunk quality.
10. Extension isolation.

Every removal optimization has paired retained and removable fixtures.
Every output artifact is executed, loaded, or rendered according to its target.

### 9.4 Test runner

Order:

1. Discovery and process status.
2. Registration and nested suites.
3. Hooks and failure propagation.
4. Promise, callback, and timeout behavior.
5. File isolation.
6. Parallel scheduling and sharding.
7. Assertions and diffs.
8. Mocks and fake time.
9. Snapshots.
10. Coverage.
11. Watch mode.
12. Compatibility fixtures.

Reporter totals are always checked against the coordinator's final event identities.

## 10. Regression levels

### 10.1 Focused

Runs one behavior under development and its smallest required setup.
This command is used for every red and green step.

### 10.2 Fast

Runs all deterministic CPU-only tests that do not require browsers, fuzzing, external tool matrices, or large corpora.
This is the normal pre-commit gate.

### 10.3 Full

Runs all deterministic acceptance, golden, failure, recovery, browser, and supported Node.js matrix tests.
This is the merge gate.

### 10.4 Compatibility

Runs selected fixtures against external reference tools.
Tool versions and effective options are recorded with results.
This gate may be scheduled or required for changes to compatibility-sensitive behavior.

### 10.5 Backend equivalence

Runs qualified pure workloads on one CPU worker, multicore CPU, Metal, and CUDA where available.
Canonical outputs must be identical.
Performance is recorded separately from correctness.

### 10.6 Fuzz and stress

Runs parser, resolver, archive, protocol, interruption, and long-running concurrency cases.
Every discovered defect is reduced to a permanent deterministic regression fixture before it is fixed.

## 11. Continuous integration

After the Bend2 capability gate passes, every pull request runs:

- Bend checks and proofs.
- The fast CPU suite.
- The supported primary Node.js version.
- Formatting and static diagnostics.
- A check that focused or skipped tests were not committed accidentally.

The merge queue runs:

- The full deterministic suite.
- The complete supported Node.js LTS matrix.
- Linux, macOS, and Windows platform fixtures appropriate to the changed area.
- Browser fixtures for web-facing changes.
- Recovery and fault fixtures for durable-state changes.

Scheduled jobs run:

- Differential compatibility suites.
- Fuzzing and stress tests.
- GPU equivalence and performance tests.
- Large registry and syntax corpora.
- Warm, cold, cached, and no-op benchmarks.

A missing optional GPU may skip only the GPU job.
A missing Bend compiler, Node.js runtime, browser, or fixture required by a mandatory job is an infrastructure failure.

## 12. Failure handling

A flaky test is a defect.
It is quarantined only when it blocks unrelated work and has an owner, a reproducible record, and a short removal condition.
Quarantine is never success for a release gate.

Tests must capture enough evidence to diagnose:

- Command and normalized arguments.
- Tool versions.
- Seed.
- Exit status and signal.
- Bounded stdout and stderr.
- Relevant file tree and artifact digests.
- Local server request log.
- Worker or backend identity when relevant.

Secrets, registry credentials, and authorization headers are redacted before evidence is stored.

## 13. Human and agent responsibilities

The human approves:

- The public seam.
- The behavior and independent oracle.
- Intentional compatibility differences.
- Destructive fixture changes.
- Golden updates with semantic differences.
- Stable API and format commitments.

The agent performs:

- Relevant code and PRD reading.
- One failing test at the approved seam.
- The red run and failure explanation.
- Minimal implementation.
- Focused and related verification.
- Review for simplicity and dead code.
- Evidence-backed delivery notes.

The agent must stop before writing a test when the public seam has not been agreed.
It must not compensate by testing a private helper.

## 14. Test inventory and traceability

Each permanent test should name the behavior rather than the implementation.

Recommended name form:

```text
<actor or command> <observable behavior> <condition>
```

Examples:

- `install rejects a tarball with the wrong integrity digest`.
- `frozen install rejects a manifest that differs from the lockfile`.
- `transpile preserves a live binding across an ESM cycle`.
- `bundle keeps a getter whose result is unused`.
- `test kills a worker that exceeds the file deadline`.

Tests may reference a PRD section or issue in metadata, but the behavior must remain understandable without that reference.
A test matrix should be generated from executable metadata once the harness exists.
A hand-maintained spreadsheet is not a source of truth.

## 15. Metrics

Coverage percentage is diagnostic information, not the main quality target.
A high percentage can coexist with weak assertions.

The useful project measures are:

- Time from red to green for focused cycles.
- Focused and fast suite duration.
- Flake rate.
- Regression escape count by product area.
- Number of reduced permanent fixtures from fuzzing and differential testing.
- Compatibility corpus pass rate.
- Backend equivalence failures.
- Mean time to classify a differential result.

No metric may reward adding low-value assertions or splitting one behavior into redundant cases.

## 16. Initial definition of done

The TDD system is ready for product work when:

- The Bend2 capability gate passes with a pinned toolchain.
- The proposed CLI, pure adapter, law, runtime, and browser seams are accepted.
- One Node.js acceptance test launches the real Bend-produced `bnpm` executable.
- The first test has demonstrated a valid red result and then passed after minimal implementation.
- Temporary workspaces and child processes are cleaned after success, failure, and interruption.
- CI runs the fast CPU suite without relying on a developer machine cache.
- A failed Bend check, proof, acceptance test, or required tool setup makes CI fail.
- The test commands and tool versions are discoverable from the repository.

## 17. First decision before implementation

Approve or change these seams before the first test is written:

1. The `bnpm` CLI is the primary acceptance seam.
2. Canonical serialized adapters are allowed only for pure algorithms that are costly to isolate through the CLI.
3. Bend2 laws protect pure product invariants and never stand in for effectful tests.
4. Node.js 24 LTS `node:test` remains the independent root driver.
5. Real Node.js and browser execution are required whenever generated runtime behavior is the contract.

The recommended choice is to accept all five.

## 18. References

- [Bend public repository](https://github.com/bendlang/bend).
- [Bend official site](https://bend-lang.org/).
- [Bend2 proof example](https://bend2.dev/learn/proofs/).
- [Bend2 and Lean comparison](https://bend2.dev/notes/bend2-vs-lean/).
- [Node.js test runner](https://nodejs.org/api/test.html).
- [Lean Lake](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/).
