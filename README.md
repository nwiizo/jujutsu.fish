# jujutsu.fish

A focused [Jujutsu (jj)](https://github.com/jj-vcs/jj) plugin for the
[fish shell](https://fishshell.com/), built around **fast abbreviations**,
**fzf-powered pickers**, and **coding-agent workspace workflows**.

Designed for people who already run a coding agent (Claude Code, Codex,
Aider) in parallel sessions and want jj's workspace model to be as
friction-free as `git worktree` was with `workspace.fish`.

## Coming from `git worktree`?

jj's native answer is `jj workspace`, and this plugin is the fish layer
on top of it. Direct equivalents:

| `git worktree …`      | `jj workspace …`                                | This plugin                      |
|-----------------------|-------------------------------------------------|----------------------------------|
| `add <path> <branch>` | `add --name <n> -r <rev> <path>`                | `jj_agent <name>` / `jwa`        |
| `list`                | `list`                                          | `jj_agent_list` / `jwl`          |
| `remove <path>`       | `forget <name>`                                 | `jj_agent_done --forget` / `jwf` |
| (shell in a worktree) | (`<name>@` revset, `-R <path>`)                 | `jj_fzf_workspace`               |

What jj workspace gives you on top of `git worktree`:

- **Revset first-class**: `feature-x@` refers to that workspace's `@` anywhere in jj — no `git -C <path>` dance.
- **Shared op log**: `jj op undo` / `jj op restore` reaches every workspace, so recovery is repo-wide.
- **Non-destructive forget**: `jj workspace forget` only detaches the workspace entry; the change itself stays in the graph (use `jj abandon` if you want the change gone too).
- **Lightweight**: adding a workspace is one working-copy link, not a separate clone.

Caveats worth knowing:

- In a colocated repo, **extra jj workspaces are not git worktrees**. Only the main workspace is visible to git tooling.
- If another workspace's operation rewrote your `@`, re-enter and `jj workspace update-stale` to resync.

## Jobs this plugin hires itself to do

| When I want to… | Use |
|---|---|
| Type jj commands fast | ~30 curated abbreviations under a single `j` prefix |
| Pick a revision from `jj log` with a preview | `jj_fzf_log` |
| Pick a bookmark by name with a preview | `jj_fzf_bookmark` |
| Pick an operation to undo/restore to | `jj_fzf_op` |
| Jump between parallel workspaces | `jj_fzf_workspace` |
| See at a glance which agent workspace is dirty | `jj_agent_list` |
| Review the files an agent just changed and open one | `jj_fzf_status` |
| Squash the current change into a chosen revision | `jj_squash_into` |
| Spin up a new parallel agent session, in $EDITOR or tmux | `jj_agent <name>` / `jj_agent <name> --tmux` |
| Close out an agent workspace — summarize, push PR, forget | `jj_agent_done <name>` |
| Clean up empty / abandoned agent workspaces | `jj_agent_prune [--dry-run]` |
| Compare two agents' output side by side | `jj_agent_diff <nameA> <nameB>` |
| Push a change and open a GitHub PR from the generated bookmark | `jj_push_pr` |

## Why another jj plugin?

- **Single-letter prefix** (`j`) — shortest keystrokes for the commands you
  actually type all day. ~30 curated abbreviations, not 70+ kitchen-sink
  ones.
- **fzf pickers** for log, bookmark, op log, workspace, changed-file, and
  squash target. Fuzzy select, live preview via `jj show` / `jj log` /
  `jj status`.
- **Full agent workspace lifecycle** — `jj_agent` to spin up,
  `jj_agent_list` to see what's running, `jj_agent_diff` to compare,
  `jj_agent_done` to close out, `jj_agent_prune` to reclaim.
- **Push → PR in one step** — `jj_push_pr` chains `jj git push --change`
  with `gh pr create`, forwarding any `gh` flags after `--`.
- **No duplicate completions.** jj 0.24+ ships dynamic completions and
  fish 4.0.2+ auto-loads them. This plugin deliberately stays out of
  the way.

## Requirements

- fish `>= 3.6`
- jj `>= 0.24` (dynamic completions, workspace improvements)
- fzf (optional — only needed for the picker functions)
- gh (optional — only needed for `jj_push_pr`)
- tmux (optional — only needed for `jj_agent --tmux`)

## Install

With [fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install nwiizo/jujutsu.fish
```

## Usage

### Abbreviations

All abbreviations use a configurable prefix (default `j`). Set
`$jujutsu_fish_prefix` in your config before this plugin loads to change
it.

| Abbr  | Expands to           |
|-------|----------------------|
| `j`   | `jj`                 |
| `jst` | `jj status`          |
| `jsh` | `jj show`            |
| `jd`  | `jj diff`            |
| `jds` | `jj describe`        |
| `jn`  | `jj new`             |
| `jed` | `jj edit`            |
| `jnx` | `jj next`            |
| `jpv` | `jj prev`            |
| `jl`  | `jj log`             |
| `jla` | `jj log -r "all()"`  |
| `jlo` | `jj log --no-graph`  |
| `jsq` | `jj squash`          |
| `jsp` | `jj split`           |
| `jab` | `jj absorb`          |
| `jrb` | `jj rebase`          |
| `jdp` | `jj duplicate`       |
| `jbk` | `jj backout`         |
| `jan` | `jj abandon`         |
| `jb`  | `jj bookmark`        |
| `jbl` | `jj bookmark list`   |
| `jbs` | `jj bookmark set`    |
| `jbm` | `jj bookmark move`   |
| `jbd` | `jj bookmark delete` |
| `jbt` | `jj bookmark track`  |
| `jop` | `jj op log`          |
| `jou` | `jj op undo`         |
| `jor` | `jj op restore`      |
| `jgf` | `jj git fetch`       |
| `jgp` | `jj git push`        |
| `jgpa`| `jj git push --allow-new` |
| `jgpc`| `jj git push --change @` |
| `jgc` | `jj git clone`       |
| `jgr` | `jj git remote`      |
| `jgra`| `jj git remote add`  |
| `jgrl`| `jj git remote list` |
| `jw`  | `jj workspace`       |
| `jwl` | `jj workspace list`  |
| `jwa` | `jj workspace add`   |
| `jwf` | `jj workspace forget`|

### fzf pickers

Call the functions directly, or wire them to keys via
`jj_configure_bindings`:

```fish
# ~/.config/fish/config.fish
function fish_user_key_bindings
    if functions -q jj_configure_bindings
        jj_configure_bindings \
            --log=\cj \
            --bookmark=\ck \
            --op= \
            --workspace=\cy \
            --status=\cu \
            --squash=\cs
    end
end
```

Every flag is optional; pass `--<name>=` with an empty value to leave it
unbound. Unpassed flags do not bind anything — they never overwrite an
existing binding.

Available pickers:

- `jj_fzf_log` — select a revision, insert its change-id
- `jj_fzf_bookmark` — select a bookmark name, insert it
- `jj_fzf_op` — select an operation id, insert it
- `jj_fzf_workspace` — select a workspace and `cd` into it
- `jj_fzf_status` — select a changed file in the working copy and open it in `$EDITOR`
- `jj_squash_into` — select a target revision and squash `@` into it (with confirm)

### Push and PR

```fish
jj_push_pr                                      # push @ and open PR via gh
jj_push_pr -r qpvuntsm                          # push a specific change
jj_push_pr -- --draft --title 'wire auth'       # forward args to gh pr create
```

`jj git push --change` creates a fresh `push-<change-id>` bookmark; this
helper scans the push output for that name and hands it to
`gh pr create --head <bookmark>`.

### Agent workspace lifecycle

The full lifecycle is five functions, each doing one thing:

```fish
jj_agent <name> [-r <rev>] [-e <editor>] [--tmux]
#   Create a new jj workspace rooted at <rev> (default: @), then open
#   it in $EDITOR or a new tmux window. Sets the tab title to
#   jj:<name> via OSC 0.

jj_agent_list
#   Tabular dirty/clean view of every workspace. Dirty is yellow,
#   clean is green; the NAME column auto-sizes.

jj_agent_diff <nameA> <nameB>
#   jj diff --from <A>@ --to <B>@. For comparing two agents on the
#   same task.

jj_agent_done <name> [--push-pr] [--forget]
#   Summarize the workspace's @ (change-id + description + diff
#   --stat). Interactive: asks to push PR, asks to forget. Flags
#   skip the prompts.

jj_agent_prune [--dry-run]
#   Forget non-default workspaces whose @ is empty. Conservative:
#   default is never touched; each candidate gets its own y/N.
```

Creation examples:

```fish
jj_agent feature-x                     # @-based, opens $EDITOR
jj_agent fix-login -r 'trunk()'        # base at trunk
jj_agent refactor -e 'claude'          # override editor
jj_agent pair-coder --tmux             # open in a new tmux window
```

`$jujutsu_agent_root` controls where workspaces are placed (defaults to
the parent of your main workspace).

`jj_agent_list` sample output:

```
NAME                  CHANGE      STATE   DESCRIPTION
default               qqwkkopr    clean   wire auth
fix-login             xpmzzqor    dirty   WIP: claude-code session
refactor-db           ttmnorqs    dirty   codex pass 2
```

### End-to-end agent loop

```fish
# 1. Spin up a workspace for a new agent task
jj_agent fix-login -r 'trunk()'

# 2. (…agent runs, jj records changes into fix-login@…)

# 3. Compare two agents' work on the same task
jj_agent_diff fix-login fix-login-alt

# 4. Close out the winning workspace — summary, push PR, forget
jj_agent_done fix-login --push-pr --forget

# 5. Reclaim stale workspaces
jj_agent_prune --dry-run
jj_agent_prune          # prompts y/N per candidate
```

## Development

Tests use [fishtape](https://github.com/jorgebucaran/fishtape) with
BDD-style names (`Given ... When ... Then ...`). Fish does not have a
widely-used native BDD framework, so this repo keeps the style in test
descriptions and shared mocks in `tests/test_helper.fish`.

```fish
fishtape tests/*.test.fish
fish_indent -w conf.d/*.fish functions/*.fish tests/*.fish
```

## Future ideas

- `JUJUTSU_FISH_CONFIRM=1` — opt-in wrappers around `jj abandon` and
  `jj op restore` that prompt before acting.
- `jj_agent --seed <dir>` — pre-seed a new workspace with context files
  (CLAUDE.md, task briefs, etc.) so agents can start without manual
  copy-paste.
- `jj_agent_handoff <from> <to>` — shortcut for
  `jj workspace add --name <to> -r <from>@`, for chained multi-agent
  sessions.

Filing issues / PRs welcome.

## License

MIT © [nwiizo](https://github.com/nwiizo)
