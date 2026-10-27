# Spec quality bar

Read this before drafting and again before presenting the spec.
This bar applies to `.spec-finder/tasks/<slug>/_spec.md`.
The saved file is the prompt the operator will point an agent at.
Reject and rewrite the spec if any item fails.

## Iron law

```text
NO PROMPT WITHOUT CURRENT-SYSTEM EVIDENCE.
NO FILE PATHS WITHOUT VERIFICATION.
NO ALGORITHM THAT STEALS THE AGENT'S JOB.
NO AMBIGUOUS SUCCESS.
NO BOILERPLATE SECTION THAT DOES NOT CHANGE EXECUTION.
NO PLACEHOLDERS IN THE SAVED SPEC.
NO RUNNER PACKET OUTPUT.
```

## Reject if

- Outcome is "make it better", "clean it up", "add support for X", or "follow best practices".
- Current and desired observable behavior are not distinguished.
- A Repository Anchors row uses a guessed path, omits the relevant fact, or lacks an execution reason.
- The spec contains after-code, a patch, or a private step-by-step algorithm the executor should choose.
- The spec tells `sf-write-spec` to create `.spec-finder/specs/`, `_techspec.md`, `_tasks.md`, `task_NN.md`, ADRs, or memory files, or to modify `_prd.md`.
- Fewer than two **Never** lines remain in Implementation boundaries.
- Implementation omits the six-question cap, one-question-per-turn rule, recommendation-first labeled choices, or allowed material decision categories.
- Implementation questions can reopen approved product decisions, ask repository facts, or solicit private implementation preferences.
- The saved spec omits the user's explicit Git commit-cadence choice, enables intermediate commits without opt-in, or permits staging unrelated changes or ignored packet files.
- Acceptance lacks Given/When/Then, observable results, or a materially applicable failure or recovery path.
- Verification lacks an exact focused command, repository gate, or runtime proof.
- A section is one vague sentence or retained boilerplate that does not change executor behavior.
- A conditional section remains as `Not applicable` instead of being deleted.
- Writer-facing template prose remains.
- Any `[…]` fill-in token or `<slug>` remains; every template token must be replaced.
- The executor would need a repo-wide hunt before it can start.
- An approved PRD exists and an in-scope `F-xx` or `US-xx` is neither mapped nor explicitly excluded with the PRD rationale.
- The spec tells the executor to read the PRD instead of carrying its implementation-relevant decisions.
- An approved PRD exists but the spec omits `Product source: .spec-finder/tasks/<slug>/_prd.md`, or the skill modifies that PRD.

## Core sections

| Section | Minimum that earns the heading |
|---|---|
| Implementation | Start procedure, bounded question protocol, task-specific Always / Ask first / Never, smallest coherent diff, and stop rule. |
| Problem and Delta | Current and desired observable behavior, affected user or operator, and why the delta matters. |
| Scope | Out before In, mapped capabilities, and preserved behavior or compatibility invariants. |
| Acceptance | Given/When/Then for success and every materially applicable invalid, conflict, permission, failure, or recovery path. |
| Repository Anchors | Verified path or symbol, current fact, why inspect, and expected role (`read`, `edit`, or `create`). |
| Verification | Exact focused command, repository gate, and runtime proof with expected observations. |
| Output | Changed behavior and files, acceptance evidence, command/runtime results, decisions, and unresolved blockers. |

## Conditional sections

| Section | Include only when | Required content |
|---|---|---|
| Contract Changes | A public interface, persisted shape, configuration, CLI, protocol, or observable error changes. | Repository-language contract plus valid and invalid examples and observable errors. |
| Risks and Edge Cases | Acceptance does not already capture a material risk. | Named case, detection, observable behavior, recovery or preservation, and evidence. |
| Milestones | One coherent outcome requires multiple ordered verification points. | Independently verifiable outcome, acceptance IDs, command, and dependencies. |

Delete a conditional section when it does not earn its tokens.
Split independent outcomes into separate specs rather than adding milestones indefinitely.

## Bad versus good

Bad Repository Anchor:

> Update `src/engine.ts` as needed.

Good:

> `src/engine.ts#runTaskPacket` currently performs one pass; inspect it to preserve the single-pass `run` contract while adding the new entry point.

Bad contract:

> The CLI should accept a loop command.

Good:

```text
spec-finder loop <task_slug> [--dry-run] [--max-iterations N]
```

- Valid: `spec-finder loop demo --dry-run` → prints plan, writes nothing, exit 0.
- Invalid: `spec-finder loop --multiple a,b` → exit 2, usage, no lock, no writes.

Bad Never:

> Do not do anything risky.

Good:

> Never change `spec-finder run` grammar or single-pass behavior.
> Never add a required config key.

## Greenfield

When a file does not exist yet, mark its Repository Anchors role `create`.
Still cite the adjacent module, test, and convention the new file must follow.
Do not invent a parallel architecture.
