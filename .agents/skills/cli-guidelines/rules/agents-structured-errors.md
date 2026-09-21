---
title: Provide Structured Error Information
impact: HIGH
impactDescription: Enables agents to programmatically handle errors
tags: agents, errors, json, exit-codes, automation
---

## Provide Structured Error Information

Provide errors in JSON format so agents can handle them programmatically.

**Error with --json:**

```
$ mycmd deploy --json
{
  "success": false,
  "error": {
    "code": "CONFIG_NOT_FOUND",
    "message": "Config file not found: /path/to/config",
    "exitCode": 3,
    "suggestion": "Run: mycmd init",
    "retryable": false
  }
}
```

**Exit code 3, terminal output:**

```
$ mycmd deploy
Error: Config file not found

Searched:
  - /etc/mycmd/config.json
  - ~/.config/mycmd/config.json
  - ./.mycmd/config.json

Run: mycmd init
```

**Include retryability:**

```json
{
  "success": false,
  "error": {
    "code": "NETWORK_TIMEOUT",
    "exitCode": 4,
    "retryable": true,
    "retryAfter": 5000
  }
}
```

**Error codes should:**

- Be consistent across commands
- Map to exit codes
- Indicate if retryable
- Provide actionable suggestions
- Include relevant context
