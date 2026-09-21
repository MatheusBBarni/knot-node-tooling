# Product requirements document: JavaScript and TypeScript test runner

Status: Draft

Date: 2026-09-17

Working CLI name: `bnpm`

Depends on: `package-manager-prd.md` and `ts-compiling-prd.md`

## 1. Summary

`bnpm test` will provide a Jest-style test runner coordinated by a native Bend2 executable.
It will discover, compile, schedule, isolate, execute, and report JavaScript, TypeScript, JSX, and TSX tests.

The product will not embed a JavaScript runtime.
The native coordinator will compile test graphs with the compiler defined in `ts-compiling-prd.md` and execute them in external Node.js worker processes.
The public test API will be available from `bnpm:test`.

The initial release will include:

- Deterministic test discovery and filtering.
- Nested suites, lifecycle hooks, serial tests, and concurrent tests.
- A practical Jest-compatible assertion API.
- Function mocks, spies, fake clocks, and timer control.
- External and inline snapshots.
- Source-mapped V8 coverage.
- Console, dots, JUnit XML, GitHub Actions, and JSON Lines reporters.
- Watch mode with dependency-aware selection.
- File-level parallelism, deterministic sharding, retries, and seeded randomization.
- Hard timeouts and process-tree cleanup.

Correctness and isolation come before startup benchmarks.
GPU execution is not part of the test runner's execution model because JavaScript execution, process control, and most test workloads are unsuitable for it.

## 2. Relationship to the other PRDs

The package manager owns dependency installation, workspace discovery, lockfile validation, and script execution policy.
The compiler owns parsing, module resolution, TypeScript removal, JSX lowering, syntax transforms, printing, and source maps.
The test runner consumes both systems.

The test runner owns:

- Test file discovery and selection.
- Test graph compilation requests.
- Runtime discovery and validation.
- Worker lifecycle and isolation.
- The `bnpm:test` library.
- Test registration and execution semantics.
- Assertions, mocks, timers, and snapshots.
- Coverage collection and source-map remapping.
- Test event aggregation and reporting.
- Watch-mode invalidation.

The test runner must preserve modules as separate runtime units.
It must not route test execution through the production bundler because bundling can change module identity, evaluation order, dynamic imports, mocking behavior, and coverage locations.

## 3. Problem

A useful test runner must coordinate several systems that fail in different ways.

It must:

- Find the intended files without scanning dependency or generated directories unnecessarily.
- Compile TypeScript and JSX without changing runtime behavior.
- Preserve Node.js module resolution and package conditions.
- Run user code that can hang, crash, leak handles, spawn children, or terminate the process.
- Attribute asynchronous failures to the correct test or file.
- Isolate global state and module caches between files.
- Run independent files in parallel without interleaving unreadable output.
- Update snapshots without concurrent writes corrupting source files.
- Merge coverage from workers back to original source locations.
- Rerun the smallest safe set after a file change.
- Produce stable machine-readable output in local and CI environments.

Bun solves much of this by integrating its test runner directly with its JavaScriptCore-based runtime.
This project has a different boundary.
It must obtain strong test semantics while keeping the runtime external and replaceable.

## 4. Product principles

1. A test file gets a fresh runtime realm by default.
2. The native coordinator remains authoritative for deadlines, process cleanup, scheduling, and final status.
3. Test output and reports are derived from one versioned event stream.
4. Source locations always refer back to original source through validated source maps.
5. Identical inputs, configuration, runtime version, and seed produce identical selection and ordering.
6. A worker crash is an infrastructure failure, not a passing or skipped test.
7. Snapshot writes are centralized and atomic.
8. Compatibility claims are explicit and covered by fixtures.
9. Unsupported Bun or Jest behavior fails with a diagnostic instead of silently changing semantics.
10. The runner never invokes a shell to launch Node.js or test subprocesses.
11. Tests are trusted project code, but the coordinator still bounds resources and cleans up descendants.
12. CPU execution is always available.
13. GPU dispatch is used only by shared compiler stages that already satisfy the compiler PRD's performance gate.
14. Fast shared-state modes are opt-in and clearly weaker than the default isolation mode.

## 5. Goals

### 5.1 Initial stable release goals

- Run JavaScript, TypeScript, JSX, TSX, ESM, and CommonJS test projects on Node.js.
- Support macOS, Linux, and Windows on the same platforms as the package manager and compiler.
- Require a supported Node.js LTS release and provide a clear version diagnostic.
- Discover conventional `test`, `spec`, `_test`, and `_spec` file names.
- Support explicit files, directories, path filters, name filters, include globs, and exclude globs.
- Support nested suites, hooks, skipped tests, todo tests, focused tests, expected failures, table tests, and conditional tests.
- Support synchronous functions, returned promises, and callback-style tests with unambiguous completion rules.
- Enforce per-test, per-hook, and per-file deadlines.
- Run files in parallel while preserving readable per-file output.
- Provide deterministic CI sharding and duration-aware scheduling.
- Provide a stable assertion API with useful structural diffs.
- Provide mocks, spies, module substitution with documented boundaries, fake clocks, and fake timers.
- Provide external snapshots, inline snapshots, property matchers, and atomic updates.
- Provide source-mapped line, function, statement, and branch coverage.
- Provide console, dots, JUnit XML, GitHub Actions, and JSON Lines reports.
- Provide dependency-aware watch mode.
- Provide a machine-readable run manifest with selected files, seed, runtime identity, and configuration digest.
- Report test, hook, compiler, worker, snapshot, and coverage failures as distinct error classes.

### 5.2 Success measures

Correctness and compatibility are release gates.
Performance targets apply after the semantic fixture corpus passes.

| Measure | Target |
| --- | --- |
| Determinism | Repeated runs with the same inputs and seed select and order the same tests. |
| Default isolation | Mutating globals or the module cache in one file cannot affect another file. |
| Timeout enforcement | An infinite loop is terminated by the native watchdog within the configured deadline plus grace period. |
| Descendant cleanup | Timed-out and interrupted workers leave no child process created by the test worker. |
| Crash handling | A worker crash fails its file and cannot produce a successful run. |
| Snapshot safety | Parallel updates never lose, overlap, or partially commit edits. |
| Coverage correctness | Remapped coverage locations match original TypeScript and JSX fixtures. |
| Reporter consistency | Every built-in reporter produces equivalent test counts and final status from the same event stream. |
| Watch selection | A changed source reruns all known dependent tests and no unrelated tests in the closed static graph. |
| CI sharding | Every selected file appears in exactly one shard for a fixed shard count and seed. |
| Compatibility | The supported `bnpm:test` API passes its conformance suite on every supported Node.js LTS release. |
| Warm performance | Median warm wall time is competitive with Vitest and Node's test runner under equivalent isolation and coverage settings. |
| Resource use | Process, memory, output, and coverage buffers remain within configured limits. |

## 6. Non-goals for the initial stable release

- Embedding Node.js, JavaScriptCore, V8, QuickJS, or another JavaScript runtime.
- Executing tests on a GPU.
- Running tests in a real browser.
- Providing a built-in DOM implementation.
- Claiming complete Jest, Vitest, or Bun compatibility.
- Supporting every Jest plugin, transformer, environment, sequencer, or custom resolver.
- Reproducing Bun runtime globals or APIs outside the test API.
- Reproducing Bun's ability to replace already-imported ESM live bindings.
- Running untrusted tests in a security boundary.
- Distributed execution across remote machines beyond deterministic CI sharding.
- Mutation testing, fuzzing, property generation, visual regression hosting, or test-impact analytics.
- Automatically downloading a JavaScript runtime.
- Loading JavaScript configuration files in the native coordinator.

