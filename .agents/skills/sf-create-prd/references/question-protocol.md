# PRD Question Protocol

## Required progression

1. **Need:** verified problem and current workflow. Restate from evidence (who, failure, cost). A requested feature is not the problem.
2. **Users:** primary persona, secondary impacts, and usage context.
3. **Success:** baseline (or explicit unknown plus how it will be measured), target, measurement method, and window. Refuse untestable success.
4. **Scope:** non-goals first, then MVP boundary, dependencies, and constraints. Ask what is out before extra capabilities.
5. **Capabilities:** observable user outcomes and Given/When/Then acceptance that survive the non-goals cut.

## Rules

- Ask exactly one question per turn and wait.
- Use the host's blocking question tool when available; otherwise stop after the question.
- Give every selectable answer an uppercase sequential label: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 evidence-backed answers. Add `Other` whenever those answers are not exhaustive and label it with the next available letter.
- Put the recommendation first and format it as `A. (Recommended) [answer] — [principal trade-off]`.
- End every prompt with `Reply with the letter (for example, A), or the letter plus context.`
- Accept uppercase or lowercase letters, letter-plus-context, and full option text. Normalize them to the labeled choice before continuing.
- Never use unlabeled bullets for answers, positional phrases such as “the second option,” or bare yes/no approval prompts.
- Ask 3-6 questions. Skip only dimensions already explicit in approved artifacts and evidence.
- Do not ask the user to choose facts that research can establish.
- Do not ask about databases, APIs, frameworks, code structure, architecture, or testing implementation.
- When restating the problem, cite research or repository evidence. Do not accept “users want X” as sufficient.
- Do not ask for extra capabilities until non-goals are explicit.
- Success questions must include baseline, target, window, and method. If baseline is unknown, the answer must say how it will be measured.
- Never auto-resolve product scope, target users, rollout policy, or success metrics.

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

## Technical drift translation

- Replace “WebSockets or polling?” with “Which user events must appear immediately?”
- Replace “Which CSV library?” with “Which information and compatibility do exported files require?”
- Replace “Which database?” with “What user-visible retention, portability, or recovery behavior is required?”
