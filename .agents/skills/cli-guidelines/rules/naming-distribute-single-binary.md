---
title: Distribute as Single Binary When Possible
impact: LOW-MEDIUM
impactDescription: Simplifies installation and reduces dependency issues
tags: distribution, packaging, installation, deployment
---

## Distribute as Single Binary When Possible

Single executables are easier to install and don't require dependency management.

**Good (one file installation):**

```bash
$ curl -L https://mycmd.dev/install.sh | bash
Downloading mycmd...
Installing to /usr/local/bin/mycmd...
✓ Installed

$ mycmd --version
mycmd 1.0.0
```

**For Node.js, use pkg or esbuild:**

```bash
# Standalone binary (no Node required)
pkg package.json

# Or bundled JS (Node required)
esbuild src/cli.ts --bundle --platform=node --outfile=mycmd.js
```

**Benefits:**

- No dependency hell
- Fast installation
- Works offline
- Easy to uninstall: `rm /usr/local/bin/mycmd`

**Alternative: npm global install**

```bash
npm install -g mycmd
```

**Make uninstall easy:**

```
$ mycmd uninstall
Removed /usr/local/bin/mycmd
Removed ~/.config/mycmd
✓ Uninstalled
```

**Multi-platform builds:**

- `mycmd-macos-arm64`
- `mycmd-macos-x64`
- `mycmd-linux-x64`
- `mycmd-windows-x64.exe`