## 7. Users and jobs

### Application developer

The developer wants one command that compiles typed tests, reports useful failures, and reruns affected tests quickly.
The developer expects a failed assertion to show the relevant values, source line, and structural difference.

### Library maintainer

The maintainer wants stable Node.js behavior, package-condition coverage, deterministic snapshots, and compatibility across supported Node.js LTS releases.

### Monorepo maintainer

The maintainer wants workspace-aware selection, bounded parallelism, stable sharding, and reports that identify the package and file for every test.

### CI author

The CI author wants deterministic shards, machine-readable reports, coverage thresholds, focused-test rejection, retry visibility, and reliable exit codes.

### Tooling author

The tooling author wants a versioned event protocol that can drive an editor, dashboard, or custom reporter without parsing terminal text.

## 8. Bun research findings

### 8.1 Runtime integration

Bun documents `bun test` as deeply integrated with the Bun runtime.
That integration gives the runner direct access to JavaScriptCore globals, module loading, timers, subprocesses, source maps, and unhandled errors.
The source tree places the core runner under `src/runtime/test_runner`, with execution, assertions, snapshots, pretty formatting, timers, and suite collection implemented beside the runtime.

This design explains capabilities that an external coordinator cannot copy directly.
Bun can replace ESM live bindings after a module has already loaded, reset a JavaScriptCore global and module registry, apply runtime time controls without replacing `Date`, and kill subprocesses associated with a timed-out test.

`bnpm test` must provide equivalent user outcomes where the external Node.js boundary permits them.
It must document the cases where the boundary changes compatibility.

### 8.2 Discovery

Bun discovers these conventional names:

- `*.test.{js|jsx|ts|tsx|mjs|cjs|mts|cts}`.
- `*_test.{js|jsx|ts|tsx|mjs|cjs|mts|cts}`.
- `*.spec.{js|jsx|ts|tsx|mjs|cjs|mts|cts}`.
- `*_spec.{js|jsx|ts|tsx|mjs|cjs|mts|cts}`.

Bun ignores `node_modules`, hidden directories, and files without JavaScript-like extensions.
Its positional filters are path substrings rather than shell globs, while `-t` applies a regular expression to the full nested test name.

`bnpm test` will keep the familiar default names.
It will add explicit include and exclude globs because configuration should not depend on substring behavior.
Positional arguments remain literal path or path-substring filters for command-line familiarity.

### 8.3 Registration and execution

Bun supports `test`, `it`, `describe`, lifecycle hooks, table tests, focused tests, skipped tests, todo tests, expected failures, conditional tests, serial tests, and concurrent tests.
Tests run in declaration order within a file unless randomization or concurrency changes the schedule.

Bun's execution source models a test attempt as an ordered sequence of outer hooks, the test body, and inner-to-outer cleanup hooks.
Concurrent tests are grouped as independent execution sequences that overlap cooperatively on one JavaScript thread.
They do not provide CPU parallelism within a file.

Bun's default test timeout is 5 seconds.
Timeouts can be set globally or per test, and zero or infinity disables a timeout.
Its runtime tracks unhandled exceptions and promise rejections outside test bodies and fails the run.

### 8.4 File parallelism and isolation

Bun runs all files in one process and a shared global/module registry by default.
Its `--parallel` mode starts worker processes, distributes files, and implies file isolation.
Its `--isolate` mode creates a fresh global and module registry for each file while retaining process-wide transformed source and bytecode caches.

The current parallel coordinator:

- Uses worker subprocesses and framed messages.
- Starts one worker immediately and adds workers after a short delay when work remains busy.
- Sorts files by path for module-cache locality unless randomization is active.
- Partitions work by prior file duration when timing data exists.
- Lets workers steal remaining files after their assigned range is complete.
- Buffers output by file.
- Replaces crashed workers for remaining work.
- Applies bail at file-dispatch granularity.
- Merges coverage, JUnit records, timings, and snapshots in the coordinator.

This is a strong scheduling model, but its isolation mechanism depends on Bun's embedded runtime.
`bnpm test` will use OS processes for the default isolation contract.

### 8.5 Assertions and compatibility

Bun provides a large Jest-style `expect` surface, asymmetric matchers, custom matchers, promise modifiers, mock matchers, and snapshots.
Bun's public Jest compatibility tracker remains open and lists unsupported combinations and APIs.
The product must therefore treat Bun and Jest as design references rather than claim drop-in compatibility.

### 8.6 Mocks

Bun provides function mocks, one-shot implementations, resolved and rejected values, invocation metadata, spies, global mock clearing, and ESM/CommonJS module mocks.
Its runtime can update already-imported ESM bindings.
Preload mocks can prevent original module evaluation.
Bun does not currently provide Jest automatic mocking and `__mocks__` behavior as a complete compatibility layer.

The external Node.js host cannot safely reproduce post-import live-binding replacement.
`bnpm test` module substitutions must be registered before the first import of the target module.
Static imports are evaluated before module-body registration code, so in-file module substitution requires an explicit hoisting transform or a preload declaration.
The initial stable release will support preload declarations and a compiler-recognized top-level `mock.module()` form with strict placement rules.

### 8.7 Time and timers

Bun provides mocked wall-clock time for `Date.now()`, `new Date()`, and `Intl.DateTimeFormat`.
Its compatibility surface includes `useFakeTimers`, `useRealTimers`, `setSystemTime`, and `now`, but its documented model differs from Jest's replacement of the `Date` constructor.
The current compatibility tracker does not claim the complete Vitest timer-control surface.

`bnpm test` will define its own timer contract and test it independently.
Fake timers will control wall-clock reads, timeouts, intervals, immediates, and queued microtask drains exposed by the API.
The implementation must preserve the original `Date` constructor identity when practical, but observable correctness takes priority over matching Bun's implementation detail.

### 8.8 Snapshots

Bun stores external snapshots beside the test file in `__snapshots__` and supports inline snapshots, error snapshots, property matchers, and explicit update mode.
It refuses to create snapshots in CI unless update mode is enabled.
Its source implementation records inline edits by file and source location, sorts them, reparses the source, validates arguments, and rewrites the file.

The important design lesson is that snapshot updates are source edits rather than reporter output.
They require parsing, conflict detection, stable formatting, and one writer per file.

### 8.9 Coverage and reporters

Bun collects source-map-aware coverage and can emit text and LCOV output.
It supports console, dots, JUnit XML, and GitHub Actions annotations.
Its custom reporter interface is tied to Bun's inspector protocol.

`bnpm test` needs a runtime-neutral event stream because its native coordinator and external host cannot share Bun's inspector objects.
Node.js exposes V8 inspector coverage through `node:inspector`, which gives the worker a viable precise-coverage source.

### 8.10 DOM tests

Bun does not ship a test DOM as part of the runner.
Its documentation recommends a preload such as `@happy-dom/global-registrator` and standard Testing Library packages.
`bnpm test` will follow the same ownership boundary for Node-hosted DOM tests.

## 9. Command-line interface

### 9.1 Primary command

```text
bnpm test [paths-or-filters...] [options]
```

With no positional filters, the command discovers all configured test files under the test root.
A positional argument beginning with `./`, `../`, `/`, or a Windows volume prefix is treated as an exact path or directory.
Other positional arguments are normalized path-substring filters.
Globs are accepted only through `--include` and `--exclude` to avoid shell-dependent interpretation.

### 9.2 Selection options

