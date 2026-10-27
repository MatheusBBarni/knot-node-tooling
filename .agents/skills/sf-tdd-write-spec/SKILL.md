---
name: sf-tdd-write-spec
description: Creates one approved, agent-executable Spec Finder spec whose implementation proceeds through Matt Pocock-style public-seam red-green vertical slices. Accepts a clear feature request or an approved `.spec-finder/tasks/<slug>/_prd.md` as product input. Writes `.spec-finder/tasks/<slug>/_spec.md`, references the PRD when one exists, prints both artifact paths, and bundles its TDD doctrine locally so the external `tdd` skill is not a dependency. A thin task with no PRD belongs to `sf-create-prd` first. Do not use for TechSpec, task, implementation, or report creation.
---

# Write a TDD Spec Finder Spec


## Coexistence with a PRD

`sf-create-prd` and this skill produce separate artifacts in `.spec-finder/tasks/<slug>/`.

1. A thin or poorly written task with little context goes to `sf-create-prd` first.
2. An approved `.spec-finder/tasks/<slug>/_prd.md` is the product source of truth and remains unchanged.
3. This invocation writes `.spec-finder/tasks/<slug>/_spec.md`, with confirmed public test seams and red-green slices. It names `_prd.md` as its Product source and inlines approved decisions.
4. A clear request may start here with no PRD. Create only `.spec-finder/tasks/<slug>/_spec.md`. If the change has no public-seam behavior, offer `sf-write-spec` instead.

One invocation changes exactly one file: `.spec-finder/tasks/<slug>/_spec.md`.
That file is a complete implementation prompt with confirmed public test seams and ordered red-green vertical slices.

Read `references/tdd-doctrine.md` before research.
Read `references/spec-template.md` and `references/quality-bar.md` before drafting.

<HARD-GATE>
- NEVER require the external `tdd` skill, a user-global `/tdd` path, or another TDD skill. The bundled `references/tdd-doctrine.md` is authoritative for this workflow.
- NEVER write or replace the spec before repository research, public-seam confirmation, complete draft review, and explicit whole-draft approval.
- NEVER write `.spec-finder/specs/`, `_prd.md`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, reports, or memory artifacts. `.spec-finder/tasks/<slug>/_spec.md` is the only packet write allowed.
- NEVER write production code or execute the implementation. This skill authors the spec only.
- NEVER require a PRD. When an approved `.spec-finder/tasks/<slug>/_prd.md` exists, treat it as the product source of truth and inline its decisions.
- NEVER invent product scope for a thin task that has no approved PRD. Stop and offer `sf-create-prd`.
- NEVER tell the executor to read the PRD instead of this spec.
- NEVER re-decide problem, users, goals, non-goals, or in-scope capabilities that the approved PRD already fixed, unless repository evidence conflicts.
- NEVER approve a TDD slice without one failing public-seam test, the same focused command for red and green, and only enough implementation to make that test pass.
- NEVER permit implementation-coupled tests, tautological expectations, or horizontal slicing.
- NEVER place refactoring inside the red-green loop. Put it in the review stage after all slices are green.
- NEVER skip repository research or ask the user for facts the repository or current primary docs answer.
- NEVER save acceptance criteria that are not observable Given/When/Then.
- NEVER omit the core Implementation, Problem and Delta, Scope, Acceptance, Repository Anchors, Public Test Seams, TDD Execution, TDD Slices, Verification, Review, or Output sections.
- NEVER retain Contract Changes or Risks and Edge Cases when the section does not change executor behavior.
- NEVER omit the bounded executor clarification protocol: at most six implementation questions, exactly one per turn, recommendation-first labeled choices, and material-decision limits.
- NEVER omit the user's commit-cadence choice from the saved spec or enable intermediate commits without their opt-in.
</HARD-GATE>

## Interaction contract

- Research first.
- Before writing any test plan, present the proposed public seams and confirm the proposed public seams with the user.
- Ask exactly one remaining question per turn using the runtime's blocking question mechanism when available.
- Give 2-3 concrete labeled choices, recommendation first. Do not auto-resolve scope, contract, security, migration, ownership, seam, or evidence decisions.
- Present the complete draft once and obtain explicit whole-draft approval before writing.
- Offer the Git commit cadence before drafting, even when no other decision remains. An explicit request for a cadence counts as the answer; preserve it in update mode unless the user changes it.

## Required input and output

Input: a clear feature request, idea, existing spec slug, or an approved `.spec-finder/tasks/<slug>/_prd.md`.
Optional update input: an existing `.spec-finder/tasks/<slug>/_spec.md`.

Write exactly one file after approval:

- `.spec-finder/tasks/<slug>/_spec.md`

