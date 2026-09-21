---
title: Set Timeouts on Network Operations
impact: HIGH
impactDescription: Prevents hanging forever on network issues
tags: robustness, network, timeouts, http, reliability
---

## Set Timeouts on Network Operations

Always set timeouts. Don't hang forever if the server doesn't respond.

**Without timeout (hangs forever):**

```
$ mycmd deploy
Connecting to server...
(hangs forever if server is down)
```

**With timeout (fails fast):**

```
$ mycmd deploy
Connecting to server...
Error: Request timed out after 30s

Check:
  - Network connection
  - Server status

Or increase timeout: mycmd deploy --timeout 60
```

**Implementation:**

```typescript
const response = await fetch(url, {
  signal: AbortSignal.timeout(30000),
})
```

**Make configurable:**

```
$ mycmd deploy --timeout 60
```

**Different timeouts for different operations:**

- Connection: 5-10s
- Read: 30-60s
- Large uploads: 5-10 minutes

**Retry with backoff:**

```
$ mycmd deploy
Connection failed, retrying in 2s...
Connection failed, retrying in 4s...
✓ Connected
```
