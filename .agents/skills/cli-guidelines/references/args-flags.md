# Arguments and Flags

## Terminology

- **Arguments (args)**: Positional parameters. Order matters: `cp foo bar` ≠ `cp bar foo`
- **Flags**: Named parameters with `-` or `--`. Order usually doesn't matter.

## Core Rules

**Prefer flags to args:**

- More explicit and readable
- Easier to extend without breaking changes
- Self-documenting in scripts

**Have full-length versions of all flags:**

```bash
# Both should work
mycmd -v
mycmd --verbose
```

**Only use single-letter flags for common operations:**

- Don't "pollute" short flag namespace
- Reserve for top-level, frequently-used flags

## Standard Flag Names

Use these when applicable—users expect them:

| Flag | Long form    | Purpose                  |
| ---- | ------------ | ------------------------ |
| `-a` | `--all`      | All items                |
| `-d` | `--debug`    | Debug output             |
| `-f` | `--force`    | Force operation          |
| `-h` | `--help`     | Show help                |
| `-n` | `--dry-run`  | Simulate without changes |
| `-o` | `--output`   | Output file              |
| `-p` | `--port`     | Port number              |
| `-q` | `--quiet`    | Suppress output          |
| `-u` | `--user`     | User name                |
| `-v` | `--verbose`  | Verbose output           |
|      | `--version`  | Show version             |
|      | `--json`     | JSON output              |
|      | `--no-input` | Disable prompts          |

## Multiple Arguments

OK for simple actions on multiple files:

```bash
rm file1.txt file2.txt file3.txt
rm *.txt  # Works with globbing
```

**If you have two+ args for different things, you're doing it wrong.**
Exception: Common primary actions like `cp <source> <dest>`.

## Order Independence

Make flags work regardless of position:

```bash
# Both should work identically
mycmd --foo=1 subcmd
mycmd subcmd --foo=1
```

## Reading from Stdin

Support `-` to read from stdin or write to stdout:

```bash
curl https://example.com/file.tar.gz | tar xvf -
cat input.txt | mycmd -
mycmd - > output.txt
```

## Optional Flag Values

Use a special word like "none" instead of empty:

```bash
ssh -F none  # No config file
ssh -F       # Ambiguous!
```

## Secrets

**Never read secrets from flags:**

```bash
# BAD - leaks to ps, shell history
mycmd --password=secret123

# GOOD - read from file
mycmd --password-file=/path/to/secret

# GOOD - read from stdin
echo "secret" | mycmd --password-stdin
```

## Dangerous Operations

Confirm before destructive actions:

| Risk Level | Example          | Approach                          |
| ---------- | ---------------- | --------------------------------- |
| Mild       | Delete file      | Maybe prompt                      |
| Moderate   | Delete directory | Prompt y/n or require `--force`   |
| Severe     | Delete server    | Require `--confirm="server-name"` |

```bash
# Moderate: prompt or force flag
$ mycmd delete-bucket mybucket
Are you sure? [y/N]:

$ mycmd delete-bucket mybucket --force

# Severe: require explicit confirmation
$ mycmd delete-server prod
Type server name to confirm: prod
```

## Prompting

- **Prompt for missing required input** if running interactively
- **Never require prompts** — always allow flag/arg input
- Skip prompts when stdin is not a TTY (scripts, pipes)
