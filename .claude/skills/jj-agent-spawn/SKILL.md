---
name: jj-agent-spawn
description: Spawn a parallel coding-agent session in its own jj workspace using `jj_agent`. Use when starting a second (or Nth) agent on a different task without disturbing the current working copy. Invoke manually; creates a workspace directory on disk.
disable-model-invocation: true
---

# jj Agent Spawn

Create a new jj workspace (the equivalent of `git worktree add`) and open it in an editor or tmux window, ready for an agent to start work.

## When to use

- User wants to run two or more agents on different tasks in parallel.
- User wants to try an alternative approach without contaminating the main working copy.
- User wants the agent's output isolated in its own `@` for later review via `jj_agent_diff`.

## Prerequisites

- `jj_agent` function is available (this plugin is installed).
- `$TMUX` is set if `--tmux` mode is desired.
- `$EDITOR` is set (or override with `-e`).

## Steps

1. Pick a workspace name. Short, descriptive, kebab-case:
   - Good: `fix-auth`, `review-pr-42`, `try-approach-b`.
   - Bad: `agent1`, `tmp`, `wip`.

2. Pick the base revision:
   ```fish
   jj_agent <name>                      # based on current @
   jj_agent <name> -r 'trunk()'         # based on trunk
   jj_agent <name> -r <change-id>       # based on a specific revision
   ```

3. Pick the launch mode:
   - `--tmux` — opens a new tmux window inside the current session. Preferred when running multiple agents side by side.
   - (default) — opens `$EDITOR` inside the new workspace directory.
   - `-e '<command>'` — override editor, e.g. `-e 'claude'`, `-e 'codex'`.

4. Confirm the workspace registered:
   ```fish
   jj_agent_list
   ```
   The new workspace should appear with state `clean` (no edits yet).

## Lifecycle follow-ups

- Compare two agents' output: `jj_agent_diff <A> <B>`.
- Close out the winning workspace: `jj_agent_done <name> --push-pr --forget`.
- Bulk cleanup of empty abandoned workspaces: `jj_agent_prune --dry-run` then `jj_agent_prune`.

See `README.md` "End-to-end agent loop" for the full cycle walkthrough.

## Notes for the invoking agent

- The spawned session is an **independent** jj workspace. Operations there record into the **shared** op log, so the main agent can see what the spawned agent did via `jj op log` from any workspace.
- Do not call `jj_agent` programmatically to reproduce this skill — the skill exists so the user explicitly chooses the name, base, and mode.
