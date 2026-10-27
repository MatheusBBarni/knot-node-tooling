---
name: sf-write-spec
description: Creates an approved, agent-executable Spec Finder spec from a clear feature request or an approved `.spec-finder/tasks/<slug>/_prd.md`. Researches the repository and current docs before asking, inlines approved PRD decisions, asks only remaining material decisions, and writes nothing until the user approves a complete draft. Writes `.spec-finder/tasks/<slug>/_spec.md`, references the PRD when one exists, then prints both artifact paths. A thin task with no PRD belongs to `sf-create-prd` first. Do not use for idea-factory discovery, PRD-only, TechSpec-only, task regeneration, packet creation, or TDD-prescribed specs (`sf-tdd-write-spec`).
---

# Write a Spec Finder Spec


## Coexistence with a PRD

`sf-create-prd` and this skill produce separate artifacts in `.spec-finder/tasks/<slug>/`. They are not a packet pipeline.

1. A thin or poorly written task with little context goes to `sf-create-prd` first. This skill does not invent that product context.
2. An approved `.spec-finder/tasks/<slug>/_prd.md` is the product source of truth and remains unchanged.
3. This invocation writes the implementation prompt to `.spec-finder/tasks/<slug>/_spec.md`. The spec names `_prd.md` as its Product source and inlines its approved decisions.
4. A clear request that already states who is affected, the current failure, testable success, and at least one non-goal may start here with no PRD. Create only `.spec-finder/tasks/<slug>/_spec.md`.
5. Prescribed red-green slices belong to `sf-tdd-write-spec`, which writes the same `_spec.md` path.

One invocation changes exactly one file: `.spec-finder/tasks/<slug>/_spec.md`. That file is the complete implementation prompt an agent runs.
It does not change `_prd.md` or write `.spec-finder/specs/`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, or memory files.
This is not `sf-idea-factory`, `sf-create-prd`, `sf-create-techspec`, and `sf-create-tasks` run in sequence.
Reading an already approved `.spec-finder/tasks/<slug>/_prd.md` is not that sequence. Do not refuse it.

Read `references/doctrine.md` before research.
Read `references/quality-bar.md` before drafting.

<HARD-GATE>
- NEVER require `sf-idea-factory`, `sf-create-prd`, `sf-create-techspec`, or `sf-create-tasks` before starting when the request is already clear. NEVER require a PRD. When an approved `.spec-finder/tasks/<slug>/_prd.md` exists, read it and treat the product sections as the product source of truth.
- NEVER write `_spec.md` before repository research, remaining-decision clarification, a complete draft review, and explicit whole-draft approval.
- NEVER write `.spec-finder/specs/`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, memory files, or any runner packet artifact.
- NEVER modify an approved `.spec-finder/tasks/<slug>/_prd.md`.
- NEVER invent product scope for a thin task that has no approved PRD. Stop and offer `sf-create-prd`.
- NEVER tell the executor to read the PRD instead of this spec. Inline the approved product decisions.
- NEVER re-decide problem, users, goals, non-goals, or in-scope capabilities that the approved PRD already fixed, unless repository evidence conflicts.
- NEVER skip repository and current-docs research because the request looks simple.
- NEVER ask the user to decide facts the repository or current docs already answer.
- NEVER expand capabilities before explicit non-goals.
- NEVER accept acceptance criteria that are not binary Given/When/Then.
  Reject "works correctly" and other untestable phrases.
- NEVER micromanage private implementation except public contracts (signatures, schemas, CLI grammar, errors, valid and invalid examples).
- NEVER omit the core Implementation, Problem and Delta, Scope, Acceptance, Repository Anchors, Verification, or Output sections.
- NEVER retain Contract Changes, Risks and Edge Cases, or Milestones when the section does not change executor behavior.
- NEVER create a milestone that is not independently testable once its declared dependencies are done.
- NEVER omit `.spec-finder/tasks/<slug>/_spec.md`.
  The `_spec.md` file is the implementation prompt and must contain every known decision needed to start without chat history.
- NEVER present a draft that fails `references/quality-bar.md` or still contains template placeholders.
- NEVER omit current-system evidence: current versus desired behavior, verified Repository Anchors, relevant callers/tests, and preserved invariants. Current-code excerpts are optional and must earn their tokens.
- NEVER omit the bounded executor clarification protocol: at most six implementation questions, exactly one per turn, recommendation-first labeled choices, and material-decision limits.
- NEVER omit the user's commit-cadence choice from the saved spec or enable intermediate commits without their opt-in.
- NEVER run idea-factory council, KPI scoring, or 3-7 market-search depth on this path.
</HARD-GATE>

## Interaction contract

- Ask exactly one remaining question per turn and wait for the answer.
- Use the runtime's blocking question mechanism when available.
  Otherwise make the question the complete response and stop.
