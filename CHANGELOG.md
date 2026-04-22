# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning is semver; pre-1.0 releases may break.

## [Unreleased]

## [0.0.1] - 2026-04-22

Initial release. Parallel coding-agent jj workflow in fish, with curated
abbreviations, fzf pickers, and a full workspace lifecycle.

### Abbreviations

Single-letter prefix (`j`, configurable via `$jujutsu_fish_prefix`),
~30 commands total — core, log, edit, bookmark, op log, git bridge
(including `jgpc` = `jj git push --change @` and `jgr`/`jgra`/`jgrl`),
workspace, plus `jnx`/`jpv` for `jj next`/`jj prev`.

### Pickers

- `jj_fzf_log` — pick a revision, insert change-id
- `jj_fzf_bookmark` — pick a bookmark name
- `jj_fzf_op` — pick an operation id
- `jj_fzf_workspace` — pick a workspace, `cd` + set title, preview shows `jj status`
- `jj_fzf_status` — pick a changed file, open in `$EDITOR`
- `jj_squash_into` — pick a target revision, confirm, `jj squash --into`

All pickers are opt-in through `jj_configure_bindings`.

### Agent workspace lifecycle

- `jj_agent <name>` — create a new jj workspace and open `$EDITOR` or a
  new tmux window. Sets terminal title to `jj:<name>` via OSC 0.
- `jj_agent_list` — tabular dirty/clean view with auto-sized name
  column and color gating on `isatty`.
- `jj_agent_done <name>` — summarize, optionally `jj_push_pr`, optionally
  `jj workspace forget`. Interactive y/N by default, `--push-pr
  --forget` to bypass.
- `jj_agent_prune [--dry-run]` — forget non-default workspaces whose `@`
  is empty. Conservative: asks per workspace, never touches `default`.
- `jj_agent_diff <nameA> <nameB>` — `jj diff --from A@ --to B@` for
  comparing parallel agent output.

### Push and PR

- `jj_push_pr [-r <rev>] [-- <gh args>...]` — chains `jj git push --change`
  and `gh pr create --head <push-bookmark>`. Extra args after `--` forward
  to `gh pr create` (`--draft`, `--title`, etc).

### Helpers

- `__jujutsu_fish_err` — repo-wide error formatter with caller-name
  prefix and `isatty`-gated color.
- `__jujutsu_fish_set_title` — OSC 0 terminal title helper, used by
  `jj_agent` and `jj_fzf_workspace`.
- `jj_configure_bindings` — opt-in keybinding wiring (log / bookmark /
  op / workspace / status / squash).

### Tooling

- fishtape test suite (44 assertions)
- `fish_indent --check` in CI (GitHub Actions, ubuntu-latest)
- Fisher uninstall hook that clears abbrs out of universal variables

### Philosophy

- No completions shipped — jj 0.24+ ships dynamic completions that
  fish 4.0.2+ auto-loads.
- Non-destructive by default — additive jj operations only.
- Curated abbreviation list (~30), not kitchen-sink.
- See [LESSONS.md](LESSONS.md) for review findings and
  [.claude/rules/plugin.md](.claude/rules/plugin.md) for the
  competitor-adoption policy.
