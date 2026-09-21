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
