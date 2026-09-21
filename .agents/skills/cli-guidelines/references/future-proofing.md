# Future-proofing

In software of any kind, it's crucial that interfaces don't change without a lengthy and well-documented deprecation process. Subcommands, arguments, flags, configuration files, environment variables: these are all interfaces, and you're committing to keeping them working.

Semantic versioning can only excuse so much change; if you're putting out a major version bump every month, it's meaningless.

## Keep Changes Additive

**Keep changes additive where you can.** Rather than modify the behavior of a flag in a backwards-incompatible way, maybe you can add a new flag—as long as it doesn't bloat the interface too much.

```bash
# Instead of changing --output behavior:
mycmd --output file.txt      # Original behavior (keep it)
mycmd --output-format json   # New flag for new behavior
```

See also: Prefer flags to args (makes future changes easier).

## Warn Before Breaking Changes

**Warn before you make a non-additive change.** Eventually, you'll find that you can't avoid breaking an interface. Before you do, forewarn your users in the program itself: when they pass the flag you're looking to deprecate, tell them it's going to change soon.

```
$ mycmd --old-flag
Warning: --old-flag is deprecated and will be removed in v2.0.
Use --new-flag instead.
```

Make sure there's a way they can modify their usage today to make it future-proof, and tell them how to do it.

**Detect when they've upgraded:** If possible, you should detect when they've changed their usage and not show the warning any more. Now they won't notice a thing when you finally roll out the change.

## Human Output Can Change

**Changing output for humans is usually OK.** The only way to make an interface easy to use is to iterate on it, and if the output is considered an interface, then you can't iterate on it.

Encourage your users to use `--plain` or `--json` in scripts to keep output stable. Human-readable output can evolve without breaking scripts.

```bash
# Scripts should use:
mycmd list --json | jq '.items[]'

# Not:
mycmd list | grep "pattern" | awk '{print $2}'
```

## Avoid Catch-all Subcommands

**Don't have a catch-all subcommand.** If you have a subcommand that's likely to be the most-used one, you might be tempted to let people omit it entirely for brevity's sake.

```bash
# You might be tempted to allow:
$ mycmd echo "hello world"     # Implies 'run' subcommand

# Instead of requiring:
$ mycmd run echo "hello world"
```

**The problem:** Now you can never add a subcommand named `echo`—or _anything at all_—without risking breaking existing usages. If there's a script out there that uses `mycmd echo`, it will do something entirely different after that user upgrades.

## Avoid Arbitrary Abbreviations

**Don't allow arbitrary abbreviations of subcommands.** For example, say your command has an `install` subcommand. When you added it, you wanted to save users some typing, so you allowed them to type any non-ambiguous prefix:

```bash
mycmd install   # Full command
mycmd inst      # Abbreviated
mycmd ins       # More abbreviated
mycmd i         # Single letter
```

**The problem:** Now you're stuck. You can't add any more commands beginning with `i`, because there are scripts out there that assume `i` means `install`.

**Solution:** There's nothing wrong with aliases—saving on typing is good—but they should be explicit and remain stable.

```bash
# Explicit aliases are OK:
mycmd install   # Full command
mycmd i         # Documented alias (stable)

# Don't allow:
mycmd ins       # Arbitrary abbreviation (unstable)
```

## Avoid Time Bombs

**Don't create a "time bomb."** Imagine it's 20 years from now. Will your command still run the same as it does today, or will it stop working because some external dependency on the internet has changed or is no longer maintained?

The server most likely to not exist in 20 years is the one that you are maintaining right now.

**Avoid:**

- Blocking calls to external services on startup
- Hard dependencies on remote APIs for core functionality
- Built-in analytics that phone home
- License checks that require internet access

**The rule:** Your CLI should work offline and continue working decades from now.

## Interface Stability Checklist

These are all interfaces you're committing to keep stable:

- [ ] Subcommand names
- [ ] Flag names (both short and long forms)
- [ ] Flag behavior and accepted values
- [ ] Argument positions and meanings
- [ ] Exit codes and their meanings
- [ ] Environment variable names
- [ ] Configuration file format and location
- [ ] `--json` output schema
- [ ] `--plain` output format

## Deprecation Process

1. **Announce**: Document the upcoming change
2. **Warn**: Show deprecation warning when old interface is used
3. **Provide alternative**: Tell users exactly what to use instead
4. **Wait**: Give users time to migrate (at least one major version)
5. **Remove**: Only after sufficient warning period
