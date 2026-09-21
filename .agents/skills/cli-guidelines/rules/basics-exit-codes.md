---
title: Return Correct Exit Codes
impact: CRITICAL
impactDescription: Required for script composition and automation
tags: basics, exit-codes, errors, scripting
---

## Return Correct Exit Codes

Return 0 on success, non-zero on failure. Exit codes are how scripts determine whether a program succeeded, so report this correctly.

**Incorrect (always returns 0):**

```typescript
async function main() {
  try {
    const result = await doWork()
    console.log('Done')
  } catch (error) {
    console.log(`Error: ${error.message}`)
  }
  // Exits with 0 even on error!
}
```

**Correct (returns appropriate exit code):**

```typescript
async function main() {
  try {
    const result = await doWork()
    console.log('Done')
    process.exit(0)
  } catch (error) {
    console.error(`Error: ${error.message}`)
    process.exit(1)
  }
}
```

**Standard exit codes:**

| Code | Meaning                             |
| ---- | ----------------------------------- |
| 0    | Success                             |
| 1    | General error                       |
| 2    | Misuse of command (bad arguments)   |
| 126  | Command found but not executable    |
| 127  | Command not found                   |
| 130  | Terminated by Ctrl-C (128 + SIGINT) |

**Map codes to failure modes:**

```typescript
enum ExitCode {
  Success = 0,
  GeneralError = 1,
  BadArguments = 2,
  ConfigError = 3,
  NetworkError = 4,
}

process.exit(ExitCode.NetworkError)
```

This enables scripts to handle different error types:

```bash
if mycmd deploy; then
    echo "Deployed successfully"
else
    case $? in
        3) echo "Config error - check your settings" ;;
        4) echo "Network error - check your connection" ;;
        *) echo "Unknown error" ;;
    esac
fi
```
