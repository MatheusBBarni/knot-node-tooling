---
title: Support --json for Machine-Readable Output
impact: HIGH
impactDescription: Enables script integration and programmatic usage
tags: output, json, automation, scripting, api
---

## Support --json for Machine-Readable Output

Provide `--json` for structured output. Essential for scripts and agents.

**Human output:**

```
$ mycmd list
Projects:
  - myapp (active)
  - oldapp (archived)
```

**Machine output:**

```
$ mycmd list --json
{
  "projects": [
    { "name": "myapp", "status": "active" },
    { "name": "oldapp", "status": "archived" }
  ]
}
```

**Pipe to jq:**

```bash
$ mycmd list --json | jq '.projects[0].name'
myapp

$ mycmd list --json | jq '.projects[] | select(.status == "active")'
{
  "name": "myapp",
  "status": "active"
}
```

**All commands should support --json:**

```bash
mycmd list --json
mycmd get user-123 --json
mycmd status --json
```

**JSON should:**

- Be valid, parseable
- Pretty-printed (2 space indent)
- Use consistent field names (camelCase)
- Go to stdout (not stderr)
- Include all relevant data
