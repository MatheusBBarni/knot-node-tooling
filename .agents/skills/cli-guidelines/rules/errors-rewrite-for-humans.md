---
title: Catch Errors and Rewrite for Humans
impact: HIGH
impactDescription: Reduces user frustration and support requests
tags: errors, usability, messages, troubleshooting
---

## Catch Errors and Rewrite for Humans

Catch expected errors and rewrite with helpful, actionable messages.

**Incorrect (raw system error):**

```
$ mycmd deploy
ECONNREFUSED: connect ECONNREFUSED 127.0.0.1:5432
    at TCPConnectWrap.afterConnect (node:net:1595:16)
```

**Correct (helpful message):**

```
$ mycmd deploy

Error: Can't connect to database at localhost:5432

Is the database running?
Try: docker start postgres
```

**Error message structure:**

1. What happened (brief)
2. Why it happened (if known)
3. How to fix it (actionable)

**Good examples:**

```
$ mycmd start

Error: Config file not found: ~/.mycmdrc

Create one with: mycmd init
```

```
$ mycmd deploy

Error: Permission denied: /etc/mycmd/

Try running with sudo:
  sudo mycmd deploy
```

**Don't expose:**

- Stack traces (unless --verbose)
- Technical jargon
- Internal details

**Catch common errors:**

```typescript
catch (error) {
  if (error.code === 'EACCES') { /* Permission denied */ }
  if (error.code === 'ENOENT') { /* File not found */ }
  if (error.code === 'ECONNREFUSED') { /* Connection refused */ }
}
```
