# Naming and Distribution

## Command Naming

**Make it memorable:**

- Simple, single word when possible
- Easy to spell and type
- Unique enough to not conflict with existing commands

**Formatting rules:**

- Lowercase only
- Use dashes if needed (not underscores): `my-app` not `my_app`
- Keep it short (users type it constantly)

**Good names:**

- `curl` — memorable, easy to type
- `git` — short, unique
- `docker` — recognizable, distinct
- `jq` — very short for frequent use

**Bad names:**

- `myApplicationCLI` — too long, mixed case
- `convert` — conflicts with ImageMagick and Windows
- `run` — too generic
- `plum` — awkward to type one-handed (the original name for Docker Compose was changed to `fig` for this reason)

## Ergonomics

**Easy on the hands:**

- Avoid awkward key combinations
- Test typing the name repeatedly
- Consider common keyboard layouts

```
# Easy to type
git, npm, go, ls, cd

# Harder to type
kubectl (people alias to k8s)
```

## Subcommand Naming

Use consistent verb patterns:

| Action  | Recommended                  |
| ------- | ---------------------------- |
| Create  | `create`, `new`, `init`      |
| Read    | `get`, `list`, `show`, `cat` |
| Update  | `update`, `set`, `edit`      |
| Delete  | `delete`, `remove`, `rm`     |
| Execute | `run`, `exec`, `start`       |

## Distribution

### Single Binary

**Distribute as one file when possible:**

```bash
# User downloads and runs - no dependencies
curl -L https://example.com/mycmd > /usr/local/bin/mycmd
chmod +x /usr/local/bin/mycmd
```

**Tools for creating single binaries:**

- Go: compiles to single binary by default
- Rust: compiles to single binary by default
- Python: PyInstaller, Nuitka
- Node: pkg, nexe

### Package Managers

**Provide packages for common managers:**

```bash
# macOS
brew install mycmd

# Linux
apt install mycmd
yum install mycmd

# Language-specific
pip install mycmd
npm install -g mycmd
cargo install mycmd
```

### Installation Script

**Provide a simple install script:**

```bash
curl -sSL https://example.com/install.sh | bash
```

**The script should:**

- Detect OS and architecture
- Download appropriate binary
- Install to appropriate location
- Verify checksum
- Print success message

### Uninstallation

**Make it easy to remove:**

```bash
# Clean removal
mycmd uninstall

# Or document manual removal
rm /usr/local/bin/mycmd
rm -rf ~/.config/mycmd
```

**Put uninstall instructions near install instructions** — users often want to uninstall right after trying.

## Version Management

**Include version in binary:**

```bash
$ mycmd --version
mycmd version 1.2.3
```

**Include useful debug info:**

```bash
$ mycmd --version
mycmd 1.2.3
  go version: go1.21.0
  platform: darwin/arm64
  commit: a1b2c3d
  built: 2024-01-15T10:30:00Z
```

## Shell Completions

**Provide shell completions:**

```bash
# Generate completions
mycmd completion bash > /etc/bash_completion.d/mycmd
mycmd completion zsh > ~/.zsh/completions/_mycmd
mycmd completion fish > ~/.config/fish/completions/mycmd.fish
```

**Libraries that help:**

- Go: Cobra (built-in completion support)
- Python: Click (built-in), argcomplete
- Rust: clap (built-in)

## Future-proofing

**Keep interfaces stable:**

- Adding flags/subcommands: OK
- Removing/changing flags: Breaking change
- Changing output format: Breaking for scripts

**Warn before breaking changes:**

```
$ mycmd old-command
Warning: 'old-command' is deprecated and will be removed in v2.0.
Use 'mycmd new-command' instead.
```

**Don't create time bombs:**

- Avoid dependencies on external services that may disappear
- Don't phone home without consent
- Include all necessary resources in the distribution