- Present every answer choice with sequential uppercase labels: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 concrete suggested answers.
  Add `Other` whenever those answers are not exhaustive; lead with `A. (Recommended)`.
- End every choice prompt with: `Reply with the letter (for example, A), or the letter plus context.`
- Do not auto-resolve a decision that changes scope, public contracts, data ownership, security, migrations, or required evidence.
- Offer the Git commit cadence as a separate choice before drafting, even when no product decision remains. Do not count it toward the executor's six implementation questions.

Read `references/question-protocol.md` before asking questions or requesting approval.

## Required inputs

- A clear feature request, idea, or spec slug that already states who is affected, the current failure, testable success, and at least one non-goal.
- Or an approved `.spec-finder/tasks/<slug>/_prd.md`.
- Optional existing `.spec-finder/tasks/<slug>/_spec.md` for update mode.

If an approved `.spec-finder/tasks/<slug>/_prd.md` exists, read it and continue. Do not send the user back through idea-factory or PRD authoring unless repository evidence conflicts with that PRD.
If the input is a thin task, ticket, or prompt and no approved PRD exists, stop and offer `sf-create-prd`. Do not invent the missing product decisions inside the spec.
A request is thin when it does not state who is affected, the current workflow failure, a testable success outcome, and at least one explicit non-goal.
If the problem, opportunity, or V1 boundary is unknown even as a task, offer `sf-idea-factory`, then `sf-create-prd`.
If they asked only for a PRD, TechSpec, task regeneration, or runner packet creation, use the specific skill for that output instead of this path.
If they asked for prescribed red-green slices, use `sf-tdd-write-spec`.

## Mandatory phase checklist

1. Resolve the spec path, read an approved PRD when present, and read the existing spec in update mode.
2. Research the repository and current docs into a current-system ledger.
3. Present evidence and remaining decisions.
4. Ask only the remaining material questions and offer the Git commit-cadence choice.
5. Draft the complete spec as one review.
6. Obtain explicit whole-draft approval.
7. Write `.spec-finder/tasks/<slug>/_spec.md`.
8. Re-read and validate against the quality bar.

## Workflow

### 1. Resolve context

- Derive or confirm a descriptive kebab-case slug.
- Target only `.spec-finder/tasks/<slug>/_spec.md`.
- Read repository instructions, `.spec-finder/config.json` when present, and the existing `_spec.md` when present. If the config is absent, continue normally without asking about it or raising its absence.
- Read `.spec-finder/tasks/<slug>/_prd.md` and its linked ADRs when that file exists. If it is missing, continue only when the request is not thin.
- If the PRD exists but is unapproved or still has a material product branch open, stop and offer finishing `sf-create-prd` before drafting the spec.
- Extract `G-xx`, `US-xx`, `F-xx`, Out of Scope, constraints, and open questions from the PRD. Do not rewrite that file.
- Create `.spec-finder/tasks/<slug>/` as needed.
  Do not write the spec yet.
- In update mode, replace only `_spec.md`.
  Preserve the approved PRD and unrelated repository files.

### 2. Research before questions

Complete research before asking.
Run independent tracks concurrently when the runtime can do real parallel work.

**Repository track - required.** Capture a current-system ledger the spec will quote:

- Current behavior versus desired behavior.
- Related flows, modules, interfaces, callers, consumers, tests, fixtures, and conventions.
- Exact verification commands from this repository.
- Optional short current-code excerpts only when they freeze a non-obvious invariant or external contract; they are evidence of now, not the fix.
- Distinguish shipped behavior from comments or plans.

**Current-docs track - required when the change depends on an evolving library, SDK, protocol, CLI, or platform**

- Consult current primary documentation.
- Capture version or date, the supported constraint, source URL, and design consequence.

Do not run idea-factory market searches, KPI scoring, or advisor council on this path.

Present:

- **Repository findings** with paths
- **Current-docs findings** with citations when that track ran
- **Inferences** labeled as inference
- **Remaining decisions** that still require the user
- **Product ledger** from the approved PRD when one exists, including conflicts with repository evidence

### 3. Clarify remaining decisions

- Ask 2-6 questions following `references/question-protocol.md`.
- Follow the remaining-decision order: need and success, non-goals, public contracts and failure, boundaries, then slice forks.
- Skip need, success, and non-goals already fixed by the approved PRD.
- If repository evidence conflicts with the PRD, present both and ask with lettered choices whether the PRD, current evidence, or another direction governs. Do not silently override the PRD.
- Ask once before drafting whether the executor should make intermediate Git commits: `A. (Recommended) No intermediate commits` or `B. Commit after each verified step or milestone`. An explicit user request for a cadence counts as the answer; preserve it in update mode unless the user changes it. A single-outcome spec without milestones has only a final verified commit if B is selected. Do not ask for arbitrary implementation checkpoints.
- If no material decision remains, ask only for the commit cadence, then draft.

