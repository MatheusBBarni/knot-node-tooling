# TDD Doctrine

Origin: maintainer `/tdd` skill. This copy is the runtime source after setup. Do not require that path to be installed.

TDD is the red → green loop. These rules apply on every cycle.

## What a good test is

A good test is a behavior spec at a public seam. It names an observable capability ("user can checkout with valid cart"), uses only the public interface, and survives refactors because it does not care about internal structure. Expected values come from an independent source of truth — a known literal, a worked example, or the spec — not from recomputing the implementation.

## Seams

A **seam** is the public boundary where behavior is observed without reaching inside. Tests live at seams, never against internals.

**Spec Finder override of upstream `/tdd`:** do not ask the user to confirm seams. Derive seams from the approved task, TechSpec, ADRs, and any existing `## TDD Plan`. Proceed with those derived seams. Review happens through the plan section, memory notes, and the TDD report — not a letter-choice gate.

## Anti-patterns (stop conditions)

Stop the current slice when any of these appear. Do not treat them as later cleanup.

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel. The tell: the test breaks when you refactor but behavior has not changed.
- **Tautological** — the assertion recomputes the expected value the way the code does, so it passes by construction and can never disagree with the code.
- **Horizontal slicing** — writing all tests first, then all implementation. Bulk tests verify imagined shape, not observed behavior. Work **vertical slices**: one failing test → one minimal implementation → repeat.

## Rules of the loop

- **Red before green.** Write the failing public-seam test first. Run the focused command and require failure for the intended missing behavior. Only then write enough production code to pass the same command identity. Do not anticipate future tests.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **No theater.** If the task has no new or changed product behavior, record not-applicable with a one-line reason. Do not invent a hollow red test.
