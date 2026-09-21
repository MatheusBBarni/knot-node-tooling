---
title: Support --plain for Script-Friendly Output
impact: MEDIUM
impactDescription: Enables reliable parsing in scripts
tags: output, scripting, automation, parsing
---

## Support --plain for Script-Friendly Output

Provide `--plain` for stable, parseable output that works with grep/awk.

**Human output (wrapped, multi-line):**

```
$ mycmd list
NAME        STATUS      DETAILS
myapp       Running     Started 2 hours ago
                        Memory: 512MB
                        CPU: 2.3%
```

**Plain output (one record per line):**

```
$ mycmd list --plain
myapp	running	2h	512MB	2.3%

$ mycmd list --plain | awk '{print $1, $2}'
myapp running
```

**Why both --plain and --json:**

```bash
# --json for complex processing
$ mycmd list --json | jq '.[] | select(.status == "running")'

# --plain for simple text processing
$ mycmd list --plain | grep running | cut -f1
```

**--plain should:**

- One record per line
- Consistent delimiters (tabs recommended)
- No wrapping or truncation
- Stable across versions

**Pipeline friendly:**

```bash
$ mycmd list --plain | grep "prod" | awk '{print $1}' | xargs mycmd restart
```
