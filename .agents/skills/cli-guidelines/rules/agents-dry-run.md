---
title: Provide --dry-run for Agent Safety
impact: MEDIUM-HIGH
impactDescription: Enables agents to preview actions before executing
tags: agents, dry-run, safety, simulation, preview
---

## Provide --dry-run for Agent Safety

Let agents preview what would happen before making changes.

**Dry-run output (shows what WOULD happen):**

```
$ mycmd deploy staging --dry-run

Would perform the following actions:
  1. Upload 15 files to staging (2.3 MB)
  2. Run 3 database migrations:
     - 001_add_users.sql
     - 002_add_posts.sql
     - 003_add_indexes.sql
  3. Restart services: api, worker
  4. Update DNS to new version

Estimated time: 2-3 minutes
Reversible: No

Run without --dry-run to execute.
```

**JSON dry-run:**

```
$ mycmd deploy staging --dry-run --json
{
  "dryRun": true,
  "actions": [
    { "type": "upload", "fileCount": 15, "size": "2.3 MB" },
    { "type": "migrate", "migrations": ["001_add_users", "002_add_posts"] },
    { "type": "restart", "services": ["api", "worker"] }
  ],
  "estimatedDuration": "2-3 minutes",
  "reversible": false
}
```

**Agent workflow:**

```
1. Run: mycmd deploy --dry-run --json
2. Parse plan, check if safe
3. Execute: mycmd deploy --yes
```

**Provide for destructive operations:**

- Deletions
- Updates
- Deployments
- Migrations