### 4. Draft the complete spec

Read `references/spec-template.md` and `references/quality-bar.md`.

Fill every core section and every earned conditional section with repository facts, not writer notes.
Delete unused conditional sections and strip every template placeholder from the spec file.
Run `references/quality-bar.md` against the complete `_spec.md` draft and rewrite until it passes, then present the draft.
The spec stays dense. Do not split it into `_techspec.md`, `_tasks.md`, or `task_NN.md`.
Do not ask for section-by-section or stage-by-stage approval.

**Agent-executable spec (`.spec-finder/tasks/<slug>/_spec.md`)**

- Read `references/spec-template.md`; fill all core sections and only conditional sections that change execution.
- Include a Product source line with `.spec-finder/tasks/<slug>/_prd.md` when an approved PRD exists.
- Include Implementation with a maximum of six executor questions, one per turn, recommendation-first labeled choices, and material-decision boundaries.
- Record the selected Git commit cadence in the spec and instruct the executor to stage only files owned by this change, never unrelated worktree changes or ignored packet files.
- Include current versus desired behavior, Out before In, preserved invariants, Given/When/Then plus applicable failure paths, verified Repository Anchors, exact focused and repository commands, runtime proof, and Output.
- Include Contract Changes only for a changed public interface or persisted shape; include Risks and Edge Cases only when Acceptance does not cover them; include Milestones only for multiple ordered, independently verifiable outcomes.
- When an approved PRD exists, carry every implementation-relevant decision and map every in-scope `F-xx` and `US-xx`. Do not duplicate unrelated product prose.
- Do not drop a PRD capability unless this spec names it out of scope with the PRD rationale.
- Translate product outcomes into acceptance, changed contracts, anchors, verification, and earned milestones. Do not paste the product sections as the spec.
- An executor pointed at `.spec-finder/tasks/<slug>/_spec.md` must be able to start implementation and verification from that file.
- Keep earned milestones inside `_spec.md`. Do not project them into `task_NN.md`.

### 5. Review and save

- Present the complete draft once.
- Ask with `A. Approve and write the spec`, `B. Adjust the draft`, `C. Rewrite`, and `D. Discard`.
- Apply feedback and present the complete current draft again.
- Write only after explicit approval of that version.
- Write exactly one file: `.spec-finder/tasks/<slug>/_spec.md`.
- Create or replace that file with the approved complete spec.
- When an approved PRD exists, include its exact path as the Product source.
- Do not modify `_prd.md`.
- Do not write `.spec-finder/specs/`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, memory files, or any runner packet artifact.

### 6. Validate before completion

Re-read `.spec-finder/tasks/<slug>/_spec.md` and verify:

- the file has no `<slug>` or template placeholder, passes `references/quality-bar.md`, contains every core section, and contains only earned conditional sections
- no acceptance line is "works correctly" or another untestable phrase
- the only write is `_spec.md`; the approved PRD is unchanged
- no `.spec-finder/specs/` file, TechSpec, task index, task file, ADR, or memory file was created or changed
- when an approved PRD was the input, `_spec.md` contains its exact path as Product source and every in-scope `F-xx` and `US-xx` appears or is named out of scope with the PRD rationale
- the Git commit cadence is explicit, matches the user's choice, and does not authorize commits of unrelated files

Fix validation failures and repeat.
Do not point to `spec-finder run <slug>` or `sf-execute-task`; this path does not create their runner packet.

### 7. Print the artifact locations

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

## Anti-patterns

- Running the four existing skills in sequence and calling that simplified.
- Creating a runner packet or a second spec projection.
- A stakeholder outline that restates the feature request with no repository anchors, acceptance, or verification evidence.
- Writer instructions or template placeholders left in the spec.
- Market council, KPI scoring, or invented baselines.
- Writing files before whole-draft approval.
- Guessed file paths.
- Public contracts as prose when a signature, schema, or CLI grammar exists.
- Layer splits when an outcome slice is possible.
- Forward dependencies such as Slice 01 depending on Slice 02.
- Telling the executor to read the PRD instead of inlining its decisions; the Product source reference is provenance, not a dependency.
- Ignoring an approved PRD and re-deciding product scope.
- Drafting from a thin task instead of handing off to `sf-create-prd`.
- Modifying the approved PRD while authoring the spec.
- Shrinking the spec because packet files do not exist.

## Failure rules

- Stop if the requested outcome and target user remain unclear after remaining questions.
- Stop if success cannot be stated as observable Given/When/Then after remaining questions.
- If codebase evidence conflicts, present both patterns and their actual usage before recommending one.
- If a material decision remains open, do not move it silently into Open Questions and save anyway.
- Preserve unrelated approved content in update mode.
