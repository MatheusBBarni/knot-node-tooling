# Task Archive Report Templates

Use actual classifier results and omit empty entry sections. Never infer completion from checkboxes.

## Consolidated report

Write `.spec-finder/TASKS_REPORT.md`:

```markdown
# Spec Finder Tasks Report

Generated: <YYYY-MM-DD>

Completion is determined by the canonical `status:` field in every `task_NN.md`. A packet moves to `.spec-finder/tasks_done/` only when it contains at least one task, every task is exactly `completed`, and no completed task has `checkpoint.state: blocked`. A blocked checkpoint remains recoverable in the active packet.

## Summary

| Location | Packets | Task files |
|---|---:|---:|
| Remaining (`.spec-finder/tasks/`) | <count> | <completed>/<total> |
| Archived (`.spec-finder/tasks_done/`) | <count> | <completed>/<total> |

- Moved this run: <packet count> packets (<task count> tasks)
- Report-only: <yes|no>

## Remaining

For each REMAINING packet, include packet, title, completed/total, non-completed statuses, dependencies or blockers when known, checkpoint-delivery blockers (including their reason) when present, index state, and unchecked-box count.

For each EARLY-STAGE packet, list present artifacts and state that task generation is still required.

## Moved This Run

For each moved packet, include title, completed task count, and archive destination.

## Previously Archived

| Packet | Title | Tasks |
|---|---|---:|

## Warnings and Skips

List destination conflicts, index drift, unexpected statuses, or `None`.
```

## Optional directory reports

Refresh these only when they already exist:

- `.spec-finder/tasks/REPORT_pending.md`: current REMAINING and EARLY-STAGE entries.
- `.spec-finder/tasks_done/REPORT_done.md`: every archived packet with title, completed/total, and `Archived` date (`today` for this run, `earlier` otherwise).

Derive packet titles from the first `# ` heading in `_prd.md`. Derive task titles from task frontmatter, falling back to `_tasks.md` only when necessary.
