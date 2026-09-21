---
title: Suggest Corrections for Typos
impact: MEDIUM
impactDescription: Helps users fix mistakes quickly
tags: help, typos, suggestions, usability, ux
---

## Suggest Corrections for Typos

When users make typos, suggest what they likely meant.

**Incorrect (unhelpful):**

```
$ mycmd pss
Error: Unknown command 'pss'
```

**Correct (suggests fix):**

```
$ mycmd pss

Error: Unknown command 'pss'

Did you mean 'ps'? [y/N]: y

Running: mycmd ps
...
```

**Or without prompt:**

```
$ mycmd pss

Error: Unknown command 'pss'

Did you mean:
  ps - Show processes

Run: mycmd ps
```

**Suggest for flags too:**

```
$ mycmd deploy --quite

Error: Unknown flag '--quite'

Did you mean '--quiet'?
```

**From Homebrew:**

```
$ brew update jq

Error: This command updates brew itself.

Did you mean:
  brew upgrade jq
```

**When to suggest:**

- 1-2 character difference
- Common abbreviations
- Case differences

**Don't auto-run corrections:**

- User might mean something else
- Auto-fix commits to supporting that syntax forever
