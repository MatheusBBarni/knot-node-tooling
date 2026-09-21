---
title: Make Operations Idempotent
impact: MEDIUM
impactDescription: Safe to retry, arrow-up and enter works
tags: robustness, idempotency, reliability, recovery
---

## Make Operations Idempotent

Running an operation twice should have the same effect as running it once.

**Good idempotent behavior:**

```
$ mycmd deploy
Deploying...
✓ Deployed

$ mycmd deploy
Already deployed, checking for updates...
No changes detected.
✓ Up to date
```

**Handles retry after failure:**

```
$ mycmd setup
Creating directory...
Installing dependencies...
Error: Network timeout

$ mycmd setup
Directory already exists, skipping...
Installing dependencies...
✓ Setup complete
```

**Check existing state:**

```
$ mycmd init myproject
Error: Directory 'myproject' already exists

Use --force to overwrite, or choose different name
```

**Atomic operations prevent partial state:**

```typescript
// Write to temp file, then atomic rename
fs.writeFileSync(tempPath, content)
fs.renameSync(tempPath, finalPath) // Atomic
```

**Benefits:**

- Just hit up-arrow and enter to retry
- No cleanup needed after failures
- Safe to run multiple times
