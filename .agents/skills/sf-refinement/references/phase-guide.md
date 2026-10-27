# Phase guide

Enter a phase only after the previous exit criteria pass.

## Phase 0: Source and setup

**Goal:** Identify the source, slug, repos, and optional design context.

1. Classify the input as a prompt, pasted ticket, or tracker URL/identifier.
2. If a tracker URL or key is present, fetch it with available tools for that tracker. On failure, ask the user to paste the body.
3. Derive a descriptive kebab-case `task_slug`. Confirm only if two slugs are equally plausible.
4. Ask which local repositories to analyze. Do not scan the machine guessing.
5. Search for an architecture map if one exists. It is optional.
6. Ask for a design link only when the source implies UI and none was given.
7. Summarize available context. Do not write files.

**Exit:** Source text in hand, slug chosen, repos named, no refinement file written.

## Phase 1: Analysis

**Goal:** Understand the source against the actual code.

1. Parse objective, personas, requirements, constraints, and ambiguities.
2. For each named repo, explore in parallel when the runtime allows:
   - top-level layout, test location, framework, naming
   - build, lint, and test commands
   - similar existing behavior with exact paths
   - related models, endpoints, and UI
   - 1-3 reference files that demonstrate patterns to copy
3. Build a current-system ledger. Label inference.
4. Prepare remaining questions. Do not dump raw findings yet.

**Exit:** Ledger complete. Question list ready.

## Phase 2: Interview

**Goal:** Close gaps that change the tickets.

Follow `question-protocol.md`.
Business gaps that affect code come before technical forks.
If the user cannot recall current behavior, explore the repo and return with evidence.
Do not ask product-success metrics that do not change implementation.

### Digested-requirements checkpoint

When remaining questions are done, present:

- business context
- decisions made in this session, with why
- in scope / out of scope
- breakdown by repository
- dependencies and sequencing
- TBD gaps that still need a product owner
- source, design, and related ticket references

Ask for approval with the lettered digested-requirements choices.
Do not generate stories until approved.

**Exit:** Digested requirements approved.

## Phase 3: Stories and specs

**Entry hard gate:** digested requirements approved, at least one repo explored, every product gap answered or marked TBD.

1. Split by user flow, then by repository inside each flow.
2. Identify a distinct flow when input, entry point, error paths, or independent value differ.
3. For each ticket, fill `spec-format.md` with verified paths and commands.
4. Add negative constraints aimed at likely over-engineering.
5. Estimate points only as a suggestion with rationale. The team confirms later.
6. Generate Gherkin scenarios. Happy path, validation, and error handling always apply. Other categories only when relevant.
7. Run `verification-gate.md`. Fix every critical miss.
8. Present one complete draft. Write `.spec-finder/refinements/<task_slug>.md` only after whole-draft approval.

**Exit:** One approved file. No tracker writes. No `.spec-finder/tasks/` or `.spec-finder/specs/` writes.

## Edge cases

- Source too vague: mark TBD, do not invent product behavior.
- Feature too large: propose phases or an MVP slice and ask.
- Team disagreement: present trade-offs, wait for a lettered choice, record the decision.
- No architecture map: still works; ask more routing questions.
- Repo unavailable: mark those paths unverified and say so.
