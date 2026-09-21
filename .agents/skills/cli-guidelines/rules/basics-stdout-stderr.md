---
title: Use stdout and stderr Correctly
impact: CRITICAL
impactDescription: Required for composability and script integration
tags: basics, stdout, stderr, output, piping
---

## Use stdout and stderr Correctly

Send primary output to `stdout` and messages/errors to `stderr`. This enables piping and script composition.

**Incorrect (everything to stdout):**

```typescript
console.log('Processing file...')
console.log('Warning: file is large')
console.log(JSON.stringify(result)) // Mixed with messages!
```

**Correct (stdout for data, stderr for messages):**

```typescript
console.error('Processing file...')
console.error('Warning: file is large')
console.log(JSON.stringify(result)) // Clean output to stdout

// Or more explicit
process.stderr.write('Processing file...\n')
process.stdout.write(JSON.stringify(result) + '\n')
```

**Why this matters:**

```bash
# stderr shows to user, stdout goes to file
$ mycmd process file.txt > output.json
Processing file...     # User sees this (stderr)
Warning: file is large # User sees this (stderr)
# JSON output is in output.json (stdout)

# If everything went to stdout:
$ mycmd process file.txt > output.json
# User sees nothing, and output.json contains mixed data/messages
```

**Rules:**

- **stdout**: Primary output, machine-readable data, pipe-able content
- **stderr**: Log messages, progress indicators, warnings, errors, human messaging

**Node.js note:** `console.log()` writes to stdout, `console.error()` writes to stderr.

```bash
# Piping works correctly
mycmd list | grep "pattern" | wc -l
```
