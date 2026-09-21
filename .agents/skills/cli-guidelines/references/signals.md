# Signals and Control Characters

Proper signal handling makes your CLI feel robust and responsive. Users expect Ctrl-C to work immediately and cleanly.

## Ctrl-C (SIGINT)

**If a user hits Ctrl-C, exit as soon as possible.**

1. Say something immediately, before you start clean-up
2. Add a timeout to any clean-up code so it can't hang forever

```python
import signal
import sys

def handler(signum, frame):
    print("\nCancelled.", file=sys.stderr)
    # Quick cleanup with timeout
    cleanup_with_timeout(timeout=5)
    sys.exit(130)  # 128 + SIGINT(2)

signal.signal(signal.SIGINT, handler)
```

```go
c := make(chan os.Signal, 1)
signal.Notify(c, os.Interrupt)

go func() {
    <-c
    fmt.Fprintln(os.Stderr, "\nCancelled.")
    cleanup()
    os.Exit(130)
}()
```

## Second Ctrl-C to Force Quit

**If a user hits Ctrl-C during clean-up operations that might take a long time, skip them.** Tell the user what will happen when they hit Ctrl-C again, in case it is a destructive action.

Example from Docker Compose:

```
$ docker-compose up
…
^CGracefully stopping... (press Ctrl+C again to force)
```

Implementation pattern:

```python
force_quit = False

def handler(signum, frame):
    global force_quit
    if force_quit:
        print("\nForce quitting!", file=sys.stderr)
        sys.exit(130)

    force_quit = True
    print("\nStopping... (press Ctrl+C again to force)", file=sys.stderr)
    graceful_shutdown()
    sys.exit(0)
```

```go
var forceQuit bool

func handleSignal() {
    c := make(chan os.Signal, 1)
    signal.Notify(c, os.Interrupt)

    go func() {
        for range c {
            if forceQuit {
                fmt.Fprintln(os.Stderr, "\nForce quitting!")
                os.Exit(130)
            }
            forceQuit = true
            fmt.Fprintln(os.Stderr, "\nStopping... (press Ctrl+C again to force)")
            go gracefulShutdown()
        }
    }()
}
```

## Expect Unclean State

**Your program should expect to be started in a situation where clean-up has not been run.** This is the "crash-only" design principle.

- Don't rely on shutdown hooks having completed
- Check for and clean up stale lock files on startup
- Use atomic operations where possible
- Design for recovery, not just clean shutdown

See also: [Crash-only software: More than meets the eye](https://lwn.net/Articles/191059/)

## Common Signals

| Signal  | Keyboard | Number | Default Action | Your Response               |
| ------- | -------- | ------ | -------------- | --------------------------- |
| SIGINT  | Ctrl-C   | 2      | Terminate      | Clean exit, exit code 130   |
| SIGTERM | (none)   | 15     | Terminate      | Graceful shutdown           |
| SIGQUIT | Ctrl-\\  | 3      | Core dump      | Can ignore or use for debug |
| SIGHUP  | (none)   | 1      | Terminate      | Reload config or terminate  |
| SIGPIPE | (none)   | 13     | Terminate      | Usually ignore              |

## Exit Codes for Signals

When your program is terminated by a signal, the conventional exit code is `128 + signal_number`:

```
128 + 2 (SIGINT)  = 130  # Ctrl-C
128 + 15 (SIGTERM) = 143  # Terminated
128 + 9 (SIGKILL)  = 137  # Killed (can't catch this)
```

## Cleanup Timeouts

Always add timeouts to cleanup operations:

```python
import threading

def cleanup_with_timeout(timeout=5):
    cleanup_done = threading.Event()

    def do_cleanup():
        try:
            # Your cleanup logic
            close_connections()
            save_state()
        finally:
            cleanup_done.set()

    thread = threading.Thread(target=do_cleanup)
    thread.start()

    if not cleanup_done.wait(timeout=timeout):
        print("Cleanup timed out, exiting anyway", file=sys.stderr)
```

## Network I/O and Ctrl-C

**If your program hangs on network I/O, always make Ctrl-C still work.**

- Set timeouts on all network operations
- Use non-blocking I/O or check for signals periodically
- Don't catch exceptions too broadly (might swallow KeyboardInterrupt)

```python
# Bad: Ctrl-C won't work during request
try:
    response = requests.get(url)  # No timeout!
except:  # Too broad!
    pass

# Good: Ctrl-C works
try:
    response = requests.get(url, timeout=30)
except KeyboardInterrupt:
    raise  # Let it propagate
except requests.RequestException:
    handle_error()
```

## Wrapped Programs

If your CLI wraps another program where Ctrl-C can't quit directly (SSH, tmux, telnet, etc), make it clear how to exit.

```
$ mycmd shell
Connected to remote host.
Press ~. to disconnect, or Ctrl-C to send interrupt to remote.
$
```

SSH uses the `~` escape character:

- `~.` - Disconnect
- `~^Z` - Suspend
- `~~` - Send literal ~
