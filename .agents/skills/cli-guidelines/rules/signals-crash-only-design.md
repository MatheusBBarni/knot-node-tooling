---
title: Design for Crash-Only Operation
impact: MEDIUM-HIGH
impactDescription: Program can be killed at any time without corruption
tags: signals, robustness, crash-only, recovery, cleanup
---

## Design for Crash-Only Operation

Design your CLI to be safely killed at any time. Don't rely on cleanup running.

**Crash-safe behavior:**

```
$ mycmd process
Processing...
^C
(killed mid-operation)

$ mycmd process
Cleaning up from previous run...
Resuming from item 45/100...
✓ Done
```

**Use atomic operations:**

```typescript
// Atomic file write - never leaves partial file
fs.writeFileSync(tempPath, content)
fs.renameSync(tempPath, finalPath) // Atomic
```

**Clean up stale state on startup:**

```
$ mycmd start

Detected stale lock file from crashed run
Cleaning up...
Starting fresh...
```

**Check for lock files:**

```typescript
if (fs.existsSync('.mycmd.lock')) {
  const pid = fs.readFileSync('.mycmd.lock', 'utf-8')
  if (!isProcessRunning(pid)) {
    console.error('Cleaning up from previous crashed run...')
    fs.unlinkSync('.mycmd.lock')
  }
}
```

**Principles:**

- Clean up in next run, not during shutdown
- Use atomic file operations
- Check for stale state on startup
- Don't require graceful shutdown

Reference: https://lwn.net/Articles/191059/
