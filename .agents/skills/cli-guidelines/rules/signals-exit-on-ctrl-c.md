---
title: Exit Immediately on Ctrl-C
impact: HIGH
impactDescription: Users expect Ctrl-C to always work
tags: signals, ctrl-c, sigint, responsiveness, ux
---

## Exit Immediately on Ctrl-C

When user hits Ctrl-C, respond immediately and exit.

**Good Ctrl-C behavior:**

```
$ mycmd process

Processing files...
^C
Cancelled.
$
(exits immediately)
```

**Allow second Ctrl-C to force quit:**

```
$ mycmd deploy

Deploying...
^C
Gracefully stopping... (press Ctrl+C again to force)
(cleaning up...)
✓ Stopped

# Or if user is impatient:
^C^C
Force quitting!
$
```

**Docker Compose example:**

```
$ docker-compose up
...
^CGracefully stopping... (press Ctrl+C again to force)
```

**Implementation:**

```typescript
process.on('SIGINT', () => {
  console.error('\nCancelled.')
  process.exit(130) // 128 + SIGINT(2)
})
```

**For long cleanup:**

```typescript
let forceQuit = false

process.on('SIGINT', () => {
  if (forceQuit) {
    console.error('\nForce quitting!')
    process.exit(130)
  }
  forceQuit = true
  console.error('\nStopping... (press Ctrl+C again to force)')
  gracefulShutdown()
})
```

**Rules:**

- Say something immediately
- Exit with code 130
- Add timeout to cleanup (max 5s)
- Allow second Ctrl-C to force
