---
name: sf-create-tasks
description: Decomposes an approved Spec Finder PRD and TechSpec into an approved, codebase-enriched task plan sliced by user/operator outcome. Numeric IDs are the canonical execution order, with backward-only dependencies, per-task tests, workflow memory, and validation. Use for executable planning or task regeneration, not product design, architecture selection, or implementation.
---

# Create Spec Finder Tasks

<HARD-GATE>
- NEVER write, replace, renumber, or delete `_tasks.md` or `task_NN.md` before source artifacts, ADRs, repository context, task boundaries, and the complete dependency graph have been reviewed and explicitly approved.
- NEVER invent implementation details to compensate for a missing TechSpec.
- NEVER create a task that depends on undeclared work, contains a cycle, separates tests from implementation, or exceeds the bounded-task limits.
- NEVER assign task IDs before the dependency graph is complete and topologically ordered. Every declared dependency MUST have a lower numeric task ID than its consumer.
- NEVER use generic source instructions such as "read the PRD" or "read the TechSpec" in a generated task. Every task MUST name its own packet's exact repository-relative `_prd.md` and `_techspec.md` paths.
- NEVER split by layer (schema / API / UI / tests) when a user-outcome slice is possible.
- NEVER create a foundation task with no independently testable outcome.
- NEVER report completion until every generated file and memory file has been re-read and the packet passes structural validation.
- NEVER overwrite existing workflow memory while regenerating tasks.
</HARD-GATE>

## Interaction contract

- Use the runtime's blocking question mechanism for material task-boundary decisions. Otherwise make the question the complete response and stop.
- Every question must provide at least two suggested answers with sequential uppercase labels: `A.`, `B.`, `C.`, and so on. Put the recommendation first as `A. (Recommended)`, add `Other` with the next available letter whenever the answers are not exhaustive, and never use unlabeled bullets or open-ended answer requests.
- End every choice prompt with: `Reply with the letter (for example, A), or the letter plus context.` Accept lowercase letters and full option text too.
- Present the entire proposed graph in one review, not task-by-task approval.
- Recommend a graph, but wait for explicit approval before filesystem writes.
- If codebase evidence conflicts with the approved TechSpec, present lettered answers for revising the TechSpec, accepting a documented task-level deviation, stopping, or another direction.

Read `references/question-protocol.md` before asking questions or requesting graph approval.

## Required inputs

- `.spec-finder/tasks/<slug>/_prd.md` or `_techspec.md`.
- Both are required for implementation-ready tasks unless the user explicitly accepts higher-level, research-enriched tasks without a TechSpec.

If both files are absent, stop and direct the user to `sf-create-prd` or `sf-create-techspec`.

Still generate `task_01.md` through `task_NN.md` and `_tasks.md`. Do not create story files. PRD `US-xx` / `F-xx` are the slice keys; tasks are the execution units.

## Mandatory phase checklist

1. Load configuration, idea, PRD, TechSpec, ADRs, memory, existing tasks, and repository rules.
2. Build requirements and implementation-context ledgers grouped by user/operator outcome.
3. Explore packet-wide and slice-specific code/test surfaces.
4. Propose an independently implementable DAG of outcome slices without final IDs.
5. Topologically order the DAG, assign sequential IDs, pass INVEST, and obtain explicit approval of that execution order.
6. Write the task index, task files, and missing memory files.
7. Enrich every task from current codebase evidence.
8. Validate naming, schema, titles, execution order, dependencies, scope, sections, tests, traceability, and memory.

## Workflow

### 1. Load authoritative context

- Read `.spec-finder/config.json`, `_idea.md`, `_prd.md`, `_techspec.md`, every ADR, `memory/MEMORY.md`, existing `_tasks.md`, and all existing `task_NN.md` files.
- Read repository instructions, test conventions, build/verification commands, and relevant platform constraints.
- Read `references/task-context-schema.md` and `references/task-template.md`.
- New packets use the current template. In regeneration mode, preserve approved task IDs, memory, and existing section layouts unless the user explicitly approves renumbering, removal, or a template migration. Identify completed tasks before proposing changes. If existing IDs violate execution order, stop and present an explicit renumbering migration; do not silently preserve an invalid order or silently renumber it.

### 2. Handle missing design context

When `_techspec.md` is missing:

- explain that tasks can specify product behavior but cannot safely assert implementation boundaries;
- perform deeper codebase exploration;
- list the exact design gaps that will remain;
- ask with lettered choices whether to stop for `sf-create-techspec`, continue with higher-level tasks, or provide another direction.

Do not bury this choice in a warning and continue automatically.

### 3. Build evidence ledgers

Create two internal mappings before decomposition:

- **Requirement ledger:** every PRD goal, story, capability, constraint, TechSpec component, contract, risk, and build-order step, grouped by user/operator outcome (`US-xx` / `F-xx`). Goals are the metrics; map leftover `M-xx` when present.
- **Repository ledger:** relevant files, callers/consumers, test files, fixtures, conventions, verification commands, and repository rules.

