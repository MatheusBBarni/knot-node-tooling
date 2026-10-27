---
name: sf-tdd-execute
description: Executes one Spec Finder task as vertical red-then-green slices at public seams, records short notes in existing memory headings, and preserves the ACP versus manual lifecycle split. Use for opted-in behavioral TDD work, not core execute, planning, or report writing under ACP.
---

# Execute a Spec Finder Task with TDD

<HARD-GATE>
- Choose exactly one lifecycle owner before editing: the Spec Finder ACP runtime or this manual skill invocation. Never let both paths write status or reports.
- NEVER write production code for slice N before a focused command fails for that same test identity.
- NEVER write all tests first. Horizontal slicing is a stop condition.
- NEVER invent a red test when `## TDD Plan` records `not_applicable` with a one-line reason.
- NEVER require a user-global `/tdd` path. Read `references/tdd-doctrine.md` in this tree.
- NEVER add a `## TDD Slices` heading. Notes go only in existing `sf-memory` headings.
</HARD-GATE>

Parallel opt-in executor. Core `sf-execute-task` remains the ACP default.

## Uninterrupted execution

- Never ask the user a question or wait for confirmation while executing a task.
- Ambiguity is a decision to make, not a reason to halt. Derive seams and interpretations from the task, TechSpec, ADRs, and memory, then continue.
- After the last green, if remaining focused tests or the repository gate fail, fix in scope and re-verify until clean. Do not ask whether to proceed.
- Missing Git HEAD or checkpoint unavailability is not an implementation blocker.
- TDD slice stops (unexpected red pass, failed green, doctrine anti-patterns) still apply to the current slice. They are not a reason to skip a later repair of an otherwise valid green path.

## Invocation

```text
/sf-tdd-execute <slug> <task_id>
```

- `<slug>` resolves to `.spec-finder/tasks/<slug>/`.
- `<task_id>` is one existing `task_NN` / `NN`. Do not invent missing files.

## Workflow

1. Decide the lifecycle owner. ACP runtime versus a manual caller such as `sf-tdd-batch`.
2. Read this skill, `references/tdd-doctrine.md`, the task, `_prd.md`, `_techspec.md`, `_tasks.md`, relevant ADRs, repository instructions, and current Git state.
3. Use `sf-memory`. Read `memory/MEMORY.md` and `memory/task_NN.md`. Keep notes short: command identity, result meaning, decisive excerpt. No transcripts.
4. Verify every declared dependency is completed and its required artifacts exist. Stop with a concrete blocker if not. This is a graph gate, not a design conflict.
5. For a manual invocation, set the task to `in_progress` before editing. The runtime performs this transition itself for ACP runs.
6. Resolve the plan:
   - If `## TDD Plan` is `not_applicable` with exactly one reason line, skip every red cycle. Do not invent tests. Continue at step 10.
   - If `## TDD Plan` is missing or incomplete, derive seams and ordered slices from the task, TechSpec, ADRs, and memory. Do not ask the user to confirm seams. Optionally write the derived section with `sf-tdd-plan` first; execute may proceed from the derived list.
7. Read `Ready for Next Run`. Resume rules:
   - `red done / green incomplete` for test identity T → rerun that same command identity. Do not start a different red.
   - `green done → next red` → start the next planned slice.
   - No resume note → start the first unfinished slice.
8. For each remaining behavioral slice, in order:
   1. Write one failing public-seam test whose identity names observable behavior.
   2. Run the repository's focused command for that identity. Poll to terminal exit. Require failure for the intended missing behavior. An unexpected pass is a stop: do not write production code for this slice.
   3. Record the red note under `Learnings` (command identity, fail meaning, short excerpt) and `Ready for Next Run` as `red done / green incomplete`.
   4. Write only enough production code to pass that same command identity.
   5. Rerun the same command. Require pass. Record the green note and set `Ready for Next Run` to `green done → next red`, or done when no slices remain.
9. After the last green, run the task's remaining focused tests and the repository verification gate to terminal exit. On failure, fix in scope and re-run until the gate is clean.
10. Update memory before any completion claim or handoff. `Important Decisions` holds applicability, seam derivation, and chosen test identities.
11. **ACP path:** stop after implementation, verification, and memory. Do not write `reports/task_NN.md`. Do not change frontmatter status.
12. **Manual path:** invoke `sf-tdd-report`, then set status to that report's exact verdict: `completed`, `failed`, or `blocked`.

## Failure rules

- Unexpected red pass, failed green, missing red evidence, or a doctrine stop condition (`implementation-coupled`, `tautological`, `horizontal slicing`) stops the slice. Keep partial notes. Manual status is `failed` or `blocked`; ACP leaves status to the runtime.
- Never weaken tests or configuration to hide a failure.
- Partial or stale command output is not evidence.
- Do not absorb follow-up scope. Record it in memory instead.
- Spec conflicts, missing optional platform evidence, and Git HEAD gaps are not halt conditions. Resolve, document, and continue unless the TDD slice itself failed.
