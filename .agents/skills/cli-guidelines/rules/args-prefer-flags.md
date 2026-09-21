---
title: Prefer Flags Over Positional Arguments
impact: HIGH
impactDescription: Makes CLIs more maintainable and easier to extend
tags: arguments, flags, api-design, extensibility
---

## Prefer Flags Over Positional Arguments

Use flags instead of positional arguments. Flags are explicit, self-documenting, and easier to extend without breaking changes.

**Incorrect (positional args - hard to read):**

```bash
# What do these values mean?
mycmd deploy myapp production us-east-1 true

# Adding new params breaks everything
mycmd deploy myapp production us-east-1 true verbose
```

**Correct (flags - explicit and clear):**

```bash
# Self-documenting
mycmd deploy --app myapp --env production --region us-east-1 --force

# Easy to add new flags without breaking existing usage
mycmd deploy --app myapp --env production --verbose
```

**Exceptions where positional args are OK:**

1. **Simple file operations:**

   ```bash
   rm file1.txt file2.txt file3.txt
   cp source.txt dest.txt
   ```

2. **Primary action on multiple items:**
   ```bash
   mycmd process *.csv  # Works with globbing
   ```

**Benefits of flags:**

- Order doesn't matter: `mycmd --app foo --env prod` = `mycmd --env prod --app foo`
- Can add new flags without breaking scripts
- Self-documenting: clear what each value represents
- Optional parameters are obvious

**Two or more positional args for different things is wrong:**

```bash
# Bad - what's what?
mycmd source-file dest-file format template

# Good - explicit
mycmd convert --input source-file --output dest-file --format json
```

Reference: https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46
