---
title: Follow XDG Base Directory Spec
impact: LOW-MEDIUM
impactDescription: Keeps user's home directory clean and organized
tags: config, xdg, directories, standards
---

## Follow XDG Base Directory Spec

Use XDG Base Directory specification for config file locations. Don't clutter the home directory with dotfiles.

**Incorrect (creates dotfiles in home):**

```typescript
import os from 'os'
import path from 'path'

// Creates ~/.mycmd, ~/.mycmdrc, ~/.mycmd_cache
const configDir = path.join(os.homedir(), '.mycmd')
const cacheDir = path.join(os.homedir(), '.mycmd_cache')
```

**Correct (follows XDG spec):**

```typescript
import os from 'os'
import path from 'path'

// XDG Base Directory locations
const configHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config')
const dataHome = process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local', 'share')
const cacheHome = process.env.XDG_CACHE_HOME || path.join(os.homedir(), '.cache')

// Your app's directories
const configDir = path.join(configHome, 'mycmd')
const dataDir = path.join(dataHome, 'mycmd')
const cacheDir = path.join(cacheHome, 'mycmd')
```

**Standard locations:**

```
~/.config/mycmd/           # Config files (XDG_CONFIG_HOME)
~/.local/share/mycmd/      # Application data (XDG_DATA_HOME)
~/.cache/mycmd/            # Cache files (XDG_CACHE_HOME)
```

**What goes where:**

| Type   | Location                | Example                 |
| ------ | ----------------------- | ----------------------- |
| Config | `~/.config/mycmd/`      | `config.json`, settings |
| Data   | `~/.local/share/mycmd/` | Databases, logs         |
| Cache  | `~/.cache/mycmd/`       | Temp files, downloads   |

**Benefits:**

- Users can backup just `~/.config` for all app settings
- Keeps home directory clean
- Respects user's XDG preferences
- Used by: yarn, fish, neovim, tmux, many modern tools

**Or use env-paths library:**

```typescript
import envPaths from 'env-paths'

const paths = envPaths('mycmd')
// paths.config  => ~/.config/mycmd
// paths.data    => ~/.local/share/mycmd
// paths.cache   => ~/.cache/mycmd
```

**Note:** Windows and macOS have their own conventions, XDG is mainly for Linux/Unix.

Reference: https://specifications.freedesktop.org/basedir-spec/latest/
