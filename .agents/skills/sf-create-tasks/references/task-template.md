---
status: pending
title: [Imperative task title]
type: [frontend, backend, docs, test, infra, refactor, chore, bugfix, spike, or repository-defined type]
complexity: [low, medium, high, or critical]
dependencies: []
---

# Task NN: [Imperative task title]

## Overview

One independently testable user/operator outcome. Name the primary `US-xx` / `F-xx`. Say why it matters and what this slice gives up.

## Source Artifacts

- PRD: `.spec-finder/tasks/<slug>/_prd.md`
- TechSpec: `.spec-finder/tasks/<slug>/_techspec.md`

Replace `<slug>` with the current packet slug before writing the task. Never leave this instruction or the placeholder in generated output.

<critical>
- Read `.spec-finder/tasks/<slug>/_prd.md`, `.spec-finder/tasks/<slug>/_techspec.md`, relevant packet ADRs, repository instructions, and current Git state before editing. These paths must contain the current packet slug in generated output.
- Treat this task's numeric ID as its canonical execution position; every declared dependency must already be completed and have a lower numeric ID.
- Use `sf-memory`; read `memory/MEMORY.md` and `memory/task_NN.md` before editing and update memory before finishing.
- Implement only this task; preserve unrelated work and do not absorb follow-up scope.
- Reference TechSpec Contracts, Architecture, and Sequencing instead of duplicating interfaces or architecture.
- Run focused tests and the exact repository verification gate to terminal exit. If they fail, fix in scope and re-run until clean. Do not stop to ask whether to proceed.
- Ambiguity and spec conflicts are decisions, not halt conditions. Resolve them against the TechSpec, this task's requirements, and ADRs; record the pick in memory; continue.
- Missing Git HEAD or checkpoint unavailability is not an implementation blocker.
- Do not change lifecycle status or write the final report when Spec Finder owns those phases.
</critical>

## Acceptance

Specialize the mapped PRD story for this slice. Do not paste the whole PRD.

- **Given** [precondition]
- **When** [action]
- **Then** [observable result]

## Out of Scope

- **[Excluded work]** — [later `task_NN` or PRD non-goal]

<requirements>
1. MUST [specific observable technical contract mapped to PRD/TechSpec ID].
2. SHOULD [bounded secondary contract and condition].
</requirements>

## Requirement Traceability

| Source ID/section | Task obligation | Evidence |
|---|---|---|

## Subtasks

Implementation steps under this outcome (files, endpoints, tests). Not extra stories.

- [ ] NN.1 [Outcome to accomplish, not code mechanics]
- [ ] NN.2 [Outcome]
- [ ] NN.3 [Verification outcome]

Use 3-7 subtasks.

## Implementation Details

Reference the approved TechSpec Contracts, Architecture, Failure, and Sequencing sections. Do not paste its code or diagrams.

### Relevant Files

- `path/to/file` — [verified role; say `create` when absent]

### Dependent Files

- `path/to/consumer-or-test` — [why this task affects it]

### Related ADRs

- [ADR-NNN: Title](adrs/adr-NNN.md) — [constraint on this task]

## Deliverables

- [Concrete implementation outcome]
- Required automated and platform evidence
- Updated `memory/MEMORY.md` and `memory/task_NN.md` when warranted
- `reports/task_NN.md` final evidence report

## Tests

### Unit Tests

- [ ] Given [specific input/state], when [action], then [expected result/error].

### Integration Tests

- [ ] At [named boundary], verify [specific interaction and expected behavior].

### Platform or Manual Evidence

- [ ] [Evidence unit tests cannot prove, or `Not applicable` with reason].

### Verification Commands

- `[focused command]`
- `[repository gate]`

## Rollout

- [Migration, compatibility, or docs note, or `N/A` with reason]

## Success Criteria

- Mapped acceptance and requirements are satisfied with evidence.
- Focused tests and repository gate pass to terminal exit.
- Coverage meets repository policy or reaches 80% for changed testable logic when measurable.
- No unrelated file or approved behavior changes.
- Memory is current and the final report records exact evidence and unresolved risks.
