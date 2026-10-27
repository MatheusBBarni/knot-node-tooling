# [Feature] Product Requirements Document

## Problem

State the verified problem, not a feature request. Cover who is affected, the current workflow, how it fails, and what it costs. Do not write “users want X”.

Name the primary user and why this is worth solving now.

### Evidence

Decision-changing rows only. Prefer repository paths, user quotes, drop-off, and primary sources. Label inference. Never invent a baseline.

| Kind | Finding | Source | Date | Confidence | Product consequence |
|---|---|---|---|---|---|
| Repository / External / Inference | [Finding] | [Path or URL] | [Date] | High / Medium / Low | [Consequence] |

## Goals

Goals are the metrics. Every `G-xx` needs a baseline (or explicit unknown plus how it will be measured), target, method, and window.

| ID | Goal | Baseline | Target | Measurement method | Window |
|---|---|---|---|---|---|
| G-01 | [Goal] | [Value or unknown + measurement plan] | [Target] | [Method] | [Window] |

## Out of Scope

Write exclusions and later phases here, each with a rationale and reconsideration trigger.

- **[Excluded capability]** — [Rationale and reconsideration trigger]

## In Scope (MVP)

Selected approach: [one sentence on the chosen product approach and what it gives up].

Thin capabilities only. No MUST/SHOULD design, APIs, or implementation.

| ID | Capability | User value | Mapped goals/stories | Observable outcome |
|---|---|---|---|---|
| F-01 | [Capability] | [Value] | G-01, US-01 | [User-visible result] |

## User Stories

### US-01: [Short name]

- **Persona:** [Persona]
- **Story:** As a [persona], I want [capability], so that [outcome].
- **Acceptance:**
  - **Given** [precondition]
  - **When** [action]
  - **Then** [observable result]

## Constraints

- Product-facing privacy, security, compliance, compatibility, performance, portability, or integration boundaries.
- Do not prescribe implementation technology.

## Risks and Mitigations

| Risk | Evidence | Likelihood/impact | Mitigation | Owner/decision trigger |
|---|---|---|---|---|

Keep this section product-focused; technical risks belong in the TechSpec.

## Architecture Decision Records

- [ADR-NNN: Title](adrs/adr-NNN.md) — [Decision summary]

## Open Questions

- Non-blocking unresolved items only. Do not save with a material product branch undecided.
