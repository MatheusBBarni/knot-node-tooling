# Robustness

## Responsiveness

**Print something within 100ms:**

```python
print("Connecting to server...", file=sys.stderr)
# Then do the slow network call
response = slow_api_call()
```

Don't leave users wondering if the program is frozen.

## Progress Indicators

**Show progress for operations >1 second:**

```python
from tqdm import tqdm

for item in tqdm(items, desc="Processing"):
    process(item)
```

```
Processing: 45%|████████████░░░░░░░░░| 45/100 [00:23<00:28, 1.98it/s]
```

**Libraries:**

- Python: `tqdm`
- Go: `schollz/progressbar`
- Node: `node-progress`, `ora`
- Rust: `indicatif`

**Rules:**

- Only show in TTY (check `isatty`)
- Show estimated time remaining
- Animate to show activity (not frozen)
- On error, reveal full logs

## Parallel Operations

Show multiple progress bars for parallel work:

```
Downloading files:
  image1.png   [████████████████████] 100%
  image2.png   [██████████░░░░░░░░░░] 50%
  image3.png   [████░░░░░░░░░░░░░░░░] 20%
```

**Rules:**

- Don't interleave output confusingly
- Use a library that handles this (tqdm, progressbar)
- On error, show which task failed

## Timeouts

**Always set network timeouts:**

```python
import requests
response = requests.get(url, timeout=30)  # 30 second timeout
```

```go
client := &http.Client{
    Timeout: 30 * time.Second,
}
```

**Make timeouts configurable:**

```bash
mycmd fetch --timeout 60
```

## Validation

**Validate early, fail fast:**

```python
def main():
    # Validate all inputs before doing any work
    if not os.path.exists(args.input):
        die(f"Input file not found: {args.input}")
    if not is_valid_email(args.email):
        die(f"Invalid email: {args.email}")

    # Now do the actual work
    process()
```

## Idempotency

**Make operations safe to retry:**

```python
def deploy():
    # Idempotent: running twice has same effect as once
    if already_deployed():
        print("Already deployed, skipping")
        return
    do_deploy()
```

**For file operations:**

```python
# Idempotent: creates only if doesn't exist
os.makedirs(path, exist_ok=True)
```

## Recoverability

**Allow resuming interrupted operations:**

```bash
$ mycmd download --resume
Resuming download from byte 1048576...
```

```python
def download_with_resume(url, path):
    if os.path.exists(path):
        resume_byte = os.path.getsize(path)
        headers = {'Range': f'bytes={resume_byte}-'}
    else:
        resume_byte = 0
        headers = {}
    # Continue download...
```

## Handling Ctrl-C

**Respond to SIGINT immediately:**

```python
import signal
import sys

def handler(signum, frame):
    print("\nCancelled. Cleaning up...", file=sys.stderr)
    cleanup()
    sys.exit(130)  # 128 + SIGINT(2)

signal.signal(signal.SIGINT, handler)
```

**For long cleanup, allow second Ctrl-C to force quit:**

```python
force_quit = False

def handler(signum, frame):
    global force_quit
    if force_quit:
        print("\nForce quitting!", file=sys.stderr)
        sys.exit(130)
    force_quit = True
    print("\nCancelling... (press Ctrl-C again to force)", file=sys.stderr)
    cleanup()
    sys.exit(130)
```

## Crash-only Design

**Design to be killed at any time:**

- Don't require cleanup to complete
- Use atomic file writes (write to temp, then rename)
- Be prepared for partial state on next run

```python
import tempfile
import shutil

# Atomic write: never leaves partial file
def atomic_write(path, content):
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write(content)
        temp_path = f.name
    shutil.move(temp_path, path)  # Atomic on same filesystem
```

## Handling Edge Cases

**Expect the unexpected:**

- Empty input
- Missing files
- Network failures
- Disk full
- Permission denied
- Unicode filenames
- Spaces in paths
- Very long inputs
- Case-insensitive filesystems (macOS)

```python
# Handle spaces in paths
subprocess.run(['rm', path])  # Good: list form
subprocess.run(f'rm {path}', shell=True)  # Bad: breaks on spaces
```

## Retry Logic

**For transient failures, retry with backoff:**

```python
import time

def retry(fn, max_attempts=3, backoff=1.0):
    for attempt in range(max_attempts):
        try:
            return fn()
        except TransientError as e:
            if attempt == max_attempts - 1:
                raise
            wait = backoff * (2 ** attempt)
            print(f"Retry in {wait}s: {e}", file=sys.stderr)
            time.sleep(wait)
```

## Dry Run

**Provide `--dry-run` for destructive operations:**

```bash
$ mycmd sync --dry-run
Would delete: old-file.txt
Would upload: new-file.txt
Would update: changed-file.txt

Run without --dry-run to apply changes.
```
