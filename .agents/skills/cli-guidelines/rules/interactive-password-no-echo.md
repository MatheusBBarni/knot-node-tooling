---
title: Don't Echo Passwords as User Types
impact: HIGH
impactDescription: Prevents shoulder-surfing and accidental exposure
tags: security, passwords, interactivity, privacy
---

## Don't Echo Passwords as User Types

Hide password input as the user types. Use password mode.

**Incorrect (password visible):**

```
$ mycmd login
Email: user@example.com
Password: secretpass123
          ^^^^^^^^^^^^^ VISIBLE!
```

**Correct (password hidden):**

```
$ mycmd login
Email: user@example.com
Password:
          (input hidden as user types)

Logged in successfully.
```

**With optional asterisks:**

```
$ mycmd login
Password: **********
```

**Implementation:** Use `prompts` library with `type: 'password'`:

```typescript
import prompts from 'prompts'

const { password } = await prompts({
  type: 'password',
  name: 'password',
  message: 'Password',
})
```

**Also hide:**

- API keys
- Tokens
- Secret values

**Provide non-interactive alternative:**

```bash
# From file
mycmd login --password-file ~/.mycmd/password

# From stdin
echo "secret" | mycmd login --password-stdin
```
