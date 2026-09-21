---
title: Support Streaming Output for Long Operations
impact: MEDIUM
impactDescription: Enables agents to show real-time progress
tags: agents, streaming, output, progress, real-time
---

## Support Streaming Output for Long Operations

Stream output line-by-line for long operations. Don't buffer everything.

**Incorrect (all output at once after 10 minutes):**

```
$ mycmd process --json

(10 minutes of silence...)

[{"id": "1", "status": "done"}, {"id": "2", "status": "done"}, ...]
```

**Correct (streams results as available):**

```
$ mycmd process --json --stream

{"id": "1", "status": "done"}
{"id": "2", "status": "done"}
{"id": "3", "status": "done"}
...
```

**JSONL format (JSON Lines):**

- One JSON object per line
- Agent can parse incrementally
- Shows progress in real-time

**Include progress updates:**

```
$ mycmd process --json --stream

{"type": "progress", "current": 1, "total": 100}
{"type": "result", "id": "item-1", "status": "completed"}
{"type": "progress", "current": 2, "total": 100}
{"type": "result", "id": "item-2", "status": "completed"}
```

**Benefits:**

- Agent sees results immediately
- Can show real-time progress
- Handles partial results if interrupted
- No 10-minute wait for all results
