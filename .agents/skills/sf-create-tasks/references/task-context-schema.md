# Spec Finder Task Context Schema

## Required frontmatter

- `status`: `pending`, `in_progress`, `completed`, `done`, `finished`, `failed`, or `blocked`.
- `title`: non-empty and exactly equal to the first H1 title after an optional `Task NN:` prefix.
- `type`: non-empty work-type slug; default to `frontend`, `backend`, `docs`, `test`, `infra`, `refactor`, `chore`, `bugfix`, or `spike` unless repository policy defines another value. Type is the primary deliverable, not the split; do not carve one user outcome into frontend/backend twins.
- `complexity`: `low`, `medium`, `high`, or `critical`.
- `dependencies`: YAML list of task IDs such as `task_01`; use `[]` when empty.

## Optional checkpoint delivery metadata

Task frontmatter may include delivery metadata owned by the task. It is independent from the lifecycle `status` field and may be omitted from older task files:

```yaml
checkpoint:
  state: active
  base_head: 0123456789abcdef0123456789abcdef01234567
  baseline_digest: 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
  paths:
    - src/example.ts
```

- `state` is `active` while delivery is being prepared or `blocked` when delivery failed.
- `base_head` is a 40- or 64-character hexadecimal Git object ID, and `baseline_digest` is a 64-character hexadecimal SHA-256 digest.
- `paths` is a non-empty list of unique repository-relative paths. Absolute paths, `.`/`..` segments, backslashes, and NUL characters are unsafe and invalid.
- A `blocked` record must also contain a non-empty `error`; an `active` record does not contain one.
- `status` remains the lifecycle field. A task with `status: completed` and `checkpoint.state: blocked` is eligible for delivery retry, while completed tasks with absent or non-blocked checkpoint metadata remain skipped.
- Successful delivery clears this optional field. Existing task files without it remain valid and keep the current task ordering behavior.

## Optional report handoff metadata

The runtime may persist report-only recovery state after implementation has succeeded but the required final report could not be completed:

```yaml
handoff:
  phase: report
  error: provider process ended before the report completed
```

- `phase` is strictly `report`; no implementation handoff value is valid.
- `error` is optional, non-empty when present, and limited to 4096 characters.
- This field is runtime-owned. Its presence means the next run resumes only the report handoff and does not rerun implementation.
- Cancellation may leave a report handoff without an error so the verified implementation remains resumable without being mislabeled as a failure.
- A successful final report clears the handoff before the task becomes `completed`. Existing task files without it remain valid.

## Naming and ordering

- Task filenames match `task_\d+.md`, normally zero-padded: `task_01.md`.
- Meta documents use leading underscores: `_idea.md`, `_prd.md`, `_techspec.md`, `_tasks.md`.
- Numeric task IDs are the canonical recommended execution order, assigned only after the logical dependency graph is complete.
- IDs are contiguous from `task_01` through `task_NN` with no gaps in a newly generated packet.
- Dependencies reference existing task IDs, form an acyclic graph, and always point to a strictly lower numeric ID.
- When multiple tasks are simultaneously runnable, order them by critical-path impact, earlier user-visible verification, downstream work unlocked, independently testable shared contracts, risk reduction (spikes before the slices they unblock), and stable source-requirement order.
- Parallelizable tasks retain deterministic numeric positions and are labeled as parallelizable in `_tasks.md`; parallelism never creates forward dependencies.
- Completed aliases are `completed`, `done`, and `finished`.

For regeneration, never silently renumber existing tasks. If current IDs violate this ordering contract, require explicit approval through lettered answers for a renumbering migration covering task files, dependencies, memory files, reports, and `_tasks.md` references.

## Required body sections

New tasks use the current template. Regeneration preserves existing section layouts unless the user explicitly asks to migrate.

- Overview (one user/operator outcome; primary `US-xx` / `F-xx`)
- Source Artifacts
- `<critical>` and `<requirements>` blocks
- Acceptance (Given/When/Then for this slice)
- Out of Scope
- Subtasks
- Implementation Details with Relevant Files and Dependent Files
- Related ADRs when applicable
- Deliverables
- Tests
- Rollout (`N/A` with reason is allowed)
- Success Criteria

Every task also has `memory/task_NN.md` and requires `reports/task_NN.md` before completion. A `spike` still needs a decision criterion, evidence, and a report; product tests may be `Not applicable` with reason.

## Source artifact binding

- `## Source Artifacts` names the task packet's exact repository-relative `.spec-finder/tasks/<actual-slug>/_prd.md` and `.spec-finder/tasks/<actual-slug>/_techspec.md` paths.
- The `<critical>` block repeats those exact paths in its read-before-edit instruction.
- Generated tasks contain neither an unresolved `<slug>` placeholder nor generic-only instructions such as "read the PRD" or "read the TechSpec".
- If the user explicitly approved higher-level tasks without a TechSpec, name the expected packet-local `_techspec.md` path as unavailable and do not direct the executor to search for another TechSpec.
