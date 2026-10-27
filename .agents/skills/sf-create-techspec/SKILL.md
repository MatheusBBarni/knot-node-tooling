---
name: sf-create-techspec
description: Translates an approved PRD into an approved, codebase-informed Technical Specification through architecture research, technical clarification, explicit approach selection, ADR capture, requirement traceability, and whole-draft approval. Use for implementation design, not product discovery, task generation, or coding.
---

# Create a Spec Finder TechSpec

<HARD-GATE>
- NEVER write or replace `_techspec.md` before source requirements, codebase exploration, relevant official documentation, technical clarification, explicit approach selection, ADR capture, complete draft review, and explicit user approval are complete.
- NEVER propose architecture from memory when the repository or current documentation can verify it.
- NEVER silently choose a material boundary, dependency, persistence, security, migration, or failure-policy decision.
- NEVER skip design review because the change appears small.
- NEVER copy PRD problem or feature prose as the design.
- NEVER omit technical non-goals.
- NEVER leave a public contract as prose when a signature, schema, or CLI grammar exists.
- NEVER require section-by-section approval; present one complete draft after the technical direction is selected.
</HARD-GATE>

## Interaction contract

- Ask exactly one technical question per turn and wait for the answer.
- Use the runtime's blocking question mechanism when available. Otherwise make the question the complete response and stop.
- Present every answer choice with sequential uppercase labels: `A.`, `B.`, `C.`, and so on. Never present selectable answers as unlabeled bullets.
- Every question must provide 2-3 concrete suggested answers. Add `Other` whenever those answers are not exhaustive, with the evidence-backed recommendation first as `A. (Recommended)`. Label `Other` with the next available letter.
- End every choice prompt with: `Reply with the letter (for example, A), or the letter plus context.` Accept lowercase letters and full option text too.
- Ask about HOW, WHERE, and WHICH only when the answer is not already dictated by approved requirements, repository conventions, or current official documentation.
- Do not auto-resolve decisions that change public contracts, data ownership, security posture, migrations, dependencies, or required evidence.

Read `references/question-protocol.md` before asking questions.

## Required inputs

- A packet slug with an approved `_prd.md`.
- Optional `_idea.md` and existing `_techspec.md` for context/update mode.

If `_prd.md` is absent, stop and present lettered choices: `A. (Recommended) Create the PRD first`, `B. Proceed from a bounded description and accept the traceability gap`, and `C. Other`. Proceed without a PRD only after the user selects the traceability-gap option; record that gap in Context and Open Questions.

## Mandatory phase checklist

1. Load PRD, idea, ADRs, existing design, memory, and repository rules.
2. Explore architecture, implementation seams, dependencies, tests, and build gates.
3. Verify evolving libraries, SDKs, protocols, or platform constraints in official sources.
4. Present technical evidence, conflicts, and unknowns.
5. Ask 3-6 technical clarification questions.
6. Present 2-3 technical approaches and obtain explicit selection.
7. Record the primary design and other consequential choices in ADRs.
8. Draft a traceable TechSpec, obtain explicit approval, save, and validate.

## Workflow

### 1. Load authoritative context

- Read `_prd.md`, `_idea.md` when present, existing `_techspec.md`, `_tasks.md`, all ADRs, packet memory, repository instructions, and `.spec-finder/config.json` when relevant.
- Extract every goal, story, capability, constraint, risk, and open question into a requirements ledger with stable IDs. Goals carry baseline, target, window, and method; map leftover `M-xx` from older PRDs or when one goal has multiple metrics.
- New TechSpecs use `references/techspec-template.md`. In update mode, identify the requested delta, preserve untouched sections, and keep the existing document structure. Do not migrate Executive Summary / Implementation Design / Impact Analysis layouts unless the user explicitly asks. The TechSpec is a living document; change only the approved delta. Identify downstream task files that may need regeneration.

### 2. Research the implementation context

**Repository exploration — always required**

- Inspect architecture, module boundaries, domain models, existing interfaces, persistence, concurrency, configuration, error conventions, security boundaries, observability, tests, fixtures, and verification commands.
- Trace relevant callers and consumers, not only the apparent target file.
- Cite concrete paths and distinguish current behavior from proposed behavior.

**External technical research — conditionally required**

- When the design depends on an evolving library, SDK, protocol, CLI, cloud service, security standard, or platform capability, consult current primary documentation before recommending an approach.
- Capture exact version or date, supported API/constraint, source URL, and design consequence.
- Do not introduce a dependency based only on popularity or memory.

Run independent exploration tracks concurrently when real delegation is available. Otherwise explore sequentially and do not claim independent confirmation.

### 3. Present technical evidence

Before questions, present:

- **Existing architecture:** components, boundaries, and paths.
- **Reusable patterns:** conventions the design should preserve.
- **External constraints:** verified current documentation.
- **Conflicts:** repository patterns or requirements that disagree.
- **Unknowns:** decisions or spikes needed before implementation.