Every requirement must map to at least one proposed task or be explicitly marked non-implementation/out-of-scope with rationale.

### 4. Explore task boundaries

- Explore packet-wide architecture first, then the concrete surfaces for each proposed **slice**, not each layer.
- Use real parallel exploration for independent surfaces when available; otherwise work sequentially.
- Verify file paths exist or clearly mark them as files to create.
- Trace dependent files and integration consumers, not only direct edit targets.
- Reassess boundaries when exploration reveals hidden coupling that would force a layer split or a foundation-only task.

### 5. Propose and order the DAG

Split by **user/operator outcome** (PRD `US-xx` / `F-xx` flow), not by layer.

- One logical task = one shippable outcome that cuts the files it needs (CLI + engine + data, TUI + store, and so on).
- Bad: “build schema”, “build API”, “build CLI”, “write tests”.
- Good: “dry-run prints plan and writes nothing”, then “resume after kill skips completed work”, then “named terminal on fail-fast”.
- Shared contracts may land first only if that task still has an independently testable outcome. “Create the Zod file” is not a task.
- If a contract is unknown, insert a `spike` first with a decision criterion, then the implementation slice. Flag blockers on the graph.
- `type` is the primary deliverable, not the split. Do not carve a vertical slice into frontend/backend twins to make types homogeneous.

First define each logical task without committing to a numeric ID. For each task present:

- temporary logical key and imperative title;
- primary `US-xx` / `F-xx`;
- 2-3 sentence user/operator outcome;
- INVEST status;
- requirement and TechSpec coverage;
- relevant and dependent files;
- type and evidence-based complexity;
- dependencies and why each is required;
- Given/When/Then acceptance;
- out of scope;
- focused tests and repository gate;
- rollout note or `N/A`;
- spike decision criterion when `type` is `spike`.

**INVEST** — fail means split, spike, or drop from MVP before asking approval:

| Letter | Meaning |
|---|---|
| I | Independently implementable once declared dependencies are done |
| N | How lives in the TechSpec; the task does not freeze extra design |
| V | Named user/operator outcome (`US-xx` / `F-xx`) |
| E | Complexity plus verified files |
| S | One outcome, at most seven primary files unless the user accepts `critical` |
| T | Given/When/Then acceptance plus named tests |

After the dependency graph is complete:

1. Topologically sort it so every prerequisite appears before every consumer.
2. Resolve ties between simultaneously runnable tasks using this deterministic priority:
   - tasks on the critical path or unlocking the most downstream work;
   - tasks delivering earlier user-visible verification;
   - independently testable shared contracts, migrations, or integration seams required by later work;
   - spikes and risk reduction before the slices they unblock;
   - stable source-requirement order as the final tie-breaker.
3. Assign `task_01` through `task_NN` only after that order is fixed.
4. Require every dependency of `task_NN` to be a strictly lower-numbered task.

The numeric ID is the canonical recommended execution position. Parallelizable tasks still receive a deterministic numeric order; label them parallelizable, but never assign a later task as a dependency of an earlier task.

Present the final execution table in numeric order, a slice grouping by primary story/capability, spikes and blockers, dependency chains, roots, leaves, critical path, parallelizable groups, tie-break rationale, and deliberate sequencing constraints.

Task invariants:

- independently implementable once declared dependencies are complete;
- one primary user/operator outcome that passes INVEST;
- no cycles or undeclared prerequisites;
- task numbers match the approved topological execution order;
- every dependency points strictly backward to a lower-numbered task;
- tests live with implementation, never in a separate test-only task;
- 3-7 outcome-oriented subtasks;
- no more than seven primary touched files unless the user approves an indivisible critical task;
- no copied interface definitions or architecture prose from the TechSpec.

Wait for explicit approval of the complete graph and numbered execution order using `A. Approve and write tasks`, `B. Revise the graph`, `C. Stop`, and `D. Other`. Revise, re-sort, and re-present when task boundaries or dependencies change.

### 6. Write files

- Write `_tasks.md` in canonical execution order with sequential IDs, primary slice (`US-xx` / `F-xx`), status, complexity, dependencies, and concise outcomes. Include an `Execution order` section, a `Slices` grouping by primary story/capability, and label parallelizable groups, spikes, and blockers without changing numeric order.
- Write `task_01.md` through `task_NN.md` using `references/task-template.md`.
- Replace every `<slug>` source-artifact placeholder in the template with the current packet slug. Do not leave placeholders or shorten the references to generic PRD or TechSpec names.
- Use required frontmatter exactly: `status`, `title`, `type`, `complexity`, and `dependencies`.
- Initialize `memory/MEMORY.md` plus `memory/task_NN.md` using `sf-memory`. Create missing files only; never overwrite existing memory.
- Require `reports/task_NN.md` as a completion invariant in every task.

