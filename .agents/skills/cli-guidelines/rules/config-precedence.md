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
# System config: port = 8080
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
