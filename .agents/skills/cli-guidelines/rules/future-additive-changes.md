---
title: Keep Changes Additive
impact: MEDIUM
impactDescription: Avoids breaking user scripts and workflows
tags: future-proofing, api-design, compatibility, versioning
---

## Keep Changes Additive

Add new flags and features. Don't change existing behavior.

**Incorrect (breaks existing scripts):**

```bash
# Version 1.0
$ mycmd process --output results.txt

# Version 2.0: --output now means format (BREAKS v1!)
$ mycmd process --output json
(tries to write to file named "json")
```

**Correct (additive):**

```bash
# Version 1.0
$ mycmd process --output results.txt

# Version 2.0: Add new flag, keep old
$ mycmd process --output results.txt --format json
```

**Deprecation warnings:**

```
$ mycmd deploy --old-flag

Warning: --old-flag is deprecated
Use --new-flag instead
--old-flag will be removed in v3.0

Deploying...
```

**What's safe to change:**

- Adding new flags/subcommands
- Adding fields to --json
- Improving human output (if users use --json in scripts)

**What breaks users:**

- Removing flags
- Changing flag behavior
- Removing --json fields
- Changing exit codes
