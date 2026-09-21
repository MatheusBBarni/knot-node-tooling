---
title: Always Support --json for Agent Consumption
impact: CRITICAL
impactDescription: Essential for AI agents to parse and understand output
tags: agents, json, automation, api, machine-readable
---

## Always Support --json for Agent Consumption

AI agents need structured output. Always provide `--json`.

**Human output:**

```
$ mycmd list
Active users:
  - Alice (alice@example.com)
  - Bob (bob@example.com)
```

**Agent output:**

```
$ mycmd list --json
{
  "users": [
    { "id": "1", "name": "Alice", "email": "alice@example.com", "status": "active" },
    { "id": "2", "name": "Bob", "email": "bob@example.com", "status": "active" }
  ]
}
```

**All commands should support --json:**

```
$ mycmd get user-123 --json
$ mycmd status --json
$ mycmd config list --json
```

**JSON should:**

- Be valid, parseable
- Use consistent field names (camelCase)
- Include all relevant data
- Use ISO 8601 for dates
- Be pretty-printed (2 space indent)

**Errors in JSON:**

```
$ mycmd deploy --json
{
  "success": false,
  "error": {
    "code": "AUTH_REQUIRED",
    "message": "Not authenticated"
  }
}
```

**Benefits:**

- Agents parse reliably
- No regex needed
- Chain commands easily