If an approved PRD exists, leave it unchanged, name its exact path as Product source, and inline its decisions into `_spec.md`.
If the input is a thin task and no approved PRD exists, stop and offer `sf-create-prd`.
A request is thin when it does not state who is affected, the current workflow failure, a testable success outcome, and at least one explicit non-goal.
If the user asks for discovery, packet creation, implementation, or reporting, use the corresponding skill instead.
If they want a spec without prescribed red-green slices, use `sf-write-spec`.

## Workflow

### 1. Resolve and research

1. Derive or confirm a descriptive kebab-case slug.
2. Read repository instructions, `.spec-finder/config.json` when present, `_spec.md` in update mode, applicable ADRs, and `.spec-finder/tasks/<slug>/_prd.md` when it exists. If the config is absent, continue normally without asking about it or raising its absence.
3. Build a current-system ledger:
   - current versus desired behavior
   - public interfaces and candidate test seams
   - callers, consumers, tests, fixtures, and conventions
   - optional short current-code excerpts only when they freeze a non-obvious invariant or external contract
   - exact focused commands and repository gate
4. Consult current primary docs when an evolving dependency, protocol, SDK, CLI, or platform affects the contract.
5. Distinguish evidence from inference.

### 2. Confirm seams and remaining decisions

1. Present repository findings and candidate public seams.
2. Ask the user which public interfaces and seams the tests should cover. Do not draft tests before confirmation.
3. Ask only unresolved material questions. Skip need, success, and non-goals already fixed by the approved PRD. Still confirm public seams, contracts, failures, boundaries, and slice ordering.
4. If work has no changed behavior at a public seam, state that TDD is not applicable and offer `sf-write-spec`; do not invent test theater.
5. Ask once whether the executor should make Git commits: `A. (Recommended) No intermediate commits`, `B. Commit after each green slice`, or `C. Commit after each observed red test and green slice`. The choice is independent of product clarification and the executor's six-question cap. Explain that C intentionally records failing tests in Git history; never commit an unexpected red or failed green.

### 3. Draft one complete spec

Fill `references/spec-template.md` with repository facts. The draft must include:

- every core section and only conditional sections that change executor behavior
- Implementation with a maximum of six executor questions, one per turn, recommendation-first labeled choices, and material-decision boundaries
- current versus desired behavior, Out before In, preserved invariants, and observable acceptance
- approved PRD implementation decisions carried into Problem and Delta, Scope, and Acceptance when `.spec-finder/tasks/<slug>/_prd.md` exists, plus a Product source line citing that exact path
- every in-scope `F-xx` and `US-xx` from that PRD, or an explicit exclusion with the PRD rationale
- Contract Changes only when a public interface or persisted shape changes, with valid and invalid examples
- the confirmed public test seams and why each is public
- test locations and exact focused command identities
- ordered TDD outcome slices, one vertical slice at a time
- for every slice: one failing public-seam test, observed red reason, minimal green behavior, and the same focused command
- anti-pattern stop conditions and system-boundary-only mocking
- review/refactoring after all slices are green
- the user's selected Git commit cadence, with a commit boundary after each green slice or after both observed red and green when opted in; keep the review/refactor commit separate if it changes files
- verified Repository Anchors, repository gate, runtime proof, and final output

Apply `references/quality-bar.md`. Delete unused conditional sections and remove all placeholders. Do not split the draft into other artifacts.

### 4. Approve and save

Ask:

- `A. Approve and write the spec`
- `B. Adjust the draft`
- `C. Rewrite`
- `D. Discard`

Write the approved spec to `.spec-finder/tasks/<slug>/_spec.md`.
Create or replace only that file.
When an approved PRD exists, include its exact path as Product source.
Do not modify `_prd.md`.
Do not write `.spec-finder/specs/`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, reports, or memory files.

### 5. Validate

Re-read `.spec-finder/tasks/<slug>/_spec.md` and verify:

- `_spec.md` is the only file this skill created or changed
- when an approved PRD was the input, its exact path is named as Product source and its in-scope capabilities are inlined or explicitly excluded
- the approved PRD is unchanged
- every template token is replaced
- every core section is present, only earned conditional sections remain, and the bounded implementation-question protocol is complete
- confirmed seams, test locations, and command identities are explicit
- each slice is red → minimal green before the next red
- red and green use the same focused command
- expected values have an independent source of truth
- mocks appear only at system boundaries
- implementation-coupled, tautological, and horizontal tests are prohibited
- refactoring is deferred until all slices are green
- the repository gate, runtime proof, and completion output are named
- the Git commit cadence is explicit, matches the user's choice, and stages only owned files

Fix any validation failure before completion.

### 6. Print the artifact locations

After validation, end the response with the applicable block and nothing after it.
Replace `<slug>` with the real slug.

When an approved PRD exists:

```text
Copy this path and point an agent at it:
.spec-finder/tasks/<slug>/_spec.md
PRD: .spec-finder/tasks/<slug>/_prd.md
```

When no PRD exists:

```text
Copy this path and point an agent at it:
.spec-finder/tasks/<slug>/_spec.md
PRD: not created; this spec started from a clear request.
```
