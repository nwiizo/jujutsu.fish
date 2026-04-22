# Lessons

Notes captured while building v0.1, distilled from two rounds of
independent review (codex) against real jj 0.40 + fish 4. Each item
is a concrete trap future contributors should skip.

## Fish authoring

### `eval $editor $path` is command injection

`$EDITOR` can legitimately contain flags (`code --wait`), which is why
`eval` looks convenient. But `$path` comes from repo contents (filenames
in `jj diff --summary`) or from `jj workspace add` — an attacker who can
create a file named `foo; rm -rf ~` triggers RCE when the user opens it.

Fix is two lines: split the editor on whitespace into a token array and
invoke directly, since fish does **not** word-split expanded variables.

```fish
set -l tokens (string split ' ' -- $editor)
$tokens -- $path   # safe: $path stays a single argument
```

Applies to `jj_fzf_status.fish`, `jj_agent.fish`, and anywhere else the
plugin hands a user-influenced string to an external program.

### fzf previews run through `$SHELL`, not fish

`fzf --preview=<cmd>` spawns `$SHELL -c <cmd>`. On macOS that is
`/bin/zsh`, on most Linux it is `/bin/bash`. Fish-only syntax
(`set -l`, `string replace`, `(cmd)`) fails silently — the preview pane
just looks empty, no error reaches the user.

Either invoke fish explicitly:

```fish
set -l preview_cmd 'fish -c \'<fish body>\' fish {}'
```

…or write the preview in POSIX sh. We picked the explicit-fish approach
because the bodies use fish-native string ops.

### `conf.d/*.fish` interactive guards block tests

The recommended guard

```fish
status is-interactive; or return
```

…also fires in fishtape, because tests run non-interactively. If the
side-effect logic (abbr registration) sits at the top level of
`conf.d/*.fish`, it never runs under test and assertions become false
positives.

Fix: put the side-effect inside a function (`__jujutsu_fish_register_abbrs`)
and call it from `conf.d` after the guard. Tests invoke the function
directly, bypassing the guard, and still exercise the real registration
logic.

### Abbreviations persist in universal variables

`abbr -a foo bar` writes to `$fish_user_abbreviations`, which is
universal. `fisher remove <plugin>` deletes the plugin's files but not
the universal variable entries, so users keep seeing expansions from a
plugin they just uninstalled.

Ship an uninstall hook:

```fish
function _jujutsu_fish_uninstall --on-event jujutsu_fish_uninstall
    __jujutsu_fish_erase_abbrs
end
```

Fisher emits `<plugin_name>_{install,update,uninstall}` events where
`<plugin_name>` is the conf.d filename stem (here: `jujutsu_fish`).

### Regex backreferences and double quotes don't mix

```fish
string replace -r "^pat (.+)\$" '$1' -- $s   # `$"` needs escape
```

Inside double quotes fish tries to expand `$"` first. Options, from
least to most surprising:

1. Single-quote the pattern: `'^pat (.+)$'` (must escape any literal
   quotes in the pattern).
2. Use `string match -rg '<pattern with groups>'` which returns only
   capture groups — no replacement string needed.
3. `string split "'" -- $line` when the delimiter is a fixed character
   (our `__jujutsu_fish_err` uses this for stack frames like
   `in function 'jj_agent'`).

### Gate color on `isatty`

Fishtape captures output via `(cmd 2>&1)`, CI captures via redirect, and
users grep stderr with `2>err.log`. If colors leak into any of these,
tests match the wrong string and logs become unreadable.

```fish
if isatty stderr
    printf '%s%s:%s %s\n' (set_color red --bold) $caller (set_color normal) $msg >&2
else
    printf '%s: %s\n' $caller $msg >&2
end
```

## jj-specific

### Verify CLI options against `--help`, not against model guesses

Two wrong guesses made it into v0.1:

- `jj workspace root --at-workspace <name>` — does not exist. Correct
  flag is `--name <name>`.
- `jj_squash_into` defaulted to the revset `'@- | trunk()::@-'`. `trunk()`
  is an alias that is **not** set by default; when absent it resolves to
  the root commit (immutable), so the first confirmation attempt errors
  with "root commit is immutable". Safer default: `@-`.

Rule: before using a flag or revset in code, run `jj <cmd> --help` in a
throwaway repo and confirm the exact name.

### `normal_target` can be null in bookmark templates

`jj bookmark list --all-remotes -T` iterates every bookmark including
ones where the local target is gone but remote-tracking refs remain.
`normal_target.commit_id()` crashes on those. Guard with:

```
if(normal_target, <body>, "")
```

Same pattern applies to any template that dereferences `normal_target`
or `conflicted_target`.

### Create side-effects AFTER preflight, not before

Original `jj_agent --tmux` ran `jj workspace add`, then checked `$TMUX`.
If the user was not inside tmux the workspace was already on disk and
the next invocation failed with "path already exists". Always reorder
so every validation happens before the first state-changing command.

## Terminal integration

### Ghostty has no IPC to control a running instance (v1.3.2, 2026-04)

