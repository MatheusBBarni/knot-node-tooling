# Subcommands

## When to Use

Use subcommands when you have:

- Multiple distinct operations on the same resource
- A complex tool that would otherwise have too many flags
- Related tools that benefit from shared configuration/context

Examples: `git commit`, `docker container ls`, `kubectl get pods`

## Structure Patterns

### Single Level

```
mycmd <subcommand> [options]

mycmd init
mycmd build
mycmd deploy
```

### Two Levels (noun-verb or verb-noun)

```
# Noun-verb (more common)
mycmd container create
mycmd container list
mycmd container delete

# Verb-noun
mycmd create container
mycmd list containers
```

**Be consistent** — pick one pattern and stick with it.

## Consistency Rules

**Use the same flag names across subcommands:**

```bash
mycmd users list --output json
mycmd projects list --output json  # Same flag, same behavior
```

**Use consistent verbs:**
| Action | Good | Avoid mixing |
|--------|------|--------------|
| Create | `create` | `new`, `add`, `make` |
| Read | `get`, `list`, `show` | `display`, `view`, `read` |
| Update | `update`, `set` | `modify`, `change`, `edit` |
| Delete | `delete`, `remove` | `rm`, `destroy`, `drop` |

## Avoid Ambiguity

Don't have similarly-named commands:

```bash
# Confusing
mycmd update   # Update what?
mycmd upgrade  # How is this different?

# Clear
mycmd update-deps      # Update dependencies
mycmd upgrade-version  # Upgrade to new version
```

## Help for Subcommands

Support all these patterns:

```bash
mycmd help
mycmd --help
mycmd subcommand --help
mycmd subcommand -h
mycmd help subcommand
```

Each subcommand should have its own help:

```
$ mycmd deploy --help
Deploy the application to a target environment.

USAGE
  $ mycmd deploy <environment> [options]

ARGUMENTS
  environment    Target environment (staging, production)

OPTIONS
  -f, --force    Deploy without confirmation
  --dry-run      Show what would be deployed

EXAMPLES
  $ mycmd deploy staging
  $ mycmd deploy production --dry-run
```

## Global vs Local Flags

Some flags apply globally, others to specific subcommands:

```bash
# Global flags (before subcommand)
mycmd --verbose deploy staging

# Local flags (after subcommand)
mycmd deploy staging --force
```

**Document which flags are global:**

```
GLOBAL OPTIONS
  --verbose, -v   Enable verbose output
  --config        Path to config file

COMMAND OPTIONS
  --force         Skip confirmation (deploy only)
```

## Don't Allow Arbitrary Abbreviations

If `install` is a subcommand, don't auto-expand `i` or `ins`:

```bash
# Don't do this
mycmd i      # Means install?
mycmd ins    # Also install?
```

This prevents adding new subcommands starting with `i` later.

**Explicit aliases are OK:**

```bash
mycmd install   # Full command
mycmd i         # Documented alias
```

## Avoid Catch-all Subcommands

Don't make the most common subcommand implicit:

```bash
# Dangerous pattern
mycmd echo "hello"  # Assumes 'run' subcommand

# Later you can never add an 'echo' subcommand!
```

If you want shortcuts, use explicit aliases.

## Shared Configuration

Subcommands should share:

- Config file location
- Authentication/credentials
- Output formatting preferences
- Verbosity settings

```bash
# Config applies to all subcommands
mycmd config set output.format json
mycmd users list    # Uses JSON format
mycmd projects list # Also uses JSON format
```

## Exit Codes

Use consistent exit codes across all subcommands:

```
0 - Success
1 - General error
2 - Invalid usage / bad arguments
```
