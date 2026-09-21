---
title: Ensure Deterministic, Versioned Output
impact: HIGH
impactDescription: Agents rely on stable output formats
tags: agents, json, versioning, schema, stability
---

## Ensure Deterministic, Versioned Output

AI agents depend on stable --json output. Version your schema and don't break it.

**Incorrect (schema changes break agents):**

```json
// Version 1.0
{ "users": [...] }

// Version 1.1 - BREAKS agents expecting { users: [...] }
{ "data": { "users": [...] } }
```

**Correct (versioned, stable schema):**

```json
// Version 1.0
{
  "version": "1.0",
  "users": [...]
}

// Version 1.1 (additive - safe)
{
  "version": "1.1",
  "users": [...],
  "metadata": { ... }
}
```

**Document schema:**

```
$ mycmd list --help

OUTPUT FORMAT (--json)
  {
    "version": "1.0",
    "success": true,
    "data": { ... }
  }
```

**Rules for stable output:**

- Include version field
- Add new fields, don't remove/move existing ones
- Use consistent naming (camelCase or snake_case)
- Use ISO 8601 for dates
- Document schema changes in changelog
