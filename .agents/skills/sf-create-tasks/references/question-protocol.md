# Task Planning Question Protocol

## Required progression

1. **Slices:** user/operator outcomes versus layer cuts. Prefer `US-xx` / `F-xx` flows.
2. **Unknowns:** spikes first, with a decision criterion, then implementation slices.
3. **Boundaries:** per-slice out of scope and blockers.
4. **Graph approval:** complete numbered execution order in one review.

## Rules

- Ask one material task-planning question per turn and wait.
- Use the host's blocking question tool when available; otherwise stop after the question.
- Give every selectable answer an uppercase sequential label: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 evidence-backed answers. Add `Other` whenever those answers are not exhaustive and label it with the next available letter.
- Put the recommendation first and format it as `A. (Recommended) [answer] — [principal trade-off]`.
- End every prompt with `Reply with the letter (for example, A), or the letter plus context.`
- Accept uppercase or lowercase letters, letter-plus-context, and full option text. Normalize them to the labeled choice before continuing.
- Never use unlabeled bullets for answers, positional phrases such as “the second option,” or bare yes/no approval prompts.
- Do not ask for task facts that repository or specification evidence can establish.
- Do not ask product or architecture questions that belong in the PRD or TechSpec.
- Do not auto-resolve a split that changes user-visible outcomes, drops a mapped requirement, or creates a layer-only foundation task.

## Required shape

```text
[One task-planning question]

A. (Recommended) [Answer] — [principal trade-off]
B. [Answer] — [principal trade-off]
C. [Answer] — [principal trade-off]
D. Other — describe a different answer.

Reply with the letter (for example, A), or the letter plus context.
```

Use only as many labeled choices as the decision needs. For graph approval, use:

```text
A. Approve and write tasks
B. Revise the graph
C. Stop
D. Other — describe another direction
```
