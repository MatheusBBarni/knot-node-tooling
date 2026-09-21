---
title: Support -h and --help Flags
impact: CRITICAL
impactDescription: Essential for discoverability and usability
tags: basics, help, flags, documentation
---

## Support -h and --help Flags

Display help when passed `-h` or `--help` flags. This applies to the main command and all subcommands.

**Incorrect (no help flag support):**

```typescript
function main() {
  if (process.argv.length < 3) {
    console.log('Usage: mycmd <command>')
    return
  }
  // No help flag handling
  const command = process.argv[2]
  runCommand(command)
}
```

**Correct (help flags work):**

```typescript
import { Command } from 'commander'

const program = new Command()
program
  .description('My CLI tool')
  .argument('<command>', 'Command to run')
  // commander automatically handles -h and --help
  .parse(process.argv)
```

**All these should show help:**

```bash
$ myapp -h
$ myapp --help
$ myapp subcommand -h
$ myapp subcommand --help
$ myapp help              # For git-like CLIs
$ myapp help subcommand   # For git-like CLIs
```

**Rules:**

- Ignore any other flags when `-h` is passed
- Don't overload `-h` for anything else
- Show help even with invalid arguments: `mycmd --foo -h` shows help
- Support both short (`-h`) and long (`--help`) forms

```bash
# User can add -h anywhere to get help
$ mycmd deploy --environment prod -h
# Shows help instead of trying to deploy
```
