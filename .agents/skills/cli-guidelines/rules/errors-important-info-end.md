---
title: Put Important Info at End of Output
impact: MEDIUM
impactDescription: Users naturally look at the last line first
tags: errors, output, ux, attention
---

## Put Important Info at End of Output

Place the most important information at the end. Users' eyes go there first.

**Incorrect (solution at top - user misses it):**

```
$ mycmd deploy

Fix: Run 'mycmd login' first

Deployment failed with error:
  Error code: AUTH_REQUIRED
  Status: 401 Unauthorized
  (20 more lines of debug info...)

Error: Not authenticated
```

**Correct (solution at end - user sees it):**

```
$ mycmd deploy

Error: Not authenticated
Unable to deploy without credentials.

Run: mycmd login
```

**Visual hierarchy:**

```
$ mycmd build

Error: Missing dependency 'libfoo'

Install: apt install libfoo
         ^^^ User's eyes go here
```

**For multiple errors:**

```
$ mycmd validate

Found 3 errors in config.json:
  - Line 5: invalid syntax
  - Line 12: missing field
  - Line 18: unknown property

Fix these errors and run again
                   ^^^ Clear next step
```

**Use red text sparingly:**

- Only for actual errors
- Don't rely on color alone
- Keep important info readable without color
