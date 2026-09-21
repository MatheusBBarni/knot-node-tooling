# Interactivity

## TTY Detection

Only use prompts/interactive elements if stdin is a TTY:

```python
import sys
if sys.stdin.isatty():
    # Can prompt user
    response = input("Continue? [y/N]: ")
else:
    # Running in script/pipe - use flags instead
    if not args.force:
        print("Error: Use --force in non-interactive mode", file=sys.stderr)
        sys.exit(1)
```

```go
import "github.com/mattn/go-isatty"

if isatty.IsTerminal(os.Stdin.Fd()) {
    // Interactive mode
} else {
    // Script mode
}
```

## The --no-input Flag

Always provide `--no-input` to explicitly disable prompts:

```bash
# In CI/scripts
mycmd deploy --no-input

# Fails with clear error if input required
Error: Deployment requires confirmation. Pass --force or run interactively.
```

## Password Input

Never echo passwords as user types:

```python
import getpass
password = getpass.getpass("Password: ")
```

```go
import "golang.org/x/term"
password, _ := term.ReadPassword(int(os.Stdin.Fd()))
```

```bash
read -s -p "Password: " password
```

## Confirmation Prompts

For destructive actions, prompt for confirmation:

```
$ mycmd delete-project myapp
This will permanently delete 'myapp' and all associated data.
Type the project name to confirm: myapp
Deleted.
```

For less severe actions:

```
$ mycmd reset-config
Reset configuration to defaults? [y/N]: y
Configuration reset.
```

**Default to the safe option** (N for destructive, y for safe operations).

## Letting Users Escape

Make it clear how to exit:

- Ctrl-C should always work
- Show escape instructions for complex interactions

```
$ mycmd interactive
Interactive mode. Press Ctrl-D to exit, Ctrl-C to cancel.
>
```

For wrapped programs (like SSH, tmux):

```
$ mycmd shell
Connected. Press ~. to disconnect.
```

## Progress During Long Operations

When waiting for user input during a long operation:

```
Processing... (press Ctrl-C to cancel)
[████████████████░░░░░░░░░░░░░░] 53% - 2m remaining
```

## Multi-step Wizards

For complex setup, guide users through steps:

```
$ mycmd init
Step 1/3: Project name
> myproject

Step 2/3: Choose template
  1. Basic
  2. Full-featured
  3. Minimal
> 2

Step 3/3: Output directory [./myproject]
>

Creating project...
✅ Done! Run 'cd myproject && mycmd start' to begin.
```

**Always allow skipping the wizard:**

```bash
mycmd init --name myproject --template full-featured --output ./myproject
```

## Select Menus

For choosing from options:

```
$ mycmd select-region
Use arrow keys to select, Enter to confirm:
> us-east-1
  us-west-2
  eu-west-1
  ap-southeast-1
```

Or numbered selection for simpler implementation:

```
$ mycmd select-region
Select a region:
  1. us-east-1
  2. us-west-2
  3. eu-west-1
> 1
```

## Editor Integration

For multi-line input, open user's editor:

```python
import os
import subprocess
import tempfile

editor = os.environ.get('EDITOR', 'vim')
with tempfile.NamedTemporaryFile(suffix='.md', delete=False) as f:
    f.write(b"# Enter your message\n")
    f.flush()
    subprocess.call([editor, f.name])
    f.seek(0)
    content = open(f.name).read()
```

Respect the `$EDITOR` environment variable.
