---
title: Map Exit Codes to Failure Modes
impact: MEDIUM-HIGH
impactDescription: Enables scripts to handle different error types
tags: errors, exit-codes, automation, error-handling
---

## Map Exit Codes to Failure Modes

Use different exit codes for different error types.

**Standard codes:**

```
0    Success
1    General error
2    Invalid arguments
3    Configuration error
4    Network error (retryable)
5    Permission denied
6    Resource not found
130  Interrupted by Ctrl-C
```

**Document in help:**

```
$ mycmd --help

EXIT CODES
  0   Success
  1   General error
  2   Invalid arguments (fix command and retry)
  3   Configuration error (check config file)
  4   Network error (retryable)
  5   Permission denied (try with sudo)
  6   Resource not found
```

**Scripts can handle specific errors:**

```bash
mycmd deploy

case $? in
  0) echo "✓ Deployed" ;;
  3) echo "Config error"; mycmd init ;;
  4) echo "Network error, retrying..."; sleep 5; mycmd deploy ;;
  5) echo "Permission denied"; sudo mycmd deploy ;;
  *) echo "Unknown error" ;;
esac
```

**Include in JSON output:**

```json
{
  "success": false,
  "error": {
    "code": "NETWORK_ERROR",
    "exitCode": 4,
    "retryable": true
  }
}
```