```text
--root <path>
--include <glob>
--exclude <glob>
-t, --test-name-pattern <regex>
--changed [<base>]
--related <source-path>
--failed
--shard <index>/<count>
--list
--pass-with-no-tests
```

`--list` performs discovery, compilation of registration metadata when required, and filtering without executing test bodies.
`--changed` selects tests affected by changes relative to a Git base when Git metadata is available.
`--related` selects tests whose known dependency graph reaches any provided source path.
`--failed` reads the last compatible failure cache.

### 9.3 Execution options

```text
--workers <auto|count|percent>
--isolation <process|shared>
--parallel-delay <duration>
--concurrent
--max-concurrency <count>
--timeout <duration>
--hook-timeout <duration>
--file-timeout <duration>
--grace-period <duration>
--bail [count]
--retry <count>
--repeat <count>
--randomize
--seed <u64>
--run-todo
--forbid-only
--runtime <path>
--runtime-arg <arg>
```

`--retry` and `--repeat` are mutually exclusive.
`--workers auto` uses available logical CPUs, configured memory limits, and observed worker startup cost.
The coordinator starts one worker immediately and adds capacity only while queued files remain and active workers stay busy.

### 9.4 Snapshot and coverage options

```text
-u, --update-snapshots
--snapshot-format <pretty-v1>
--coverage
--coverage-reporter <text|lcov|json>
--coverage-dir <path>
--coverage-include <glob>
--coverage-exclude <glob>
--coverage-threshold <dimension=value>
--coverage-all
```

Snapshot updates are explicit.
The command must not infer update mode from watch mode.

### 9.5 Output options

```text
--reporter <console|dots|junit|github|jsonl>
--reporter-outfile <path>
--only-failures
--silent
--no-color
--show-output <always|failure|never>
--timings <path>
```

Multiple reporters may be configured.
A reporter that writes structured output must use a separate destination from human-readable terminal output.

## 10. Configuration

Configuration lives in `bnpm.toml` under `[test]`.
CLI flags override project configuration.
Workspace package configuration overrides root defaults only for fields explicitly marked workspace-overridable.

```toml
[test]
root = "."
include = ["**/*.test.{js,jsx,ts,tsx,mjs,cjs,mts,cts}", "**/*.spec.{js,jsx,ts,tsx,mjs,cjs,mts,cts}"]
exclude = ["node_modules/**", ".git/**", "dist/**", "coverage/**"]
setup_files = ["./test/setup.ts"]
global_setup = "./test/global-setup.ts"
global_teardown = "./test/global-teardown.ts"
runtime = "node"
workers = "auto"
isolation = "process"
timeout_ms = 5000
hook_timeout_ms = 5000
file_timeout_ms = 120000
grace_period_ms = 1000
max_concurrency = 20
forbid_only = false
pass_with_no_tests = false
timezone = "UTC"

[test.coverage]
enabled = false
reporters = ["text"]
directory = "coverage"
exclude_test_files = true

[[test.reporters]]
name = "console"
```

Configuration paths are resolved relative to the file that declares them.
Unknown keys are errors.
Invalid combinations are reported before workers start.

## 11. Discovery and stable identities

### 11.1 Filesystem traversal

Discovery starts at the canonical test root.
The walker prunes excluded directories before reading their descendants.
It does not follow directory symlinks by default.
An opt-in may follow symlinks while tracking canonical directories to prevent cycles.

Default exclusions include:

- `node_modules`.
- `.git`.
- Hidden directories, except paths named explicitly.
- The compiler cache.
- The test cache.
- Coverage and configured output directories.

Explicit files bypass default naming patterns but still require a supported loader.

### 11.2 Ordering

Selected files are sorted by normalized project-relative path before sharding or randomization.
Path comparison uses forward slashes and Unicode code-point order.
Case folding is not applied, even on case-insensitive filesystems.

Without randomization, tests retain declaration order among sibling entries.
With randomization, the runner shuffles sibling tests and suites using the recorded seed.
Hook scope and serial barriers remain intact.

### 11.3 Test identity

A test identity consists of:

- Workspace identity.
- Project-relative file path.
- Nested suite name sequence.
- Test name.
- Declaration source position.
- Table-row index when applicable.

The source position prevents duplicate names from collapsing into one result.
Reporters display the readable full name, while caches and protocols use the complete identity.

## 12. Runtime boundary

### 12.1 Supported host

The initial host is Node.js 24 LTS or newer supported Node.js LTS releases validated by the compatibility matrix.
The command locates Node.js from `--runtime`, `[test].runtime`, or `PATH`, in that order.
It resolves the executable to a canonical path and records its version and build identity in the run manifest.

The runner does not download Node.js.
A missing, unsupported, or unparsable runtime is a configuration failure.

### 12.2 Process model

The default unit of isolation is one Node.js process per test file.
The native coordinator launches each process directly with an argument vector and explicit environment.
It never constructs a shell command string.

A worker process receives:

- One compiled test entry.
- The resolved setup-file entries.
- A read-only run configuration payload.
- A worker identifier.
- A framed event channel.
- A control channel for cancellation and snapshot responses.

The process exits after one file.
This makes global state, module caches, fake timers, unhandled handlers, and native process state disposable.

### 12.3 Shared mode

`--isolation shared` allows one worker process to execute multiple files sequentially.
It is an opt-in performance mode.
The harness resets its own registries between files, but it cannot guarantee removal of application globals, native addon state, process listeners, or every module cache effect.
Reports and manifests label shared-mode results.

Thread isolation may be evaluated after the process model is stable.
A Node.js worker thread has a separate JavaScript environment but shares the OS process and some native state, so it cannot silently replace process isolation.

### 12.4 Environment

Workers receive `NODE_ENV=test` when the user has not set it.
Workers receive `TZ=UTC` by default unless configuration or the environment overrides it.
Workers receive `BNPM_TEST_WORKER_ID` and `JEST_WORKER_ID` as one-based identifiers.

Environment construction is explicit and case-normalized on Windows.
Secrets are inherited by default because tests are trusted project code.
An environment allowlist mode may reduce inheritance, but it is not a sandbox.

## 13. Compilation and module loading

### 13.1 Compilation mode

The compiler emits unbundled JavaScript modules and source maps into a content-addressed test cache.
The output preserves module boundaries, package conditions, dynamic imports, and module identity.

The compilation target is the selected Node.js version.
Test files may use TypeScript, JSX, TSX, ESM, or CommonJS according to project configuration and package boundaries.

### 13.2 Harness injection

The compiler resolves `bnpm:test` to the versioned harness entry supplied by the installed `bnpm` executable.
The harness is not resolved from the project's dependency graph.
This prevents a project dependency from replacing runner control code.

An opt-in Bun compatibility mode maps `bun:test` imports to `bnpm:test`.
That mode covers only documented test APIs.
It does not define the `Bun` runtime global or emulate unrelated Bun modules.

Optional globals may expose `test`, `it`, `describe`, `expect`, hooks, `jest`, and `vi`.
Explicit imports remain the recommended mode because they make dependencies visible and typing reliable.

### 13.3 Cache keys

A compiled test graph key includes:

- Canonical source identities and content digests.
- Resolver and loader configuration.
- Package condition set.
- Compiler version and semantic options.
- Selected Node.js major version.
- Harness protocol version.
- Setup-file graph digests.
- Compatibility mode.

Cached output is published atomically.
A worker never observes a partially written module or source map.

### 13.4 Dynamic loading