If a conflict could change product behavior, stop and return it to the PRD owner/user rather than resolving it as a technical preference.

### 4. Clarify material decisions

- Ask 3-6 questions following `references/question-protocol.md`.
- Follow the protocol order: contracts, state, failure and NFRs, then evidence.
- Skip dimensions already fixed by the PRD, repository, or official docs; do not manufacture questions to reach a quota.
- When uncertainty can be resolved with a bounded spike, offer the spike and its decision criterion instead of asking for a guess.

### 5. Present technical approaches

- Offer 2-3 viable designs labeled `A.`, `B.`, and `C.` in presentation order; label another design with the next letter. For each include component changes, data flow, affected contracts, migration path, failure behavior, security implications, testing burden, operational cost, reversibility, and rejected complexity.
- Recommend the smallest design that satisfies every approved requirement and repository constraint.
- State the primary trade-off explicitly and identify any prerequisite or evidence gap.
- Wait for explicit user selection before creating an accepted ADR or drafting.

### 6. Record ADRs

- Read `references/adr-template.md` and allocate sequential zero-padded ADRs without replacing existing files.
- Create at least one ADR for the selected primary technical approach.
- Create additional ADRs only for consequential independent decisions such as persistence, protocol, compatibility, security boundary, or migration strategy.
- Record evidence, rejected alternatives, consequences, risks, rollback/reversal considerations, and implementation notes.

### 7. Draft the TechSpec

- Read `references/techspec-template.md` and fill applicable sections in this order: Context and Evidence, Technical Goals and Non-Goals, Requirement Traceability, Decision, Architecture, Contracts, Failure and Edge Cases, Security/NFRs/Operations, Tests, Sequencing, Open Questions, ADRs.
- Target 800–1500 words of prose. Schemas, signatures, tables, and diagrams do not count. Skip N/A sections. Cut anything that does not change a decision. Evidence is at most 8 decision-changing rows.
- Link the packet `_prd.md`. Translate PRD IDs into technical obligations; do not copy problem or feature prose.
- Write technical non-goals before extra design. Justify every new package, directory, abstraction, or service.
- Prefer existing modules. Prefer a mermaid or ASCII diagram over a flow paragraph when more than one component changes.
- Contracts are the source of truth: types, CLI grammar, schemas, errors, and changed boundaries. They may exceed 20 lines when they are the contract; unused fields are still forbidden.
- Map every PRD goal, story, capability, and constraint in the traceability table. Map `M-xx` when present. No requirement may disappear silently.
- Name failure modes, security/privacy, compatibility, rollback, and observability only where they apply.
- Sequencing is build-order constraints for `sf-create-tasks`, not a task plan. Every step after the first names prerequisites.
- End with links to every relevant ADR.

### 8. Review, save, and validate

- Present one complete draft and ask with `A. Approve`, `B. Adjust`, `C. Rewrite`, and `D. Discard`.
- Apply feedback and present the complete current draft again.
- Write `.spec-finder/tasks/<slug>/_techspec.md` only after explicit approval.
- Re-read the saved file and validate:
  - the packet PRD is linked, or an approved traceability gap is recorded in Context and Open Questions;
  - technical non-goals exist and are not contradicted by Contracts or Architecture;
  - every PRD goal, story, capability, and constraint is mapped; leftover `M-xx` is mapped when present;
  - public contracts are signatures, schemas, or CLI grammar, not prose alone;
  - failure modes are named with detection, behavior, and recovery;
  - tests map to contracts and name exact gates;
  - sequencing is build-order constraints, not tasks;
  - no product-scope expansion;
  - Evidence is capped, cited, and distinguished from inference;
  - ADRs are linked and no material branch sits in Open Questions;
  - prose is in the 800–1500 word target unless the user approved a longer delta.
- Point to `sf-create-tasks` as the next step.

## Anti-patterns

- Greenfield architecture that ignores existing seams.
- Technology selection without a requirements or repository rationale.
- “Handle errors” without named failure modes and recovery behavior.
- Tests that do not map to contracts and requirements.
- Copying PRD prose instead of translating it into technical obligations.
- Public contracts as prose when a schema, signature, or CLI grammar exists.
- Filling N/A sections to match the template.
- Dumping the full research ledger into Evidence.
- Sequencing that is a task plan.
- Hiding unresolved decisions as implementation details.

## Failure rules

- If codebase evidence conflicts, present both patterns and their actual usage before recommending one.
- If official documentation is unavailable for a critical external dependency, present lettered choices to wait for documentation, proceed with a documented research-limited design, or provide another direction.
- If an approved product requirement is technically infeasible, do not weaken it silently; return the conflict for decision.
- Preserve unrelated approved sections in update mode and identify downstream task files that require regeneration.
