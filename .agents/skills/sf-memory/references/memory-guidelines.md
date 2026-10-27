# Spec Finder Workflow Memory Guidelines

## File roles

### Shared memory: `memory/MEMORY.md`

Keep cross-task state, durable decisions, reusable learnings, open risks, and handoffs. Avoid scratch notes and facts already explicit in the packet or repository.

Initialize with:

```markdown
# Workflow Memory

## Current State

## Shared Decisions

## Shared Learnings

## Open Risks

## Handoffs
```

### Current task memory: `memory/task_NN.md`

Keep task-local decisions, learnings, touched surfaces, errors, corrections, and next-run notes. Do not repeat the full task specification.

Initialize with:

```markdown
# Task Memory: task_NN

## Objective Snapshot

## Important Decisions

## Learnings

## Files / Surfaces

## Errors / Corrections

## Ready for Next Run
```

## Promotion

Promote an item from task memory only when it is durable across runs, useful to another task, and likely to prevent repeated mistakes or rediscovery.

## Compaction

When memory becomes noisy:

1. Compact shared memory before task memory.
2. Preserve current state, durable decisions, reusable learnings, open risks, and handoffs.
3. Remove repetition, stale notes, long transcripts, and derivable facts.
4. Rewrite retained items as concise factual bullets.
5. Keep the default headings intact.
