---
title: Don't Allow Arbitrary Abbreviations
impact: MEDIUM
impactDescription: Prevents breaking changes when adding commands
tags: subcommands, abbreviations, future-proofing, aliases
---

## Don't Allow Arbitrary Abbreviations

Don't auto-expand subcommand prefixes. It prevents adding new commands.

**Problem:**

```
# User runs this, expecting 'install'
$ mycmd i
Running: install

# Later you add 'inspect' command
$ mycmd i
Error: Ambiguous command 'i' - could be 'install' or 'inspect'

# Or worse, silently runs wrong command!
```

**Correct (explicit aliases only):**

```
$ mycmd install
✓ Installed

$ mycmd i
✓ Installed  (documented alias)

$ mycmd ins
Error: Unknown command 'ins'
Did you mean 'install'? Use 'i' or 'install'
```

**Explicit aliases are fine:**

```
$ mycmd --help
Commands:
  install, i, add    Install package
  remove, rm         Remove package
```

**kubectl example:**

```
$ kubectl get pods    # Full command
$ kubectl get po      # Documented short form
$ kubectl get p       # Error: unknown resource
```

**Benefits:**

- Can add new commands safely
- Aliases are documented and stable
- No surprising behavior
