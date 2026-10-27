---
name: sf-refinement
description: Creates an approved, tracker-agnostic refinement document from a prompt, pasted ticket, or issue URL (Jira, Linear, GitHub, GitLab, or similar). Explores the codebase first, asks remaining decisions one at a time, and writes only `.spec-finder/refinements/<task_slug>.md`. Use for refinement, PRD breakdown, story writing, or turning a ticket into AI-ready specs. Do not use for idea-factory discovery, PRD-only, TechSpec-only, one-shot specs, packet creation, or implementation.
---

# Refine a Prompt or Ticket

One invocation produces exactly one saved artifact: `.spec-finder/refinements/<task_slug>.md`.
It does not create or update `.spec-finder/tasks/` or `.spec-finder/specs/`.
This is not `sf-write-spec`, `sf-idea-factory`, `sf-create-prd`, `sf-create-techspec`, or `sf-create-tasks`.

Read `references/doctrine.md` before research.
Read `references/phase-guide.md` when entering a phase.
Read `references/question-protocol.md` before asking.
Read `references/quality-bar.md` before drafting.

## Iron law

```
NO SPECS WITHOUT CODE EXPLORATION FIRST.
NO FILE PATHS WITHOUT VERIFICATION.
NO STORIES WITHOUT DIGESTED-REQUIREMENTS APPROVAL.
```

<HARD-GATE>
- NEVER skip repository exploration because the request looks simple.
- NEVER invent file paths, endpoints, or patterns. Verify with search and read.
- NEVER write stories before the digested-requirements checkpoint is approved.
- NEVER write or replace `.spec-finder/tasks/` or `.spec-finder/specs/`.
- NEVER write ADRs, memory files, runner packets, or any file except `.spec-finder/refinements/<task_slug>.md`.
- NEVER require Portuguese or any other language.
- NEVER translate the source into another language unless the user asks.
- NEVER vendor-lock intake or output to Jira, Linear, GitHub, or any one tracker.
- NEVER create, update, or close tickets in an issue tracker.
- NEVER write the refinement file before whole-draft approval.
- NEVER ask the user to decide facts the repository or source already answers.
- NEVER split work only by technical layer. Split by user flow, then by repository.
- NEVER present a draft that fails `references/quality-bar.md` or still contains template placeholders.
</HARD-GATE>

## Language

- Skill instructions stay in English.
- Section headings in the saved file stay in English (file schema).
- Write all narrative, stories, acceptance, constraints, and test scenarios in the language of the source prompt, ticket, or user replies.
- Do not force English body text when the source is another language.
- Do not require a specific human language for body text beyond the English file-schema headings.

## Interaction contract

- Ask exactly one remaining question per turn and wait.
- Use the runtime's blocking question mechanism when available. Otherwise make the question the complete response and stop.
- Present every answer choice with sequential uppercase labels: `A.`, `B.`, `C.`.
- Every question must provide 2-3 concrete suggested answers. Add `Other` when those answers are not exhaustive; lead with `A. (Recommended)`.
- End every choice prompt with: `Reply with the letter (for example, A), or the letter plus context.`
- Do not auto-resolve a decision that changes scope, public contracts, data ownership, security, migrations, or required evidence.

## Required inputs

One of:

- A freeform prompt or pasted PRD
- A pasted ticket body
- A ticket URL or identifier from any tracker (Jira, Linear, GitHub Issues, GitLab, Azure Boards, or similar)

Optional: existing `.spec-finder/refinements/<task_slug>.md` for update mode, local repository paths, design links, or an architecture map.

If the user needs discovery of the problem or V1 boundary, stop and offer `sf-idea-factory`.
If they asked for a one-shot implementation spec, use `sf-write-spec`.
If they asked only for a PRD, TechSpec, or runner packet, use that skill instead.

## Mandatory phase checklist

1. Resolve the slug and source (prompt or tracker ticket).
2. Collect repos to analyze and optional design links.
3. Research the repository into a current-system ledger.
4. Ask only remaining material questions.
5. Present digested requirements and obtain approval.
6. Draft the complete refinement (flows, stories, specs, tests).
7. Run the verification gate.
8. Obtain explicit whole-draft approval.
9. Write only `.spec-finder/refinements/<task_slug>.md`.
10. Re-read and validate against the quality bar.

## Workflow

### 1. Resolve source and slug

- Derive a descriptive kebab-case `task_slug` from the title or prompt.
- Target only `.spec-finder/refinements/<task_slug>.md`.
- Create `.spec-finder/refinements/` as needed. Do not write the file yet.
- If the input is a tracker URL or key, fetch with whatever tools are available for that tracker. If fetch fails, ask the user to paste the body.
- Record tracker name, identifier, and URL when present. Do not assume one vendor.
- Read repository instructions, `.spec-finder/config.json` when present, and the existing refinement file in update mode.

### 2. Research before questions

Complete research before asking. Run independent repo tracks concurrently when the runtime can do real parallel work.

Capture a current-system ledger: current versus desired behavior; related flows, modules, callers, tests, and conventions; exact verification commands; 1-3 short current-code excerpts that show the seam. Distinguish shipped behavior from comments or plans.

Present repository findings with paths, inferences labeled as inference, and remaining decisions.

### 3. Clarify remaining decisions

Follow `references/question-protocol.md`.
Skip dimensions already fixed by the source or the code.
If none remain, present digested requirements.

### 4. Digested-requirements checkpoint

Present the complete understanding from `references/phase-guide.md`.
Ask with `A. Approve digested requirements`, `B. Adjust`, `C. Rewrite`, and `D. Discard`.
Do not generate stories until this version is approved.

### 5. Draft the complete refinement

Read `references/refinement-template.md` and `references/spec-format.md`.
Split by user flow first, then by repository inside each flow.
Frontend work is a Story. Backend work is a Task. One ticket per repository.
Each ticket needs impact analysis, relevant NFRs, negative constraints, verified paths, test signatures, and exact DONE commands.
Include Gherkin test scenarios for happy path, validation, and error handling; add other categories only when they apply.
Run `references/verification-gate.md` and rewrite until it passes.
Do not create tracker issues.

### 6. Review and save

Present the complete draft once.
Ask with `A. Approve and write the refinement`, `B. Adjust the draft`, `C. Rewrite`, and `D. Discard`.
Write files only after explicit approval of that version.
Write exactly one file: `.spec-finder/refinements/<task_slug>.md`.

### 7. Validate before completion

Re-read the saved file and verify it passes `references/quality-bar.md`.
The intended write set is exactly that one file.
No `.spec-finder/tasks/` or `.spec-finder/specs/` files were created or changed.

## Anti-patterns

- Generating stories from the source without exploring code
- Guessed paths
- Portuguese-only templates
- Creating Jira or Linear tickets as the deliverable
- One backend ticket and one frontend ticket that mix multiple user flows
- Writing a runner packet or a `sf-write-spec` file
- "Follow best practices" instead of a verified reference file

## Failure rules

- Stop if the outcome and target user remain unclear after remaining questions.
- If a material decision remains open, do not hide it in Open Questions and save anyway.
- If a path cannot be verified, mark it unverified in the file; do not invent it.
- Preserve unrelated approved content in update mode.
