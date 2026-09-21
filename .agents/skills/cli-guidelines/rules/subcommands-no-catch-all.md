---
title: Don't Have Catch-All Subcommands
impact: MEDIUM
impactDescription: Prevents breaking changes when adding commands
tags: subcommands, future-proofing, api-design, parsing
---

## Don't Have Catch-All Subcommands

Don't make unknown commands default to a subcommand. Prevents adding commands later.

**Problem:**

```
# Version 1.0: unknown commands default to 'run'
$ mycmd echo "hello"
(runs: mycmd run echo "hello")

# Version 2.0: you add 'echo' subcommand
$ mycmd echo "hello"
(now runs the NEW echo command - BREAKS scripts!)
```

**Correct (explicit subcommands only):**

```
$ mycmd echo "hello"
Error: Unknown command 'echo'

Did you mean: mycmd run echo "hello"
```

**Require explicit subcommand:**

```
$ mycmd run echo "hello"
hello

$ mycmd r echo "hello"  # Explicit alias OK
hello
```

**npm example (requires explicit 'run'):**

```
$ npm build
Error: Unknown command 'build'

Did you mean: npm run build
```

**Provide helpful error:**

```
$ mycmd unknown-cmd
Error: Unknown command 'unknown-cmd'

Did you mean: mycmd run unknown-cmd?

Run 'mycmd --help' for available commands
```

**Benefits:**

- Can add new commands without breaking scripts
- Explicit is better than implicit
- No ambiguity
