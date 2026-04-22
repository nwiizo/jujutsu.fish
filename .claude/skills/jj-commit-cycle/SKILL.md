---
name: jj-commit-cycle
description: In a jj repository, complete the "commit" pattern — describe the current working copy with a message, then open a fresh change for the next unit of work. Use when a coherent edit is finished and should be preserved before moving on. Invoke manually; mutates state.
disable-model-invocation: true
---

# jj Commit Cycle

The jj equivalent of `git add -A && git commit -m "<msg>"`. Two commands, executed in order, with a verification step.

## When to use

You (or the user) just finished an atomic edit in a jj working copy and want to preserve it before starting the next change.

## Prerequisites

- `.jj/` exists (a jj repo, possibly colocated).
- Working copy has changes to describe (`jj st` shows non-empty output).

## Steps

1. Survey what will be preserved:
   ```fish
   jj st
   jj diff --stat
   ```

2. Describe the current change. Follow the repo's commit convention (see `~/.claude/rules/coding.md` for this user's `<type>(<scope>): <subject>` format):
   ```fish
   jj describe -m "<type>(<scope>): <subject>"
   ```

3. Open a new child change so the just-described change is finalized and future edits land on a fresh `@`:
   ```fish
   jj new
   ```

4. Verify the stack layout:
   ```fish
   jj log -r '::@' --limit 3
   ```

## Common mistakes

- **Skipping step 3**: any further edits get absorbed into the change you just "committed", silently polluting it.
- **Running `git commit`**: jj does not track the resulting commit as `@`; subsequent `jj describe` will feel like the commit message "reverted".
- **Using deprecated `jj commit -m`**: always `jj describe -m` + `jj new`.

## Related

- Multi-change cleanup: `jj squash --from <src> --into <dst>`, `jj split`.
- Recovery if the wrong change was described: `jj op undo`.
- Pushing after the cycle: `jj_push_pr` (this plugin) or `jj git push --change @`.
