# Refinement doctrine

These rules are mandatory on `sf-refinement`.
They are the contract, not style notes.

## Single output only

`sf-refinement` writes exactly one saved artifact: `.spec-finder/refinements/<task_slug>.md`.
It never writes `.spec-finder/tasks/`, `.spec-finder/specs/`, a runner packet, PRD, TechSpec, task index, task file, ADR, or memory file.
The refinement file must carry digested requirements, decisions, stories, technical specs, test scenarios, and verification evidence.

## Tracker-agnostic intake

Accept a prompt, a pasted ticket, or a ticket URL/identifier from any issue tracker.
Jira, Linear, GitHub Issues, GitLab, Azure Boards, and similar sources are equivalent.
Fetch with whatever tools exist for that tracker.
If fetch fails, ask the user to paste the body.
Do not require a Feature key, cloud id, project key, or issue type from any vendor.
Do not create, update, link, or close tracker tickets.

## Language is inherited, not chosen

Do not require Portuguese.
Do not require English narrative.
Do not translate the source unless the user asks.
Keep English section headings as the file schema.
Write the body in the language of the source prompt, ticket, or user replies.

## Code first

No stories without a current-system ledger from the actual repositories.
Cite verified paths, callers, tests, and short current-code excerpts labeled as evidence of now, not as the fix.
If a repository is unavailable, mark those paths unverified. Do not guess.

## Digested requirements before stories

Present the full understanding and obtain explicit approval before generating stories.
Unresolved product gaps that block coding stay marked TBD.
Do not silently fill them.

## Split by user flow, then repository

Each flow is independently shippable.
Inside a flow, one ticket per repository.
Frontend work is a Story. Backend work is a Task.
Do not emit one catch-all backend ticket and one catch-all frontend ticket.

## Specs are for an implementing agent

Every ticket includes:

- verifiable acceptance
- impact analysis with named services, files, or screens
- only relevant non-functional requirements
- verified reference files
- create / modify / do-not
- concrete test signatures
- exact verification commands from that repository
- API contracts when the ticket crosses a network boundary

Negative constraints matter as much as the work to do.
Agents over-engineer; tell them what not to invent.

## Research, then ask, then approve, then write

Research the repository before any question.
Ask only remaining material decisions, one at a time.
Write nothing until the user explicitly approves one complete draft that passes `quality-bar.md`.
