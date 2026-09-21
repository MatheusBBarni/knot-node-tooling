---
title: Use Consistent Verbs Across Subcommands
impact: MEDIUM
impactDescription: Reduces cognitive load, makes CLI guessable
tags: subcommands, verbs, consistency, api-design
---

## Use Consistent Verbs Across Subcommands

Use the same verb for the same action across all resources.

**Incorrect (inconsistent):**

```bash
mycmd users create      # create
mycmd projects new      # new (different!)
mycmd teams add         # add (different!)
```

**Correct (consistent):**

```bash
mycmd users create
mycmd projects create
mycmd teams create
```

**Standard CRUD verbs:**

| Action | Use                | Avoid mixing         |
| ------ | ------------------ | -------------------- |
| Create | `create`           | `new`, `add`, `make` |
| Read   | `get`, `show`      | `display`, `view`    |
| List   | `list`             | `ls`, `all`          |
| Update | `update`           | `modify`, `edit`     |
| Delete | `delete`, `remove` | `rm`, `destroy`      |

**Docker example (good):**

```bash
docker container create
docker container list
docker container start
docker container remove

docker image create
docker image list
docker image remove
```

**kubectl example (consistent):**

```bash
kubectl create deployment
kubectl get deployment
kubectl delete deployment

kubectl create pod
kubectl get pod
kubectl delete pod
```

Pick one pattern and use everywhere.
