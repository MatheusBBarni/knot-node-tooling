---
title: Print Something Within 100ms
impact: MEDIUM-HIGH
impactDescription: Prevents users thinking the program is frozen
tags: robustness, responsiveness, ux, feedback
---

## Print Something Within 100ms

Display output within 100ms of starting. If you're about to do something slow, tell the user first.

**Incorrect (silent, appears frozen):**

```typescript
async function deploy() {
  // 30 seconds of silence - looks broken
  const result = await slowNetworkCall()
  console.log('Deployed!')
}
```

**Correct (immediate feedback):**

```typescript
async function deploy() {
  console.error('Connecting to server...')
  const result = await slowNetworkCall()
  console.error('Deployed!')
}
```

**For operations >1 second, show progress:**

```typescript
import ora from 'ora'

const spinner = ora('Processing files...').start()
for (const file of files) {
  await process(file)
}
spinner.succeed('Processed all files')
```

**Output before slow operations:**

```typescript
// Tell user before network call
console.error('Fetching data from API...')
const data = await fetch(url)

// Tell user before computation
console.error('Analyzing results...')
const results = expensiveComputation(data)
```

**Why this matters (user experience):**

```
# Without feedback - appears frozen, user gets anxious
$ mycmd deploy
_
(30 seconds of silence... is it working? frozen? should I Ctrl-C?)
(User hits Ctrl-C thinking it's broken)

# With immediate feedback - user knows what's happening
$ mycmd deploy
Connecting to server...
⠋ Uploading files (15 files, 2.3 MB)...
⠙ Building application...
⠹ Deploying to production...
✓ Deployed successfully! (1m 23s)

  URL: https://myapp.com
  Version: v1.2.3
```

**Perceived performance is as important as actual performance:**

- Immediate response feels faster
- Progress indicators make waits tolerable
- Silence causes anxiety and Ctrl-C mashing

Reference: https://www.nngroup.com/articles/response-times-3-important-limits/
