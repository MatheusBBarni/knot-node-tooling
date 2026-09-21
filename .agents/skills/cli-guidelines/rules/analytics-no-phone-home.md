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
# Environment variable
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
