---
title: Provide --yes Flag to Skip All Confirmations
impact: MEDIUM-HIGH
impactDescription: Enables agents to run destructive operations
tags: agents, confirmations, automation, flags, force
---

## Provide --yes Flag to Skip All Confirmations

Provide `--yes` or `--force` to skip confirmation prompts.

**Interactive (prompts user):**

```
$ mycmd delete project-123
This will permanently delete 'project-123' and all data.
Are you sure? [y/N]: y

Deleting project-123...
✓ Deleted
```

**Non-interactive (for agents):**

```
$ mycmd delete project-123 --yes
Deleting project-123...
✓ Deleted
```

**Without --yes in non-interactive mode:**

```
$ mycmd delete project-123
Error: Use --yes or --force to confirm deletion

This operation cannot be undone.
Run: mycmd delete project-123 --yes
```

**Common patterns:**

| Flag                | Purpose               | Danger   |
| ------------------- | --------------------- | -------- |
| `--yes`, `-y`       | Skip confirmations    | Moderate |
| `--force`, `-f`     | Force dangerous ops   | High     |
| `--confirm=<value>` | Type value to confirm | Severe   |

**For severe operations (require explicit value):**

```
$ mycmd delete-server prod-db
Error: Type server name to confirm: --confirm=prod-db

$ mycmd delete-server prod-db --confirm=prod-db
✓ Deleted
```

**Document in help:**

```
OPTIONS
  -y, --yes    Skip all confirmations
  -f, --force  Force operation

For automation, always use --yes or --force.
```
