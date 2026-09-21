# CLI Design Guidelines

**Version 1.0.0**  
CLI Guidelines  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring cli design guidelines. Humans  
> may also find it useful, but guidance here is optimized for automation  
> and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide to designing and building well-crafted command-line interfaces following modern best practices. Designed for AI agents and LLMs to follow when creating, reviewing, or refactoring CLI tools. Contains guidelines across 15 categories covering philosophy, basics, help text, output formatting, error handling, arguments/flags, interactivity, subcommands, configuration, robustness, signals, future-proofing, naming, distribution, and analytics.

---

## Table of Contents

1. [Agents Deterministic Output](#agents-deterministic-output)
2. [Agents Dry Run](#agents-dry-run)
3. [Agents Exit Codes Documented](#agents-exit-codes-documented)
4. [Agents Help Machine Readable](#agents-help-machine-readable)
5. [Agents Json Required](#agents-json-required)
6. [Agents No Prompts Default](#agents-no-prompts-default)
7. [Agents Progress To Stderr](#agents-progress-to-stderr)
8. [Agents Streaming Output](#agents-streaming-output)
9. [Agents Structured Errors](#agents-structured-errors)
10. [Agents Yes Flag](#agents-yes-flag)
11. [Analytics No Phone Home](#analytics-no-phone-home)
12. [Args No Secrets Flags](#args-no-secrets-flags)
13. [Args Order Independent](#args-order-independent)
14. [Args Prefer Flags](#args-prefer-flags)
15. [Args Standard Names](#args-standard-names)
16. [Args Stdin Stdout](#args-stdin-stdout)
17. [Basics Exit Codes](#basics-exit-codes)
18. [Basics Full Flags](#basics-full-flags)
19. [Basics Help Flags](#basics-help-flags)
20. [Basics Stdout Stderr](#basics-stdout-stderr)
21. [Basics Use Parsing Library](#basics-use-parsing-library)
22. [Config Precedence](#config-precedence)
23. [Config Xdg Spec](#config-xdg-spec)
24. [Errors Exit Code Mapping](#errors-exit-code-mapping)
25. [Errors Important Info End](#errors-important-info-end)
26. [Errors Rewrite For Humans](#errors-rewrite-for-humans)
27. [Errors Signal To Noise](#errors-signal-to-noise)
28. [Future Additive Changes](#future-additive-changes)
29. [Help Concise Default](#help-concise-default)
30. [Help Lead Examples](#help-lead-examples)
31. [Help Suggest Corrections](#help-suggest-corrections)
32. [Help Web Documentation](#help-web-documentation)
33. [Interactive No Input Flag](#interactive-no-input-flag)
34. [Interactive Password No Echo](#interactive-password-no-echo)
35. [Interactive Tty Check](#interactive-tty-check)
36. [Naming Distribute Single Binary](#naming-distribute-single-binary)
37. [Naming Simple Memorable](#naming-simple-memorable)
38. [Output Json Flag](#output-json-flag)
39. [Output Pager](#output-pager)
40. [Output Plain Flag](#output-plain-flag)
41. [Output State Changes](#output-state-changes)
42. [Output Tty Detection](#output-tty-detection)
43. [Robustness 100ms Response](#robustness-100ms-response)
44. [Robustness Idempotent](#robustness-idempotent)
45. [Robustness Network Timeouts](#robustness-network-timeouts)
46. [Robustness Progress Indicators](#robustness-progress-indicators)
47. [Robustness Validate Early](#robustness-validate-early)
48. [Signals Crash Only Design](#signals-crash-only-design)
49. [Signals Exit On Ctrl C](#signals-exit-on-ctrl-c)
50. [Subcommands Consistency](#subcommands-consistency)
51. [Subcommands Consistent Verbs](#subcommands-consistent-verbs)
52. [Subcommands No Abbreviations](#subcommands-no-abbreviations)
53. [Subcommands No Catch All](#subcommands-no-catch-all)

---

## 1. Agents Deterministic Output

---
title: Ensure Deterministic, Versioned Output
impact: HIGH
impactDescription: Agents rely on stable output formats
tags: agents, json, versioning, schema, stability
---

## Ensure Deterministic, Versioned Output

AI agents depend on stable --json output. Version your schema and don't break it.

**Incorrect (schema changes break agents):**

```json
// Version 1.0
{ "users": [...] }

// Version 1.1 - BREAKS agents expecting { users: [...] }
{ "data": { "users": [...] } }
```

**Correct (versioned, stable schema):**

```json
// Version 1.0
{
  "version": "1.0",
  "users": [...]
}

// Version 1.1 (additive - safe)
{
  "version": "1.1",
  "users": [...],
  "metadata": { ... }
}
```

**Document schema:**

```
$ mycmd list --help

OUTPUT FORMAT (--json)
  {
    "version": "1.0",
    "success": true,
    "data": { ... }
  }
```

**Rules for stable output:**

- Include version field
- Add new fields, don't remove/move existing ones
- Use consistent naming (camelCase or snake_case)
- Use ISO 8601 for dates
- Document schema changes in changelog

---

## 2. Agents Dry Run

---
title: Provide --dry-run for Agent Safety
impact: MEDIUM-HIGH
impactDescription: Enables agents to preview actions before executing
tags: agents, dry-run, safety, simulation, preview
---

## Provide --dry-run for Agent Safety

Let agents preview what would happen before making changes.

**Dry-run output (shows what WOULD happen):**

```
$ mycmd deploy staging --dry-run

Would perform the following actions:
  1. Upload 15 files to staging (2.3 MB)
  2. Run 3 database migrations:
     - 001_add_users.sql
     - 002_add_posts.sql
     - 003_add_indexes.sql
  3. Restart services: api, worker
  4. Update DNS to new version

Estimated time: 2-3 minutes
Reversible: No

Run without --dry-run to execute.
```

**JSON dry-run:**

```
$ mycmd deploy staging --dry-run --json
{
  "dryRun": true,
  "actions": [
    { "type": "upload", "fileCount": 15, "size": "2.3 MB" },
    { "type": "migrate", "migrations": ["001_add_users", "002_add_posts"] },
    { "type": "restart", "services": ["api", "worker"] }
  ],
  "estimatedDuration": "2-3 minutes",
  "reversible": false
}
```

**Agent workflow:**

```
1. Run: mycmd deploy --dry-run --json
2. Parse plan, check if safe
3. Execute: mycmd deploy --yes
```

**Provide for destructive operations:**

- Deletions
- Updates
- Deployments
- Migrations

---

## 3. Agents Exit Codes Documented

---
title: Document All Exit Codes
impact: MEDIUM-HIGH
impactDescription: Agents use exit codes for flow control
tags: agents, exit-codes, errors, documentation, automation
---

## Document All Exit Codes

Document all possible exit codes so agents can handle them.

**Show in help:**

```
$ mycmd --help

EXIT CODES
  0    Success
  1    General error
  2    Invalid arguments (fix and retry)
  3    Config error (check config file)
  4    Network error (retryable)
  5    Permission denied (try sudo)
  6    Not found
  130  Ctrl-C
```

**Provide exit-codes command:**

```
$ mycmd exit-codes --json
{
  "exitCodes": [
    { "code": 0, "name": "Success", "retryable": false },
    { "code": 4, "name": "NetworkError", "retryable": true },
    { "code": 5, "name": "PermissionDenied", "retryable": false }
  ]
}
```

**Include in error output:**

```json
{
  "success": false,
  "error": {
    "code": "NETWORK_TIMEOUT",
    "exitCode": 4,
    "retryable": true,
    "retryAfter": 5000
  }
}
```

**Agents decide based on exit code:**

- Code 4: Retry after delay
- Code 2: Don't retry, fix arguments
- Code 5: Don't retry, need permissions

---

## 4. Agents Help Machine Readable

---
title: Make Help Text Machine-Readable
impact: MEDIUM
impactDescription: Enables agents to discover capabilities programmatically
tags: agents, help, documentation, discovery, automation
---

## Make Help Text Machine-Readable

Provide structured help via --help --json so agents can understand capabilities.

**Terminal output:**

```
$ mycmd --help --json
{
  "name": "mycmd",
  "version": "1.0.0",
  "description": "My CLI tool",
  "commands": [
    {
      "name": "deploy",
      "description": "Deploy application",
      "arguments": [
        { "name": "app", "required": true }
      ],
      "options": [
        { "flag": "--env", "required": true, "choices": ["staging", "production"] },
        { "flag": "--force", "required": false }
      ]
    }
  ]
}
```

**Command-specific help:**

```
$ mycmd deploy --help --json
{
  "command": "deploy",
  "usage": "mycmd deploy <app> --env <env>",
  "arguments": [
    { "name": "app", "required": true }
  ],
  "options": [
    { "flag": "--env", "type": "string", "required": true },
    { "flag": "--force", "type": "boolean", "required": false }
  ],
  "examples": [
    "mycmd deploy myapp --env staging"
  ]
}
```

**Benefits for agents:**

- Discover available commands
- Understand required vs optional flags
- Know valid values for enum flags
- Build correct commands programmatically

---

## 5. Agents Json Required

---
title: Always Support --json for Agent Consumption
impact: CRITICAL
impactDescription: Essential for AI agents to parse and understand output
tags: agents, json, automation, api, machine-readable
---

## Always Support --json for Agent Consumption

AI agents need structured output. Always provide `--json`.

**Human output:**

```
$ mycmd list
Active users:
  - Alice (alice@example.com)
  - Bob (bob@example.com)
```

**Agent output:**

```
$ mycmd list --json
{
  "users": [
    { "id": "1", "name": "Alice", "email": "alice@example.com", "status": "active" },
    { "id": "2", "name": "Bob", "email": "bob@example.com", "status": "active" }
  ]
}
```

**All commands should support --json:**

```
$ mycmd get user-123 --json
$ mycmd status --json
$ mycmd config list --json
```

**JSON should:**

- Be valid, parseable
- Use consistent field names (camelCase)
- Include all relevant data
- Use ISO 8601 for dates
- Be pretty-printed (2 space indent)

**Errors in JSON:**

```
$ mycmd deploy --json
{
  "success": false,
  "error": {
    "code": "AUTH_REQUIRED",
    "message": "Not authenticated"
  }
}
```

**Benefits:**

- Agents parse reliably
- No regex needed
- Chain commands easily

---

## 6. Agents No Prompts Default

---
title: Avoid Interactive Prompts for Agent-Driven CLIs
impact: HIGH
impactDescription: Agents cannot respond to interactive prompts
tags: agents, prompts, automation, flags, non-interactive
---

## Avoid Interactive Prompts for Agent-Driven CLIs

Make all operations possible via flags. Agents can't answer prompts.

**Incorrect (requires interaction - agent stuck):**

```
$ mycmd deploy
Choose environment:
  1. staging
  2. production
> _
(agent can't respond)
```

**Correct (works non-interactively):**

```
$ mycmd deploy --env staging
Deploying to staging...
✓ Deployed
```

**If flag missing in non-interactive mode:**

```
$ mycmd deploy
Error: --env is required

Usage: mycmd deploy --env <staging|production>
```

**Provide flags for all inputs:**

| Instead of           | Provide flag            |
| -------------------- | ----------------------- |
| "Choose environment" | `--env <env>`           |
| "Are you sure?"      | `--yes` or `--force`    |
| "Enter API key"      | `--api-key-file <file>` |
| "Select region"      | `--region <region>`     |

**Agent-friendly design:**

```bash

mycmd init --name myproject --template basic
mycmd deploy --env staging --region us-east --yes
mycmd delete resource-123 --force
```

**Still support interactive for humans:**

- Prompt if stdin is TTY
- Use flags if provided
- Use env vars as fallback

---

## 7. Agents Progress To Stderr

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

---

## 8. Agents Streaming Output

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

---

## 9. Agents Structured Errors

---
title: Provide Structured Error Information
impact: HIGH
impactDescription: Enables agents to programmatically handle errors
tags: agents, errors, json, exit-codes, automation
---

## Provide Structured Error Information

Provide errors in JSON format so agents can handle them programmatically.

**Error with --json:**

```
$ mycmd deploy --json
{
  "success": false,
  "error": {
    "code": "CONFIG_NOT_FOUND",
    "message": "Config file not found: /path/to/config",
    "exitCode": 3,
    "suggestion": "Run: mycmd init",
    "retryable": false
  }
}
```

**Exit code 3, terminal output:**

```
$ mycmd deploy
Error: Config file not found

Searched:
  - /etc/mycmd/config.json
  - ~/.config/mycmd/config.json
  - ./.mycmd/config.json

Run: mycmd init
```

**Include retryability:**

```json
{
  "success": false,
  "error": {
    "code": "NETWORK_TIMEOUT",
    "exitCode": 4,
    "retryable": true,
    "retryAfter": 5000
  }
}
```

**Error codes should:**

- Be consistent across commands
- Map to exit codes
- Indicate if retryable
- Provide actionable suggestions
- Include relevant context

---

## 10. Agents Yes Flag

---
title: Provide --yes Flag to Skip All Confirmations
impact: MEDIUM-HIGH
impactDescription: Enables agents to run destructive operations
tags: agents, confirmations, automation, flags, force
---

## Provide --yes Flag to Skip All Confirmations

Provide `--yes` or `--force` to skip confirmation prompts.

**Interactive (prompts user):**

```
$ mycmd delete project-123
This will permanently delete 'project-123' and all data.
Are you sure? [y/N]: y

Deleting project-123...
✓ Deleted
```

**Non-interactive (for agents):**

```
$ mycmd delete project-123 --yes
Deleting project-123...
✓ Deleted
```

**Without --yes in non-interactive mode:**

```
$ mycmd delete project-123
Error: Use --yes or --force to confirm deletion

This operation cannot be undone.
Run: mycmd delete project-123 --yes
```

**Common patterns:**

| Flag                | Purpose               | Danger   |
| ------------------- | --------------------- | -------- |
| `--yes`, `-y`       | Skip confirmations    | Moderate |
| `--force`, `-f`     | Force dangerous ops   | High     |
| `--confirm=<value>` | Type value to confirm | Severe   |

**For severe operations (require explicit value):**

```
$ mycmd delete-server prod-db
Error: Type server name to confirm: --confirm=prod-db

$ mycmd delete-server prod-db --confirm=prod-db
✓ Deleted
```

**Document in help:**

```
OPTIONS
  -y, --yes    Skip all confirmations
  -f, --force  Force operation

For automation, always use --yes or --force.
```

---

## 11. Analytics No Phone Home

---
title: Don't Phone Home Without Consent
impact: MEDIUM
impactDescription: Violates user trust and privacy expectations
tags: analytics, telemetry, privacy, consent, ethics
---

## Don't Phone Home Without Consent

Never send usage data or crash reports without explicit user consent.

**First-run consent prompt:**

```
$ mycmd init

Welcome to mycmd!

Help improve mycmd by sending anonymous usage data? [y/N]: n

Your choice has been saved. Change anytime with:
  mycmd config set telemetry true
```

**Provide easy disable:**

```bash

export MYCMD_TELEMETRY=off
export DO_NOT_TRACK=1

# Config command
mycmd config set telemetry false

# Flag for one-off
mycmd deploy --no-telemetry
```

**Be transparent:**

```
$ mycmd telemetry status

Telemetry: enabled

We collect:
  - Command names (e.g., 'deploy', 'build')
  - CLI version
  - OS type

We do NOT collect:
  - File paths or arguments
  - Personal information
  - Environment variables

Disable: mycmd config set telemetry false
```

**Rules:**

- Default to OFF (opt-in, not opt-out)
- Never block main operation if telemetry fails
- Respect DO_NOT_TRACK environment variable
- Never collect personal data
- Be explicit about what you collect

---

## 12. Args No Secrets Flags

---
title: Don't Read Secrets from Flags
impact: CRITICAL
impactDescription: Prevents credential leaks via ps and shell history
tags: security, secrets, flags, credentials, passwords
---

## Don't Read Secrets from Flags

Never accept secrets via flags. They leak into `ps` output and shell history.

**Incorrect (exposes secrets):**

```bash

$ mycmd deploy --password secretpass123
$ mycmd login --api-key sk_live_abc123xyz
```

**Why this is dangerous:**

```bash
$ mycmd login --api-key secret123 &
$ ps aux | grep mycmd
user  1234  mycmd login --api-key secret123  # EXPOSED!

$ history
  501  mycmd login --api-key secret123  # EXPOSED!
```

**Correct (secure methods):**

```bash
# Method 1: Read from file
$ mycmd login --password-file ~/.mycmd/password

# Method 2: Read from stdin
$ cat ~/.mycmd/password | mycmd login --password-stdin

# Method 3: Prompt interactively (hidden input)
$ mycmd login
Password:
✓ Logged in
```

**Implementation:**

```typescript
if (options.passwordFile) {
  password = fs.readFileSync(options.passwordFile, 'utf-8').trim()
} else if (!process.stdin.isTTY) {
  password = fs.readFileSync(0, 'utf-8').trim() // stdin
} else {
  const { password: pwd } = await prompts({
    type: 'password',
    name: 'password',
    message: 'Password',
  })
  password = pwd
}
```

**Environment variables are also insecure:**

- Visible to child processes
- Leak into logs

**Use instead:**

- Files with restricted permissions (`chmod 600`)
- Secret management services
- OS keychain
- Interactive prompts

---

## 13. Args Order Independent

---
title: Make Flags Order-Independent
impact: MEDIUM
impactDescription: Matches user expectations, reduces frustration
tags: arguments, flags, ux, parsing, usability
---

## Make Flags Order-Independent

Flags should work regardless of position. Don't require specific ordering.

**Incorrect (order matters - frustrating):**

```
$ mycmd --verbose deploy
✓ Works

$ mycmd deploy --verbose
Error: Unknown option '--verbose'
(User hits up-arrow to add flag at end - breaks!)
```

**Correct (order doesn't matter):**

```
$ mycmd --verbose deploy
✓ Works

$ mycmd deploy --verbose
✓ Works

$ mycmd deploy --env prod --verbose
✓ Works
```

**Why users expect this:**

```

$ mycmd deploy
Error: missing --env

$ mycmd deploy --env prod
✓ Works
```

**Both should work:**

```bash
mycmd --verbose deploy --env prod
mycmd deploy --env prod --verbose
mycmd deploy --verbose --env prod
```

**Implementation:** Use commander, yargs, or oclif - they handle this by default.

**Global vs local flags both work:**

```
$ mycmd --verbose deploy --force
$ mycmd deploy --force --verbose
```

---

## 14. Args Prefer Flags

---
title: Prefer Flags Over Positional Arguments
impact: HIGH
impactDescription: Makes CLIs more maintainable and easier to extend
tags: arguments, flags, api-design, extensibility
---

## Prefer Flags Over Positional Arguments

Use flags instead of positional arguments. Flags are explicit, self-documenting, and easier to extend without breaking changes.

**Incorrect (positional args - hard to read):**

```bash

mycmd deploy myapp production us-east-1 true

# Adding new params breaks everything
mycmd deploy myapp production us-east-1 true verbose
```

**Correct (flags - explicit and clear):**

```bash
# Self-documenting
mycmd deploy --app myapp --env production --region us-east-1 --force

# Easy to add new flags without breaking existing usage
mycmd deploy --app myapp --env production --verbose
```

**Exceptions where positional args are OK:**

1. **Simple file operations:**

   ```bash
   rm file1.txt file2.txt file3.txt
   cp source.txt dest.txt
   ```

2. **Primary action on multiple items:**
   ```bash
   mycmd process *.csv  # Works with globbing
   ```

**Benefits of flags:**

- Order doesn't matter: `mycmd --app foo --env prod` = `mycmd --env prod --app foo`
- Can add new flags without breaking scripts
- Self-documenting: clear what each value represents
- Optional parameters are obvious

**Two or more positional args for different things is wrong:**

```bash
# Bad - what's what?
mycmd source-file dest-file format template

# Good - explicit
mycmd convert --input source-file --output dest-file --format json
```

Reference: https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46

---

## 15. Args Standard Names

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

---

## 16. Args Stdin Stdout

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

---

## 17. Basics Exit Codes

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

---

## 18. Basics Full Flags

---
title: Provide Full-Length Flag Versions
impact: CRITICAL
impactDescription: Improves script readability and self-documentation
tags: basics, flags, arguments, readability
---

## Provide Full-Length Flag Versions

Every flag should have both short (`-v`) and long (`--verbose`) versions. Long versions make scripts self-documenting.

**Incorrect (short flag only):**

```bash

mycmd deploy -v

# Unclear in scripts
#!/bin/bash
mycmd process -v -q -f
```

**Correct (both short and long):**

```typescript
import { Command } from 'commander'

const program = new Command()
program
  .option('-v, --verbose', 'verbose output')
  .option('-q, --quiet', 'suppress output')
  .option('-f, --force', 'force operation')
  .parse(process.argv)
```

Now scripts are readable:

```bash
#!/bin/bash
mycmd process --verbose --quiet --force
# Clear what each flag does
```

**Benefits:**

- Scripts are self-documenting
- No need to look up flag meanings
- Easier to review and maintain
- Both forms work identically

```bash
# These are equivalent
mycmd deploy -v -f
mycmd deploy --verbose --force
mycmd deploy --verbose -f  # Can mix
```

**Other languages:**

```go
// Go with Cobra
cmd.Flags().BoolP("verbose", "v", false, "Verbose output")
```

```python
# Python with Click
@click.option('-v', '--verbose', is_flag=True)
```

---

## 19. Basics Help Flags

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

$ mycmd deploy --environment prod -h
# Shows help instead of trying to deploy
```

---

## 20. Basics Stdout Stderr

---
title: Use stdout and stderr Correctly
impact: CRITICAL
impactDescription: Required for composability and script integration
tags: basics, stdout, stderr, output, piping
---

## Use stdout and stderr Correctly

Send primary output to `stdout` and messages/errors to `stderr`. This enables piping and script composition.

**Incorrect (everything to stdout):**

```typescript
console.log('Processing file...')
console.log('Warning: file is large')
console.log(JSON.stringify(result)) // Mixed with messages!
```

**Correct (stdout for data, stderr for messages):**

```typescript
console.error('Processing file...')
console.error('Warning: file is large')
console.log(JSON.stringify(result)) // Clean output to stdout

// Or more explicit
process.stderr.write('Processing file...\n')
process.stdout.write(JSON.stringify(result) + '\n')
```

**Why this matters:**

```bash

$ mycmd process file.txt > output.json
Processing file...     # User sees this (stderr)
Warning: file is large # User sees this (stderr)
# JSON output is in output.json (stdout)

# If everything went to stdout:
$ mycmd process file.txt > output.json
# User sees nothing, and output.json contains mixed data/messages
```

**Rules:**

- **stdout**: Primary output, machine-readable data, pipe-able content
- **stderr**: Log messages, progress indicators, warnings, errors, human messaging

**Node.js note:** `console.log()` writes to stdout, `console.error()` writes to stderr.

```bash
# Piping works correctly
mycmd list | grep "pattern" | wc -l
```

---

## 21. Basics Use Parsing Library

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

---

## 22. Config Precedence

---
title: Follow Configuration Precedence
impact: MEDIUM
impactDescription: Predictable config behavior expected by users
tags: config, precedence, environment, flags
---

## Follow Configuration Precedence

Apply configuration in order from highest to lowest priority.

**Precedence (highest to lowest):**

1. **Flags** - `--port=5000`
2. **Environment variables** - `MYAPP_PORT=4000`
3. **Project config** - `./.myapprc`
4. **User config** - `~/.config/myapp/config.json`
5. **System config** - `/etc/myapp/config`

**Example behavior:**

```bash

# User config: port = 3000
# No env var, no flag

$ mycmd start
Starting on port 3000...
(uses user config)

$ MYAPP_PORT=4000 mycmd start
Starting on port 4000...
(env var overrides user config)

$ mycmd start --port 5000
Starting on port 5000...
(flag overrides everything)
```

**Why this order makes sense:**

- Flags are most explicit/immediate
- Env vars are session-specific
- Project config is shared with team
- User config is personal
- System config is global default

**Show config sources:**

```
$ mycmd config show port
port = 5000 (from flag --port)

$ mycmd config show port
port = 3000 (from ~/.config/myapp/config.json)
```

---

## 23. Config Xdg Spec

---
title: Follow XDG Base Directory Spec
impact: LOW-MEDIUM
impactDescription: Keeps user's home directory clean and organized
tags: config, xdg, directories, standards
---

## Follow XDG Base Directory Spec

Use XDG Base Directory specification for config file locations. Don't clutter the home directory with dotfiles.

**Incorrect (creates dotfiles in home):**

```typescript
import os from 'os'
import path from 'path'

// Creates ~/.mycmd, ~/.mycmdrc, ~/.mycmd_cache
const configDir = path.join(os.homedir(), '.mycmd')
const cacheDir = path.join(os.homedir(), '.mycmd_cache')
```

**Correct (follows XDG spec):**

```typescript
import os from 'os'
import path from 'path'

// XDG Base Directory locations
const configHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config')
const dataHome = process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local', 'share')
const cacheHome = process.env.XDG_CACHE_HOME || path.join(os.homedir(), '.cache')

// Your app's directories
const configDir = path.join(configHome, 'mycmd')
const dataDir = path.join(dataHome, 'mycmd')
const cacheDir = path.join(cacheHome, 'mycmd')
```

**Standard locations:**

```
~/.config/mycmd/           # Config files (XDG_CONFIG_HOME)
~/.local/share/mycmd/      # Application data (XDG_DATA_HOME)
~/.cache/mycmd/            # Cache files (XDG_CACHE_HOME)
```

**What goes where:**

| Type   | Location                | Example                 |
| ------ | ----------------------- | ----------------------- |
| Config | `~/.config/mycmd/`      | `config.json`, settings |
| Data   | `~/.local/share/mycmd/` | Databases, logs         |
| Cache  | `~/.cache/mycmd/`       | Temp files, downloads   |

**Benefits:**

- Users can backup just `~/.config` for all app settings
- Keeps home directory clean
- Respects user's XDG preferences
- Used by: yarn, fish, neovim, tmux, many modern tools

**Or use env-paths library:**

```typescript
import envPaths from 'env-paths'

const paths = envPaths('mycmd')
// paths.config  => ~/.config/mycmd
// paths.data    => ~/.local/share/mycmd
// paths.cache   => ~/.cache/mycmd
```

**Note:** Windows and macOS have their own conventions, XDG is mainly for Linux/Unix.

Reference: https://specifications.freedesktop.org/basedir-spec/latest/

---

## 24. Errors Exit Code Mapping

---
title: Map Exit Codes to Failure Modes
impact: MEDIUM-HIGH
impactDescription: Enables scripts to handle different error types
tags: errors, exit-codes, automation, error-handling
---

## Map Exit Codes to Failure Modes

Use different exit codes for different error types.

**Standard codes:**

```
0    Success
1    General error
2    Invalid arguments
3    Configuration error
4    Network error (retryable)
5    Permission denied
6    Resource not found
130  Interrupted by Ctrl-C
```

**Document in help:**

```
$ mycmd --help

EXIT CODES
  0   Success
  1   General error
  2   Invalid arguments (fix command and retry)
  3   Configuration error (check config file)
  4   Network error (retryable)
  5   Permission denied (try with sudo)
  6   Resource not found
```

**Scripts can handle specific errors:**

```bash
mycmd deploy

case $? in
  0) echo "✓ Deployed" ;;
  3) echo "Config error"; mycmd init ;;
  4) echo "Network error, retrying..."; sleep 5; mycmd deploy ;;
  5) echo "Permission denied"; sudo mycmd deploy ;;
  *) echo "Unknown error" ;;
esac
```

**Include in JSON output:**

```json
{
  "success": false,
  "error": {
    "code": "NETWORK_ERROR",
    "exitCode": 4,
    "retryable": true
  }
}
```

---

## 25. Errors Important Info End

---
title: Put Important Info at End of Output
impact: MEDIUM
impactDescription: Users naturally look at the last line first
tags: errors, output, ux, attention
---

## Put Important Info at End of Output

Place the most important information at the end. Users' eyes go there first.

**Incorrect (solution at top - user misses it):**

```
$ mycmd deploy

Fix: Run 'mycmd login' first

Deployment failed with error:
  Error code: AUTH_REQUIRED
  Status: 401 Unauthorized
  (20 more lines of debug info...)

Error: Not authenticated
```

**Correct (solution at end - user sees it):**

```
$ mycmd deploy

Error: Not authenticated
Unable to deploy without credentials.

Run: mycmd login
```

**Visual hierarchy:**

```
$ mycmd build

Error: Missing dependency 'libfoo'

Install: apt install libfoo
         ^^^ User's eyes go here
```

**For multiple errors:**

```
$ mycmd validate

Found 3 errors in config.json:
  - Line 5: invalid syntax
  - Line 12: missing field
  - Line 18: unknown property

Fix these errors and run again
                   ^^^ Clear next step
```

**Use red text sparingly:**

- Only for actual errors
- Don't rely on color alone
- Keep important info readable without color

---

## 26. Errors Rewrite For Humans

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

---

## 27. Errors Signal To Noise

---
title: Maintain Signal-to-Noise Ratio
impact: MEDIUM-HIGH
impactDescription: Users can quickly identify actual problems
tags: errors, output, debugging, usability
---

## Maintain Signal-to-Noise Ratio

Keep error output focused. Don't drown the problem in debug info.

**Incorrect (too much noise):**

```
$ mycmd deploy
[DEBUG] Loading config from ~/.mycmdrc
[DEBUG] Config loaded
[DEBUG] Connecting to api.example.com
[DEBUG] Connection established
ERROR: Invalid API key
[DEBUG] Closing connection
[DEBUG] Cleanup complete
```

**Correct (focused, clear):**

```
$ mycmd deploy

Error: Invalid API key

Fix: Set MYCMD_API_KEY environment variable
Or: echo "your-key" > ~/.mycmd/credentials
```

**Group similar errors:**

```

Error: Line 1: invalid format
Error: Line 5: invalid format
... (98 more)

# Good - grouped summary
Error: 100 lines with invalid format

First error at line 1:
  Expected: name,email,age
  Got:      invalid data

Run with --verbose to see all errors
```

**Debug info in verbose mode only:**

```
$ mycmd deploy --verbose
[DEBUG] Loading config...
[DEBUG] Connecting...
Error: Connection failed
[DEBUG] Stack trace: ...
```

**Save full logs to file:**

```
$ mycmd deploy
Error: Deployment failed
Full logs: /tmp/mycmd-deploy.log
```

---

## 28. Future Additive Changes

---
title: Keep Changes Additive
impact: MEDIUM
impactDescription: Avoids breaking user scripts and workflows
tags: future-proofing, api-design, compatibility, versioning
---

## Keep Changes Additive

Add new flags and features. Don't change existing behavior.

**Incorrect (breaks existing scripts):**

```bash

$ mycmd process --output results.txt

# Version 2.0: --output now means format (BREAKS v1!)
$ mycmd process --output json
(tries to write to file named "json")
```

**Correct (additive):**

```bash
# Version 1.0
$ mycmd process --output results.txt

# Version 2.0: Add new flag, keep old
$ mycmd process --output results.txt --format json
```

**Deprecation warnings:**

```
$ mycmd deploy --old-flag

Warning: --old-flag is deprecated
Use --new-flag instead
--old-flag will be removed in v3.0

Deploying...
```

**What's safe to change:**

- Adding new flags/subcommands
- Adding fields to --json
- Improving human output (if users use --json in scripts)

**What breaks users:**

- Removing flags
- Changing flag behavior
- Removing --json fields
- Changing exit codes

---

## 29. Help Concise Default

---
title: Display Concise Help by Default
impact: CRITICAL
impactDescription: Prevents users from getting stuck with unclear error messages
tags: help, usability, documentation, ux
---

## Display Concise Help by Default

When your command requires arguments but is run with none, display concise help text. Don't just error out or hang.

**Incorrect (unclear error):**

```
$ mycmd
Error: missing required argument
```

**Correct (helpful default):**

```
$ mycmd
mycmd - Process and transform data files

Usage: mycmd <file> [options]

Examples:
  mycmd input.csv
  mycmd data.json --format yaml

Options:
  -h, --help     Show detailed help
  -v, --version  Show version

See 'mycmd --help' for more information.
```

**Concise help should include:**

1. Brief description of what the tool does
2. One or two example invocations
3. Most common flags
4. Instruction to pass `--help` for full help

**Example from jq:**

```
$ jq
jq - commandline JSON processor [version 1.6]

Usage:    jq [options] <jq filter> [file...]
          jq [options] --args <jq filter> [strings...]

jq is a tool for processing JSON inputs, applying the given filter to
its JSON text inputs and producing the filter's results as JSON on
standard output.

The simplest filter is ., which copies jq's input to its output
unmodified.

Example:

    $ echo '{"foo": 0}' | jq .
    {
        "foo": 0
    }

For a listing of options, use jq --help.
```

**Exception:** Interactive programs like `npm init` can skip this.

---

## 30. Help Lead Examples

---
title: Lead with Examples in Help Text
impact: HIGH
impactDescription: Users learn from examples faster than reading descriptions
tags: help, examples, documentation, usability
---

## Lead with Examples in Help Text

Put examples first in help text. Users gravitate toward examples and skip dense text.

**Incorrect (examples buried at the end):**

```
$ mycmd --help
mycmd - Data processing tool

OPTIONS:
  -i, --input <file>     Input file path
  -o, --output <file>    Output file path
  -f, --format <fmt>     Output format (json, yaml, csv)
  -v, --verbose          Verbose output
  -q, --quiet            Quiet mode
  --no-header            Skip header row
  --delimiter <char>     Field delimiter
  ... (50 more lines of options) ...

EXAMPLES:
  mycmd -i data.csv -o output.json -f json
```

**Correct (examples up front):**

```
$ mycmd --help
mycmd - Process and transform data files

EXAMPLES
  # Basic usage
  mycmd input.csv

  # Convert CSV to JSON
  mycmd data.csv --format json > output.json

  # Process multiple files
  mycmd *.csv --format yaml --output results/

  # With filtering and transformation
  mycmd data.csv --filter "age > 18" --format json

  # Custom delimiter
  mycmd data.tsv --delimiter '\t' --format json

USAGE
  mycmd <input> [options]

COMMON OPTIONS
  -f, --format <type>     Output format (json, yaml, csv)
  -o, --output <file>     Output file (default: stdout)
  --filter <expression>   Filter rows
  -h, --help             Show this help

Run 'mycmd --help --full' for all options.
```

**Build toward complex usage:**

- Start with simplest example
- Add complexity gradually
- Show actual output when helpful
- Include common use cases

**If you have many examples, separate them:**

```bash
mycmd examples        # Show example gallery
mycmd --help          # Concise help with 2-3 examples
```

Reference: See `git --help` for good example structure

---

## 31. Help Suggest Corrections

---
title: Suggest Corrections for Typos
impact: MEDIUM
impactDescription: Helps users fix mistakes quickly
tags: help, typos, suggestions, usability, ux
---

## Suggest Corrections for Typos

When users make typos, suggest what they likely meant.

**Incorrect (unhelpful):**

```
$ mycmd pss
Error: Unknown command 'pss'
```

**Correct (suggests fix):**

```
$ mycmd pss

Error: Unknown command 'pss'

Did you mean 'ps'? [y/N]: y

Running: mycmd ps
...
```

**Or without prompt:**

```
$ mycmd pss

Error: Unknown command 'pss'

Did you mean:
  ps - Show processes

Run: mycmd ps
```

**Suggest for flags too:**

```
$ mycmd deploy --quite

Error: Unknown flag '--quite'

Did you mean '--quiet'?
```

**From Homebrew:**

```
$ brew update jq

Error: This command updates brew itself.

Did you mean:
  brew upgrade jq
```

**When to suggest:**

- 1-2 character difference
- Common abbreviations
- Case differences

**Don't auto-run corrections:**

- User might mean something else
- Auto-fix commits to supporting that syntax forever

---

## 32. Help Web Documentation

---
title: Provide Web-Based Documentation
impact: MEDIUM
impactDescription: Users need searchable, linkable documentation
tags: documentation, help, web, discoverability
---

## Provide Web-Based Documentation

Provide web docs that users can search, link to, and share.

**Show in help:**

```
$ mycmd --help
mycmd - My CLI tool

Usage: mycmd <command> [options]
...

DOCUMENTATION
  https://mycmd.dev/docs

Report issues: https://github.com/org/mycmd/issues
```

**Link from subcommands:**

```
$ mycmd deploy --help
Deploy application

Usage: mycmd deploy <app> --env <env>
...

Learn more: https://mycmd.dev/docs/deploy
```

**Provide docs command:**

```
$ mycmd docs
Opening https://mycmd.dev/docs...

$ mycmd docs deploy
Opening https://mycmd.dev/docs/deploy...
```

**Link from errors:**

```
$ mycmd config set invalid.key value

Error: Invalid config key 'invalid.key'

Learn more: https://mycmd.dev/docs/configuration
```

**Web docs should include:**

- Getting started guide
- Complete command reference
- Troubleshooting
- API reference (--json schemas)

---

## 33. Interactive No Input Flag

---
title: Support --no-input Flag
impact: MEDIUM
impactDescription: Allows explicit disabling of all prompts
tags: interactivity, flags, automation, scripting
---

## Support --no-input Flag

Provide `--no-input` to explicitly disable all prompts for CI/CD.

**Without --no-input (hangs in CI):**

```
$ mycmd deploy
Environment [staging/production]:
(waits forever in CI - no one to answer)
```

**With --no-input (fails fast with clear error):**

```
$ mycmd deploy --no-input
Error: --env is required when using --no-input

Usage: mycmd deploy --env <env> --no-input
```

**Correct usage in automation:**

```
$ mycmd deploy --env staging --no-input --yes
Deploying to staging...
✓ Deployed successfully
```

**In CI/CD:**

```yaml

- name: Deploy
  run: mycmd deploy --env production --no-input --force
```

**Rules:**

- Fail immediately if required input missing
- Provide clear error showing which flags are needed
- Skip all confirmation prompts
- Works even when stdin is TTY

---

## 34. Interactive Password No Echo

---
title: Don't Echo Passwords as User Types
impact: HIGH
impactDescription: Prevents shoulder-surfing and accidental exposure
tags: security, passwords, interactivity, privacy
---

## Don't Echo Passwords as User Types

Hide password input as the user types. Use password mode.

**Incorrect (password visible):**

```
$ mycmd login
Email: user@example.com
Password: secretpass123
          ^^^^^^^^^^^^^ VISIBLE!
```

**Correct (password hidden):**

```
$ mycmd login
Email: user@example.com
Password:
          (input hidden as user types)

Logged in successfully.
```

**With optional asterisks:**

```
$ mycmd login
Password: **********
```

**Implementation:** Use `prompts` library with `type: 'password'`:

```typescript
import prompts from 'prompts'

const { password } = await prompts({
  type: 'password',
  name: 'password',
  message: 'Password',
})
```

**Also hide:**

- API keys
- Tokens
- Secret values

**Provide non-interactive alternative:**

```bash

mycmd login --password-file ~/.mycmd/password

# From stdin
echo "secret" | mycmd login --password-stdin
```

---

## 35. Interactive Tty Check

---
title: Only Prompt if stdin is a TTY
impact: HIGH
impactDescription: Prevents scripts from hanging on prompts
tags: interactivity, tty, prompts, scripting, automation
---

## Only Prompt if stdin is a TTY

Only prompt when running interactively. In scripts, fail with clear error.

**Incorrect (hangs in scripts):**

```
$ cat deploy.sh
#!/bin/bash
mycmd deploy

$ ./deploy.sh
Continue? [y/N]:
(hangs forever - no one to answer)
```

**Correct (detects non-interactive):**

```
$ ./deploy.sh

Error: Use --force in non-interactive mode

Usage: mycmd deploy --force
```

**Interactive mode works:**

```
$ mycmd deploy
Continue? [y/N]: y
✓ Deployed
```

**Non-interactive with flag:**

```
$ mycmd deploy --force
✓ Deployed
```

**Check stdin TTY:**

```typescript
if (process.stdin.isTTY) {
  // Can prompt
} else {
  // Require flags
}
```

**Always provide --no-input:**

```
$ mycmd deploy --no-input
Error: --env required with --no-input
```

**In CI:**

```yaml
- run: mycmd deploy --no-input --env prod --force
```

---

## 36. Naming Distribute Single Binary

---
title: Distribute as Single Binary When Possible
impact: LOW-MEDIUM
impactDescription: Simplifies installation and reduces dependency issues
tags: distribution, packaging, installation, deployment
---

## Distribute as Single Binary When Possible

Single executables are easier to install and don't require dependency management.

**Good (one file installation):**

```bash
$ curl -L https://mycmd.dev/install.sh | bash
Downloading mycmd...
Installing to /usr/local/bin/mycmd...
✓ Installed

$ mycmd --version
mycmd 1.0.0
```

**For Node.js, use pkg or esbuild:**

```bash

pkg package.json

# Or bundled JS (Node required)
esbuild src/cli.ts --bundle --platform=node --outfile=mycmd.js
```

**Benefits:**

- No dependency hell
- Fast installation
- Works offline
- Easy to uninstall: `rm /usr/local/bin/mycmd`

**Alternative: npm global install**

```bash
npm install -g mycmd
```

**Make uninstall easy:**

```
$ mycmd uninstall
Removed /usr/local/bin/mycmd
Removed ~/.config/mycmd
✓ Uninstalled
```

**Multi-platform builds:**

- `mycmd-macos-arm64`
- `mycmd-macos-x64`
- `mycmd-linux-x64`
- `mycmd-windows-x64.exe`

---

## 37. Naming Simple Memorable

---
title: Use Simple, Memorable Command Names
impact: LOW-MEDIUM
impactDescription: Users type the command name constantly
tags: naming, usability, ux, ergonomics
---

## Use Simple, Memorable Command Names

Choose a command name that is simple, memorable, and easy to type.

**Good command names:**

- `curl` - memorable, easy to type
- `git` - short, unique
- `docker` - recognizable, distinct
- `jq` - very short for frequent use
- `npm` - memorable acronym

**Bad command names:**

- `myApplicationCLI` - too long, mixed case
- `convert` - conflicts with ImageMagick and Windows
- `run` - too generic
- `plum` - awkward to type one-handed (original Docker Compose name, changed to `fig`)

**Formatting rules:**

- **Lowercase only**: `mycmd`, not `MyCMD` or `MyCmd`
- **Use dashes if needed**: `my-app`, not `my_app`
- **Keep it short**: Users type it constantly
- **Make it unique**: Don't conflict with common commands

**Test ergonomics:**

```bash

git status
npm install
docker ps

# Hard to type (awkward)
kubectl get pods  # People alias to k8s
```

**Consider these factors:**

- Can you type it with one hand comfortably?
- Is it easy to spell?
- Will users remember it?
- Does it conflict with existing commands?
- Can you say it out loud clearly?

**Subcommand naming:**

```bash
# Consistent, memorable verbs
mycmd create
mycmd list
mycmd update
mycmd delete

# Avoid confusing pairs
mycmd update vs mycmd upgrade  # Too similar!
```

**If your name is taken, consider:**

- Adding a prefix/suffix: `myapp-cli`
- Using the project name: `acme-deploy`
- Finding a unique alternative: `fig` instead of `plum`

**Document alternatives:**

```bash
# Common pattern for long names
kubectl → alias k=kubectl
kubernetes-cli → k8s
```

---

## 38. Output Json Flag

---
title: Support --json for Machine-Readable Output
impact: HIGH
impactDescription: Enables script integration and programmatic usage
tags: output, json, automation, scripting, api
---

## Support --json for Machine-Readable Output

Provide `--json` for structured output. Essential for scripts and agents.

**Human output:**

```
$ mycmd list
Projects:
  - myapp (active)
  - oldapp (archived)
```

**Machine output:**

```
$ mycmd list --json
{
  "projects": [
    { "name": "myapp", "status": "active" },
    { "name": "oldapp", "status": "archived" }
  ]
}
```

**Pipe to jq:**

```bash
$ mycmd list --json | jq '.projects[0].name'
myapp

$ mycmd list --json | jq '.projects[] | select(.status == "active")'
{
  "name": "myapp",
  "status": "active"
}
```

**All commands should support --json:**

```bash
mycmd list --json
mycmd get user-123 --json
mycmd status --json
```

**JSON should:**

- Be valid, parseable
- Pretty-printed (2 space indent)
- Use consistent field names (camelCase)
- Go to stdout (not stderr)
- Include all relevant data

---

## 39. Output Pager

---
title: Use a Pager for Long Output
impact: LOW-MEDIUM
impactDescription: Improves readability of long output
tags: output, pager, less, usability
---

## Use a Pager for Long Output

Automatically page long output. Don't dump 1000 lines to the terminal.

**Without pager (scrolls off screen):**

```
$ mycmd logs
(1000 lines scroll by)
...
line 998
line 999
line 1000
```

**With pager (readable):**

```
$ mycmd logs
(opens in less, can scroll/search)
```

**Examples that use pagers:**

- `git diff`
- `git log`
- `man` pages

**When to page:**

- Help text with many commands
- Log output
- Diff output
- Any output >100 lines

**Don't page when:**

- Output is piped: `mycmd logs | grep error`
- `--json` or `--plain` output
- Not a TTY
- User passed `--no-pager`

**Good less options: `less -FIRX`**

- `-F`: Don't page if fits on screen
- `-I`: Case-insensitive search
- `-R`: Allow colors
- `-X`: Don't clear screen on exit

---

## 40. Output Plain Flag

---
title: Support --plain for Script-Friendly Output
impact: MEDIUM
impactDescription: Enables reliable parsing in scripts
tags: output, scripting, automation, parsing
---

## Support --plain for Script-Friendly Output

Provide `--plain` for stable, parseable output that works with grep/awk.

**Human output (wrapped, multi-line):**

```
$ mycmd list
NAME        STATUS      DETAILS
myapp       Running     Started 2 hours ago
                        Memory: 512MB
                        CPU: 2.3%
```

**Plain output (one record per line):**

```
$ mycmd list --plain
myapp	running	2h	512MB	2.3%

$ mycmd list --plain | awk '{print $1, $2}'
myapp running
```

**Why both --plain and --json:**

```bash

$ mycmd list --json | jq '.[] | select(.status == "running")'

# --plain for simple text processing
$ mycmd list --plain | grep running | cut -f1
```

**--plain should:**

- One record per line
- Consistent delimiters (tabs recommended)
- No wrapping or truncation
- Stable across versions

**Pipeline friendly:**

```bash
$ mycmd list --plain | grep "prod" | awk '{print $1}' | xargs mycmd restart
```

---

## 41. Output State Changes

---
title: Tell the User When You Change State
impact: MEDIUM
impactDescription: Users need to understand what happened
tags: output, state, feedback, transparency
---

## Tell the User When You Change State

Explain what changed. Help users understand the new state.

**Incorrect (silent):**

```
$ mycmd deploy
$
(did it work? what happened?)
```

**Correct (explains what happened):**

```
$ mycmd deploy

Uploading files... done (15 files, 2.3 MB)
Building application... done (1m 23s)
Deploying to production... done

✓ Deployed successfully
  URL: https://myapp.com
  Version: v1.2.3

View logs: mycmd logs myapp
```

**git push example (explains every step):**

```
$ git push
Enumerating objects: 18, done.
Counting objects: 100% (18/18), done.
Compressing objects: 100% (10/10), done.
Writing objects: 100% (10/10), 2.09 KiB, done.
To github.com:user/repo.git
   6c22c90..a2a5217  main -> main
```

**Show current state + next steps:**

```
$ git status
On branch main
Changes not staged:
  modified: src/index.js

no changes added to commit (use "git add")
```

**After init (suggests next steps):**

```
$ mycmd init myproject

✓ Created project 'myproject'

Next steps:
  1. cd myproject
  2. mycmd start
  3. Open http://localhost:3000
```

---

## 42. Output Tty Detection

---
title: Check if TTY Before Using Colors/Animations
impact: HIGH
impactDescription: Prevents broken output in pipes and CI/CD
tags: output, tty, colors, animations, piping
---

## Check if TTY Before Using Colors/Animations

Only use colors and animations when outputting to a terminal. They break in pipes.

**With TTY detection (works everywhere):**

```
$ mycmd deploy
✓ Deployed successfully
(shows colors in terminal)

$ mycmd deploy | cat
Deployed successfully
(plain text when piped)
```

**Without TTY detection (breaks):**

```
$ mycmd deploy | cat
^[[32mDeployed successfully^[[0m
(escape codes visible)
```

**Check before colors:**

```typescript
if (process.stdout.isTTY) {
  console.log('\x1b[32mSuccess!\x1b[0m')
} else {
  console.log('Success!')
}
```

**Use chalk (auto-detects):**

```typescript
import chalk from 'chalk'
console.log(chalk.green('Success!'))
// Colors in terminal, plain when piped
```

**Also disable colors when:**

- `NO_COLOR` env var is set
- `TERM=dumb`
- `--no-color` flag passed

**Animations must check TTY:**

```typescript
if (process.stderr.isTTY) {
  showProgressBar()
} else {
  console.error('Processing...')
}
```

---

## 43. Robustness 100ms Response

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

---

## 44. Robustness Idempotent

---
title: Make Operations Idempotent
impact: MEDIUM
impactDescription: Safe to retry, arrow-up and enter works
tags: robustness, idempotency, reliability, recovery
---

## Make Operations Idempotent

Running an operation twice should have the same effect as running it once.

**Good idempotent behavior:**

```
$ mycmd deploy
Deploying...
✓ Deployed

$ mycmd deploy
Already deployed, checking for updates...
No changes detected.
✓ Up to date
```

**Handles retry after failure:**

```
$ mycmd setup
Creating directory...
Installing dependencies...
Error: Network timeout

$ mycmd setup
Directory already exists, skipping...
Installing dependencies...
✓ Setup complete
```

**Check existing state:**

```
$ mycmd init myproject
Error: Directory 'myproject' already exists

Use --force to overwrite, or choose different name
```

**Atomic operations prevent partial state:**

```typescript
// Write to temp file, then atomic rename
fs.writeFileSync(tempPath, content)
fs.renameSync(tempPath, finalPath) // Atomic
```

**Benefits:**

- Just hit up-arrow and enter to retry
- No cleanup needed after failures
- Safe to run multiple times

---

## 45. Robustness Network Timeouts

---
title: Set Timeouts on Network Operations
impact: HIGH
impactDescription: Prevents hanging forever on network issues
tags: robustness, network, timeouts, http, reliability
---

## Set Timeouts on Network Operations

Always set timeouts. Don't hang forever if the server doesn't respond.

**Without timeout (hangs forever):**

```
$ mycmd deploy
Connecting to server...
(hangs forever if server is down)
```

**With timeout (fails fast):**

```
$ mycmd deploy
Connecting to server...
Error: Request timed out after 30s

Check:
  - Network connection
  - Server status

Or increase timeout: mycmd deploy --timeout 60
```

**Implementation:**

```typescript
const response = await fetch(url, {
  signal: AbortSignal.timeout(30000),
})
```

**Make configurable:**

```
$ mycmd deploy --timeout 60
```

**Different timeouts for different operations:**

- Connection: 5-10s
- Read: 30-60s
- Large uploads: 5-10 minutes

**Retry with backoff:**

```
$ mycmd deploy
Connection failed, retrying in 2s...
Connection failed, retrying in 4s...
✓ Connected
```

---

## 46. Robustness Progress Indicators

---
title: Show Progress for Long Operations
impact: MEDIUM
impactDescription: Prevents users thinking program is frozen
tags: robustness, progress, ux, feedback
---

## Show Progress for Long Operations

Display progress for operations >1 second. Don't leave users wondering if it's frozen.

**Incorrect (silent for 5 minutes):**

```
$ mycmd process files/*.csv
(silence...)
Done
```

**Correct (shows progress):**

```
$ mycmd process files/*.csv

Processing files...
████████████░░░░░░░░░ 45% | 45/100 | ETA: 28s
```

**With spinner:**

```
$ mycmd deploy
⠋ Deploying application... (30s)
```

**Multiple tasks:**

```
$ mycmd setup

Setting up environment...
  ✓ Install dependencies (12s)
  ⠹ Build application (running...)
  ⠿ Start services (waiting...)
```

**Parallel operations:**

```
$ mycmd download

Downloading files...
  ✓ image1.png  [████████████████████] 100% (2.3 MB)
  ⠹ image2.png  [██████████░░░░░░░░░░]  50% (1.1 MB)
  ⠋ image3.png  [████░░░░░░░░░░░░░░░░]  20% (0.4 MB)
```

**Only show in TTY:**

- Check `process.stderr.isTTY`
- Plain output for scripts/CI

**Libraries:** ora, cli-progress, listr2

---

## 47. Robustness Validate Early

---
title: Validate Input Early, Fail Fast
impact: MEDIUM-HIGH
impactDescription: Catches errors before work is done
tags: robustness, validation, errors, inputs
---

## Validate Input Early, Fail Fast

Validate all inputs before doing work. Don't wait 15 minutes to discover bad input.

**Incorrect (validates too late):**

```
$ mycmd deploy myapp invalid-env us-east-1

Starting deployment...
Uploading files... (5 minutes)
Building... (10 minutes)
Error: Invalid environment 'invalid-env'
```

**Correct (validates first):**

```
$ mycmd deploy myapp invalid-env us-east-1

Error: Invalid environment 'invalid-env'
Valid: staging, production

Fix and retry
```

**Validate everything upfront:**

```
$ mycmd deploy --env prod --region invalid

Error: Invalid region 'invalid'
Valid regions: us-east-1, us-west-2, eu-west-1

Run 'mycmd regions list' to see all regions
```

**Multiple validation errors:**

```
$ mycmd deploy

Errors:
  - Missing required flag: --env
  - Invalid region: xyz
  - File not found: config.json

Fix these errors and retry
```

**Benefits:**

- Fails in <1 second instead of after minutes
- Clear, immediate feedback
- No wasted work

---

## 48. Signals Crash Only Design

---
title: Design for Crash-Only Operation
impact: MEDIUM-HIGH
impactDescription: Program can be killed at any time without corruption
tags: signals, robustness, crash-only, recovery, cleanup
---

## Design for Crash-Only Operation

Design your CLI to be safely killed at any time. Don't rely on cleanup running.

**Crash-safe behavior:**

```
$ mycmd process
Processing...
^C
(killed mid-operation)

$ mycmd process
Cleaning up from previous run...
Resuming from item 45/100...
✓ Done
```

**Use atomic operations:**

```typescript
// Atomic file write - never leaves partial file
fs.writeFileSync(tempPath, content)
fs.renameSync(tempPath, finalPath) // Atomic
```

**Clean up stale state on startup:**

```
$ mycmd start

Detected stale lock file from crashed run
Cleaning up...
Starting fresh...
```

**Check for lock files:**

```typescript
if (fs.existsSync('.mycmd.lock')) {
  const pid = fs.readFileSync('.mycmd.lock', 'utf-8')
  if (!isProcessRunning(pid)) {
    console.error('Cleaning up from previous crashed run...')
    fs.unlinkSync('.mycmd.lock')
  }
}
```

**Principles:**

- Clean up in next run, not during shutdown
- Use atomic file operations
- Check for stale state on startup
- Don't require graceful shutdown

Reference: https://lwn.net/Articles/191059/

---

## 49. Signals Exit On Ctrl C

---
title: Exit Immediately on Ctrl-C
impact: HIGH
impactDescription: Users expect Ctrl-C to always work
tags: signals, ctrl-c, sigint, responsiveness, ux
---

## Exit Immediately on Ctrl-C

When user hits Ctrl-C, respond immediately and exit.

**Good Ctrl-C behavior:**

```
$ mycmd process

Processing files...
^C
Cancelled.
$
(exits immediately)
```

**Allow second Ctrl-C to force quit:**

```
$ mycmd deploy

Deploying...
^C
Gracefully stopping... (press Ctrl+C again to force)
(cleaning up...)
✓ Stopped


^C^C
Force quitting!
$
```

**Docker Compose example:**

```
$ docker-compose up
...
^CGracefully stopping... (press Ctrl+C again to force)
```

**Implementation:**

```typescript
process.on('SIGINT', () => {
  console.error('\nCancelled.')
  process.exit(130) // 128 + SIGINT(2)
})
```

**For long cleanup:**

```typescript
let forceQuit = false

process.on('SIGINT', () => {
  if (forceQuit) {
    console.error('\nForce quitting!')
    process.exit(130)
  }
  forceQuit = true
  console.error('\nStopping... (press Ctrl+C again to force)')
  gracefulShutdown()
})
```

**Rules:**

- Say something immediately
- Exit with code 130
- Add timeout to cleanup (max 5s)
- Allow second Ctrl-C to force

---

## 50. Subcommands Consistency

---
title: Be Consistent Across Subcommands
impact: MEDIUM-HIGH
impactDescription: Reduces cognitive load and improves predictability
tags: subcommands, consistency, flags, ux
---

## Be Consistent Across Subcommands

Use the same flag names, output formats, and patterns across all subcommands.

**Incorrect (inconsistent flags):**

```bash

mycmd users list --output json
mycmd projects list --format json  # Different flag!
mycmd teams list -f json            # Different flag again!
```

**Correct (consistent flags):**

```bash
# Same flag everywhere
mycmd users list --format json
mycmd projects list --format json
mycmd teams list --format json

# Or all support -o shorthand
mycmd users list -o json
mycmd projects list -o json
```

**Use consistent verbs:**

| Action | Good                  | Avoid mixing         |
| ------ | --------------------- | -------------------- |
| Create | `create`              | `new`, `add`, `make` |
| Read   | `get`, `list`, `show` | `display`, `view`    |
| Update | `update`, `set`       | `modify`, `change`   |
| Delete | `delete`, `remove`    | `rm`, `destroy`      |

**Example of good consistency (Docker):**

```bash
docker container create
docker container list
docker container start
docker container stop
docker container remove

docker image create
docker image list
docker image push
docker image pull
docker image remove
```

**Inconsistent patterns to avoid:**

```bash
# Bad - similar names, different meanings
mycmd update     # Update dependencies
mycmd upgrade    # Upgrade version??

# Good - clear distinction
mycmd update-deps
mycmd upgrade-version
```

**Shared behavior across subcommands:**

- Global flags work everywhere: `--verbose`, `--config`
- Output format flags: `--json`, `--plain`
- Authentication/credentials
- Help patterns: `mycmd help <subcommand>`

**Benefits:**

- Users learn once, apply everywhere
- Reduces documentation burden
- Predictable behavior
- Lower cognitive load

---

## 51. Subcommands Consistent Verbs

---
title: Use Consistent Verbs Across Subcommands
impact: MEDIUM
impactDescription: Reduces cognitive load, makes CLI guessable
tags: subcommands, verbs, consistency, api-design
---

## Use Consistent Verbs Across Subcommands

Use the same verb for the same action across all resources.

**Incorrect (inconsistent):**

```bash
mycmd users create      # create
mycmd projects new      # new (different!)
mycmd teams add         # add (different!)
```

**Correct (consistent):**

```bash
mycmd users create
mycmd projects create
mycmd teams create
```

**Standard CRUD verbs:**

| Action | Use                | Avoid mixing         |
| ------ | ------------------ | -------------------- |
| Create | `create`           | `new`, `add`, `make` |
| Read   | `get`, `show`      | `display`, `view`    |
| List   | `list`             | `ls`, `all`          |
| Update | `update`           | `modify`, `edit`     |
| Delete | `delete`, `remove` | `rm`, `destroy`      |

**Docker example (good):**

```bash
docker container create
docker container list
docker container start
docker container remove

docker image create
docker image list
docker image remove
```

**kubectl example (consistent):**

```bash
kubectl create deployment
kubectl get deployment
kubectl delete deployment

kubectl create pod
kubectl get pod
kubectl delete pod
```

Pick one pattern and use everywhere.

---

## 52. Subcommands No Abbreviations

---
title: Don't Allow Arbitrary Abbreviations
impact: MEDIUM
impactDescription: Prevents breaking changes when adding commands
tags: subcommands, abbreviations, future-proofing, aliases
---

## Don't Allow Arbitrary Abbreviations

Don't auto-expand subcommand prefixes. It prevents adding new commands.

**Problem:**

```

$ mycmd i
Running: install

# Later you add 'inspect' command
$ mycmd i
Error: Ambiguous command 'i' - could be 'install' or 'inspect'

# Or worse, silently runs wrong command!
```

**Correct (explicit aliases only):**

```
$ mycmd install
✓ Installed

$ mycmd i
✓ Installed  (documented alias)

$ mycmd ins
Error: Unknown command 'ins'
Did you mean 'install'? Use 'i' or 'install'
```

**Explicit aliases are fine:**

```
$ mycmd --help
Commands:
  install, i, add    Install package
  remove, rm         Remove package
```

**kubectl example:**

```
$ kubectl get pods    # Full command
$ kubectl get po      # Documented short form
$ kubectl get p       # Error: unknown resource
```

**Benefits:**

- Can add new commands safely
- Aliases are documented and stable
- No surprising behavior

---

## 53. Subcommands No Catch All

---
title: Don't Have Catch-All Subcommands
impact: MEDIUM
impactDescription: Prevents breaking changes when adding commands
tags: subcommands, future-proofing, api-design, parsing
---

## Don't Have Catch-All Subcommands

Don't make unknown commands default to a subcommand. Prevents adding commands later.

**Problem:**

```

$ mycmd echo "hello"
(runs: mycmd run echo "hello")

# Version 2.0: you add 'echo' subcommand
$ mycmd echo "hello"
(now runs the NEW echo command - BREAKS scripts!)
```

**Correct (explicit subcommands only):**

```
$ mycmd echo "hello"
Error: Unknown command 'echo'

Did you mean: mycmd run echo "hello"
```

**Require explicit subcommand:**

```
$ mycmd run echo "hello"
hello

$ mycmd r echo "hello"  # Explicit alias OK
hello
```

**npm example (requires explicit 'run'):**

```
$ npm build
Error: Unknown command 'build'

Did you mean: npm run build
```

**Provide helpful error:**

```
$ mycmd unknown-cmd
Error: Unknown command 'unknown-cmd'

Did you mean: mycmd run unknown-cmd?

Run 'mycmd --help' for available commands
```

**Benefits:**

- Can add new commands without breaking scripts
- Explicit is better than implicit
- No ambiguity

---

## References

1. [https://clig.dev/](https://clig.dev/)
2. [https://github.com/cli-guidelines/cli-guidelines](https://github.com/cli-guidelines/cli-guidelines)
3. [https://en.wikipedia.org/wiki/The_Unix_Programming_Environment](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment)
4. [https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)
5. [https://www.gnu.org/prep/standards/html_node/Program-Behavior.html](https://www.gnu.org/prep/standards/html_node/Program-Behavior.html)
6. [https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)
7. [https://devcenter.heroku.com/articles/cli-style-guide](https://devcenter.heroku.com/articles/cli-style-guide)
