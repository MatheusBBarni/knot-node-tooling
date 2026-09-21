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
