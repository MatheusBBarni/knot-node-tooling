---
title: Make Help Text Machine-Readable
impact: MEDIUM
impactDescription: Enables agents to discover capabilities programmatically
tags: agents, help, documentation, discovery, automation
---

## Make Help Text Machine-Readable

Provide structured help via --help --json so agents can understand capabilities.

**Terminal output:**

```
$ mycmd --help --json
{
  "name": "mycmd",
  "version": "1.0.0",
  "description": "My CLI tool",
  "commands": [
    {
      "name": "deploy",
      "description": "Deploy application",
      "arguments": [
        { "name": "app", "required": true }
      ],
      "options": [
        { "flag": "--env", "required": true, "choices": ["staging", "production"] },
        { "flag": "--force", "required": false }
      ]
    }
  ]
}
```

**Command-specific help:**

```
$ mycmd deploy --help --json
{
  "command": "deploy",
  "usage": "mycmd deploy <app> --env <env>",
  "arguments": [
    { "name": "app", "required": true }
  ],
  "options": [
    { "flag": "--env", "type": "string", "required": true },
    { "flag": "--force", "type": "boolean", "required": false }
  ],
  "examples": [
    "mycmd deploy myapp --env staging"
  ]
}
```

**Benefits for agents:**

- Discover available commands
- Understand required vs optional flags
- Know valid values for enum flags
- Build correct commands programmatically
