---
title: Support --no-input Flag
impact: MEDIUM
impactDescription: Allows explicit disabling of all prompts
tags: interactivity, flags, automation, scripting
---

## Support --no-input Flag

Provide `--no-input` to explicitly disable all prompts for CI/CD.

**Without --no-input (hangs in CI):**

```
$ mycmd deploy
Environment [staging/production]:
(waits forever in CI - no one to answer)
```

**With --no-input (fails fast with clear error):**

```
$ mycmd deploy --no-input
Error: --env is required when using --no-input

Usage: mycmd deploy --env <env> --no-input
```

**Correct usage in automation:**

```
$ mycmd deploy --env staging --no-input --yes
Deploying to staging...
✓ Deployed successfully
```

**In CI/CD:**

```yaml
# GitHub Actions
- name: Deploy
  run: mycmd deploy --env production --no-input --force
```

**Rules:**

- Fail immediately if required input missing
- Provide clear error showing which flags are needed
- Skip all confirmation prompts
- Works even when stdin is TTY
