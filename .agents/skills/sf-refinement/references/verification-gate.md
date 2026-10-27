# Verification gate

Run after the draft exists and before presenting it.
Do not deliver a draft that fails this gate.

## Path checks

For every ticket:

- Every Read first path exists, or is marked unverified with why.
- Every file to modify exists, and the cited function or section exists.
- Every file to create has an existing parent directory, and is not already a modify.
- Every new endpoint is not an unnoticed duplicate of an existing method + path.
- Test directories and naming match that repository.
- DONE commands are copied from that repository, not invented.

## Independent review

Dispatch a reviewer subagent when the runtime can do real parallel work.
The reviewer must read the cited files, not trust the draft.

Check:

1. Completeness — every acceptance line has a matching implementation detail
2. Consistency — tickets do not contradict or overlap
3. Dependencies — sequencing is backward-only and accurate
4. Negative constraints — every ticket has Do not
5. Testability — signatures are implementable
6. Code evidence — claims match the repository

If real delegation is unavailable, perform the same checklist yourself and say so.

## Output block

Add a Verification section to the refinement file:

```
## Verification

- Reference files confirmed: [n/n]
- Files to create: parent directories confirmed
- Files to modify: confirmed existing
- Endpoint conflicts: [none or list]
- Unverified paths: [none or list]
```

## Failures

| Failure | Action |
|---|---|
| Path does not exist | Fix with search, or mark unverified |
| Reference file does not show the claimed pattern | Cite a better file |
| Endpoint conflict | Ask with lettered choices |
| Test convention mismatch | Match the repo |
| Contradiction across tickets | Fix before presentation |
| Repo unavailable | Mark unverified; do not invent |

Never skip the gate.
Never deliver known failures as if verified.
