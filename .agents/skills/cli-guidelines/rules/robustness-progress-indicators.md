---
title: Show Progress for Long Operations
impact: MEDIUM
impactDescription: Prevents users thinking program is frozen
tags: robustness, progress, ux, feedback
---

## Show Progress for Long Operations

Display progress for operations >1 second. Don't leave users wondering if it's frozen.

**Incorrect (silent for 5 minutes):**

```
$ mycmd process files/*.csv
(silence...)
Done
```

**Correct (shows progress):**

```
$ mycmd process files/*.csv

Processing files...
████████████░░░░░░░░░ 45% | 45/100 | ETA: 28s
```

**With spinner:**

```
$ mycmd deploy
⠋ Deploying application... (30s)
```

**Multiple tasks:**

```
$ mycmd setup

Setting up environment...
  ✓ Install dependencies (12s)
  ⠹ Build application (running...)
  ⠿ Start services (waiting...)
```

**Parallel operations:**

```
$ mycmd download

Downloading files...
  ✓ image1.png  [████████████████████] 100% (2.3 MB)
  ⠹ image2.png  [██████████░░░░░░░░░░]  50% (1.1 MB)
  ⠋ image3.png  [████░░░░░░░░░░░░░░░░]  20% (0.4 MB)
```

**Only show in TTY:**

- Check `process.stderr.isTTY`
- Plain output for scripts/CI

**Libraries:** ora, cli-progress, listr2
