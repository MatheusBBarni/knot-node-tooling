---
name: sf-tdd-plan
description: Adds or updates an additive ## TDD Plan on an existing Spec Finder task_NN.md with derived public seams and ordered observable slices, or a one-line not-applicable reason. Use for TDD planning on existing implementation tasks, not to replace sf-create-tasks, execute code, or write reports.
---

# Plan Spec Finder TDD Slices

<HARD-GATE>
- NEVER write, replace, or delete required create-tasks sections, `_tasks.md` IDs, or task frontmatter status.
- NEVER require a user-global `/tdd` path. Read `references/tdd-doctrine.md` in this tree.
- NEVER ask the user to confirm seams. Derive them from the task, TechSpec, ADRs, and any existing plan.
- NEVER invent red slices for `not_applicable` work, and NEVER accept a not-applicable plan without exactly one reason line.
- NEVER accept a slice identity that lacks observable behavior (for example "test happy path").
</HARD-GATE>

Opt-in planning only. Core `sf-create-tasks` remains the task-graph author. This skill enriches an existing `task_NN.md` with an additive `## TDD Plan`.

## Invocation

```text
/sf-tdd-plan <slug> [task_id|range|all]
```

- `<slug>` resolves to `.spec-finder/tasks/<slug>/`.
- Omit the selector or pass one `task_NN` / `NN` to plan that file.
- `all` and inclusive ranges (`task_01 to task_03`, `01 to 03`) plan each existing file in numeric order.
- Do not invent missing task files.

## Workflow

1. Read this skill, `references/tdd-doctrine.md`, and `references/tdd-plan-template.md`.
2. Read the packet `_prd.md`, `_techspec.md`, relevant ADRs, `memory/MEMORY.md`, and each selected `task_NN.md` plus `memory/task_NN.md`.
3. Classify the task:
   - **applicable** when it adds or changes product behavior that can be observed at a public seam.
   - **not_applicable** when it is docs, chore, config-only, research-only, or otherwise has no new or changed product behavior. Write exactly one reason line. Leave Seams and Slices empty. Stop for that task.
4. For applicable work, derive public seams from the task, TechSpec, and ADRs. Do not open an interactive confirmation gate.
5. Write ordered vertical slice identities. Each name must state observable behavior at a named seam. Reject vague names such as "test happy path", "add tests", or "cover edge cases" and rewrite or stop until the identity is observable.
6. Add `## TDD Plan` if missing, or replace only that section if present, using the template shapes. Leave every other heading untouched.
7. Update `memory/task_NN.md` with the applicability choice and derived seam list when that helps the next execute run.

## Rules

- Doctrine in this tree is sufficient after setup. Cite `/tdd` only as maintainer origin.
- One vertical slice per numbered item; no horizontal all-tests list.
- Tests belong at public seams. Do not plan private-method or collaborator-mock slices.
- Re-planning is this skill's job after `sf-create-tasks` regeneration. Do not teach create-tasks to delete unknown sections.
- Do not execute tests, write production code, or write `reports/task_NN.md`.
