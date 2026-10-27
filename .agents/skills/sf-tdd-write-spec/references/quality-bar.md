# TDD spec quality bar

Apply this bar before presenting and after saving `.spec-finder/tasks/<slug>/_spec.md`.

## Iron law

```text
NO PROMPT WITHOUT CURRENT-SYSTEM EVIDENCE.
NO TEST PLAN WITHOUT CONFIRMED PUBLIC SEAMS.
NO GREEN WITHOUT AN OBSERVED RED.
NO HORIZONTAL TEST BATCH.
NO IMPLEMENTATION-COUPLED OR TAUTOLOGICAL TEST.
NO BOILERPLATE SECTION THAT DOES NOT CHANGE EXECUTION.
NO EXTERNAL TDD SKILL DEPENDENCY.
NO ARTIFACT EXCEPT THE SPEC.
NO PLACEHOLDERS IN THE SAVED SPEC.
```

## Reject if

- Outcome, current behavior, desired behavior, or preserved behavior is ambiguous.
- A Repository Anchors path is guessed rather than verified or marked `create`.
- A proposed test seam was not explicitly confirmed by the user.
- Implementation omits the six-question cap, one-question-per-turn rule, recommendation-first labeled choices, or allowed material decision categories.
- Implementation can reopen a confirmed seam without conflicting repository evidence.
- The saved spec omits the user's explicit Git commit-cadence choice, enables intermediate commits without opt-in, or permits staging unrelated changes or ignored packet files.
- A test reaches a private method, mocks an internal collaborator, or verifies through a side channel.
- An expected value is computed with production logic instead of an independent literal, example, or contract.
- Tests are written as a horizontal batch before implementation.
- Any slice lacks one test, an intended red reason, minimal green behavior, or the same exact focused command for both states.
- A later slice starts before the current slice is green.
- Refactoring occurs inside a red-green slice.
- A mock is used away from a system boundary.
- A red command can pass before implementation without stopping the slice.
- The spec tells the executor to load or invoke an external TDD skill.
- The workflow creates `.spec-finder/specs/`, a TechSpec, task file, ADR, report, or memory artifact, or modifies an approved `_prd.md`.
- An approved PRD exists and an in-scope `F-xx` or `US-xx` is neither mapped nor explicitly excluded with the PRD rationale.
- The spec tells the executor to read the PRD instead of carrying its implementation-relevant decisions, or omits that PRD's exact path as Product source.
- Acceptance omits a materially relevant invalid, empty, conflict, permission, or recovery path.
- Exact focused commands, repository gate, or runtime proof are absent.
- A conditional section remains as `Not applicable` instead of being deleted.
- Writer instructions, fill-in tokens, or `<slug>` remain.

## Core sections

| Section | Required content |
|---|---|
| Implementation | Start procedure, bounded question protocol, task-specific boundaries, ordered slice execution, and stop rule. |
| Problem and Delta | Current and desired observable behavior, affected user or operator, and why the delta matters. |
| Scope | Out before In, mapped capabilities, and preserved behavior or compatibility invariants. |
| Acceptance | Observable Given/When/Then success plus every materially applicable failure or recovery path. |
| Repository Anchors | Verified path or symbol, current fact, why inspect, and expected role. |
| Public Test Seams | Confirmed public interface, observable behavior, test location, exact command, and why it is public. |
| TDD Execution | Red, minimal green, same command, vertical ordering, stop conditions, and boundary-only mocking. |
| TDD Slices | One observable outcome with Given/When/Then, one seam, one test, red reason, minimal green, and exact command. |
| Verification | Focused commands, repository gate, and runtime proof with expected observations. |
| Review | Refactoring only after all slices are green, followed by focused, repository, and runtime verification. |
| Output | Per-slice red/green evidence, changed behavior and files, acceptance, gate/runtime results, decisions, and blockers. |

## Conditional sections

| Section | Include only when | Required content |
|---|---|---|
| Contract Changes | A public interface, persisted shape, configuration, CLI, protocol, or observable error changes. | Repository-language contract plus valid and invalid examples and observable errors. |
| Risks and Edge Cases | Acceptance and TDD Slices do not already capture a material risk. | Named case, detection, observable behavior, recovery or preservation, and evidence. |

Delete a conditional section when it does not earn its tokens.
A spec passes only when an executor can perform each red-green cycle without chat history or an external TDD skill.
