---
title: Send Progress to stderr, Data to stdout
impact: HIGH
impactDescription: Enables agents to capture output without progress noise
tags: agents, stdout, stderr, progress, output, piping
---

## Send Progress to stderr, Data to stdout

Send all progress and status messages to stderr. Keep stdout clean for data.

**Incorrect (progress mixed with data):**

```
$ mycmd export --json
Exporting users...
{"id": "1", "name": "Alice"}
Processing...
{"id": "2", "name": "Bob"}
Done
```

**Correct (progress to stderr, data to stdout):**

```
$ mycmd export --json
(stderr) Exporting users...
(stdout) {"id": "1", "name": "Alice"}
(stderr) Processing...
(stdout) {"id": "2", "name": "Bob"}
(stderr) ✓ Done
```

**Agent captures stdout cleanly:**

```typescript
const { stdout } = await exec('mycmd export --json')
// stdout = '{"id": "1"...}\n{"id": "2"...}\n'
// No progress messages mixed in
```

**Why this matters:**

```bash
# Works correctly - only JSON in output
$ mycmd export --json | jq '.[] | .name'
Alice
Bob

# Breaks if progress goes to stdout
$ mycmd export --json | jq
parse error: Invalid JSON (progress messages mixed in)
```

**Use console.error() for all non-data:**

```typescript
console.error('Processing...') // stderr
console.log(JSON.stringify(data)) // stdout
```

**Even --verbose goes to stderr:**

```typescript
if (options.verbose) {
  console.error('[DEBUG] Fetching...')
}
console.log(JSON.stringify(result))
```
