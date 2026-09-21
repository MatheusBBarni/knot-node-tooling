---
title: Tell the User When You Change State
impact: MEDIUM
impactDescription: Users need to understand what happened
tags: output, state, feedback, transparency
---

## Tell the User When You Change State

Explain what changed. Help users understand the new state.

**Incorrect (silent):**

```
$ mycmd deploy
$
(did it work? what happened?)
```

**Correct (explains what happened):**

```
$ mycmd deploy

Uploading files... done (15 files, 2.3 MB)
Building application... done (1m 23s)
Deploying to production... done

✓ Deployed successfully
  URL: https://myapp.com
  Version: v1.2.3

View logs: mycmd logs myapp
```

**git push example (explains every step):**

```
$ git push
Enumerating objects: 18, done.
Counting objects: 100% (18/18), done.
Compressing objects: 100% (10/10), done.
Writing objects: 100% (10/10), 2.09 KiB, done.
To github.com:user/repo.git
   6c22c90..a2a5217  main -> main
```

**Show current state + next steps:**

```
$ git status
On branch main
Changes not staged:
  modified: src/index.js

no changes added to commit (use "git add")
```

**After init (suggests next steps):**

```
$ mycmd init myproject

✓ Created project 'myproject'

Next steps:
  1. cd myproject
  2. mycmd start
  3. Open http://localhost:3000
```
