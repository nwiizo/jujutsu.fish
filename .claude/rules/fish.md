---
paths: ["**/*.fish"]
description: Fish shell authoring conventions (autoload, indent, guards, exit codes)
---

# Fish Shell Rules

## Autoload contract

- `functions/<name>.fish` is **one function per file**, and the filename must match the function name (fish autoload depends on this).
- `conf.d/*.fish` is sourced on every shell start. Anything with side effects (registering abbrs, binding keys, etc.) must be guarded with `status is-interactive; or return` and, where applicable, `type -q <cmd>; or return`.

## Formatting

- `fish_indent --check conf.d/*.fish functions/*.fish tests/*.fish` must pass before commit (CI runs the same check).
- Format manually with `fish_indent -w <file>`. Don't rely on editor integrations — run it and inspect the diff.

## Exit codes

- Missing dependency: return `127` and emit `<func>: <cmd> is not installed` on stderr.
- User cancels fzf (empty selection): return `130`, matching fzf's own convention. Breaking this hurts keybinding UX.
- Invalid arguments: let `argparse` fail naturally (`return 2`).

## Error messages

- Route user-facing stderr through `__jujutsu_fish_err <func> <msg...>` instead of ad hoc `echo >&2`. This keeps prefixes consistent (`jj_agent: ...`, `jj_fzf_log: ...`) and makes the output easy to assert against in tests.

## Version floor

- Assume fish `>= 3.6` and jj `>= 0.24`. If you rely on a newer feature, bump the Requirements section in `README.md` in the same commit.

## Common traps (details in [LESSONS.md](../../LESSONS.md))

- Never `eval $cmd $arg` for paths or user-influenced strings. Split the command into tokens and invoke directly: `set -l t (string split ' ' -- $cmd); $t -- $arg`.
- `fzf --preview=<cmd>` runs through `$SHELL`, not fish. If the body uses fish syntax, wrap it: `fish -c '<body>' fish {}`.
- In `string replace -r`, put the replacement (`'$1'`) in single quotes. If the pattern contains a literal `$`, either single-quote the pattern or escape it (`"\$"`). Prefer `string match -rg` when you only need capture groups.
- Gate colored output on `isatty stdout` / `isatty stderr`. Tests, CI, and `2>file` redirects capture stderr into non-TTY streams; ANSI codes break assertions and dirty logs.
- Parse external-command output with `string match -rg '(<group>)' -- $text` (fish-native, no subprocesses). Do not reach for `grep` / `sed` / `awk` — `jj_push_pr` is the reference implementation for extracting a bookmark name from `jj git push --change` output.
- Do the text-shaping work **before** fzf, not inside `--preview`. `jj_fzf_status` emits pre-split `<status>\t<path>` rows and uses `--with-nth=1,2` + `{2}` in preview, so the preview body stays plain POSIX (`jj diff -- {2}`) and is immune to the fish-vs-`$SHELL` trap.
