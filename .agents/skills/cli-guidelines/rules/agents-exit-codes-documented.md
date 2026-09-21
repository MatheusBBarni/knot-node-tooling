---
title: Document All Exit Codes
impact: MEDIUM-HIGH
impactDescription: Agents use exit codes for flow control
tags: agents, exit-codes, errors, documentation, automation
---

## Document All Exit Codes

Document all possible exit codes so agents can handle them.

**Show in help:**

```
$ mycmd --help

EXIT CODES
  0    Success
  1    General error
  2    Invalid arguments (fix and retry)
  3    Config error (check config file)
  4    Network error (retryable)
  5    Permission denied (try sudo)
  6    Not found
  130  Ctrl-C
```

**Provide exit-codes command:**

```
$ mycmd exit-codes --json
{
  "exitCodes": [
    { "code": 0, "name": "Success", "retryable": false },
    { "code": 4, "name": "NetworkError", "retryable": true },
    { "code": 5, "name": "PermissionDenied", "retryable": false }
  ]
}
```

**Include in error output:**

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

**Agents decide based on exit code:**

- Code 4: Retry after delay
- Code 2: Don't retry, fix arguments
- Code 5: Don't retry, need permissions
