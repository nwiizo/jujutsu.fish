# jujutsu.fish

A mature [Jujutsu (jj)](https://github.com/jj-vcs/jj) plugin for the
[fish shell](https://fishshell.com/), focused on **fast abbreviations**,
**fzf-powered pickers**, and **coding-agent workspace workflows**.

Designed for people who already run a coding agent (Claude Code, Codex,
Aider) in parallel sessions and want jj's workspace model to be as
friction-free as `git worktree` was with `workspace.fish`.

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
| `jgc` | `jj git clone`       |
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

## License

MIT © [nwiizo](https://github.com/nwiizo)
