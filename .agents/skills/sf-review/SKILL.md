---
name: sf-review
description: Reviews one active Spec Finder packet against its contracts, reports, diff, checkpoints, and verification evidence, then explicitly ships only that reviewed slug through local targeted archive. Use when reconciling completed work before archival.
---

# Review and Ship One Packet

Review is a packet-wide, read-only reconciliation. It does not write task status,
reports, memory, checkpoints, review state, or unrelated packet files. It does
not push, open or merge pull requests, release, or request remote acceptance.

## Invocation

Accept exactly one active packet slug and an optional literal suffix:

```text
/sf-review TASK_SLUG
/sf-review TASK_SLUG ship
```

`TASK_SLUG` must be one lowercase kebab-case slug matching the active directory
under `.spec-finder/tasks/`. Without `ship`, perform only the review. The word
`ship` is the only authorization to archive; a PASS or natural-language approval
never authorizes movement. Reject invalid slugs and extra tokens before reading
or writing anything.

`sf-review` requires `sf-archive-tasks` for its explicit ship phase. Setup
automatically includes that dependency whenever `sf-review` is selected.

## Review phase

1. Read the execution, report, and archive skill contracts, then read the full
   target packet: `_prd.md`, `_techspec.md`, `_tasks.md`, every `task_NN.md`,
   relevant ADRs, memory, and reports.
2. Confirm the target directory exists under `.spec-finder/tasks/`, is a valid
   packet, and has valid dependencies and paths. Do not inspect `tasks_done/`.
3. Require every task file to have canonical `status: completed`. Completion
   aliases, checkboxes, `_tasks.md`, and consolidated reports are not authority.
4. Require every task to have a substantive completed report. Map every numbered
   requirement and contract to concrete report evidence. Require named commands
   to have fresh terminal output; do not infer success from prose or stale logs.
5. Inspect staged, unstaged, and untracked Git changes. Reconcile each changed
   path with the TechSpec contract and required documentation. Block any path
   that cannot be mapped, including unrelated packet changes.
6. Treat checkpoint metadata and report handoffs separately from status. Block
   pending or blocked delivery, open handoffs, missing evidence, destination
   conflicts, malformed packets, and contradictory reports.
7. Do not edit any file while reviewing. Emit concise workspace-relative
   findings without secrets or raw provider payloads.

A clean review emits:

```text
REVIEW: PASS: <slug>
```

Any failed gate emits:

```text
REVIEW: BLOCKED: <slug>: <task, requirement, path, or concrete reason>
```

A missing packet is `REVIEW: BLOCKED: <slug>: packet missing`; an invalid slug
is `REVIEW: BLOCKED: invalid task slug`; an invalid suffix is
`REVIEW: BLOCKED: expected no suffix or ship`. Review leaves packet and Git bytes
unchanged in every outcome.

## Explicit ship phase

For `/sf-review <slug> ship`, complete the entire review immediately before
archiving. If any review gate fails, emit:

```text
SHIP: BLOCKED: <slug>: <concrete reason>
```

and do not call the archive workflow or move anything. A canonical completed
status, missing report evidence, pending or blocked checkpoint, or existing
archive destination is a blocker. Do not repair status, reports, memory, or
checkpoints as part of ship.

After a fresh PASS, use the existing archive skill and its classifier with the
exact reviewed slug:

```text
/sf-archive-tasks --slug <slug>
```

The target filter must be present. It limits classification, movement, and report
entries to that one slug; never run an unfiltered sweep for explicit ship. Honor
`DONE` only from the bundled classifier. Move the complete packet locally to
`.spec-finder/tasks_done/` using the archive skill's existing tracked/untracked
rules, refuse an existing destination without overwrite, and preserve all task
bytes. If classification or movement fails, emit `SHIP: BLOCKED` with the named
failure and leave the source recoverable. Do not write task status.

Only after the exact target has been archived successfully emit:

```text
SHIP: COMPLETE: <slug>
```

No ship outcome authorizes a remote operation.
