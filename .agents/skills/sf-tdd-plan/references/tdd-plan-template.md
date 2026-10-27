# TDD Plan section

Add or replace only the `## TDD Plan` heading on an existing `task_NN.md`. Do not rewrite required create-tasks sections, renumber task IDs, or edit `_tasks.md` IDs.

## Applicable shape

```markdown
## TDD Plan

- Applicability: applicable
- Not-applicable reason:

### Seams
- `<public interface>` — <observable behavior>

### Slices (order is execution order)
1. `<test identity>` at `<seam>` — <observable behavior>
```

- Omit the not-applicable reason line, or leave it empty, when applicability is `applicable`.
- Every seam names a public interface and the behavior observed there.
- Every slice identity names observable behavior (not "test happy path", "add tests", or "cover edge cases").
- Slice order is the execute order. One vertical slice per numbered item.

## Not-applicable shape

```markdown
## TDD Plan

- Applicability: not_applicable
- Not-applicable reason: <exactly one line stating there is no new or changed product behavior>

### Seams

### Slices (order is execution order)
```

- The reason is required and must be exactly one line.
- Do not invent seams or red slices to fill the tables.
- Missing reason is incomplete; do not treat the plan as finished.
