---
title: Check if TTY Before Using Colors/Animations
impact: HIGH
impactDescription: Prevents broken output in pipes and CI/CD
tags: output, tty, colors, animations, piping
---

## Check if TTY Before Using Colors/Animations

Only use colors and animations when outputting to a terminal. They break in pipes.

**With TTY detection (works everywhere):**

```
$ mycmd deploy
✓ Deployed successfully
(shows colors in terminal)

$ mycmd deploy | cat
Deployed successfully
(plain text when piped)
```

**Without TTY detection (breaks):**

```
$ mycmd deploy | cat
^[[32mDeployed successfully^[[0m
(escape codes visible)
```

**Check before colors:**

```typescript
if (process.stdout.isTTY) {
  console.log('\x1b[32mSuccess!\x1b[0m')
} else {
  console.log('Success!')
}
```

**Use chalk (auto-detects):**

```typescript
import chalk from 'chalk'
console.log(chalk.green('Success!'))
// Colors in terminal, plain when piped
```

**Also disable colors when:**

- `NO_COLOR` env var is set
- `TERM=dumb`
- `--no-color` flag passed

**Animations must check TTY:**

```typescript
if (process.stderr.isTTY) {
  showProgressBar()
} else {
  console.error('Processing...')
}
```
