# [Feature] Technical Specification

## Context

- **PRD:** `.spec-finder/tasks/<slug>/_prd.md`
- Current seam, why a design is needed, and the selected design in one sentence. Do not copy PRD problem or feature prose. Record an approved traceability gap here if there is no PRD.

### Evidence

Decision-changing rows only. Prefer repository paths and current official docs. Label inference.

| Kind | Finding/constraint | Source | Version/date | Design consequence |
|---|---|---|---|---|
| Repository / Official docs / Inference | [Finding] | [Path or URL] | [Version/date] | [Consequence] |

## Technical Goals and Non-Goals

### Goals

Engineering obligations mapped to PRD IDs. Not a restatement of user stories.

- **[Design obligation]** — [G-01, F-01]

### Non-Goals

Explicit what not to do in this design.

- **[Excluded design]** — [Rationale and reconsideration trigger]

## Requirement Traceability

| PRD ID | Technical obligation | Component/interface | Verification | Status/gap |
|---|---|---|---|---|

Map every PRD goal, story, capability, and constraint. Map `M-xx` when present. Do not repeat essays from the PRD.

## Decision

Chosen approach: [one paragraph on the selected design, the primary trade-off, and what it gives up].

### Alternatives rejected

- **[Alternative]** — [Why not selected]

## Architecture

### Components

| Component | Existing/new | Responsibility | Inputs/outputs | Dependencies |
|---|---|---|---|---|

### Data flow

Mermaid or ASCII for normal, failure, cancellation, and recovery when more than one component changes. Skip when the change is a single function.

### Impact

| Component/file | Impact | Risk | Required action |
|---|---|---|---|

Include direct consumers and dependent tests, not only edit targets.

## Contracts

Schemas, signatures, and CLI grammar over prose. Specify errors, ownership, and compatibility. Omit unused fields.

### Public interfaces

Repository language for types, functions, CLI, or protocol contracts.

### Data model

Entities, validation, ownership, retention, concurrency, and consistency only when applicable.

### Errors

Named errors, mapping to user/system behavior, and fail-closed cases.

### Changed boundaries

| Boundary | Current contract | Change | Failure behavior | Compatibility/migration |
|---|---|---|---|---|

Omit this table when no boundary contract changes.

## Failure and Edge Cases

| Failure mode | Detection | User/system behavior | Recovery/rollback | Evidence |
|---|---|---|---|---|

## Security, NFRs, and Operations

Omit empty subsections.

### Security and privacy

Trust boundaries, permissions, secrets, sensitive data, abuse cases, auditability, and fail-closed behavior.

### Compatibility, rollout, and rollback

Versioning, schema/config migration, rollout ordering, backward compatibility, rollback trigger, and cleanup.

### Observability

Structured events, metrics, logs, redaction, diagnostic context, and success/failure signals.

## Tests

Named contracts mapped to obligations. Exact commands, not a testing essay.

- **Unit:** [contract, inputs, expected outcome]
- **Integration:** [boundary, fixture, failure case]
- **Platform / e2e:** [evidence unit tests cannot prove]
- **Gates:** [focused command] ; [repository-wide gate]

## Sequencing

Build-order constraints for implementation, not a task plan.

1. [Step] — no dependencies.
2. [Step] — depends on step 1 because [reason].

## Open Questions

- Non-blocking unresolved items only. Do not save with a material design branch undecided.

## Architecture Decision Records

- [ADR-NNN: Title](adrs/adr-NNN.md) — [Decision summary]
