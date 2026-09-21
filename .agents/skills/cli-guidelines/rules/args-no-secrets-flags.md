---
title: Don't Read Secrets from Flags
impact: CRITICAL
impactDescription: Prevents credential leaks via ps and shell history
tags: security, secrets, flags, credentials, passwords
---

## Don't Read Secrets from Flags

Never accept secrets via flags. They leak into `ps` output and shell history.

**Incorrect (exposes secrets):**

```bash
# INSECURE - visible in ps and history
$ mycmd deploy --password secretpass123
$ mycmd login --api-key sk_live_abc123xyz
```

**Why this is dangerous:**

```bash
$ mycmd login --api-key secret123 &
$ ps aux | grep mycmd
user  1234  mycmd login --api-key secret123  # EXPOSED!

$ history
  501  mycmd login --api-key secret123  # EXPOSED!
```

**Correct (secure methods):**

```bash
# Method 1: Read from file
$ mycmd login --password-file ~/.mycmd/password

# Method 2: Read from stdin
$ cat ~/.mycmd/password | mycmd login --password-stdin

# Method 3: Prompt interactively (hidden input)
$ mycmd login
Password:
✓ Logged in
```

**Implementation:**

```typescript
if (options.passwordFile) {
  password = fs.readFileSync(options.passwordFile, 'utf-8').trim()
} else if (!process.stdin.isTTY) {
  password = fs.readFileSync(0, 'utf-8').trim() // stdin
} else {
  const { password: pwd } = await prompts({
    type: 'password',
    name: 'password',
    message: 'Password',
  })
  password = pwd
}
```

**Environment variables are also insecure:**

- Visible to child processes
- Leak into logs

**Use instead:**

- Files with restricted permissions (`chmod 600`)
- Secret management services
- OS keychain
- Interactive prompts
