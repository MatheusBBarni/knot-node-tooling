---
name: sf-tdd-report
description: Writes the mandatory TDD evidence report for a Spec Finder task, requiring per-slice red and green command identities or a one-line not-applicable reason. Use after TDD execute on the manual path or during the ACP report phase for opted work. Do not change task frontmatter status.
---

# Write a Spec Finder TDD Task Report

<HARD-GATE>
- Never report a passing test, completed requirement, or clean outcome without current evidence.
- Do not change task frontmatter status; the invoking runtime or manual execution orchestrator owns it.
- Do not write or edit `skills/sf-task-report/`.
- Forbid honest `completed` when any behavioral slice lacks red and green command evidence without task-level not-applicable coverage.
- Never invent theater red rows for not-applicable work.
- NEVER require a user-global `/tdd` path. Read `references/tdd-doctrine.md` in this tree.
</HARD-GATE>

ACP report phase may write this report; the runtime still owns status. Manual TDD completion still uses this skill. Core `sf-task-report` remains the unmarked path.

## Invocation

```text
/sf-tdd-report <slug> <task_id>
```

- `<slug>` resolves to `.spec-finder/tasks/<slug>/`.
- `<task_id>` is one existing `task_NN` / `NN`.

## Workflow

1. Read this skill, `references/tdd-doctrine.md`, and `references/tdd-report-template.md`.
2. Read the task, `_prd.md`, `_techspec.md`, ADRs, `memory/MEMORY.md`, `memory/task_NN.md`, current diff, and verification output.
3. Re-run focused verification when evidence is missing, partial, or stale. Poll to terminal exit.
4. Classify coverage:
   - **Behavioral:** every planned slice must show the same focused command failing for the intended missing behavior, then passing.
   - **Not-applicable:** `## TDD Plan` has `not_applicable` and exactly one reason line. Repeat that line in the report. Do not add red table rows.
   - Missing reason, missing red, missing green, or a different green command → cannot claim `completed`.
5. Write `reports/task_NN.md` using the template. Keep Outcome, Changes, Requirements, Verification, Risks and Follow-ups, and Final Verdict. Add the TDD Evidence section in exactly one of the two shapes.
6. Use `sf-memory` to record any final factual learning, risk, correction, or handoff before writing the verdict.
7. Choose exactly one final verdict: `completed`, `failed`, or `blocked`. Do not set task status.

## Completed examples

Allowed behavioral row:

```markdown
| 1 | user can checkout with valid cart | `bun test a.test.ts -t checkout` fail | same command pass |
```

Forbidden behavioral claim: any slice whose Red column is empty, "not run", or a pass.

Allowed not-applicable claim: one reason line copied from the plan and no red rows.

## Rules

- Excerpts stay short. No full transcripts, secrets, or env files.
- Partial or stale command output is not evidence.
- ACP report phase may write the TDD report. Do not change task frontmatter status; Spec Finder owns it.
