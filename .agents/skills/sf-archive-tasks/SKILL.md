---
name: sf-archive-tasks
description: Archives fully completed Spec Finder task packets from .spec-finder/tasks to .spec-finder/tasks_done and refreshes consolidated task reports. A packet moves only when it contains at least one task_NN.md, every task has frontmatter status completed, and no completed task has blocked checkpoint delivery; incomplete and early-stage packets stay. Use to sweep, archive, tidy, dry-run, or report on Spec Finder packets, not to execute tasks or force incomplete work into the archive.
---

# Archive Completed Spec Finder Packets

<HARD-GATE>
- Move a packet only when the bundled classifier reports `DONE`.
- Never move a packet with no task files or any status other than `completed`.
- Never move a packet when a `status: completed` task has `checkpoint.state: blocked`; delivery is incomplete and the blocker must remain recoverable in the active packet.
- Never partially move a packet, edit its task content, overwrite an archive destination, commit, or push.
- Treat each `task_NN.md` frontmatter status as authoritative. `_tasks.md` is advisory and may not contain status data.
</HARD-GATE>

Sweep completed packets from `.spec-finder/tasks/` into `.spec-finder/tasks_done/`, then write a truthful report of what moved and what remains.

## Invocation

```text
/sf-archive-tasks [tasks-dir=.spec-finder/tasks] [report-only] [--slug TASK_SLUG]
```

- `tasks-dir` is the source directory; its archive sibling is `tasks_done/`.
- `report-only` classifies and writes reports without moving packets.
- `--slug` accepts exactly one lowercase kebab-case active packet slug. It
  limits classification, movement, and report entries to that packet. Invalid,
  repeated, missing, or absent target values fail before movement.
- Omit `--slug` to preserve the full-directory sweep.

## Classification

| Verdict | Condition | Action |
|---|---|---|
| `DONE` | At least one task, every status is `completed`, and no completed task has `checkpoint.state: blocked` | Move unless report-only |
| `REMAINING` | Any task is pending, in progress, failed, blocked, missing status, otherwise not completed, or completed with blocked checkpoint delivery | Keep |
| `EARLY-STAGE` | No `task_NN.md` exists | Keep |

Unchecked Markdown boxes are verification checklists, not lifecycle state. Report their count but never use them to decide a move. Optional checkpoint metadata is read only to keep completed-but-blocked delivery recoverable; absent metadata and successful delivery retain existing archive behavior.

## Workflow

Track this checklist:

```text
Archive progress:
- [ ] 1. Run the bundled read-only classifier
- [ ] 2. Reconcile index information and print the plan
- [ ] 3. Move only DONE packets
- [ ] 4. Refresh reports
- [ ] 5. Summarize without committing
```

### 1. Classify

Resolve this skill's installed directory, read `references/report-template.md`, then run:

```bash
bash <skill-dir>/scripts/scan-tasks.sh .spec-finder/tasks [report-only] [--slug TASK_SLUG]
```

For a targeted run, pass the exact reviewed slug with `--slug`. The emitted
tab-separated `VERDICT` records are the source of truth; do not reclassify by
eye or inspect unrelated packets as part of a targeted run.

### 2. Print the plan

- Report every `DONE`, `REMAINING`, and `EARLY-STAGE` packet and its reason.
- For a completed task with `checkpoint.state: blocked`, include the emitted checkpoint blocker in the remaining-packet report so the operator knows what must be resolved before archiving.
- `_tasks.md` may report `indexNoStatus`; that is normal for indexes without a status column.
- If `indexDrift(...)` appears, trust per-task frontmatter, record the drift, and do not edit task files.
- Treat unexpected statuses as `REMAINING` and surface them explicitly.

### 3. Move completed packets

- Create the archive sibling only when at least one move is needed.
- Use `git mv` for tracked packets and `mv` for untracked packets so history is preserved where possible.
- Skip and report any packet whose destination already exists. Never merge or overwrite destinations.
- Under `report-only`, perform no moves.

### 4. Refresh reports

Follow `references/report-template.md` using current classifier results and today's date.

- Always write `.spec-finder/TASKS_REPORT.md`.
- Refresh `.spec-finder/tasks/REPORT_pending.md` or `.spec-finder/tasks_done/REPORT_done.md` only when those files already exist.
- Derive feature titles from the first H1 in `_prd.md`; derive task titles from task frontmatter or `_tasks.md`.
- Include destination conflicts, index drift, unexpected statuses, and unchecked-box counts.

### 5. Summarize

Report moved packets and task counts, remaining and early-stage packets, skipped destinations, drift, report paths, and whether the run was report-only. Leave all changes uncommitted.

## Rules

- If the source directory is missing or has no packet directories, stop and report it.
- Do not treat `done` or `finished` aliases as archive-ready; canonical archive state is exactly `completed`.
- Do not edit status to make a packet eligible.
- Preserve unrelated working-tree changes and never use blanket staging.

## Resources

- `scripts/scan-tasks.sh` is the deterministic read-only classifier.
- `references/report-template.md` defines consolidated and optional directory reports.
