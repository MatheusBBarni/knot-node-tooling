# Ticket format

Each ticket inside `.spec-finder/refinements/<task_slug>.md` is self-contained for one repository.
An agent working that ticket must not need another ticket's body.

Frontend work is a **Story**. Backend work is a **Task**.
These are labels, not issue-tracker types.

Write the body in the source language. Keep the headings below in English.

## User story

```
### [STORY|TASK] [Title]

As [persona], I want [action] so that [benefit].

#### Context
- Why this ticket exists
- Source: [prompt or tracker identifier/URL]
- Related tickets in this file

#### Acceptance
- [ ] When [action], then [expected result]
- [ ] [Named error] shows [exact observable message or state]

#### Out of scope
- [Adjacent work that belongs in another ticket]

#### Impact
- Backend: [service or module, or none]
- Frontend: [screen or component, or none]
- Shared: [library or schema consumers, or none]

#### Non-functional
Include only categories that apply: performance, security, scalability, observability, reliability.
Do not include accessibility unless the source requires it.
```

Every acceptance line must be observable. Reject "works correctly".

## Technical spec

```
#### Done when
- [ ] Unit tests covering new code: `[exact command]`
- [ ] Lint: `[exact command]`
- [ ] Build: `[exact command]`

#### Repo
[repo-name] — [language, framework]

#### Read first
- `path/to/PatternFile.ext` — pattern for [what]

#### Create
**`path/to/NewFile.ext`**
- Responsibility
- Public types
- Loading / error / empty / success behavior

#### Modify
**`path/to/ExistingFile.ext`**
- Function or section
- Before → after if helpful

#### Do not
- DO NOT create [thing] — use existing [alternative]
- DO NOT modify [out-of-scope file]
- DO NOT add [library]
- DO NOT implement [other flow]

#### Tests — create in `path/to/tests/`
Concrete signatures that match that repo's runner and naming.

#### API contract
Only when this ticket introduces or changes a network boundary.
Method, path, headers, request, 200, and error shape.
```

## Anti-patterns

| Avoid | Write instead |
|---|---|
| "Implement as appropriate" | Behavior per state |
| "Follow best practices" | `Read first` with a verified path |
| "Add tests" | Exact signatures |
| "Handle errors" | Named error and observable result |
| "Similar to feature X" | Path and lines to read |
| Guessed `src/...` | Verified path or `unverified` |
