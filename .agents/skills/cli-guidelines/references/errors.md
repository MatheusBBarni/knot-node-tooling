# Error Handling

## Philosophy

Errors are documentation. Make them teach users what went wrong and how to fix it.

## Rewrite Errors for Humans

Don't expose raw system errors:

```
# Bad
EACCES: permission denied, open '/etc/config'

# Good
Can't write to /etc/config. Try running with sudo, or check file permissions.
```

## Error Message Structure

1. What happened (brief)
2. Why it happened (if known)
3. How to fix it (actionable)

```
Error: Can't connect to database at localhost:5432
The database server may not be running.
Try: docker start postgres
```

## Signal-to-Noise Ratio

- Group similar errors under one header
- Don't print 100 identical errors
- Filter out irrelevant context
- Put most important info at the END (where eyes go)

## Exit Codes

```
0   - Success
1   - General error
2   - Misuse (bad args, missing required input)
126 - Command found but not executable
127 - Command not found
128+N - Killed by signal N (e.g., 130 = Ctrl-C)
```

Map non-zero codes to failure modes:

```go
const (
    ExitSuccess        = 0
    ExitConfigError    = 1
    ExitNetworkError   = 2
    ExitPermissionError = 3
)
```

## Unexpected Errors

For bugs/unexpected errors:

1. Write debug info to file (not terminal)
2. Show brief message with file location
3. Provide bug report URL

```
Unexpected error occurred. Debug log written to /tmp/myapp-debug.log
Please report this issue: https://github.com/org/myapp/issues
```

## Color in Errors

- Use red sparingly (only for actual errors)
- Important info should be visible without color
- Red draws attention—don't overuse

## Don't Scare Users

Avoid:

- Full stack traces for user errors
- Technical jargon
- Alarming language for minor issues

```
# Bad
FATAL: Unhandled exception in module loader

# Good
Couldn't load config file. Create one with: myapp init
```
