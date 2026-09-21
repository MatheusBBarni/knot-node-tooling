---
title: Use a Pager for Long Output
impact: LOW-MEDIUM
impactDescription: Improves readability of long output
tags: output, pager, less, usability
---

## Use a Pager for Long Output

Automatically page long output. Don't dump 1000 lines to the terminal.

**Without pager (scrolls off screen):**

```
$ mycmd logs
(1000 lines scroll by)
...
line 998
line 999
line 1000
```

**With pager (readable):**

```
$ mycmd logs
(opens in less, can scroll/search)
```

**Examples that use pagers:**

- `git diff`
- `git log`
- `man` pages

**When to page:**

- Help text with many commands
- Log output
- Diff output
- Any output >100 lines

**Don't page when:**

- Output is piped: `mycmd logs | grep error`
- `--json` or `--plain` output
- Not a TTY
- User passed `--no-pager`

**Good less options: `less -FIRX`**

- `-F`: Don't page if fits on screen
- `-I`: Case-insensitive search
- `-R`: Allow colors
- `-X`: Don't clear screen on exit
