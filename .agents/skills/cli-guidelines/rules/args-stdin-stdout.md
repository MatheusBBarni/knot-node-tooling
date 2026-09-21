---
title: Accept - for stdin/stdout
impact: MEDIUM-HIGH
impactDescription: Enables pipe composition and unix-style workflows
tags: arguments, stdin, stdout, piping, composability
---

## Accept - for stdin/stdout

Support `-` as a filename to read from stdin or write to stdout. This enables pipe-based workflows without temporary files.

**Incorrect (requires actual files):**

```bash
# Requires temp file
$ curl https://example.com/data.tar.gz > temp.tar.gz
$ mycmd extract temp.tar.gz
$ rm temp.tar.gz
```

**Correct (supports - for stdin):**

```bash
# No temp file needed
$ curl https://example.com/data.tar.gz | mycmd extract -
```

**Implementation:**

```typescript
import fs from 'fs'

function readInput(filename: string): string {
  if (filename === '-') {
    return fs.readFileSync(process.stdin.fd, 'utf-8')
  } else {
    return fs.readFileSync(filename, 'utf-8')
  }
}

function writeOutput(filename: string, content: string) {
  if (filename === '-') {
    process.stdout.write(content)
  } else {
    fs.writeFileSync(filename, content)
  }
}

// Usage with commander
program
  .argument('<input>', 'input file (use - for stdin)')
  .option('-o, --output <file>', 'output file (use - for stdout)')
```

**Real-world example (tar):**

```bash
# Extract from stdin
$ curl https://example.com/file.tar.gz | tar xvf -

# Create to stdout
$ tar czf - mydir/ | ssh remote 'tar xzf -'
```

**Benefits:**

- No temporary files
- Memory efficient for streams
- Composes with other tools
- Standard Unix pattern

```bash
# Chaining commands without temp files
$ mycmd export --json | jq '.items[]' | mycmd import -
```

**Handle both input and output:**

```bash
mycmd transform - -o -  # Read stdin, write stdout
cat input.txt | mycmd process - > output.txt
```
