---
title: Use Standard Flag Names
impact: MEDIUM
impactDescription: Reduces learning curve, flags are guessable
tags: flags, conventions, standards, usability
---

## Use Standard Flag Names

Use conventional flag names that users already know from other tools.

**Standard flags:**

| Flag | Long form    | Purpose              | Example tools |
| ---- | ------------ | -------------------- | ------------- |
| `-a` | `--all`      | All items            | ps, fetchmail |
| `-d` | `--debug`    | Debug output         | Most tools    |
| `-f` | `--force`    | Force operation      | rm, git       |
| `-h` | `--help`     | Show help            | Universal     |
| `-n` | `--dry-run`  | Simulate, no changes | rsync, git    |
| `-o` | `--output`   | Output file          | gcc, sort     |
| `-p` | `--port`     | Port number          | ssh, psql     |
| `-q` | `--quiet`    | Suppress output      | wget, curl    |
| `-u` | `--user`     | User name            | ssh, psql     |
| `-v` | `--verbose`  | Verbose output       | Most tools    |
|      | `--version`  | Show version         | Universal     |
|      | `--json`     | JSON output          | Modern CLIs   |
|      | `--no-input` | Disable prompts      | Modern CLIs   |

**Incorrect (non-standard names):**

```bash
# Unclear, user has to look it up
mycmd process --silent      # Should be --quiet
mycmd deploy --show-detail  # Should be --verbose
mycmd build --simulate      # Should be --dry-run
```

**Correct (standard names):**

```bash
mycmd process --quiet
mycmd deploy --verbose
mycmd build --dry-run
```

**Benefits:**

- Users can guess flags without reading docs
- Consistent muscle memory across tools
- Reduced learning curve

**Avoid conflicts:**

- `-v` can mean verbose OR version (prefer `-v` for verbose, `--version` only for version)
- `-h` should ONLY mean help, never hostname

**Example implementation:**

```python
parser.add_argument('-q', '--quiet', action='store_true')
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('-f', '--force', action='store_true')
parser.add_argument('-n', '--dry-run', action='store_true')
parser.add_argument('--version', action='version')
```

When introducing non-standard flags, use descriptive long forms:

```bash
mycmd deploy --rollback-on-error  # Clear and specific
```
