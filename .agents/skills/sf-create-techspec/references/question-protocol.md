# TechSpec Question Protocol

## Required progression

1. **Contracts:** public interfaces, ownership, and compatibility of the change.
2. **State:** data lifecycle, persistence, concurrency, and retention.
3. **Failure and NFRs:** recovery, security, privacy, migration, and rollback.
4. **Evidence:** tests and gates that prove the contracts.

## Rules

- Ask exactly one technical question per turn and wait.
- Use the host's blocking question tool when available; otherwise stop after the question.
- Give every selectable answer an uppercase sequential label: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 evidence-backed answers. Add `Other` whenever those answers are not exhaustive and label it with the next available letter.
- Put the recommendation first and format it as `A. (Recommended) [answer] — [principal trade-off]`.
- End every prompt with `Reply with the letter (for example, A), or the letter plus context.`
- Accept uppercase or lowercase letters, letter-plus-context, and full option text. Normalize them to the labeled choice before continuing.
- Never use unlabeled bullets for answers, positional phrases such as “the second option,” or bare yes/no approval prompts.
- Ask 3-6 questions. Skip dimensions already fixed by the PRD, repository evidence, or current official documentation. Do not manufacture questions to reach a quota.
- Do not ask for technical preferences already resolved by repository evidence, approved requirements, or current official documentation.
- Do not ask about product scope, users, or success metrics; return those to the PRD.
- Never auto-resolve decisions that change public contracts, data ownership, security posture, migrations, dependencies, or required evidence.

## Required shape

```text
[One technical question]

A. (Recommended) [Answer] — [principal trade-off]
B. [Answer] — [principal trade-off]
C. [Answer] — [principal trade-off]
D. Other — describe a different answer.

Reply with the letter (for example, A), or the letter plus context.
```

Use only as many labeled choices as the decision needs. For a binary decision, use `A.` and `B.`; add `C. Other` when another answer is meaningful.
