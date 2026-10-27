# TDD Doctrine

Origin: Matt Pocock's TDD skill. This bundled copy is the runtime source after setup. The external skill and any user-global path are not dependencies.

TDD is the red → green loop. Apply every rule on every cycle.

## Tests specify behavior

A good test describes observable behavior through a public interface and survives internal refactoring. Its name states the capability, not the implementation. Expected values come from an independent source of truth: a known literal, worked example, approved contract, or specification. Never recompute the expected value with the production algorithm.

## Public seams

A seam is the public boundary where behavior is observed without reaching inside. Tests live at seams, never against private methods or internal collaborators.

The implementation executor uses confirmed seams without reopening them unless repository evidence invalidates a seam. In that case, use the saved spec's bounded implementation-question protocol before changing the seam.

## Mocking

Mock at system boundaries only: external APIs, time or randomness, and databases or filesystems when a real isolated boundary is impractical. Do not mock code owned by the module under test. Prefer integration-style tests through real public interfaces.

## Stop conditions

- **Implementation-coupled:** private methods, internal collaborator mocks, call counts, or side-channel verification.
- **Tautological:** the assertion derives its expected value through the same logic as production.
- **Horizontal slicing:** all tests first and all implementation later.
- **Unexpected pass:** the red command passes before implementation, so the test does not prove the missing behavior.
- **Failed green:** the same focused command remains red after the minimal implementation.

Stop the current slice when one occurs. Never weaken a test to conceal it.

## Rules of the loop

- **Red before green.** Write one failing public-seam test. Run its focused command to terminal exit and require failure for the intended missing behavior.
- **Minimal green.** Add only enough production behavior to pass that test. Run the same focused command to terminal exit and require success.
- **One slice at a time.** Finish red then green for one vertical outcome before writing the next test.
- **No speculative behavior.** Do not anticipate later slices.
- **No refactoring in the loop.** Review and refactor only after every planned slice is green, preserving all observable behavior.
- **No test theater.** When no public behavior changes, state that TDD is not applicable rather than inventing a hollow test.