Literal dynamic imports participate in the compiled graph.
A computed dynamic import of JavaScript may fall through to Node.js when the target is already executable for the host.
A computed import of TypeScript or JSX that was not emitted must fail with a diagnostic that names the unresolved runtime path.

The initial release will not run a synchronous native compiler RPC from Node.js loader hooks.
This keeps the worker protocol bounded and avoids deadlocks during module loading.

## 14. Test API and registration

### 14.1 Exports

`bnpm:test` exports:

```ts
export {
  test,
  it,
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  onTestFinished,
  expect,
  mock,
  spyOn,
  jest,
  vi,
  setSystemTime,
};
```

`it` is an alias of `test`.
`jest` and `vi` expose only the compatibility methods documented by this product.
They are not broad claims of Jest or Vitest compatibility.

### 14.2 Collection phase

A test file has a collection phase followed by an execution phase.
The harness evaluates setup files and the test module during collection.
`describe` callbacks run during collection and must be synchronous.
Registering a test or hook after collection closes is an error.

Top-level await may delay completion of module evaluation.
It must finish within the file deadline before execution begins.

### 14.3 Test forms

The API supports:

- `test(name, fn, timeout?)`.
- `test.skip(name, fn?)`.
- `test.todo(name)`.
- `test.only(name, fn, timeout?)`.
- `test.failing(name, fn, timeout?)`.
- `test.concurrent(name, fn, timeout?)`.
- `test.serial(name, fn, timeout?)`.
- `test.each(table)(name, fn, timeout?)`.
- `test.if(condition)`.
- `test.skipIf(condition)`.
- `test.todoIf(condition)`.
- Equivalent supported `describe` modifiers.

A table row gets a stable row index even when its formatted name duplicates another row.

### 14.4 Focused tests

If any selected file contains an active `only`, that file executes only the focused branches.
`--forbid-only` turns focused registration into a run failure.
CI templates should enable `--forbid-only`.

Focus detection occurs after collection.
The runner does not execute unrelated test bodies to determine focus.

## 15. Lifecycle semantics

### 15.1 Hook order

For a test nested in suites, hooks run in this order:

1. Outer `beforeEach` hooks run before inner `beforeEach` hooks.
2. The test body runs.
3. Inner `afterEach` hooks run before outer `afterEach` hooks.
4. `onTestFinished` callbacks run in last-in-first-out order after `afterEach` completes.

`beforeAll` runs once before executable descendants in its suite.
`afterAll` runs once after started descendants and their cleanup complete.

### 15.2 Hook failures

A failed `beforeAll` skips unstarted descendants in that scope and marks them blocked by the hook failure.
The runner still attempts applicable `afterAll` hooks.

A failed `beforeEach` prevents the test body from running.
Applicable `afterEach` hooks still run.

A failed `afterEach`, `afterAll`, or `onTestFinished` callback fails the affected test or suite even when the test body passed.
Multiple cleanup failures are retained as secondary diagnostics instead of replacing the primary failure.

### 15.3 Async completion

A test or hook may:

- Return normally.
- Throw synchronously.
- Return a promise or thenable.
- Accept one callback and call it once.

Returning a promise while also accepting the callback is an error.
Calling the callback more than once is an error.
A callback error argument fails the test or hook.

## 16. Scheduling and concurrency

### 16.1 File scheduling

The coordinator maintains a queue of selected files and a bounded set of worker processes.
It starts one worker immediately.
It adds workers after the configured parallel delay while queued work remains and all active workers are busy.

Without historical timing data, files are grouped by path locality and dispatched in deterministic order.
With compatible timing data, the scheduler prioritizes long files and balances estimated total duration across workers.
Workers request another file only after their current process has exited and its result has been finalized.

### 16.2 In-file concurrency

Tests are serial by default.
`test.concurrent` and `--concurrent` permit promise-level overlap in one Node.js event loop.
They do not create threads.

`--max-concurrency` limits active concurrent test sequences.
A serial test creates a barrier before and after itself.
Hooks attached to concurrent tests must be safe for overlap.

`onTestFinished` is supported for concurrent tests because each execution sequence keeps its own callback stack.

### 16.3 Sharding

`--shard i/n` uses one-based indices.
The selection set is sorted before assignment.
The shard function is deterministic for a fixed set, count, seed, and timing database version.

When compatible timings exist, the runner uses deterministic greedy bin packing by descending duration with path as a tie breaker.
Without timings, it assigns files by stable round-robin.
Every selected file belongs to exactly one shard.

### 16.4 Bail

`--bail` without a count means one failed test or infrastructure failure.
The coordinator stops dispatching new files when the threshold is reached.
Already running files receive a cooperative cancellation request and a grace period unless configuration permits them to finish.
The final report distinguishes canceled tests from skipped tests.

## 17. Timeouts, crashes, and cleanup

### 17.1 Two-layer deadline

The JavaScript harness enforces cooperative test and hook deadlines so it can report the active identity and run cleanup.
The native coordinator enforces an authoritative file deadline and worker heartbeat deadline.

An infinite loop can block the JavaScript harness.
The native deadline therefore remains mandatory even when the harness has timers.

### 17.2 Timeout behavior

On a cooperative timeout, the harness records the test or hook failure and starts cleanup.
On a hard timeout, lost heartbeat, or ignored cancellation, the coordinator terminates the complete worker process tree.

A hard timeout aborts the current file.
Unstarted tests in that file are reported as not run because the worker terminated.
The runner does not silently reevaluate the file to continue because reevaluation may repeat irreversible side effects.

### 17.3 Process-tree ownership

Each worker starts in an owned process group on Unix-like systems or a kill-on-close Job Object on Windows.
The coordinator first requests graceful termination.
After the grace period it terminates the entire group or job.

Tests that deliberately detach descendants can escape ordinary parent-child tracking on some platforms.
The documentation must state this limit.
The release tests must cover normal child and grandchild cleanup.

### 17.4 Crashes and explicit exits

A signal, runtime fatal error, protocol violation, or unexpected worker exit fails the file as infrastructure.
A test calling `process.exit()` fails the file unless the test runs an explicitly spawned child process and asserts that child's exit.

The coordinator captures the exit code, signal, last heartbeat, active test identity, and bounded output tail.
It may start a replacement worker for files that had not begun.

## 18. Assertions

### 18.1 Core matcher set

The initial matcher set includes:

- Identity with `toBe`.
- Deep equality with `toEqual`.
- Prototype-aware strict equality with `toStrictEqual`.
- Truthiness, falsiness, null, undefined, defined, and NaN checks.
- Numeric comparisons and approximate equality.
- String and regular-expression matching.
- Array, set, map, iterable, and string containment.
- Length and property-path checks.
- Instance checks.
- Synchronous throw checks.
- Promise `resolves` and `rejects` modifiers.
- Mock call, argument, return, and order matchers.
- Snapshot and inline snapshot matchers.

`not` negates the final matcher result.
Asymmetric matchers include `anything`, `any`, `arrayContaining`, `objectContaining`, `stringContaining`, `stringMatching`, and numeric proximity.

### 18.2 Equality contract

Deep equality must define behavior for:

- Sparse arrays and explicit `undefined` entries.
- Object prototypes.
- Enumerable symbols.
- Dates and invalid dates.
- Regular expressions.
- Maps and sets.
- Typed arrays, array buffers, and data views.
- Errors and causes.
- Circular references.
- Getters and proxies.

`toEqual` follows a permissive Jest-style value comparison.
`toStrictEqual` requires matching prototypes, array sparseness, and explicit undefined properties.
Getters are not invoked solely to improve a diff beyond normal property access required by the contract.
Proxy exceptions become assertion diagnostics.

