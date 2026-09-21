---
title: Use Simple, Memorable Command Names
impact: LOW-MEDIUM
impactDescription: Users type the command name constantly
tags: naming, usability, ux, ergonomics
---

## Use Simple, Memorable Command Names

Choose a command name that is simple, memorable, and easy to type.

**Good command names:**

- `curl` - memorable, easy to type
- `git` - short, unique
- `docker` - recognizable, distinct
- `jq` - very short for frequent use
- `npm` - memorable acronym

**Bad command names:**

- `myApplicationCLI` - too long, mixed case
- `convert` - conflicts with ImageMagick and Windows
- `run` - too generic
- `plum` - awkward to type one-handed (original Docker Compose name, changed to `fig`)

**Formatting rules:**

- **Lowercase only**: `mycmd`, not `MyCMD` or `MyCmd`
- **Use dashes if needed**: `my-app`, not `my_app`
- **Keep it short**: Users type it constantly
- **Make it unique**: Don't conflict with common commands

**Test ergonomics:**

```bash
# Easy to type (good)
git status
npm install
docker ps

# Hard to type (awkward)
kubectl get pods  # People alias to k8s
```

**Consider these factors:**

- Can you type it with one hand comfortably?
- Is it easy to spell?
- Will users remember it?
- Does it conflict with existing commands?
- Can you say it out loud clearly?

**Subcommand naming:**

```bash
# Consistent, memorable verbs
mycmd create
mycmd list
mycmd update
mycmd delete

# Avoid confusing pairs
mycmd update vs mycmd upgrade  # Too similar!
```

**If your name is taken, consider:**

- Adding a prefix/suffix: `myapp-cli`
- Using the project name: `acme-deploy`
- Finding a unique alternative: `fig` instead of `plum`

**Document alternatives:**

```bash
# Common pattern for long names
kubectl → alias k=kubectl
kubernetes-cli → k8s
```
