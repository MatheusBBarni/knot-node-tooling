---
title: Only Prompt if stdin is a TTY
impact: HIGH
impactDescription: Prevents scripts from hanging on prompts
tags: interactivity, tty, prompts, scripting, automation
---

## Only Prompt if stdin is a TTY

Only prompt when running interactively. In scripts, fail with clear error.

**Incorrect (hangs in scripts):**

```
$ cat deploy.sh
#!/bin/bash
mycmd deploy

$ ./deploy.sh
Continue? [y/N]:
(hangs forever - no one to answer)
```

**Correct (detects non-interactive):**

```
$ ./deploy.sh

Error: Use --force in non-interactive mode

Usage: mycmd deploy --force
```

**Interactive mode works:**

```
$ mycmd deploy
Continue? [y/N]: y
✓ Deployed
```

**Non-interactive with flag:**

```
$ mycmd deploy --force
✓ Deployed
```

**Check stdin TTY:**

```typescript
if (process.stdin.isTTY) {
  // Can prompt
} else {
  // Require flags
}
```

**Always provide --no-input:**

```
$ mycmd deploy --no-input
Error: --env required with --no-input
```

**In CI:**

```yaml
- run: mycmd deploy --no-input --env prod --force
```
