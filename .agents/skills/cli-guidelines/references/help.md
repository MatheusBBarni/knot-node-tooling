# Help Text Patterns

## Display Rules

**Display extensive help text when asked.** Display help when passed `-h` or `--help` flags. This also applies to subcommands which might have their own help text.

**Show help on:**

- `-h`
- `--help`
- `help` subcommand (if git-like)

**Ignore other flags when `-h` is passed**—`mycmd --foo -h` should show help. Don't overload `-h` for anything else.

## Concise Help (No Arguments)

**Display concise help text by default.** When `myapp` or `myapp subcommand` requires arguments to function, and is run with no arguments, display concise help text.

You can ignore this guideline if your program is interactive by default (e.g. `npm init`).

The concise help text should only include:

1. A description of what your program does
2. One or two example invocations
3. Descriptions of flags, unless there are lots of them
4. An instruction to pass the `--help` flag for more information

### Example: jq

`jq` does this well. When you type `jq`, it displays an introductory description and an example, then prompts you to pass `jq --help` for the full listing of flags:

```
$ jq
jq - commandline JSON processor [version 1.6]

Usage:    jq [options] <jq filter> [file...]
    jq [options] --args <jq filter> [strings...]
    jq [options] --jsonargs <jq filter> [JSON_TEXTS...]

jq is a tool for processing JSON inputs, applying the given filter to
its JSON text inputs and producing the filter's results as JSON on
standard output.

The simplest filter is ., which copies jq's input to its output
unmodified (except for formatting, but note that IEEE754 is used
for number representation internally, with all that that implies).

For more advanced filters see the jq(1) manpage ("man jq")
and/or https://stedolan.github.io/jq

Example:

    $ echo '{"foo": 0}' | jq .
    {
        "foo": 0
    }

For a listing of options, use jq --help.
```

## Full Help Structure

**Show full help when `-h` and `--help` are passed.** All of these should show help:

```
$ myapp
$ myapp --help
$ myapp -h
```

### Example Structure

```
USAGE
  $ myapp <command> [options]

DESCRIPTION
  Brief description of what the tool does.

EXAMPLES
  $ myapp init           # Create new project
  $ myapp build --prod   # Build for production
  $ myapp deploy staging # Deploy to staging

COMMANDS
  init      Initialize a new project
  build     Build the project
  deploy    Deploy to production

OPTIONS
  -h, --help     Show help
  -v, --version  Show version
  -q, --quiet    Suppress output

CONFIGURATION
  myapp reads from ~/.myapprc or $MYAPP_CONFIG

MORE INFO
  Docs: https://myapp.dev/docs
  Bugs: https://github.com/org/myapp/issues
```

## Git-like Help

If your program is `git`-like, the following should also offer help:

```
$ myapp help
$ myapp help subcommand
$ myapp subcommand --help
$ myapp subcommand -h
```

## Display Common Flags First

**Display the most common flags and commands at the start of the help text.** It's fine to have lots of flags, but if you've got some really common ones, display them first.

### Example: Git

Git displays the commands for getting started and the most commonly used subcommands first:

```
$ git
usage: git [--version] [--help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           <command> [<args>]

These are common Git commands used in various situations:

start a working area (see also: git help tutorial)
   clone      Clone a repository into a new directory
   init       Create an empty Git repository or reinitialize an existing one

work on the current change (see also: git help everyday)
   add        Add file contents to the index
   mv         Move or rename a file, a directory, or a symlink
   reset      Reset current HEAD to the specified state
   rm         Remove files from the working tree and from the index

examine the history and state (see also: git help revisions)
   bisect     Use binary search to find the commit that introduced a bug
   grep       Print lines matching a pattern
   log        Show commit logs
   show       Show various types of objects
   status     Show the working tree status
…
```

## Use Formatting

**Use formatting in your help text.** Bold headings make it much easier to scan. But, try to do it in a terminal-independent way so that your users aren't staring down a wall of escape characters.

### Example: Heroku

```
$ heroku apps --help
list your apps

USAGE
  $ heroku apps

OPTIONS
  -A, --all          include apps in all teams
  -p, --personal     list apps in personal account when a default team is set
  -s, --space=space  filter by space
  -t, --team=team    team to use
  --json             output in json format

EXAMPLES
  $ heroku apps
  === My Apps
  example
  example2

  === Collaborated Apps
  theirapp   other@owner.name

COMMANDS
  apps:create     creates a new app
  apps:destroy    permanently destroy an app
  apps:errors     view app errors
  apps:favorites  list favorited apps
  apps:info       show detailed app information
  apps:join       add yourself to a team app
  apps:leave      remove yourself from a team app
  apps:lock       prevent team members from joining an app
  apps:open       open the app in a web browser
  apps:rename     rename an app
  apps:stacks     show the list of available stacks
  apps:transfer   transfer applications to another user or team
  apps:unlock     unlock an app so any team member can join
```

Note: When piped through a pager, the command emits no escape characters.

## Lead with Examples

**Lead with examples.** Users tend to use examples over other forms of documentation, so show them first in the help page, particularly the common complex uses. If it helps explain what it's doing and it isn't too long, show the actual output too.

You can tell a story with a series of examples, building your way toward complex uses.

**If you've got loads of examples, put them somewhere else,** in a cheat sheet command or a web page. It's useful to have exhaustive, advanced examples, but you don't want to make your help text really long.

For more complex use cases, e.g. when integrating with another tool, it might be appropriate to write a fully-fledged tutorial.

## Suggest Corrections

**If the user did something wrong and you can guess what they meant, suggest it.** For example, `brew update jq` tells you that you should run `brew upgrade jq`.

```
$ heroku pss
 ›   Warning: pss is not a heroku command.
Did you mean ps? [y/n]:
```

You can ask if they want to run the suggested command, but don't force it on them.

### When NOT to Auto-correct

Rather than suggesting the corrected syntax, you might be tempted to just run it for them, as if they'd typed it right in the first place. Sometimes this is the right thing to do, but not always.

**Firstly**, invalid input doesn't necessarily imply a simple typo—it can often mean the user has made a logical mistake, or misused a shell variable. Assuming what they meant can be dangerous, especially if the resulting action modifies state.

**Secondly**, be aware that if you change what the user typed, they won't learn the correct syntax. In effect, you're ruling that the way they typed it is valid and correct, and you're committing to supporting that indefinitely. Be intentional in making that decision, and document both syntaxes.

_Further reading: ["Do What I Mean"](http://www.catb.org/~esr/jargon/html/D/DWIM.html)_

## Support and Documentation Links

**Provide a support path for feedback and issues.** A website or GitHub link in the top-level help text is common.

**In help text, link to the web version of the documentation.** If you have a specific page or anchor for a subcommand, link directly to that. This is particularly useful if there is more detailed documentation on the web, or further reading that might explain the behavior of something.

## Piped Input Handling

**If your command is expecting to have something piped to it and `stdin` is an interactive terminal, display help immediately and quit.** This means it doesn't just hang, like `cat`. Alternatively, you could print a log message to `stderr`.

```go
if isatty.IsTerminal(os.Stdin.Fd()) && needsInput {
    showHelp()
    os.Exit(0)
}
```

```python
import sys
if sys.stdin.isatty() and needs_input:
    show_help()
    sys.exit(0)
```
