---
title: Make Flags Order-Independent
impact: MEDIUM
impactDescription: Matches user expectations, reduces frustration
tags: arguments, flags, ux, parsing, usability
---

## Make Flags Order-Independent

Flags should work regardless of position. Don't require specific ordering.

**Incorrect (order matters - frustrating):**

```
$ mycmd --verbose deploy
✓ Works

$ mycmd deploy --verbose
Error: Unknown option '--verbose'
(User hits up-arrow to add flag at end - breaks!)
```

**Correct (order doesn't matter):**

```
$ mycmd --verbose deploy
✓ Works

$ mycmd deploy --verbose
✓ Works

$ mycmd deploy --env prod --verbose
✓ Works
```

**Why users expect this:**

```
# Common pattern: hit up-arrow, add flag at end
$ mycmd deploy
Error: missing --env

$ mycmd deploy --env prod
✓ Works
```

**Both should work:**

```bash
mycmd --verbose deploy --env prod
mycmd deploy --env prod --verbose
mycmd deploy --verbose --env prod
```

**Implementation:** Use commander, yargs, or oclif - they handle this by default.

**Global vs local flags both work:**

```
$ mycmd --verbose deploy --force
$ mycmd deploy --force --verbose
```
