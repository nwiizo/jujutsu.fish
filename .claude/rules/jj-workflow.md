---
paths: ["**/*"]
description: How agents operate in a jj (Jujutsu) repository — commit cycle, working copy semantics, recovery paths. Prevents the "git commit reflex" that corrupts jj state.
---

# Jujutsu Workflow Rules

Apply whenever `.jj/` exists in the repo root (jj-native or colocated).

## Commit cycle — not `git commit`

- To preserve the current working copy: `jj describe -m "<msg>"`. There is no staging step; the working copy **is** the current change (`@`).
- Before starting the next unit of work: `jj new`. Skip this and your next edits land inside the change you just described.
- Never run `git commit` / `git add` / `git reset` in a jj repo. They bypass the op log and desynchronize jj's view of `@`.

## Working copy is `@`, not a staging area

- Every file edit mutates `@` automatically. There is no index, no `git add`.
- No stash. To set WIP aside: `jj new` creates a new change; the old one stays in the graph and is resumable via `jj edit <change-id>`.
- Fetch / push: `jj git fetch`, `jj git push --change @` (creates a fresh `push-<change-id>` bookmark).

## Recovery before anything destructive

- `jj op log` — every mutation is recorded. Read this before panicking.
- `jj op undo` — undoes the last operation. Repeatable.
- `jj op restore <op-id>` — rewind to any prior repo state.
- Do **not** `rm -rf .jj/`. `jj op restore` is almost always the right answer.

## Bookmarks, not branches

- `jj bookmark set <name>` places a bookmark at `@`. `jj bookmark move <name> --to <rev>` moves it.
- `git checkout <branch>` has no single-command equivalent. Use `jj edit <rev>` (resume work on an existing change) or `jj new <rev>` (start fresh from a revision).

## Stack discipline

- Stacking is the default: `jj new` repeatedly builds a chain. Each change can become its own PR via `jj git push --change <id>`.
- Reorder: `jj rebase -r <rev> -d <new-parent>`.
- Merge two changes into one: `jj squash --from <src> --into <dst>`.
- Split one change into two: `jj split` (interactive).

## Read-only git commands are fine

In colocated repos, `git log` / `git show` / `git diff` / `git blame` see the same objects jj does. Use them freely. Use git for what jj does not manage: tags (`git tag`), submodules, LFS.

## When this plugin helps

- `jj_fzf_log` / `jj_fzf_op` — pick a revision or operation with preview.
- `jj_agent <name>` — create a parallel workspace (jj's `git worktree add`).
- `jj_push_pr` — `jj git push --change` + `gh pr create` in one call.
- See `README.md` "Coming from git worktree?" for the full mapping.
