# Analytics and Telemetry

Usage metrics can be helpful to understand how users are using your program, how to make it better, and where to focus effort. But, unlike websites, users of the command-line expect to be in control of their environment, and it is surprising when programs do things in the background without telling them.

## The Golden Rule

**Do not phone home usage or crash data without consent.** Users will find out, and they will be angry.

If you collect telemetry, be very explicit about:

- **What** you collect
- **Why** you collect it
- **How anonymous** it is and how you anonymize it
- **How long** you retain it

## Opt-in vs Opt-out

**Ideally, ask users whether they want to contribute data ("opt-in").** This is the most respectful approach.

```
$ mycmd init
Would you like to send anonymous usage statistics to help improve mycmd?
This data is anonymous and helps us prioritize features. [y/N]:
```

**If you choose to do it by default ("opt-out")**, then:

1. Clearly tell users about it on your website
2. Mention it on first run
3. Make it easy to disable

```
$ mycmd
Note: mycmd collects anonymous usage statistics.
To disable: mycmd config set telemetry.enabled false
Learn more: https://mycmd.dev/telemetry
```

## Examples of Good Telemetry Practices

### Angular CLI

- [Collects detailed analytics](https://angular.io/analytics) using Google Analytics
- Requires **explicit opt-in**
- Allows you to point to your own GA property for organizational tracking

### Homebrew

- Sends metrics to Google Analytics
- Has a [comprehensive FAQ](https://docs.brew.sh/Analytics) explaining practices
- Opt-out via `brew analytics off`

### Next.js

- [Collects anonymized usage statistics](https://nextjs.org/telemetry)
- Enabled by default (opt-out)
- Clear documentation on what's collected
- Easy disable: `npx next telemetry disable`

## What NOT to Collect

- Personally identifiable information (PII)
- File contents or paths that might contain sensitive data
- Environment variables (may contain secrets)
- Command arguments (may contain sensitive data)
- Anything that could identify a specific user or machine

## What's Reasonable to Collect

- Command/subcommand usage frequency
- Error types (not full error messages)
- Feature usage (which flags are commonly used)
- CLI version
- OS type (not full version)
- Anonymized session ID (for counting unique users)

## Disabling Telemetry

Always provide multiple ways to disable:

```bash
# Environment variable (works everywhere)
export MYCMD_TELEMETRY=off

# Config command
mycmd config set telemetry false

# Flag (for one-off runs)
mycmd --no-telemetry command

# Config file
echo "telemetry: false" >> ~/.mycmdrc
```

## Alternatives to Collecting Analytics

Consider these less invasive alternatives:

### Instrument Your Web Docs

If you want to know how people are using your CLI tool, make a set of docs around the use cases you'd like to understand best, and see how they perform over time. Look at what people search for within your docs.

### Instrument Your Downloads

This can be a rough metric to understand usage and what operating systems your users are running. You can track:

- Download counts by platform
- Version adoption rates
- Geographic distribution (from CDN logs)

### Talk to Your Users

- Reach out and ask people how they're using your tool
- Encourage feedback and feature requests in your docs and repos
- Try to draw out more context from those who submit feedback
- Run user interviews or surveys

### GitHub/GitLab Insights

- Stars/forks over time
- Issue patterns
- PR contributions
- Discussion topics

## Implementation Guidelines

If you do implement telemetry:

```python
# Good pattern
def send_telemetry(event):
    if not telemetry_enabled():
        return

    if not is_online():
        return  # Don't queue or retry

    # Fire and forget, never block
    try:
        threading.Thread(
            target=_send_async,
            args=(event,),
            daemon=True
        ).start()
    except:
        pass  # Never fail the main operation

def telemetry_enabled():
    # Check multiple disable methods
    if os.environ.get('MYCMD_TELEMETRY') in ('off', 'false', '0'):
        return False
    if os.environ.get('DO_NOT_TRACK') == '1':
        return False
    return config.get('telemetry.enabled', False)  # Default OFF
```

**Rules:**

- Never block the main thread
- Never fail the command if telemetry fails
- Respect `DO_NOT_TRACK` environment variable
- Default to OFF, not on
- Don't retry or queue failed sends

_Further reading: [Open Source Metrics](https://opensource.guide/metrics/)_
