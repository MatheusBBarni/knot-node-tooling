---
title: Provide Full-Length Flag Versions
impact: CRITICAL
impactDescription: Improves script readability and self-documentation
tags: basics, flags, arguments, readability
---

## Provide Full-Length Flag Versions

Every flag should have both short (`-v`) and long (`--verbose`) versions. Long versions make scripts self-documenting.

**Incorrect (short flag only):**

```bash
# What does -v mean? Have to look it up
mycmd deploy -v

# Unclear in scripts
#!/bin/bash
mycmd process -v -q -f
```

**Correct (both short and long):**

```typescript
import { Command } from 'commander'

const program = new Command()
program
  .option('-v, --verbose', 'verbose output')
  .option('-q, --quiet', 'suppress output')
  .option('-f, --force', 'force operation')
  .parse(process.argv)
```

Now scripts are readable:

```bash
#!/bin/bash
mycmd process --verbose --quiet --force
# Clear what each flag does
```

**Benefits:**

- Scripts are self-documenting
- No need to look up flag meanings
- Easier to review and maintain
- Both forms work identically

```bash
# These are equivalent
mycmd deploy -v -f
mycmd deploy --verbose --force
mycmd deploy --verbose -f  # Can mix
```

**Other languages:**

```go
// Go with Cobra
cmd.Flags().BoolP("verbose", "v", false, "Verbose output")
```

```python
# Python with Click
@click.option('-v', '--verbose', is_flag=True)
```
