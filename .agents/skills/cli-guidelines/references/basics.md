# The Basics

There are a few basic rules you need to follow. Get these wrong, and your program will be either very hard to use, or flat-out broken.

## Use an Argument Parsing Library

**Use a command-line argument parsing library where you can.** Either your language's built-in one, or a good third-party one. They will normally handle arguments, flag parsing, help text, and even spelling suggestions in a sensible way.

Don't roll your own argument parser—it's harder than it looks and you'll miss edge cases.

### Recommended Libraries

| Language       | Libraries                                                                                                                                            |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multi-platform | [docopt](http://docopt.org)                                                                                                                          |
| Bash           | [argbash](https://argbash.dev)                                                                                                                       |
| Go             | [Cobra](https://github.com/spf13/cobra), [urfave/cli](https://github.com/urfave/cli)                                                                 |
| Haskell        | [optparse-applicative](https://hackage.haskell.org/package/optparse-applicative)                                                                     |
| Java           | [picocli](https://picocli.info/)                                                                                                                     |
| Julia          | [ArgParse.jl](https://github.com/carlobaldassi/ArgParse.jl), [Comonicon.jl](https://github.com/comonicon/Comonicon.jl)                               |
| Kotlin         | [clikt](https://ajalt.github.io/clikt/)                                                                                                              |
| Node           | [oclif](https://oclif.io/)                                                                                                                           |
| Deno           | [parseArgs](https://jsr.io/@std/cli/doc/parse-args/~/parseArgs)                                                                                      |
| Perl           | [Getopt::Long](https://metacpan.org/pod/Getopt::Long)                                                                                                |
| PHP            | [symfony/console](https://github.com/symfony/console), [CLImate](https://climate.thephpleague.com)                                                   |
| Python         | [argparse](https://docs.python.org/3/library/argparse.html), [Click](https://click.palletsprojects.com/), [Typer](https://github.com/tiangolo/typer) |
| Ruby           | [TTY](https://ttytoolkit.org/)                                                                                                                       |
| Rust           | [clap](https://docs.rs/clap)                                                                                                                         |
| Swift          | [swift-argument-parser](https://github.com/apple/swift-argument-parser)                                                                              |

## Exit Codes

**Return zero exit code on success, non-zero on failure.** Exit codes are how scripts determine whether a program succeeded or failed, so you should report this correctly.

```bash
# In scripts
if mycmd; then
    echo "Success"
else
    echo "Failed with exit code $?"
fi
```

### Standard Exit Codes

| Code  | Meaning                           |
| ----- | --------------------------------- |
| 0     | Success                           |
| 1     | General error                     |
| 2     | Misuse of command (bad arguments) |
| 126   | Command found but not executable  |
| 127   | Command not found                 |
| 128+N | Fatal error from signal N         |
| 130   | Terminated by Ctrl-C (128 + 2)    |

**Map non-zero exit codes to the most important failure modes:**

```go
const (
    ExitSuccess         = 0
    ExitGeneralError    = 1
    ExitBadArguments    = 2
    ExitConfigError     = 3
    ExitNetworkError    = 4
    ExitPermissionError = 5
)
```

## Standard Streams

### stdout: Primary Output

**Send output to `stdout`.** The primary output for your command should go to `stdout`. Anything that is machine readable should also go to `stdout`—this is where piping sends things by default.

```bash
# Output goes to stdout, can be piped
mycmd list | grep "pattern"
mycmd export > output.json
```

### stderr: Messages and Errors

**Send messaging to `stderr`.** Log messages, errors, and so on should all be sent to `stderr`. This means that when commands are piped together, these messages are displayed to the user and not fed into the next command.

```python
import sys

# Primary output to stdout
print(json.dumps(data))

# Messages and errors to stderr
print("Processing...", file=sys.stderr)
print("Error: file not found", file=sys.stderr)
```

```go
// Primary output
fmt.Println(result)

// Messages and errors
fmt.Fprintln(os.Stderr, "Processing...")
fmt.Fprintln(os.Stderr, "Error:", err)
```

### Why This Matters

```bash
# stderr shows to user, stdout goes to file
$ mycmd process > output.json
Processing input...     # User sees this (stderr)
Done!                   # User sees this (stderr)
# JSON output is in output.json (stdout)

# If everything went to stdout:
$ mycmd process > output.json
# User sees nothing, and output.json contains mixed data/messages
```

## Summary Checklist

- [ ] Use an argument parsing library (don't roll your own)
- [ ] Return 0 on success, non-zero on failure
- [ ] Map exit codes to specific failure modes
- [ ] Send primary output to stdout
- [ ] Send messages, progress, and errors to stderr
- [ ] Support `-h` and `--help`
- [ ] Have full-length versions of all flags