### 7. Enrich every task

Every task must contain:

- `## Overview` with one user/operator outcome, primary `US-xx` / `F-xx`, and value;
- `## Source Artifacts` with the exact repository-relative `.spec-finder/tasks/<actual-slug>/_prd.md` and `.spec-finder/tasks/<actual-slug>/_techspec.md` paths for that packet;
- the complete `<critical>` block;
- `## Acceptance` with Given/When/Then for this slice;
- `## Out of Scope` naming excluded work and the later task or PRD non-goal;
- numbered MUST/SHOULD requirements;
- 3-7 bounded `## Subtasks` describing WHAT under this outcome, not extra stories or code mechanics;
- `## Implementation Details` with verified relevant/dependent paths and TechSpec Contracts / Architecture / Sequencing references;
- applicable ADR links;
- concrete deliverables including tests, memory, and final report;
- specific unit/integration/platform test cases with named inputs, conditions, and expected behavior;
- `## Rollout` with a migration/compat/docs note or `N/A` and reason;
- measurable success criteria and the exact repository verification gate.

A `spike` must state the unknown, the decision criterion, and the evidence that will resolve it. Product tests may be `Not applicable` with reason; the report still records the decision.

Use the repository's coverage policy. If none exists, target at least 80% coverage for new or changed testable logic and state when coverage is not measurable or applicable.

Created tasks run unattended. Do not write halt-on-first-failure, halt-on-ambiguity, or "ask the user" instructions into `task_NN.md`. Every generated `<critical>` block MUST include the template's uninterrupted-execution lines so an executor that only reads the task file still tries to fix verification failures and resolve spec conflicts before stopping.
Prefer automated evidence. When platform evidence cannot run in the execution environment, the task MUST allow documenting the limitation and continuing with the automated gate.

### 8. Validate before completion

Re-read every generated file and verify:

- filenames match `task_\d+.md` and numbering is consistent;
- YAML frontmatter parses and uses allowed values;
- H1 title exactly matches frontmatter title;
- IDs are contiguous and reflect the approved topological execution order;
- all dependencies exist, have lower numeric IDs than their consumers, and form an acyclic graph;
- `_tasks.md`, task filenames, task H1 numbers, memory filenames, and report paths all use the same execution-order ID;
- `_tasks.md` groups tasks by primary slice and labels spikes and blockers;
- every source requirement is covered exactly where intended;
- every task names a primary `US-xx` / `F-xx`, has Given/When/Then acceptance, out of scope, and a rollout note;
- no task is a layer-only foundation when an outcome slice was possible;
- every task passes INVEST;
- all mandatory sections, tests, gates, memory files, and report paths exist;
- every task names its packet's exact `_prd.md` and `_techspec.md` paths in `## Source Artifacts` and `<critical>`, contains no unresolved `<slug>` placeholder, and does not rely on generic "the PRD" or "the TechSpec" instructions;
- task scope and complexity match discovered files and coupling;
- existing completed tasks and memory were not overwritten.

Fix all validation failures and repeat validation. Report unresolved failures rather than claiming the packet is ready.

## Complexity

- `low`: one primary file, no new interface, straightforward behavior.
- `medium`: 2-4 primary files or one bounded new interface, limited integration.
- `high`: 5-7 primary files, a subsystem/refactor, concurrency, migration, or several integrations.
- `critical`: indivisible cross-cutting/high-regression work; split unless the user explicitly accepts the coordination burden.

## Anti-patterns

- Mega-tasks that hide multiple outcomes.
- Splitting by layer (schema, API, UI, tests) when a user-outcome slice is possible.
- “Foundation” tasks with no independently testable value.
- Homogeneous `type` values as a reason to split a vertical slice.
- Separate implementation and test tasks.
- Vague tests such as “test errors” or “verify happy path”.
- Missing out of scope so follow-up work leaks into the slice.
- Dependencies added only to force serial execution.
- Numbering tasks by PRD section, UI/backend grouping, or discovery order instead of executable dependency order.
- Assigning IDs before the graph is complete, producing forward dependencies such as `task_02` required by `task_01`.
- File paths guessed without codebase evidence.
- Generic PRD or TechSpec instructions that let an executor select source artifacts from another packet.
- Regeneration that silently renumbers tasks, migrates old layouts, or erases memory.
- Tasks that tell the executor to halt on the first failed command, missing optional platform evidence, Git HEAD, or spec ambiguity.

## Failure rules

- If task boundaries conflict with the TechSpec, stop at the graph decision gate.
- If one task cannot be enriched, continue analyzing the others but do not write a partially approved packet without disclosing the failure.
- If completed tasks constrain regeneration, preserve them and propose additive/replacement work explicitly.
- If validation cannot pass, leave status truthful and report exact failing files and rules.
