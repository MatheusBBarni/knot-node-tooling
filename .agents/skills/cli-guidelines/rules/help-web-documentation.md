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
