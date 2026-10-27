---
name: sf-idea-factory
description: Expands a raw product or feature idea into an approved, research-backed idea packet through clarification, codebase and market research, viability analysis, independent critique, opportunity scanning, and explicit scope decisions. Use before PRD creation when the problem, opportunity, or V1 boundary still needs discovery.
---

# Spec Finder Idea Factory

Turn a raw idea into the approved foundation for the Spec Finder pipeline.

<HARD-GATE>
- NEVER write or replace `_idea.md` before clarification, both research tracks, viability analysis, independent critique, opportunity selection, a complete draft review, and explicit user approval are complete.
- NEVER skip research, critique, or user decisions because an idea appears simple.
- NEVER invent market evidence, user demand, metrics, codebase facts, or advisor consensus.
- NEVER silently choose a material scope or opportunity branch for the user.
- NEVER ask for section-by-section approval; present one complete draft after the direction is approved.
</HARD-GATE>

## Interaction contract

- Ask exactly one question per turn and wait for the answer.
- Use the runtime's blocking question mechanism when available. If unavailable, make the question the complete response and stop.
- Present every answer choice with sequential uppercase labels: `A.`, `B.`, `C.`, and so on. Never present selectable answers as unlabeled bullets.
- Every question must provide 2-3 concrete suggested answers. Add an `Other` path whenever those answers are not exhaustive. Put the evidence-backed recommendation first as `A. (Recommended)` and explain its trade-off. Label `Other` with the next available letter.
- End every choice prompt with: `Reply with the letter (for example, A), or the letter plus context.` Accept lowercase letters and full option text too.
- Do not ask for information that repository or web research can answer.
- Do not auto-resolve a decision that changes scope, target user, success metrics, or the selected opportunity.

Read `references/question-protocol.md` before the first question.

## Required inputs

- A feature idea, problem, or opportunity.
- Optional existing `_idea.md` for update mode.

## Mandatory phase checklist

Track and complete these phases in order:

1. Resolve packet and existing context.
2. Clarify the problem, user, workflow, V1 boundary, ambition, and success.
3. Complete codebase and external research.
4. Produce the evidence ledger and viability assessment.
5. Run independent critique and preserve genuine disagreement.
6. Scan alternatives and obtain an explicit direction decision.
7. Record the selected scope in an ADR.
8. Draft the complete idea and obtain explicit approval.
9. Save `_idea.md` and hand off to `sf-create-prd`.

## Workflow

### 1. Resolve the packet

- Derive a descriptive 2-5 word kebab-case slug.
- Target `.spec-finder/tasks/<slug>/` and read existing `_idea.md`, downstream artifacts, and `adrs/` before proposing changes.
- Operate in update mode when `_idea.md` exists. Preserve sections outside the approved change.
- Create directories as needed, but do not create `_idea.md` yet.

### 2. Clarify the idea

- Ask 3-6 targeted questions using `references/question-protocol.md`.
- Establish the concrete pain, primary user, current workaround, workflow moment, V1 boundary, ambition, and measurable success.
- Keep questions on WHAT, WHY, and WHO. Defer implementation design to `sf-create-techspec`.
- Complete at least one clarification round before research. Stop early only when the required decisions are already explicit.

### 3. Research both tracks

Run both tracks concurrently when the runtime supports real parallel work; otherwise run them sequentially and say so.

**Codebase track — required**

- Inspect repository instructions, related features, domain models, user flows, integration points, tests, and known constraints.
- Record concrete file paths and distinguish implemented behavior from plans or comments.

**External track — required**

- Perform 3-7 current searches spanning competitors, user expectations, adoption or market evidence, feasibility, and pricing/cost when relevant.
- Prefer primary sources, official documentation, first-party pricing, research papers, and direct product documentation.
- Record source URL, publication/update date when available, supported claim, and relevance.
- Do not turn absence of evidence into evidence of absence.

If external research is unavailable, disclose exactly what is missing and ask with lettered choices whether to proceed with a research-limited artifact, wait, or provide another direction. Do not call the research phase complete without that decision.

### 4. Present evidence and viability

Present an evidence ledger before recommendations:

- **Repository evidence:** verified behavior and constraints with paths.
- **External evidence:** sourced facts with citations and dates.
- **Inferences:** conclusions derived from evidence, labeled as inference.
- **Unknowns:** material gaps that could change scope or viability.

Read `references/business-analyst.md`. Define 3-6 measurable KPIs with baselines or an explicit `unknown`, targets, measurement method, and window. Score Impact, Reach, Frequency, Differentiation, Defensibility, and Feasibility as `Must do`, `Strong`, `Maybe`, or `Pass`, with evidence-backed rationale.

### 5. Run independent critique

Read `references/council.md` and dispatch 3-5 independent advisors through the host's real delegation mechanism when available. Select perspectives that create useful tension: pragmatic engineering, architecture, security/privacy, product, devil's advocate, or first-principles framing.

Require opening positions, steel-manned rebuttals, concessions or hold-firm statements, position evolution, unresolved tensions, and synthesis. Never simulate multiple advisors while claiming independent review.

If real delegation is unavailable, disclose the limitation and ask with lettered choices whether to proceed with a labeled single-agent structured critique, stop, or provide another direction. This is a material evidence-quality decision.

### 6. Scan opportunities and decide

Read `references/product-strategist.md`. Compare at most three directions:

- the original or refined proposal;
- a smaller essence-first version;
- a more ambitious or adjacent higher-leverage version.

Score each with the same viability framework. Recommend one based on evidence, name its principal cost, and present original, alternative, hybrid, and another direction as lettered answers. Do not draft until the user decides.

### 7. Record the scope decision

- Read `references/adr-template.md`.
- Allocate the next zero-padded ADR number under `adrs/` without replacing an existing ADR.
- Record the accepted direction, rejected alternatives, evidence, consequences, risks, and mitigations.
- Create additional ADRs only for other consequential decisions the user explicitly made.

### 8. Draft and review

- Read `references/idea-template.md` and fill every mandatory section.
- Separate sourced facts from inference; cite research near the claim it supports.
- Include 3-10 prioritized features, 3-6 measurable KPIs, at least three justified V1 exclusions, council tensions, ADR links, and unresolved questions.
- Present the entire draft once. Ask with `A. Approve`, `B. Adjust`, `C. Rewrite`, and `D. Discard`.
- On revision, present the complete revised draft again. Approval must apply to the current version.

### 9. Save

- Confirm the final path if the slug changed during discovery.
- Write `.spec-finder/tasks/<slug>/_idea.md` only after explicit approval.
- Re-read the saved file, verify template completeness and citations, then point to `sf-create-prd`.

## Failure rules

- Put unresolved but non-blocking gaps in Open Questions; never fill them by guessing.
- Stop when a missing answer would materially change the target user, V1 scope, viability, or selected direction.
- In update mode, show which approved decisions change and preserve unrelated content.
- If sources disagree, present the disagreement and its consequence instead of selecting the convenient claim.
