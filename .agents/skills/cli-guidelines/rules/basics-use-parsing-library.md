---
title: Use an Argument Parsing Library
impact: CRITICAL
impactDescription: Prevents broken CLI behavior and edge case bugs
tags: basics, arguments, parsing, flags
---

## Use an Argument Parsing Library

Use a command-line argument parsing library (built-in or third-party). Don't roll your own—it's harder than it looks and you'll miss edge cases.

**Incorrect (manual parsing, prone to bugs):**

```typescript
// Manual parsing - misses many edge cases
const args = process.argv.slice(2)
const verbose = args.includes('--verbose') || args.includes('-v')
let output = null
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--output' && i + 1 < args.length) {
    output = args[i + 1]
  }
}
```

**Correct (using commander):**

```typescript
import { Command } from 'commander'

const program = new Command()
program
  .option('-v, --verbose', 'verbose output')
  .option('-o, --output <file>', 'output file')
  .parse(process.argv)

const options = program.opts()
```

Libraries handle:

- Flag parsing (short and long forms)
- Help text generation
- Type validation
- Spelling suggestions
- Error messages

**Recommended libraries:**

- **Node/TypeScript**: commander, oclif, yargs
- **Go**: Cobra, urfave/cli
- **Python**: Click, Typer, argparse
- **Rust**: clap
- **Ruby**: TTY
