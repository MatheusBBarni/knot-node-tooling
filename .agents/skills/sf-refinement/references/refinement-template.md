# Refinement: [Title]

- **Slug:** `<task_slug>`
- **This file:** `.spec-finder/refinements/<task_slug>.md`

## Source

- **Kind:** prompt | pasted-ticket | tracker-ticket
- **Tracker:** none | jira | linear | github | gitlab | azure-boards | other ([name])
- **Identifier:** [id or none]
- **URL:** [url or none]
- **Language:** [language of the source body]

## Digested requirements

[3-6 sentences: who, current workflow, failure, desired outcome]

## Decisions

| Decision | Choice | Why |
|---|---|---|
| [decision] | [choice] | [evidence] |

## Scope

### In

- [behavior]

### Out

- [excluded behavior] — [reconsideration trigger]

## Repository breakdown

### [repo-name]

- [what changes here]

## Sequencing

1. [first ticket] — [why it is first]
2. [next ticket] — blocked by [previous]

## Tickets

### [STORY|TASK] [Title]

As [persona], I want [action] so that [benefit].

#### Context

- [why]
- Source: [identifier or prompt]
- Related: [other tickets in this file]

#### Acceptance

- [ ] **Given** [precondition] **When** [action] **Then** [observable result]

#### Out of scope

- [adjacent work]

#### Impact

- Backend: [named service or none]
- Frontend: [named screen or none]
- Shared: [named module or none]

#### Non-functional

- [only relevant NFRs]

#### Done when

- [ ] `[exact test command]`
- [ ] `[exact lint command]`
- [ ] `[exact build command]`

#### Repo

[repo-name] — [stack]

#### Read first

- `path/to/file.ext` — [pattern] (current evidence, not the fix)

#### Create

- `path/to/new.ext` — [responsibility]

#### Modify

- `path/to/existing.ext` — [function or section]

#### Do not

- DO NOT [specific over-engineering]

#### Tests

```
describe('[unit]', () => {
  it('[observable behavior]')
})
```

#### API contract

[omit this heading when the ticket has no network boundary]

## Test scenarios

### Happy path

#### CT-01: [title]

| Field | Value |
|---|---|
| Priority | High |
| Type | Functional |
| Risk | High |

**Steps:**

Given [precondition]
When [action]
Then [result]

### Validation

#### CT-02: [title]

Given [precondition]
When [invalid input]
Then [observable rejection]

### Error handling

#### CT-03: [title]

Given [precondition]
When [failure]
Then [observable error]

## Open questions

- [TBD] [gap] — [why it blocks or does not block coding]

## Verification

- Reference files confirmed: [n/n]
- Files to create: parent directories confirmed
- Files to modify: confirmed existing
- Endpoint conflicts: [none or list]
- Unverified paths: [none or list]