### 18.3 Assertion accounting

`expect.assertions(count)` requires exactly that many completed matcher calls in the current test attempt.
`expect.hasAssertions()` requires at least one completed matcher call.
Promise matchers count when their asynchronous result settles.

### 18.4 Custom matchers

`expect.extend()` registers matchers in the current worker.
A matcher returns `{ pass, message }` and may return a promise.
Custom matcher output passes through the same value formatter and source-location mapper as built-in matchers.

Setup files may register shared matchers.
A matcher registered in one isolated test file cannot affect another file except through shared setup code.

### 18.5 Diffs

Failure output chooses a representation based on value type and size.
It provides compact scalar output, unified string diffs, structural object diffs, and bounded context for large collections.

The formatter handles cycles and getter failures.
It truncates by configured byte and depth limits while recording that truncation occurred.
Terminal color is a presentation layer and never appears in JUnit or JSON data.

## 19. Mocks and spies

### 19.1 Function mocks

`mock(fn?)`, `jest.fn`, and `vi.fn` create callable mocks that record:

- Arguments.
- Receiver contexts.
- Constructor instances.
- Return, throw, incomplete, resolve, and reject results.
- Invocation order.
- The most recent call.

Mocks support default and one-shot implementations, return values, resolved values, rejected values, names, clearing, resetting, restoring, and temporary implementations.

### 19.2 Spies

`spyOn(object, key, accessType?)` supports methods, getters, and setters.
It preserves the original property descriptor and restores it exactly when possible.
Spying on non-configurable properties fails before mutation.

`restoreAllMocks` restores every active spy created through the harness.
A restoration failure is reported rather than ignored.

### 19.3 Module substitution

`mock.module(specifier, factory)` substitutes a module before its first evaluation.
The factory may be synchronous or asynchronous and returns the mock namespace.

Supported registration paths are:

- A setup file that runs before the test module graph.
- A compiler-recognized top-level call before imports are lowered.
- A dynamic import performed after registration.

The compiler hoists only the exact imported `mock.module` binding from `bnpm:test` when the call is top-level and statically analyzable.
Aliased, nested, computed, or conditional forms are not hoisted.
They affect only later dynamic loading.

For a recognized hoist, the compiler emits a bootstrap module that registers substitutions and then dynamically imports the transformed test body.
The hoisted factory may capture literals, globals, and bindings from `bnpm:test`, but it may not capture ordinary local or imported application bindings.
An invalid capture is a compilation error because loading those bindings first would defeat the substitution order.
The compiled resolver maps the substituted canonical module identity to a generated mock module whose top-level await can evaluate an asynchronous factory.

A request to replace an already evaluated module fails with a diagnostic.
The runner does not pretend to patch ESM live bindings.

Automatic mocks, `__mocks__` directories, and implicit package-wide replacement are outside the initial release.

## 20. Fake time

### 20.1 Clock model

Fake time belongs to one file worker and resets when the process exits.
It can control:

- `Date.now()` and zero-argument `new Date()`.
- `performance.now()` with a stable monotonic origin.
- `setTimeout` and `clearTimeout`.
- `setInterval` and `clearInterval`.
- `setImmediate` and `clearImmediate`.
- Harness-visible timer counts.

`process.hrtime` remains monotonic and real by default because replacing it can break Node.js internals.
The API documents this difference.

### 20.2 Timer operations

The compatibility object supports:

- `useFakeTimers()`.
- `useRealTimers()`.
- `setSystemTime(value?)`.
- `now()`.
- `advanceTimersByTime(ms)` and its asynchronous form.
- `advanceTimersToNextTimer()` and its asynchronous form.
- `runAllTimers()` and its asynchronous form.
- `runOnlyPendingTimers()` and its asynchronous form.
- `clearAllTimers()`.
- `getTimerCount()`.

Timer execution has a configurable recursion limit.
Exceeding it fails with a likely-infinite-timer diagnostic.

Microtasks queued by a timer callback drain before the next timer in asynchronous operations.
Synchronous operations do not pretend to settle arbitrary promises.

## 21. Snapshots

### 21.1 External snapshots

External snapshots live at:

```text
<test-directory>/__snapshots__/<test-file-name>.snap
```

A snapshot key contains the nested test name, optional hint, and one-based snapshot ordinal.
Duplicate keys are errors.

Snapshot files use a versioned, parseable format.
The header records the format version, not the local machine or absolute path.

### 21.2 Serialization

The `pretty-v1` serializer defines stable representations for:

- Primitive values and big integers.
- Arrays, sparse arrays, objects, and symbol keys.
- Dates, regular expressions, URLs, and errors.
- Maps and sets in iteration order.
- Typed arrays and array buffers.
- Functions and mocks without unstable addresses.
- Circular references through stable reference markers.
- DOM-like values through registered serializers.

Object property order follows ECMAScript enumeration order.
The serializer does not sort user maps, sets, or object keys because order can be observable and worth testing.

Serializer plugins run in the worker and return serialized fragments through the event protocol.
They must declare a stable name and version for cache and report metadata.

### 21.3 Update policy

A missing or mismatched snapshot fails by default.
`--update-snapshots` adds missing entries, replaces mismatches, and removes obsolete entries for tests that were selected and completed.
It does not remove entries belonging to unselected tests.

In CI, creating or changing snapshots requires the explicit update flag.
Watch mode never enables updates automatically.

### 21.4 Inline snapshots

Inline snapshot requests include the original source identity, matcher call range, formatted value, and expected source digest.
The native coordinator groups edits by source file, reparses the original source, validates the call shape, and applies edits from the end of the file toward the beginning.

Overlapping edits, changed source digests, ambiguous calls, spread arguments, and non-literal existing snapshots fail without writing.
The completed file is written to a sibling temporary file, flushed, and atomically replaced.

Only the coordinator writes source or snapshot files.
Workers never mutate them directly.

## 22. Coverage

### 22.1 Collection

Each Node.js worker opens an in-process inspector session and enables V8 precise coverage before setup and test modules execute.
It takes coverage before exit and sends the bounded result to the coordinator.

Coverage collection records generated script URLs, function ranges, block ranges, and counts.
Internal harness modules and cache plumbing are excluded by canonical identity rather than output-path substring alone.

When coverage is enabled, the compiler also emits a coverage map that identifies original statements, branch arms, functions, and lines and maps each item to one or more generated ranges.
The coordinator combines that semantic map with V8 range counts instead of treating every V8 block boundary as a source-language branch.

### 22.2 Source-map remapping

The coordinator validates each source map before use.
Generated ranges are remapped to canonical original sources using the compiler's source-map segments and coverage map.
Unmapped generated code is reported separately and does not inflate original-source coverage.

Ranges from multiple workers are merged by original source identity and semantic item identity.
An item is covered when its mapped generated range has an execution count greater than zero under the metric's documented rule.
Counts saturate on integer overflow and emit an infrastructure diagnostic.

### 22.3 Metrics

The runner reports:

- Statement coverage.
- Branch coverage.
- Function coverage.
- Line coverage.

Thresholds may be global or path-specific.
They are evaluated from the merged internal model before reporter output.
A threshold therefore behaves the same whether text, LCOV, JSON, or several reporters are enabled.

### 22.4 Included files

By default, coverage includes loaded project source and excludes test files, setup files, dependencies, generated output, and the harness.
`--coverage-all` adds configured source files that were never loaded with zero counts.

Files included by `--coverage-all` must be parseable by the compiler and match coverage include/exclude rules.
The runner does not invent executable ranges for unsupported loaders.

