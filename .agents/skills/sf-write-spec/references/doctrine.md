# Agent-executable spec doctrine

These rules are mandatory on `sf-write-spec`.
They are the spec contract, not style notes.

## The spec is the prompt

`.spec-finder/tasks/<slug>/_spec.md` is the file an agent is pointed at.
The entire file is the complete implementation prompt.
An executor that reads that file plus the repository must be able to start, implement, verify, and stop without chat history.
Resolve every known product and public-contract decision before approval.
The saved Implementation protocol permits only bounded questions about material conflicts or decisions discovered during execution.
Do not leave intent only in chat.

## Single output only

`sf-write-spec` changes exactly one file: `.spec-finder/tasks/<slug>/_spec.md`.
It never changes `_prd.md` or writes `.spec-finder/specs/`, a TechSpec, task index, task file, ADR, or memory file.

## The PRD remains a separate product source

Approved product sections remain in `.spec-finder/tasks/<slug>/_prd.md`.
When that PRD exists, `_spec.md` names its exact path as Product source and carries every implementation-relevant product decision.
Map every in-scope `F-xx` and `US-xx`, but do not duplicate product prose that does not constrain implementation.
The source reference records provenance; it does not make the PRD required reading for execution.
Do not re-decide product scope the PRD already fixed unless repository evidence conflicts and the user chooses.
A thin task with no approved PRD is not a spec. Hand it to `sf-create-prd`.
A clear request may still start here. Create only `_spec.md` and omit the Product source line.

## Current-system evidence is mandatory

State current and desired observable behavior as a delta.
Use Repository Anchors to cite verified paths or symbols, shipped facts, relevant seams, tests, and preserved invariants.
An excerpt is optional and belongs only where freezing a non-obvious invariant or external contract earns its tokens.
Greenfield work still names adjacent modules, tests, and conventions to follow.

## Core plus conditional

Every saved spec contains the core sections:

- Implementation
- Problem and Delta
- Scope
- Acceptance
- Repository Anchors
- Verification
- Output

Include a conditional section only when it changes executor behavior:

- Contract Changes when a public interface or persisted shape changes
- Risks and Edge Cases when Acceptance does not already capture a material case
- Milestones when one coherent outcome needs multiple ordered, independently verifiable stages

Delete unused conditional sections instead of filling them with `Not applicable`.

## What and why, plus changed contracts, not algorithms

State the user or operator outcome and why it matters.
When a public contract changes, specify signatures, schemas, CLI grammar, error shapes, and one valid plus one invalid example.
When no public contract changes, delete Contract Changes.
Do not prescribe private algorithms, after-code, or a sketched patch.
Do not write a stakeholder PRD with no repository anchors.

## Binary acceptance

Every acceptance criterion uses Given/When/Then with an observable result.
Include empty, invalid, conflict, permission, or recovery paths that materially apply.
Reject "works correctly", "handle errors", "be robust", and "feel fast".
A tester who cannot see the code must be able to pass or fail the criterion.

## Scope and boundaries

Write explicit non-goals before in-scope capabilities.
Name preserved behavior and compatibility invariants.
Implementation boundaries use Always / Ask first / Never:

- **Always:** task-specific invariants, patterns, and evidence.
- **Ask first:** unresolved material branches that execution may discover.
- **Never:** at least two concrete bans.

The executor may ask at most six implementation questions for material scope, public contract, ownership, security, migration, destructive behavior, or evidence decisions that repository research cannot answer.
Questions are one per turn, use 2-3 labeled choices, put the recommendation first, and never replace repository research.
Do not manufacture questions to reach the limit.

## Named verification is done

Done requires exact focused and repository-gate commands plus runtime proof through the changed public surface.
Commands run to terminal exit.
Prohibited completion phrases: "tests should pass", "implementation looks correct".

## Milestones only when earned

Keep one small coherent outcome as one implementation flow.
Use milestones only for ordered outcomes that can each be verified.
Split independent outcomes into separate specs instead of producing a release-sized prompt.
No foundation-only or test-only milestone.

## Research, then ask, then approve

Research the repository and current docs before any authoring question.
Ask only remaining material decisions.
Write nothing until the user explicitly approves one complete draft whose spec file passes `quality-bar.md`.
