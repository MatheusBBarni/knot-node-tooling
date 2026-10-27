# Refinement quality bar

Apply this bar before presenting and after saving `.spec-finder/refinements/<task_slug>.md`.
Reject and rewrite if any item fails.
Do not present a failing file.
Every template token such as `<task_slug>` or `[Title]` must be replaced.

## Iron law

```
NO FILE WITHOUT CODE EXPLORATION.
NO PATH WITHOUT VERIFICATION.
NO STORIES WITHOUT DIGESTED-REQUIREMENTS APPROVAL.
NO RUNNER PACKET OUTPUT.
NO LANGUAGE MANDATE.
NO TRACKER VENDOR LOCK.
```

## Fail the file when

- It was written before digested-requirements approval and whole-draft approval.
- The write set is anything other than `.spec-finder/refinements/<task_slug>.md`.
- `.spec-finder/tasks/` or `.spec-finder/specs/` were created or changed.
- Portuguese section titles are required, or the body was translated without being asked.
- Intake or output assumes Jira, Linear, or any one tracker.
- Tracker tickets were created.
- A file path, endpoint, or pattern was not verified and is not marked unverified.
- Work is split only by layer instead of by user flow then repository.
- Any acceptance line is "works correctly", "handle errors", or another untestable phrase.
- A ticket lacks Read first, Do not, test signatures, or exact DONE commands.
- A ticket lacks Impact with named areas, or includes NFRs that do not apply.
- Test scenarios omit happy path, validation, or error handling.
- Writer instructions or template placeholders remain.

## Pass only when

- Source kind, tracker (or none), identifier, URL, and language are recorded.
- Digested requirements, decisions, in/out scope, repo breakdown, and sequencing are present.
- Each ticket is one repo, one flow, and independently shippable once its blockers land.
- Frontend tickets are Stories and backend tickets are Tasks.
- Reference files exist or are marked unverified.
- Out of scope is not contradicted by in scope.
- Verification summary is present.
- An implementing agent can execute a ticket from this file plus the repository without chat history.
