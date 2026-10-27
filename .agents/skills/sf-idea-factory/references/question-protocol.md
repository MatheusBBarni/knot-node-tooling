# Idea Discovery Question Protocol

## Required progression

1. **Problem:** concrete pain/opportunity, trigger, and current workaround.
2. **User:** primary user, workflow moment, frequency, and affected secondary users.
3. **Scope:** smallest credible V1, exclusions, dependencies, and constraints.
4. **Ambition:** quick win, strategic bet, or compounding capability.
5. **Success:** observable behavior change, baseline, target, and measurement window.

## Interaction rules

- Ask one question per turn and wait.
- Use the host's blocking question tool when available; otherwise stop after the question.
- Give every selectable answer an uppercase sequential label: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 evidence-informed answers. Add `Other` whenever those answers are not exhaustive and label it with the next available letter.
- Put the recommendation first and format it as `A. (Recommended) [answer] — [principal trade-off]`.
- End every prompt with `Reply with the letter (for example, A), or the letter plus context.`
- Accept uppercase or lowercase letters, letter-plus-context, and full option text. Normalize them to the labeled choice before continuing.
- Never use unlabeled bullets for answers, positional phrases such as “the second option,” or bare yes/no approval prompts.
- Ask 3-6 questions total. Stop early only when problem, user, scope, and success are explicit.
- Do not ask questions answerable from repository or external research.
- Never auto-resolve target user, V1 boundary, ambition, or success metrics.

## Required shape

```text
[One question]

A. (Recommended) [Answer] — [principal trade-off]
B. [Answer] — [principal trade-off]
C. [Answer] — [principal trade-off]
D. Other — describe a different answer.

Reply with the letter (for example, A), or the letter plus context.
```

Use only as many labeled choices as the decision needs. For a binary decision, use `A.` and `B.`; add `C. Other` when another answer is meaningful.

## Focus boundary

Ask WHAT, WHY, WHO, and WHEN. Do not ask HOW, WHERE, or WHICH technology. Translate technical-sounding ideas into user outcomes.

## Scope discipline

Challenge every proposed capability:

- Which verified need does it serve?
- Must V1 include it to test the core hypothesis?
- What happens if it is deferred?

Prefer a narrow, measurable V1. Put useful but nonessential work in Out of Scope with rationale.