### 22.5 Reporters

Text output shows uncovered lines and summaries.
LCOV output uses project-relative source paths and normalized separators.
JSON output follows a versioned schema and includes source digests.

Coverage publication uses a staging directory and atomic replacement where the platform permits it.
A report failure makes the command fail because coverage was explicitly requested.

## 23. Event protocol and reporters

### 23.1 Framing

Worker events use a length-prefixed binary frame carrying a versioned message body.
User stdout and stderr never share the control stream.
Every frame includes run, worker, file, and sequence identifiers as applicable.

The coordinator rejects unknown required fields, invalid lengths, out-of-order lifecycle transitions, and frames that exceed configured limits.
Optional fields can be ignored by older compatible readers.

### 23.2 Event types

The protocol includes:

- Worker ready, heartbeat, diagnostic, and exit events.
- File collection, start, end, cancel, and crash events.
- Suite registration, start, and end events.
- Hook start and end events.
- Test registration, attempt start, attempt end, and final result events.
- Assertion and structured failure events.
- Stdout and stderr chunk events.
- Snapshot request and result events.
- Coverage fragment events.
- Timing and resource usage events.

The coordinator validates the event state machine before updating run totals.

### 23.3 Output capture

Stdout and stderr are drained continuously to prevent pipe backpressure from blocking workers.
Output is tagged with file and active test identity when known.

Console and dots reporters buffer ordinary output per file to avoid interleaving.
Failure diagnostics may stream promptly while preserving each diagnostic block.
Per-worker and per-file output limits prevent an accidental log loop from exhausting memory.
Truncation is visible and does not change the test result by itself unless strict output limits are enabled.

### 23.4 Built-in reporters

The console reporter shows hierarchical results, focused failure details, captured output, and a final summary.
The dots reporter emits compact progress and expands failures at the end.
The JUnit reporter writes valid XML with escaped control characters, suite timing, test attempts, failures, skips, and captured output.
The GitHub reporter emits workflow commands only when GitHub Actions is detected or explicitly requested.
The JSON Lines reporter emits one documented event object per line.

All reporters consume finalized coordinator events.
No reporter recomputes pass or failure status.

### 23.5 Custom integrations

The initial extension point is the JSON Lines event stream or a reporter subprocess that reads it from stdin.
The coordinator launches reporter programs directly without a shell.
A reporter cannot mutate runner state or snapshot decisions.

A slow reporter receives bounded buffering and backpressure.
If it exceeds its deadline or exits early, the run fails as a reporter infrastructure error when the reporter was explicitly requested.

## 24. Watch mode

### 24.1 Dependency graph

Compilation records source-to-source dependency edges and test entry reachability.
The watch index maps every canonical source to the test files that reached it during the last successful compile.

A changed test reruns itself.
A changed source reruns every known reverse-dependent test.
A changed setup file, test configuration, compiler configuration, package manifest, lockfile, or unresolved dependency invalidates all affected workspace tests.
An unknown or dynamic dependency change falls back to a wider safe selection.

### 24.2 Run lifecycle

A new change cancels the current run cooperatively.
The coordinator waits for worker cleanup or enforces the grace period before beginning the next generation.
Events from an older generation cannot update the current summary.

Failed tests run first in the next compatible generation.
Within each group, deterministic path order or the recorded random seed remains in force.

### 24.3 Watch output

Watch mode displays the reason each file was selected.
It preserves the previous failure summary until the replacement result arrives.
A clear-screen option is configurable and disabled for noninteractive output.

Snapshot updates, coverage, and retries retain their explicit configuration in watch mode.

## 25. Setup and teardown

### 25.1 Per-file setup

`setup_files` execute in declaration order inside every file worker before the test module.
They may register hooks, matchers, mocks, DOM globals, and environment state.
Their code is part of the test file's timeout and coverage policy.

A setup failure aborts the file before test execution.

### 25.2 Global setup

`global_setup` runs once in its own Node.js process after discovery and compilation but before test workers start.
It may return a JSON-serializable value that the coordinator provides read-only to workers.
It may also write files or expose external services through explicit environment variables.

Live JavaScript objects, sockets, handles, and module instances cannot cross from global setup into isolated workers.
This is a consequence of the runtime boundary and must remain explicit.

### 25.3 Global teardown

`global_teardown` runs once after workers and reporters finish, including after test failures.
It receives the serialized setup value and run summary.
Its timeout is enforced by the native coordinator.

A teardown failure makes the command fail even if all tests passed.
A hard interruption may prevent JavaScript teardown, so users must not depend on it as the sole recovery mechanism for external resources.

## 26. Retries, repeats, and randomization

### 26.1 Retries

A retry applies only after a failed test attempt.
Each attempt reruns applicable `beforeEach` and `afterEach` hooks.
`beforeAll` and `afterAll` remain suite-scoped within the file process.

The report retains every attempt and labels a final pass after failure as flaky.
A retry never erases the first failure from machine-readable output.
Snapshot updates are committed only from the final accepted attempt.

Infrastructure crashes are not ordinary test retries.
An explicit `--retry-crashes` mode may rerun the entire file in a fresh process, but it is outside the initial stable contract.

### 26.2 Repeats

`--repeat n` runs every selected test `n` additional times.
Each repetition uses a fresh file process under default isolation.
The repetition index is part of the result identity but not the snapshot key.

A snapshot mismatch in any repetition fails the test.
Snapshot updates with repeats are rejected because competing repetitions could produce different values.

### 26.3 Seeded randomization

`--randomize` uses a specified or generated 64-bit seed.
The seed appears at the start and end of human output and in every structured report.

The pseudorandom algorithm and version are part of the run manifest.
A future algorithm change requires a version change so old runs remain reproducible.

## 27. Diagnostics and result model

### 27.1 Test statuses

Final test statuses are:

- Passed.
- Failed.
- Skipped.
- Todo.
- Expected failure.
- Unexpected pass.
- Blocked by hook failure.
- Canceled.
- Not run because the worker terminated.

Retries add attempt metadata without creating a new final status category.

### 27.2 Failure classes

Failures are classified as:

- Compilation or resolution failure.
- Test assertion failure.
- Test exception or rejection.
- Hook failure.
- Test or hook timeout.
- File hard timeout.
- Unhandled error outside a test.
- Snapshot mismatch or update failure.
- Coverage threshold or report failure.
- Worker crash or protocol failure.
- Reporter failure.
- Global setup or teardown failure.
- Configuration or discovery failure.

Every diagnostic includes a stable code, severity, original source location when known, and remediation text when actionable.

### 27.3 Exit codes

| Code | Meaning |
| --- | --- |
| `0` | All selected tests and requested reports succeeded. |
| `1` | A test, hook, snapshot, unhandled error, focused-test rule, or coverage threshold failed. |
| `2` | Configuration, discovery, runtime validation, compilation, global setup, or reporter setup failed. |
| `3` | A worker crashed, violated the protocol, or exceeded a hard infrastructure deadline. |
| `130` | The run was interrupted by the user where the platform supports the conventional code. |

Scripts should treat every nonzero code as failure.
The distinct codes exist for diagnostics and CI routing.

### 27.4 No-test behavior

Finding no tests is a failure by default when no explicit filter was provided.
A filter that selects no registered tests is also a failure because it commonly indicates a misspelled name.
`--pass-with-no-tests` changes both cases to success while keeping a visible warning.

## 28. Security and trust model

Tests execute arbitrary project code with the developer's operating-system identity.
The runner is not a sandbox.
A test can read files, use the network, inspect inherited environment variables, spawn processes, and modify the project unless the operating system or Node.js permission model prevents it.

