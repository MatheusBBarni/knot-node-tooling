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