- `ghostty +new-window` — exits 1 with `"not supported on this platform"` on macOS.
- No `GHOSTTY_IPC_SOCKET` env var, no UDS under `/tmp`/`$TMPDIR`/`~/Library`, no XPC service in the app bundle.
- Consequence: a `jj_agent --ghostty` that opens a new tab in the current Ghostty window is **not possible today**. The workable fallback is `open -a Ghostty.app --args --working-directory=<path>` which opens a new **window** (not tab). Gate it on `$TERM_PROGRAM = ghostty` and `uname = Darwin`.
- Detection is reliable: `$TERM_PROGRAM`, `$GHOSTTY`, `$GHOSTTY_SHELL_FEATURES`, `$GHOSTTY_SURFACE_ID` are all set.
- OSC 9 desktop notifications are **not implemented** by Ghostty yet. Emitting OSC 9 is a silent no-op; `osascript` is the macOS fallback.

### Terminal title (OSC 0) is the cheapest UX win

- `printf '\e]0;%s\a' $title` is honored by Ghostty, iTerm2, WezTerm, Alacritty, Kitty, and tmux (with `set-titles on`).
- Cost: ~4 lines of fish. Value: N parallel agent tabs stay legible.
- Always gate on `isatty stdout` — fishtape's command substitution is non-tty, so a well-written helper silently no-ops in tests without any mocking.
- Ghostty's shell integration already handles OSC 7 (cwd) and OSC 133 (prompt marks). The plugin must not re-emit these.

## Competitor adoption discipline

A 2026-04 gap analysis (four competing plugins, manually cross-checked
by an independent reviewer) shortlisted ~15 candidate features. Only
three families made it in:

- **jj primitives that cover daily stack operations** — `jnx` / `jpv`
  (`jj next` / `jj prev`) and `jgr` / `jgra` / `jgrl`
  (`jj git remote` family).
- **Composite workflow matching the plugin's thesis** — `jgpc`
  (`jj git push --change @`) plus `jj_push_pr`, which chains
  `jj git push -c` and `gh pr create`.

The rejects, with reasons preserved so they do not come back round the
loop:

- `jj_ai_describe` — Claude Code / Codex already write commit messages;
  duplicating adds surface area without new value.
- `jj_fzf_interdiff` — two chained revision pickers feel clever in
  isolation but confuse fish readline bindings and are rarely needed.
- AI spinner / tool auto-detect UIs — fragile under tmux and non-tty
  agent runs; `$JJ_AI_TOOL` pinning is the only shape worth shipping.
- `jjrt` = `cd (jj root)` — one keystroke saved, outside the thesis.
- `jj bisect` / `jj fix` / `jj arrange` / `jj parallelize` abbreviations —
  rare operations that would push the abbr list past its ~30 ceiling.

Rule of thumb: **new competitor features need positive evidence that
they serve parallel-agent workflows, not merely "HotThoughts has it".**

## jj authoring

### The working copy keeps absorbing edits until `jj new`

In a colocated jj+git repo, the working copy change (`@`) is mutated
every time a file changes. If you `jj describe -m "feat: A"` and then
keep editing files, those new edits land in the "feat: A" change —
*not* a new one. The fix is to start a fresh change **before** the new
work begins:

```fish
jj new -m 'next topic'
```

Symptom I hit: a describe called "OSC 0 title sync" ended up carrying
an unrelated batch of abbr additions a session later. Recovery used
`jj split -- <paths>` (see below) but it is cheaper to not let the
mess happen.

### `jj workspace` is the `git worktree` equivalent, but not a subset

Reviewers and cold readers often ask "why do I need this plugin if I
can just use `git worktree`?". The one-paragraph answer — now mirrored
in `README.md` under "Coming from `git worktree`?" — is that
`jj workspace` covers every git-worktree use case **and** adds:

- `<name>@` as a first-class revset (no `git -C <path>` dance).
- Shared op log: `jj op undo` / `op restore` from any workspace
  reaches every workspace.
- `jj workspace forget` is non-destructive — the change itself stays,
  only the workspace entry goes away.
- Adding a workspace is a working-copy link, not a fresh clone.

Two caveats worth preserving:

- **Colocated repos**: the main workspace is a real git repo; extra
  jj workspaces are **not** git worktrees. Git tooling only sees the
  primary.
- **Stale working copy**: if another workspace's operation rewrote
  your `@` while you were away, re-entering that workspace needs
  `jj workspace update-stale` to resync.

When changing `jj_agent` / `jj_fzf_workspace` / `jj_agent_list` /
`jj_agent_done` / `jj_agent_prune` / `jj_agent_diff` behavior, keep
the README mapping table honest — that is the canonical onboarding
surface.

### `jj split` takes paths after `--`, not `--paths`

The flag-style attempt (`jj split --paths a --paths b`) fails with
"use '-- --paths' to pass". The correct shape is positional
filesets after `--`:

```fish
jj split -m '<new change message>' -- path1 path2 path3
```

After the split, the specified paths become a **new change placed as
parent of the original `@`**, and the remaining diff stays on `@`. The
resulting order may feel inverted — annotate the change descriptions
so future readers can follow the narrative regardless.

## Process

- **Trust but verify every agent suggestion.** Codex correctly flagged
  all five v0.1 blockers, but also raised concerns that turned out to be
  non-issues (e.g. `time.start()` was claimed unstable but works fine in
  jj 0.40). `home-fix-review-comments` exists precisely because
  reviewers are not always right.
- **Stage irreversible steps.** Repo creation, PR opening, `gh repo
  create` are all confirmed with the user before running. Local commits
  are not.
