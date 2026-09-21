---
title: Avoid Interactive Prompts for Agent-Driven CLIs
impact: HIGH
impactDescription: Agents cannot respond to interactive prompts
tags: agents, prompts, automation, flags, non-interactive
---

## Avoid Interactive Prompts for Agent-Driven CLIs

Make all operations possible via flags. Agents can't answer prompts.

**Incorrect (requires interaction - agent stuck):**

```
$ mycmd deploy
Choose environment:
  1. staging
  2. production
> _
(agent can't respond)
```

**Correct (works non-interactively):**

```
$ mycmd deploy --env staging
Deploying to staging...
✓ Deployed
```

**If flag missing in non-interactive mode:**

```
$ mycmd deploy
Error: --env is required

Usage: mycmd deploy --env <staging|production>
```

**Provide flags for all inputs:**

| Instead of           | Provide flag            |
| -------------------- | ----------------------- |
| "Choose environment" | `--env <env>`           |
| "Are you sure?"      | `--yes` or `--force`    |
| "Enter API key"      | `--api-key-file <file>` |
| "Select region"      | `--region <region>`     |

**Agent-friendly design:**

```bash
# Everything via flags
mycmd init --name myproject --template basic
mycmd deploy --env staging --region us-east --yes
mycmd delete resource-123 --force
```

**Still support interactive for humans:**

- Prompt if stdin is TTY
- Use flags if provided
- Use env vars as fallback
