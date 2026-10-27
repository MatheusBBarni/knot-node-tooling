# Write-spec question protocol

Use this protocol only after repository and current-docs research.

## Remaining-decision order

Ask only dimensions still open after research and existing artifacts:

1. **Need and success** if the problem, primary user, or testable success is still open.
2. **Non-goals and MVP boundary** if exclusions are not explicit.
3. **Public contracts and failure** if signatures, errors, or recovery still fork.
4. **Boundaries** if Always / Ask first / Never cannot be written from evidence.
5. **Slice or sequencing** only when a split would change user-visible outcomes.

Skip a dimension that research, the request, or an approved artifact already fixed.
An approved `.spec-finder/tasks/<slug>/_prd.md` fixes need, users, success, non-goals, and in-scope capabilities.
Skip those dimensions.
Ask only public contracts, failure, boundaries, and slice forks that the PRD did not decide.
If the PRD conflicts with the repository, that conflict is the question. Do not silently override the PRD.
Do not manufacture questions to reach a quota.
Ask 2-6 remaining material questions when they exist. Separately offer the Git commit-cadence choice before drafting, even if no material question remains; this is an execution preference, not a product question.
If no material decision remains, ask only about Git cadence, then present the complete draft.

## Rules

- Ask exactly one question per turn and wait.
- Use the host's blocking question tool when available; otherwise stop after the question.
- Give every selectable answer an uppercase sequential label: `A.`, `B.`, `C.`, and so on.
- Every question must provide 2-3 evidence-backed answers.
  Add `Other` whenever those answers are not exhaustive and label it with the next available letter.
- Put the recommendation first as `A. (Recommended) [answer] - [principal trade-off]`.
- End every prompt with `Reply with the letter (for example, A), or the letter plus context.`
- Accept uppercase or lowercase letters, letter-plus-context, and full option text.
- Never use unlabeled bullets, positional phrases such as "the second option", or bare yes/no approval prompts.
- Do not ask the user to choose facts the repository or current docs already answer.
- Do not auto-resolve a decision that changes scope, public contracts, data ownership, security, migrations, or required evidence.

## Required shape

```text
[One remaining decision, with the evidence that left it open]

A. (Recommended) [Answer] - [principal trade-off]
B. [Answer] - [principal trade-off]
C. [Answer] - [principal trade-off]
D. Other - describe a different answer.

Reply with the letter (for example, A), or the letter plus context.
```

Use only as many labeled choices as the decision needs.
For a binary decision, use `A.` and `B.`; add `C. Other` when another answer is meaningful.

For whole-draft approval:

```text
A. Approve and write the spec
B. Adjust the draft
C. Rewrite
D. Discard
```

## Translation

- Replace "WebSockets or polling?" with "Which events must appear immediately?"
- Replace "Which library?" with "Which existing module should this follow, and what public contract changes?"
- Replace "How should we split the work?" with "Which user/operator outcome must ship first?"
