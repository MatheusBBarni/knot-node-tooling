---
name: sf-memory
description: Maintains packet-wide and per-task workflow memory inside Spec Finder task packets. Use when initializing, reading, updating, compacting, or promoting durable context during task execution and reporting.
---

# Maintain Spec Finder Memory

Use these fixed paths for the active packet:

- Shared memory: `.spec-finder/tasks/<slug>/memory/MEMORY.md`
- Current task memory: `.spec-finder/tasks/<slug>/memory/task_NN.md`

## Workflow

1. Resolve the packet directory and current `task_NN.md` from the caller. Do not guess when either is ambiguous.
2. Initialize missing memory files from `references/memory-guidelines.md`. Never overwrite an existing memory file during initialization.
3. Before implementation, read the shared and current-task memory files. Treat them as required context.
4. During the task, update current-task memory when the objective changes, a non-obvious decision is made, an important learning appears, an error changes the plan, or a touched surface matters to the next run.
5. Promote an item to shared memory only when it is durable, useful to another task, and not already obvious from the repository or specification packet.
6. Before completion, reporting, handoff, or commit, update both files as needed and remove stale task-local notes.

## Rules

- Record facts only; never invent history, status, decisions, or evidence.
- Keep task-local execution detail out of shared memory.
- Do not copy large code blocks, stack traces, command transcripts, or task specifications.
- Do not read unrelated task memory files unless shared memory explicitly points to them.
- Trust repository and task artifacts over stale memory, then correct the memory.
- Preserve existing headings when compacting.

## Promotion test

Promote a task-memory item only when all answers are yes:

1. Will another task need it to avoid a mistake or rediscovery?
2. Is it durable across multiple runs?
3. Is it absent from the PRD, TechSpec, task files, and repository?

Read `references/memory-guidelines.md` when initializing files, compacting memory, or deciding whether an item is shared or task-local.
