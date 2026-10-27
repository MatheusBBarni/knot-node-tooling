# [Outcome] Spec

This file is the complete implementation prompt at `.spec-finder/tasks/<slug>/_spec.md`.
An executor that reads this file plus the repository must implement and verify without chat history.

- **Slug:** `<slug>`
- **This file:** `.spec-finder/tasks/<slug>/_spec.md`
- **Product source:** `.spec-finder/tasks/<slug>/_prd.md` [include only when that approved PRD exists]
- **Job:** [Feature | Improvement | Bug]
- **Outcome:** [one observable user or operator result]
- **Git commits:** [No intermediate commits | Commit after each verified step or milestone]

Omit writer notes and unused conditional sections from the saved spec.

## Implementation

1. Read this file, inspect Repository Anchors and adjacent tests, and verify the stated current behavior before editing.
2. Treat Scope, Acceptance, Contract Changes, and Boundaries as the implementation contract. Private implementation choices remain yours.
3. If repository evidence and current primary docs cannot resolve a material decision, ask at most 6 implementation questions across this run.
4. Ask exactly one question at a time and wait for its answer. Offer 2-3 concrete uppercase choices, put `A. (Recommended)` first, explain the principal trade-off, and add `Other` only when the choices are not exhaustive.
5. End each question with: `Reply with the letter (for example, A), or the letter plus context.`
6. Ask only about unresolved scope, public contracts, data ownership, security, migrations, destructive behavior, or required evidence. Never ask for repository facts, private implementation preferences, or product decisions already fixed here.
7. If no material decision remains, do not manufacture a question. Implement the smallest coherent diff, fix verification failures before continuing, and stop after Output.
8. Follow the selected Git commit cadence above. With no intermediate commits, leave commit timing to the operator; do not commit on your own. With verified-step commits, commit only after the focused check for each independently verifiable step or earned milestone succeeds, before starting the next; a single-outcome spec without milestones gets only a final commit after Verification. Never commit a broken state. Stage explicit paths owned by this implementation, inspect the staged diff, and do not include unrelated changes or ignored packet files. If the worktree cannot be separated safely, stop and ask before committing.

Example implementation question:

```text
[Material decision and the evidence that leaves it open]

A. (Recommended) [answer] - [principal trade-off]
B. [answer] - [principal trade-off]
C. Other - describe a different answer.

Reply with the letter (for example, A), or the letter plus context.
```

### Boundaries

**Always**

- [task-specific invariant, repository pattern, or required evidence]

**Ask first**

- [material branch that is not already decided; omit this item when none exists]

**Never**

- [concrete banned scope expansion or unsafe behavior]
- [second concrete banned action]

## Problem and Delta

**Current**

- [observable shipped behavior or failure]
- [who is affected and why it matters]

**Desired**

- [observable behavior after implementation]

## Scope

### Out

- **[excluded capability]** — [rationale]. Reconsider when [trigger].

### In

| ID | Capability | Observable outcome |
|---|---|---|
| F-01 | [capability] | [result] |

### Preserve

- [existing behavior, compatibility rule, or invariant that must not regress]

## Acceptance

### AC-01 / US-01: [behavior]

- **Given** [precondition]
- **When** [action]
- **Then** [observable result]

### AC-02: [failure or recovery behavior]

- **Given** [precondition]
- **When** [invalid, conflicting, denied, or failing action]
- **Then** [observable error, unchanged state, or recovery]

## Contract Changes

Delete this section when no public signature, schema, protocol, configuration, storage, CLI, or error contract changes.
Private implementation does not belong here.

### Public interface

```ts
// repository-language signature, schema, protocol, or CLI grammar
```

- Valid: [input] → [output]
- Invalid: [input] → [observable error]

| Error / state | Trigger | Observable behavior |
|---|---|---|
| [named error] | [condition] | [result] |

## Repository Anchors

Verified paths and symbols only. These are evidence and starting points, not a prescribed patch.

| Path / symbol | Current fact | Why inspect | Expected role |
|---|---|---|---|
| `path/to/file#symbol` | [shipped behavior or convention] | [relevant seam or invariant] | [read / edit / create] |

## Risks and Edge Cases

Delete this section when Acceptance already covers every material risk and edge case.

| Case | Detection | Observable behavior | Recovery / preservation | Evidence |
|---|---|---|---|---|
| [named case] | [condition] | [result] | [recovery or unchanged state] | [acceptance ID, test, or command] |

## Verification

- **Focused:** `[exact command]` — proves [changed behavior].
- **Repository gate:** `[exact command]` — proves [regression protection].
- **Runtime proof:** `[exact scenario, request, CLI invocation, or UI interaction]` — observe [result].

Completion requires observed command results and runtime evidence, not "tests should pass" or source inspection alone.

## Milestones

Delete this section for one small coherent outcome.
Keep it only when the work has multiple ordered, independently verifiable outcomes.

| Milestone | Outcome | Acceptance | Verification | Dependencies |
|---|---|---|---|---|
| M-01 | [observable result] | AC-01 | `[focused command]` | none |

Finish and verify each milestone before starting the next.
When verified-step commits are selected, each verified milestone is a commit boundary, not a reason to invent extra milestones.
Split independent outcomes into separate specs instead of growing this table.

## Output

Report and stop:

- changed behavior and files
- acceptance criteria satisfied
- focused, repository-gate, and runtime results with observed evidence
- implementation decisions made within the contract
- commit hashes and their verified steps, when commits were selected
- unresolved blockers or Ask-first follow-ups not implemented
