# Refinement question protocol

Use this protocol only after repository research and source intake.

## Remaining-decision order

Ask only dimensions still open after research and the source:

1. **Source completeness** if a tracker fetch failed or the prompt is too thin to code against.
2. **Need and success** if the problem, primary user, or testable success is still open.
3. **Gaps that block implementation** if a source sentence is too vague to code.
4. **Undescribed flows** if error, cancel, empty, permission, or limit paths are missing.
5. **Side effects** if persistence, overwrite, audit, feature flags, or integrations are unspecified.
6. **Non-goals and MVP boundary** if exclusions are not explicit.
7. **Repository routing** if more than one credible repo could own the change.
8. **Behavior and UI** if loading, error, empty, or success states still fork.
9. **Data and API** if entities, fields, or contracts still fork.
10. **Edge cases, NFRs, and sequencing** only when they change the tickets.

Skip a dimension that research, the source, or an approved artifact already fixed.
Do not manufacture questions to reach a quota.
Ask 2-8 remaining questions.
If none remain, present digested requirements.

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
- Do not ask the user to choose facts the repository or source already answers.
- Do not auto-resolve a decision that changes scope, public contracts, data ownership, security, migrations, or required evidence.
- Lead with homework: state what the code or source already shows, then ask for confirmation.

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

For digested-requirements approval:

```text
A. Approve digested requirements
B. Adjust
C. Rewrite
D. Discard
```

For whole-draft approval:

```text
A. Approve and write the refinement
B. Adjust the draft
C. Rewrite
D. Discard
```

## Translation

- Replace "Which tracker?" with nothing. Record whatever source the user already gave.
- Replace "WebSockets or polling?" with "Which events must appear immediately?"
- Replace "Which library?" with "Which existing module should this follow, and what public contract changes?"
- Replace "How should we split the work?" with "Which user/operator outcome must ship first?"
