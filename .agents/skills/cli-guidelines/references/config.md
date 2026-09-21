# Configuration

## Configuration Types

| Type           | Changes   | Scope        | Storage          |
| -------------- | --------- | ------------ | ---------------- |
| Per-invocation | Every run | Session      | Flags            |
| Per-session    | Rarely    | User/machine | Env vars         |
| Per-project    | Rarely    | Project      | Project file     |
| Per-user       | Rarely    | User         | User config file |
| System-wide    | Rarely    | All users    | System config    |

## Precedence (Highest to Lowest)

1. **Flags** — `--config-value=X`
2. **Environment variables** — `MYAPP_CONFIG_VALUE=X`
3. **Project config** — `./.myapprc`, `./.env`
4. **User config** — `~/.config/myapp/config.json`
5. **System config** — `/etc/myapp/config`

Later values are overridden by earlier ones.

## XDG Base Directory Spec

Follow XDG for config file locations:

```
~/.config/myapp/           # User config (XDG_CONFIG_HOME)
~/.local/share/myapp/      # User data (XDG_DATA_HOME)
~/.cache/myapp/            # Cache (XDG_CACHE_HOME)
```

```python
import os

config_home = os.environ.get('XDG_CONFIG_HOME', os.path.expanduser('~/.config'))
config_dir = os.path.join(config_home, 'myapp')
```

## Environment Variables

**Naming rules:**

- Uppercase letters, numbers, underscores only
- Don't start with a number
- Prefix with app name: `MYAPP_*`

```bash
MYAPP_DEBUG=1
MYAPP_CONFIG_PATH=/path/to/config
MYAPP_API_KEY=xxx
```

**Check standard env vars:**

- `NO_COLOR` / `FORCE_COLOR` — color output
- `DEBUG` — verbose output
- `EDITOR` — text editor
- `HTTP_PROXY`, `HTTPS_PROXY` — network proxy
- `HOME` — user home directory
- `TMPDIR` — temporary files
- `PAGER` — output pager (less, more)
- `TERM` — terminal type

## The .env File

Read `.env` for project-specific env vars:

```bash
# .env
DATABASE_URL=postgres://localhost/myapp
API_KEY=dev-key-123
```

```python
from dotenv import load_dotenv
load_dotenv()  # Loads .env into os.environ
```

**Don't use .env for:**

- Secrets in production (use secret manager)
- Complex configuration (use proper config file)
- Version-controlled settings (use config file)

## Config File Formats

| Format | Pros               | Cons                 |
| ------ | ------------------ | -------------------- |
| JSON   | Universal, typed   | No comments          |
| YAML   | Readable, comments | Whitespace-sensitive |
| TOML   | Readable, comments | Less known           |
| INI    | Simple             | Limited structure    |

```toml
# config.toml
[server]
port = 8080
host = "localhost"

[database]
url = "postgres://localhost/myapp"
```

## Modifying System Config

If your tool modifies system config:

1. **Ask for consent** before modifying
2. **Show exactly what will change**
3. **Create new files** rather than appending to existing (e.g., `/etc/cron.d/myapp` not `/etc/crontab`)
4. **Add dated comments** if you must append:

```bash
# Added by myapp on 2024-01-15
0 * * * * /usr/bin/myapp sync
```

## Config Commands

Provide commands to manage config:

```bash
mycmd config list              # Show all config
mycmd config get key           # Get specific value
mycmd config set key value     # Set value
mycmd config unset key         # Remove value
mycmd config edit              # Open in $EDITOR
mycmd config path              # Show config file location
```

## Secrets

**Never store secrets in:**

- Environment variables (leak to child processes, logs)
- Config files (may be committed to git)
- Command-line flags (visible in `ps`)

**Do store secrets in:**

- Dedicated secret files with restricted permissions
- Secret management services (Vault, AWS Secrets Manager)
- OS keychain/credential manager

```bash
# Good: Read from file
mycmd --credentials-file ~/.myapp/credentials

# Good: Read from stdin
cat credentials | mycmd --credentials-stdin
```

## Validation

Validate config at startup:

```
$ mycmd start
Error: Invalid configuration
  - server.port: must be between 1 and 65535 (got: 99999)
  - database.url: missing required field
```
