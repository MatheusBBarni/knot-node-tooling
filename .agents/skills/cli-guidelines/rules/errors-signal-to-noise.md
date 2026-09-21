---
title: Maintain Signal-to-Noise Ratio
impact: MEDIUM-HIGH
impactDescription: Users can quickly identify actual problems
tags: errors, output, debugging, usability
---

## Maintain Signal-to-Noise Ratio

Keep error output focused. Don't drown the problem in debug info.

**Incorrect (too much noise):**

```
$ mycmd deploy
[DEBUG] Loading config from ~/.mycmdrc
[DEBUG] Config loaded
[DEBUG] Connecting to api.example.com
[DEBUG] Connection established
ERROR: Invalid API key
[DEBUG] Closing connection
[DEBUG] Cleanup complete
```

**Correct (focused, clear):**

```
$ mycmd deploy

Error: Invalid API key

Fix: Set MYCMD_API_KEY environment variable
Or: echo "your-key" > ~/.mycmd/credentials
```

**Group similar errors:**

```
# Bad - 100 identical errors
Error: Line 1: invalid format
Error: Line 5: invalid format
... (98 more)

# Good - grouped summary
Error: 100 lines with invalid format

First error at line 1:
  Expected: name,email,age
  Got:      invalid data

Run with --verbose to see all errors
```

**Debug info in verbose mode only:**

```
$ mycmd deploy --verbose
[DEBUG] Loading config...
[DEBUG] Connecting...
Error: Connection failed
[DEBUG] Stack trace: ...
```

**Save full logs to file:**

```
$ mycmd deploy
Error: Deployment failed
Full logs: /tmp/mycmd-deploy.log
```