The runner still must:

- Launch executables without a shell.
- Canonicalize runtime, cache, output, snapshot, and report paths.
- Reject snapshot edits that escape the project through symlinks unless explicitly allowed.
- Bound protocol frames, captured output, diagnostics, and coverage payloads.
- Validate source maps before resolving original paths.
- Avoid placing secrets in reports or manifests by default.
- Clean up owned workers and descendants on cancellation and timeout.
- Treat reporter subprocesses as trusted tools with the same user privileges.

Node.js permission flags may be forwarded explicitly through runtime arguments.
The runner must not imply that those flags provide a complete security boundary.

## 29. Performance model

### 29.1 Expected costs

The main costs are:

- Filesystem discovery and hashing.
- Module graph resolution and test compilation.
- Node.js process startup.
- Setup-file evaluation.
- Test workload execution.
- Output serialization.
- Snapshot formatting.
- Coverage collection and source-map remapping.

Process-per-file isolation can dominate small test files.
The product accepts that cost for the default correctness contract and reduces it through warm compile caches, lazy worker scale-up, duration-aware ordering, and bounded parallel starts.

### 29.2 Benchmark policy

Benchmarks compare `bnpm test` with Bun, Node's built-in test runner, Vitest, and Jest.
Each comparison must use equivalent source transforms, isolation, worker counts, warm or cold state, coverage setting, and reporter output.

Required corpora include:

- Many tiny files.
- Few large files.
- TypeScript-heavy graphs.
- JSX and DOM setup.
- Snapshot-heavy suites.
- Coverage-heavy suites.
- Child-process and timeout cases.
- Monorepo workspace selection.
- Watch changes with narrow and broad invalidation.

Startup, compile, execution, merge, and report time are measured separately.
A faster result obtained by weaker isolation or missing coverage is not a valid win.

### 29.3 GPU policy

The test coordinator, JavaScript execution, hooks, assertions, process management, and reporting stay on the CPU.
Their workloads are branch-heavy, effectful, latency-sensitive, or controlled by the external runtime.

Shared compiler stages may use a qualified GPU path under `ts-compiling-prd.md`.
The test runner does not add a `--gpu` execution mode or promise faster tests from GPU hardware.

## 30. Native coordinator architecture

The coordinator is divided into explicit subsystems:

1. Configuration loader and validator.
2. Workspace and root resolver.
3. Test file scanner and filter engine.
4. Compilation graph client.
5. Runtime resolver and validator.
6. Scheduler and shard planner.
7. Worker process supervisor.
8. Framed protocol decoder and event state machine.
9. Snapshot transaction manager.
10. Coverage merger and reporter.
11. Human and structured reporter fan-out.
12. Watch index and invalidation engine.
13. Timing and failure cache manager.

Pure planning functions return immutable values.
Filesystem changes, process creation, signal handling, terminal output, and atomic publication remain host-side effects.

The coordinator owns final truth.
Workers propose events and artifacts, but the coordinator validates lifecycle order, counts, deadlines, snapshot preconditions, and report completion.

## 31. JavaScript harness architecture

The harness contains:

1. A suite and hook registry.
2. A collection state machine.
3. A serial and concurrent execution scheduler.
4. Async completion and timeout tracking.
5. Assertion and asymmetric matcher libraries.
6. Value formatting and diffing.
7. Function mocks and spies.
8. Module substitution registration.
9. Fake clock and timer control.
10. Snapshot request generation.
11. Unhandled exception and rejection tracking.
12. Coverage session control.
13. Output attribution.
14. Event encoding and heartbeat emission.

The harness is versioned with the native protocol.
A native executable must launch only the harness version shipped with it.
Project code cannot override that path through package resolution.

The public TypeScript declarations are generated from the same API inventory used by compatibility tests.
Runtime exports and declarations must match exactly.

## 32. State machines and invariants

### 32.1 File state

A file moves through:

```text
selected -> compiling -> compiled -> starting -> collecting -> running -> finalizing -> complete
```

Failure and cancellation edges may enter terminal states from each active state.
A completed or failed file cannot emit new test results.

### 32.2 Test state

A test moves through:

```text
registered -> selected -> waiting -> attempt-running -> attempt-complete -> final
```

Retries return from `attempt-complete` to `waiting` with a higher attempt number.
Skipped, todo, and blocked tests move directly from selected to final.

### 32.3 Run invariants

- Every selected file has exactly one final file result.
- Every registered selected test has exactly one final test result.
- Every started hook and attempt has one terminal event or an explicit worker-termination synthesis.
- Reporter totals come from final identities rather than event counts.
- Snapshot writes occur after all contributing attempts are final.
- Coverage thresholds run after all accepted coverage fragments are merged.
- Global teardown runs after worker termination and before final report publication.
- Exit code zero requires successful requested artifact publication.

## 33. Delivery plan

### Phase 1: Coordinator and external runtime

Deliver discovery, configuration, Node.js validation, unbundled compilation, one-file worker processes, the framed protocol, cancellation, hard file timeouts, output capture, and basic console reporting.

Exit criteria:

- JavaScript and TypeScript smoke projects run end to end.
- An infinite loop is killed by the native watchdog.
- A worker crash fails the run.
- Global mutation cannot cross file boundaries.

### Phase 2: Core test semantics

Deliver suites, hooks, sync, promise, callback, skip, todo, only, failing, table tests, serial barriers, concurrent tests, assertion accounting, and the core matcher set.

Exit criteria:

- Hook-order and failure-propagation fixtures pass.
- Duplicate names remain distinct by source identity.
- Promise-plus-callback and double-callback cases fail deterministically.

### Phase 3: Parallel scheduling and CI output

Deliver worker scaling, timing data, sharding, bail, retries, repeats, randomization, dots, JUnit XML, GitHub Actions, JSON Lines, and stable exit codes.

Exit criteria:

- Shards are complete and disjoint.
- Reporter totals agree on the same run.
- Interrupted and timed-out process trees are cleaned up on every supported platform.

### Phase 4: Mocks, spies, and fake time

Deliver function mocks, spies, global cleanup APIs, preload module substitution, recognized top-level substitution hoisting, fake clocks, and fake timers.

Exit criteria:

- ESM and CommonJS fixture boundaries are documented and tested.
- Already-loaded module replacement fails clearly.
- Timer ordering and microtask fixtures pass.

### Phase 5: Snapshots

Deliver the stable serializer, external snapshots, inline snapshots, property matchers, source-digest validation, conflict detection, and atomic updates.

Exit criteria:

- Parallel updates produce deterministic files.
- A concurrent source edit prevents replacement.
- Failed edits leave original files byte-identical.

### Phase 6: Coverage and watch mode

Deliver precise V8 coverage, source-map remapping, thresholds, text, LCOV, JSON, dependency indexes, change selection, cancellation generations, and the failure cache.

Exit criteria:

- TypeScript, JSX, branches, and unloaded-source fixtures report expected ranges.
- Watch mode reruns the closed reverse dependency set.
- Configuration and unresolved dynamic changes trigger safe wider reruns.

### Phase 7: Compatibility hardening

Deliver opt-in `bun:test` import mapping, documented Jest and Vitest aliases, DOM preload fixtures, cross-platform stress tests, and comparative benchmarks.

Exit criteria:

- The published compatibility table is generated from passing fixtures.
- No compatibility claim depends on an undocumented alias or silent fallback.
- Performance results state isolation, coverage, cache, and worker settings.

