---
name: sf-task-report
description: Writes the mandatory evidence-backed final report for a Spec Finder implementation task. Use after implementation and verification, before task completion.
---

# Write a Spec Finder Task Report

<HARD-GATE>
Never report a passing test, completed requirement, or clean outcome without current evidence. Do not change task frontmatter status; the invoking runtime or manual execution orchestrator owns it.
</HARD-GATE>

1. Read the task, PRD, TechSpec, ADRs, `memory/MEMORY.md`, current `memory/task_NN.md`, current diff, and verification output.
2. Re-run focused verification when evidence is missing, partial, or stale.
3. Write `reports/task_NN.md` beside the task packet using `references/report-template.md`.
4. Map every numbered requirement to satisfied, failed, blocked, or not applicable with evidence.
5. Use `sf-memory` to record any final factual learning, risk, correction, or handoff before writing the verdict.
6. State platform gaps and unresolved risks candidly. Choose exactly one final verdict: completed, failed, or blocked.
