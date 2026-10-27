---
name: sf-tdd-batch
description: Sequentially executes a range or all tasks in one Spec Finder packet through sf-tdd-execute, with dependency gates, stop-on-failure behavior, config-driven local checkpoint phases, and runtime-aware lifecycle ownership. Use for multi-task manual TDD skill runs; use sf-batch-tasks for the core non-TDD path, and sf-tdd-execute for one task.
---

# Batch-Execute Spec Finder Tasks with TDD

<HARD-GATE>
- NEVER start a task until the packet, requested range, current statuses, dependency graph, execution order, and config-owned checkpoint mode are resolved and printed.
- NEVER run a task whose dependency is neither completed nor scheduled and completed earlier in this batch.
- NEVER continue after a task fails verification, lacks a substantive report, or does not reach `status: completed`.
- NEVER treat an invocation token as checkpoint policy. Never blanket-stage, include pre-existing unrelated changes, or push.
- NEVER let both the Spec Finder runtime and this skill own lifecycle changes for the same run.
- NEVER invoke `sf-execute-task` or `sf-task-report`. The only invoke targets are `sf-tdd-execute` and `sf-tdd-report`.
- NEVER require a user-global `/tdd` path. Read `references/tdd-doctrine.md` in this tree.
</HARD-GATE>

Use `spec-finder run <slug>` when the user wants the cockpit/ACP runtime. That path defaults to core unless the packet has `tdd.json`. This skill remains the manual TDD orchestration path for explicit ranges and config-driven local checkpoints.

## Invocation

```text
/sf-tdd-batch <slug> <range> [force]
```

- `<slug>` resolves to `.spec-finder/tasks/<slug>/`.
- `<range>` accepts the forms below.
- `force` includes tasks already in a completed terminal state.

Checkpoint policy is read only from `.spec-finder/config.json`:

- `auto_commit: false` or an omitted field preserves the existing no-commit flow.
- `auto_commit: true` enables the shared local checkpoint service through the CLI bridge.
- Legacy `auto-commit=true` and `auto-commit=false` tokens are rejected before task work with: `legacy auto-commit=<value> invocation token is unsupported; set auto_commit in .spec-finder/config.json instead`. They are never policy inputs.

Examples:

```text
/sf-tdd-batch progress-cockpit task_01 to task_04
/sf-tdd-batch progress-cockpit all
/sf-tdd-batch progress-cockpit 03 to 05 force
```

## Workflow

Track this checklist:

```text
Batch progress:
- [ ] 1. Resolve packet and enumerate tasks
- [ ] 2. Parse range and validate dependencies
- [ ] 3. Filter completed tasks and print the plan
- [ ] 4. Execute each task through sf-tdd-execute
- [ ] 5. Gate report/status and complete the optional checkpoint phase
- [ ] 6. Summarize completed, skipped, failed, and remaining tasks
```

### 1. Resolve the packet

- Resolve `.spec-finder/tasks/<slug>/`; never ask for paths derivable from the slug.
- If absent, stop and list available packet slugs.
- Read `_idea.md`, `_prd.md`, `_techspec.md`, `_tasks.md`, all ADRs, shared memory, task files, repository instructions, and current Git state.
- Enumerate `task_*.md` numerically. If none exist, stop and recommend `sf-create-tasks`.

### 2. Parse and order the range

Normalize and deduplicate the requested tasks, retain only existing files, and report missing requests. Order selected tasks topologically by declared dependencies, using numeric task order as the stable tie-breaker.

| Input | Meaning |
|---|---|
| `all` | Every task file in the packet |
| `task_03` or `03` | One task |
| `task_01 to task_10` | Inclusive range |
| `01 to 10` or `task_01-task_10` | Equivalent lenient ranges |

Normalize numbers to the repository's actual zero-padded filename. Do not invent missing tasks.

### 3. Filter and print the plan

- Unless `force` is present, skip `completed`, `done`, and `finished` tasks.
- For every task to run, require each dependency to be terminal-completed or scheduled earlier in this batch. Stop on an unmet dependency; do not merely warn.
- Print tasks to run in order, completed skips, missing requests, dependency blockers, and the config-owned `auto_commit` mode.
- When `auto_commit: true`, use the CLI bridge to capture each task baseline; do not capture or stage Git state in the skill itself. A skipped begin (missing Git HEAD) is not a batch blocker.

### 4. Execute sequentially

For each selected task:

1. If `auto_commit: true`, run `spec-finder checkpoint begin <slug> <task_id>`.
   - Exit 0 and a created baseline: keep checkpoints enabled for this batch and continue.
   - Exit 0 with `checkpoint begin skipped` (missing Git HEAD / unborn branch): print the skip reason, disable begin/complete for the rest of this batch, and continue task execution. Do not stop. Do not create an initial commit.
   - Nonzero exit (blocked): stop the batch before task execution. Unsafe Git state still fail-closes.
2. Invoke `sf-tdd-execute` with the absolute `task_NN.md` path and state that this is a manual batch invocation, so `sf-tdd-execute` owns the task's TDD report (`sf-tdd-report`) and status transition.
3. Let it complete dependency checks, red→green slices or N/A skip, focused verification, repository verification, memory updates, and `sf-tdd-report`.
4. Re-read the task and `reports/task_NN.md`. Continue only when status is exactly `completed`, the report is substantive, its verdict is completed, and TDD Evidence is either per-slice red+green or a one-line not-applicable reason.
5. If checkpoints remain enabled for this batch, run `spec-finder checkpoint complete <slug> <task_id>` only after that report/status gate. A blocked complete stops the batch before the next task; the completed task is retried by a normal rerun without rerunning its implementation. Do not call complete after a skipped begin.
6. Stop immediately on failed, blocked, incomplete, missing, partial, or stale evidence.

Checkpoint phases are local-only and use the shared service. They preserve Git hooks/signing and never push, open a PR, imply review/merge, or accept remote/bypass/stash/reset/clean options.

### 6. Summarize

Report completed tasks, completed skips, missing requests, the failed or blocked task, and tasks not started. Include any created checkpoint identifier or blocked-delivery reason. State that checkpoints are local and uncommitted changes remain uncommitted when `auto_commit` is false. Never push.

## Rules

- Preserve unrelated dirty state and task scope.
- Treat the per-task frontmatter status and mandatory TDD report as the completion contract.
- Record out-of-scope discoveries as memory or report follow-ups; never absorb them silently.
- Do not duplicate Git checkpoint logic in the skill; both phases must route through the CLI bridge and shared service.
- If the harness cannot invoke `sf-tdd-execute`, stop and report the missing capability instead of silently substituting `sf-execute-task`.