## 34. Verification strategy

### 34.1 End-to-end fixtures

The primary verification method launches the real `bnpm test` command against temporary projects.
Fixtures cover:

- ESM and CommonJS package boundaries.
- JavaScript, TypeScript, JSX, and TSX.
- Nested hooks and failures in every lifecycle stage.
- Promise, callback, timeout, unhandled rejection, and process exit behavior.
- Global and module-cache isolation.
- Concurrent tests and serial barriers.
- Worker crashes and child-process cleanup.
- Snapshot creation, mismatch, update, conflict, and interruption.
- Coverage mapping and thresholds.
- Reporter validity and output escaping.
- Sharding, retries, repeats, randomization, and bail.
- Watch invalidation across source and package edges.

### 34.2 Protocol tests

The coordinator is tested against malformed, oversized, duplicated, reordered, and truncated frames.
It must reject invalid transitions without deadlocking or trusting worker totals.

Golden protocol fixtures include the schema and protocol version.
Breaking changes require an intentional version increment.

### 34.3 Differential tests

Selected semantic fixtures run against `bnpm:test`, Bun, Jest, Vitest, and Node's test runner where their contracts overlap.
Differences are classified as:

- Intended product behavior.
- Unsupported compatibility.
- Reference-runner difference.
- Product defect.

Differential testing does not make another runner the sole oracle.
The product contract in this document remains authoritative.

### 34.4 Fault injection

Fault tests terminate workers during collection, execution, snapshot emission, coverage emission, and shutdown.
They fill output pipes, corrupt cache entries, modify source during inline updates, remove the runtime, and interrupt atomic report publication.

A fault must produce a nonzero result and leave source, snapshots, caches, and reports in a valid previous or clearly absent state.

## 35. Risks and mitigations

### Runtime startup cost

Risk: Process-per-file isolation can be slower than Bun's reusable runtime globals.

Mitigation: Use warm unbundled compile caches, lazy parallel scale-up, duration-aware ordering, and an explicit shared mode without weakening the default contract.

### Module mocking gap

Risk: Users may expect Jest hoisting or Bun's post-import ESM replacement.

Mitigation: Define recognized hoisting syntax, require registration before evaluation, fail on late replacement, and publish a fixture-generated compatibility table.

### Source-map drift

Risk: Coverage and diagnostics may point to generated rather than original locations.

Mitigation: Share compiler source maps, validate every map, keep generated and original identities, and test TypeScript and JSX ranges end to end.

### Snapshot corruption

Risk: Parallel workers or a simultaneous editor save could overwrite source.

Mitigation: Centralize writes, compare source digests, reject overlaps, write sibling temporary files, and replace atomically.

### Unbounded user output

Risk: A log loop can block pipes or exhaust coordinator memory.

Mitigation: Drain continuously, stream to bounded storage, expose truncation, and keep the control channel separate.

### Timeout cleanup gaps

Risk: Descendant processes may outlive a failed test.

Mitigation: Use process groups or Job Objects, enforce a grace period, and run platform-specific grandchild cleanup fixtures.

### Watch under-selection

Risk: Dynamic resolution can hide a dependency edge and skip an affected test.

Mitigation: Track unresolved and dynamic edges and widen selection when certainty is lost.

### Runtime version differences

Risk: Node.js behavior and inspector coverage can differ across LTS releases.

Mitigation: Maintain an explicit support matrix, key caches by runtime major version, and run conformance fixtures on every supported release.

## 36. Open decisions before implementation

The following decisions require prototype evidence before their contracts are frozen:

1. Whether Node.js 22 LTS remains in the first support matrix or Node.js 24 LTS is the minimum.
2. Whether recognized `mock.module` hoisting should be enabled by default or only in an explicit compatibility mode.
3. Whether `onTestFinished` callbacks run before or after outer `afterEach` hooks when nested suites register them.
4. Which serializer plugin interface can remain deterministic across process and protocol versions.
5. Whether shared isolation should ship in the initial stable release or remain experimental.
6. Which active-resource signals are reliable enough to support a strict open-handle failure mode.
7. Whether test-name regular expressions use JavaScript syntax in a small helper process or a documented native regex subset.

Each decision needs an executable fixture and a recorded compatibility impact.
None may be resolved by silently inheriting whichever behavior is easiest to implement.

## 37. Release gates

The initial stable release is blocked until:

- Default process isolation passes global, module-cache, timer, listener, and environment mutation fixtures.
- Hard timeouts terminate infinite loops and ordinary descendant processes on every supported operating system.
- Every public `bnpm:test` export has matching runtime behavior, TypeScript declarations, and a conformance fixture.
- Hook ordering, cleanup after failure, unhandled errors, retries, and concurrent barriers pass end-to-end fixtures.
- Snapshot writes are atomic and conflict-safe.
- Coverage maps TypeScript and JSX to expected original ranges.
- JUnit XML validates against representative CI consumers.
- JSON Lines protocol documentation matches emitted events.
- Shards are complete, disjoint, deterministic, and balanced with timing data.
- Watch mode widens selection whenever the dependency graph is uncertain.
- Unsupported Bun, Jest, and Vitest behaviors are listed without implying compatibility.
- Benchmark reports disclose runtime, isolation, coverage, cache, worker count, and corpus.
- The command works without a GPU.

## 38. Source references

Research for this document used the following primary sources:

- [Bun test runner overview](https://bun.sh/docs/test).
- [Bun test discovery](https://bun.sh/docs/test/discovery).
- [Bun test writing API](https://bun.sh/docs/test/writing-tests).
- [Bun test lifecycle hooks](https://bun.sh/docs/test/lifecycle).
- [Bun test parallel execution](https://bun.sh/docs/test/parallel).
- [Bun test runtime behavior](https://bun.sh/docs/test/runtime-behavior).
- [Bun test mocks](https://bun.sh/docs/test/mocks).
- [Bun test dates and times](https://bun.sh/docs/test/dates-times).
- [Bun test snapshots](https://bun.sh/docs/test/snapshots).
- [Bun test code coverage](https://bun.sh/docs/test/code-coverage).
- [Bun test reporters](https://bun.sh/docs/test/reporters).
- [Bun test configuration](https://bun.sh/docs/test/configuration).
- [Bun DOM testing guidance](https://bun.sh/docs/test/dom).
- [Bun test runner source directory](https://github.com/oven-sh/bun/tree/main/src/runtime/test_runner).
- [Bun parallel runner source](https://github.com/oven-sh/bun/blob/main/src/runtime/cli/test/parallel/runner.rs).
- [Bun Jest compatibility tracker](https://github.com/oven-sh/bun/issues/1825).
- [Node.js test runner documentation](https://nodejs.org/api/test.html).
- [Node.js module customization hooks](https://nodejs.org/api/module.html#customization-hooks).
- [Node.js inspector API](https://nodejs.org/api/inspector.html).
- [Node.js child process API](https://nodejs.org/api/child_process.html).
- [Node.js worker threads API](https://nodejs.org/api/worker_threads.html).

## 39. Final product decision

`bnpm test` will be a native coordinator around isolated external Node.js processes, not a hidden JavaScript runtime implementation.
It will borrow Bun's strongest ideas in discovery, cooperative in-file concurrency, lazy worker scaling, duration-aware scheduling, centralized aggregation, snapshots, and source-mapped coverage.
It will change the defaults where this architecture demands a safer contract, especially file isolation and module mocking.

The first release succeeds when it provides dependable test semantics, clear compatibility boundaries, safe failure handling, and useful performance on ordinary CPU systems.
