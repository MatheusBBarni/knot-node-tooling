---
name: sf-execute-task
description: Executes one approved Spec Finder task with dependency checks, strict scope, fresh verification, memory updates, and runtime-aware lifecycle discipline. Use when implementing a task_NN.md file manually or through the Spec Finder ACP runtime.
---

# Execute a Spec Finder Task

<HARD-GATE>
Choose exactly one lifecycle owner before editing: the Spec Finder ACP runtime or this manual skill invocation. Never let both paths write status or reports.
</HARD-GATE>

## Uninterrupted execution

Spec Finder runs tasks in a loop. Pausing for clarification or the first failed command breaks the loop.

- Never ask the user a question, present option menus, or wait for confirmation while executing a task.
- Never stop because the task file, TechSpec, ADRs, or PRD disagree. Resolve the conflict with the Authority rules below, record the chosen interpretation in task memory, and continue.
- Ambiguity is a decision to make, not a reason to halt. Prefer the interpretation that is most consistent with machine-checkable TechSpec contracts and the task's numbered requirements, then implement it.
- If focused tests or the repository gate fail, keep status unchanged, fix the failure, and re-verify until clean. Do not ask whether to proceed.
- Surface decisions only as brief memory notes or report follow-ups, never as a blocking prompt.
- Missing Git HEAD or checkpoint unavailability is not an implementation blocker.

## Authority

Resolve contradictions autonomously (highest wins). Record the pick; continue.

1. Machine-checkable TechSpec constraints beat conflicting prose in the same TechSpec.
2. This task's numbered `<requirements>` and assigned tests beat a looser paraphrase of the same fact.
3. ADRs beat informal notes when they address the same decision.
4. Among remaining ties, prefer the interpretation that satisfies the most mapped requirements and remains implementable in this task's scope.
5. The existing runtime shape is never the contract. If current code cannot express the resolved contract, extend it within task scope. If that is truly out of scope, implement the closest faithful solution, record the gap as a follow-up, and continue.

## Workflow

1. Determine whether the caller is the Spec Finder ACP runtime or a manual invocation such as `sf-batch-tasks`.
2. Read the task, `_prd.md`, `_techspec.md`, `_tasks.md`, relevant ADRs, repository instructions, and current git state before editing.
3. Use `sf-memory` to read `memory/MEMORY.md` and the current `memory/task_NN.md`. Keep task memory current and promote only durable cross-task facts.
4. Verify every declared dependency is completed and its required artifacts exist. Stop with a concrete blocker if not. This is a graph gate, not a design conflict.
5. For a manual invocation, set the task to `in_progress` before editing. The runtime performs this transition itself for ACP runs.
6. Map task requirements to existing code and tests. Keep unrelated dirty state untouched.
7. Implement the smallest complete change satisfying the task. Do not absorb follow-up scope.
8. Run the task's focused tests, then the relevant repository verification gate. Poll long-running commands to terminal exit; partial output is not evidence. On failure, fix in scope and re-run until the gate is clean.
9. Update memory before any completion claim or handoff. Include conflict-resolution decisions.
10. For an ACP runtime invocation, stop after implementation, verification, and memory updates. Do not write the report or change status; the runtime owns both remaining phases.
11. For a manual invocation, invoke `sf-task-report`, verify the report is substantive, and then set status to its exact verdict: `completed`, `failed`, or `blocked`. Update `_tasks.md` only when it explicitly tracks lifecycle status.

## Failure rules

- Never weaken tests or configuration to hide a failure.
- Distinguish implementation failure, environment failure, and missing platform evidence.
- An environment limitation that still allows a faithful in-scope solution is not a halt: capture the strongest available evidence, note the limitation, and continue.
- Record follow-ups instead of silently expanding scope.
- Missing Git HEAD or checkpoint unavailability is not an implementation blocker. Do not stop the task to create an initial commit or to wait for checkpoints. Batch and runtime own checkpoint phases.
- Stop only for true blockers: unmet declared dependencies, missing task or packet files, or a failure that cannot be fixed inside this task's scope after a serious repair attempt.
