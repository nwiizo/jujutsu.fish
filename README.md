# jujutsu.fish

A focused [Jujutsu (jj)](https://github.com/jj-vcs/jj) plugin for the
[fish shell](https://fishshell.com/), built around **fast abbreviations**,
**fzf-powered pickers**, and **coding-agent workspace workflows**.

Designed for people who already run a coding agent (Claude Code, Codex,
Aider) in parallel sessions and want jj's workspace model to be as
friction-free as `git worktree` was with `workspace.fish`.

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

## Why another jj plugin?

- **Single-letter prefix** (`j`) — shortest keystrokes for the commands you
  actually type all day. ~30 curated abbreviations, not 70+ kitchen-sink
  ones.
- **fzf pickers** for `log`, `bookmark`, `op log`, and `workspace`. Fuzzy
  select, live preview via `jj show` / `jj log`.
- **`jj_agent`** helper: create a workspace for a parallel agent session
  and open it in `$EDITOR` with one command.
- **No duplicate completions.** jj 0.24+ ships dynamic completions and
  fish 4.0.2+ auto-loads them. This plugin deliberately stays out of
  the way.

## Requirements

- fish `>= 3.6`
- jj `>= 0.24` (dynamic completions, workspace improvements)
- fzf (optional — only needed for the picker functions)

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
            --workspace=\cy
    end
end
```

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

### Agent workspace helper

```fish
# Create a workspace at ../feature-x based on @ and open it in $EDITOR
jj_agent feature-x

# Base at a specific revset
jj_agent fix-login -r 'trunk()'

# Open with a different editor / command
jj_agent refactor -e 'claude'
```

`$jujutsu_agent_root` controls where workspaces are placed (defaults to
the parent of your main workspace).

Creating (or switching to) a workspace updates the terminal tab title to
`jj:<name>` via OSC 0, so a row of parallel Ghostty / iTerm2 / WezTerm
tabs stays readable at a glance. Runs silently when stdout is piped.

Inspect running agent workspaces at a glance:

```fish
jj_agent_list
# NAME                  CHANGE      STATE   DESCRIPTION
# default               qqwkkopr    clean   wire auth
# fix-login             xpmzzqor    dirty   WIP: claude-code session
# refactor-db           ttmnorqs    dirty   codex pass 2
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

## Future ideas (not in v0.1)

- `jj_agent_prune` — detect workspaces whose change is merged or abandoned
  and remove them with confirmation.
- `JUJUTSU_FISH_CONFIRM=1` — opt-in wrappers around `jj abandon` and
  `jj op restore` that prompt before acting.

Filing issues / PRs welcome.

## License

MIT © [nwiizo](https://github.com/nwiizo)
