# TDD Task Report Template

Write `reports/task_NN.md` with every core field below plus one TDD Evidence shape. Do not omit Outcome, Changes, Requirements, Verification, Risks and Follow-ups, or Final Verdict.

```markdown
# Task NN Final Report: [Title]

## Outcome

- Verdict: [completed | failed | blocked]
- Date: YYYY-MM-DD
- Provider/session: [known identity or unavailable]

## Changes

- `path` — Summary

## Requirements

| Requirement | Status | Evidence |
|---|---|---|

## Verification

| Command or check | Result | Evidence |
|---|---|---|

## TDD Evidence

### Behavioral shape

| Slice | Test identity | Red command / result | Green command / result |
|---|---|---|---|
| 1 | <observable behavior> | `<focused command>` fail — <short excerpt> | same command pass — <short excerpt> |

### Not-applicable shape

- Not-applicable reason: <exactly the one line from `## TDD Plan`>

Use exactly one of the two shapes. Do not invent red rows for not-applicable work.

## Risks and Follow-ups

## Final Verdict

[One factual paragraph.]
```

## Completed gate

Honest `completed` is allowed only when:

- every behavioral slice has the same focused command identity failing, then passing, or
- the whole task uses the not-applicable shape with the plan's one-line reason and no theater red rows.

Missing red, missing green, a different command on green, stale or partial output, or N/A without the reason line forbids `completed`. Use `failed` or `blocked`.

Evidence excerpts stay short: command identity, result meaning, decisive snippet. No transcripts.
