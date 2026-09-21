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
# Different flags for same thing
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
