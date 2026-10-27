# [Outcome] TDD Spec

This file is the complete implementation prompt at `.spec-finder/tasks/<slug>/_spec.md`.
An executor that reads this file plus the repository must implement and verify without chat history or an external TDD skill.

- **Slug:** `<slug>`
- **This file:** `.spec-finder/tasks/<slug>/_spec.md`
- **Product source:** `.spec-finder/tasks/<slug>/_prd.md` [include only when that approved PRD exists]
- **Job:** [Feature | Improvement | Bug]
- **Outcome:** [one observable user or operator result]
- **Git commits:** [No intermediate commits | After each green slice | After each observed red test and green slice]

Omit writer notes and unused conditional sections from the saved spec.

## Implementation

1. Read this file, inspect Repository Anchors and confirmed Public Test Seams, and verify the stated current behavior before editing.
2. Treat Scope, Acceptance, Contract Changes, Public Test Seams, TDD Execution, and Boundaries as the implementation contract.
3. If repository evidence and current primary docs cannot resolve a material decision, ask at most 6 implementation questions across this run.
4. Ask exactly one question at a time and wait for its answer. Offer 2-3 concrete uppercase choices, put `A. (Recommended)` first, explain the principal trade-off, and add `Other` only when the choices are not exhaustive.
5. End each question with: `Reply with the letter (for example, A), or the letter plus context.`
6. Ask only about unresolved scope, public contracts, data ownership, security, migrations, destructive behavior, required evidence, or repository evidence that invalidates a confirmed test seam. Never ask for repository facts, private implementation preferences, or product decisions already fixed here.
7. If no material decision remains, do not manufacture a question. Execute TDD Slices in order, fix a failed slice before continuing, and stop after Output.
8. Follow the selected Git commit cadence above. With no intermediate commits, leave commit timing to the operator; do not commit on your own. With green-slice commits, commit after the same focused command passes for each slice, before writing the next test. With red-and-green commits, commit only the new test after observing its intended red failure, then commit the minimal implementation after the same focused command passes; a red commit intentionally has a failing focused test. Never commit an unexpected red pass or a failed green. If Review changes files, commit those changes separately only after its verification passes. Stage explicit paths owned by this implementation, inspect the staged diff, and do not include unrelated changes or ignored packet files. If the worktree cannot be separated safely, stop and ask before committing.

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

- Test through the confirmed public seams with independently sourced expected values.
- Preserve exact red and green command evidence.

**Ask first**

- A new dependency, public contract, schema migration, security boundary, or repository conflict that invalidates a confirmed test seam.

**Never**

- Mock internal collaborators or test private methods.
- Write all tests before implementation.
- Refactor during a red-green slice.

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

## Public Test Seams

These seams were confirmed before this spec was approved.

| ID | Public interface | Observable behavior | Test location | Focused command | Why public |
|---|---|---|---|---|---|
| S-01 | `[interface]` | [behavior] | `path/to/test` | `[exact command]` | [consumer-visible boundary] |

## TDD Execution

For every slice:

1. Write one failing public-seam test named for observable behavior.
2. Run the slice's focused command to terminal exit and require failure for the intended missing behavior.
3. Add only enough production behavior to pass that test.
4. Run the same focused command to terminal exit and require success.
5. Start no later slice before this one is green.

When commits are selected, make them at the chosen red and/or green boundaries before starting the next slice. A red commit contains only the new failing test and is permitted only after observing its intended failure.
Stop on implementation-coupled tests, tautological expectations, horizontal slicing, unexpected red passes, or failed green. Mock only system boundaries. Refactor only during Review after every slice is green.

## TDD Slices

### Slice 01: [observable outcome]

- **Primary:** AC-01 / US-01 / F-01
- **Seam:** S-01
- **Dependencies:** none
- **Given/When/Then:** [binary behavior]
- **Test:** `path/to/test` — [public-interface assertion and independent expected value]
- **Red:** `[exact focused command]` fails because [missing behavior]
- **Green:** `[same exact focused command]` passes after only [minimal behavior]
- **Files:** `path/to/file` — [role]
- **Out of scope:** [excluded work]

Add another slice only for the next independently observable outcome. Finish red then green before starting it.

## Risks and Edge Cases

Delete this section when Acceptance and TDD Slices already cover every material risk and edge case.

| Case | Detection | Observable behavior | Recovery / preservation | Evidence |
|---|---|---|---|---|
| [named case] | [condition] | [result] | [recovery or unchanged state] | [acceptance ID, slice, test, or command] |

## Verification

- **Focused:** `[exact command or ordered command set]` — proves every slice remains green.
- **Repository gate:** `[exact command]` — proves regression protection.
- **Runtime proof:** `[exact scenario, request, CLI invocation, or UI interaction]` — observe [result].

Completion requires observed red and green results plus runtime evidence, not "tests should pass" or source inspection alone.

## Review

After every slice is green:

1. Review duplication, naming, locality, and maintainability without changing behavior.
2. Refactor only where evidence justifies it.
3. Re-run all focused commands, the repository gate, and runtime proof.

## Output

Report and stop:

- red and green result for each slice, including command identity
- changed behavior and files
- acceptance criteria satisfied
- repository-gate and runtime results with observed evidence
- implementation decisions made within the contract
- commit hashes with their slice and red/green phase, when commits were selected
- unresolved blockers or Ask-first follow-ups not implemented
