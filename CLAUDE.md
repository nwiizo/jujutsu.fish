# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A fish-shell plugin for [Jujutsu (jj)](https://github.com/jj-vcs/jj). Three concerns only:

1. ~30 `j`-prefixed abbreviations (prefix configurable via `$jujutsu_fish_prefix`)
2. fzf pickers for `log` / `bookmark` / `op` / `workspace` / `status`
3. `jj_agent` / `jj_agent_list` — helpers for parallel coding-agent sessions in separate jj workspaces

Completions are deliberately not shipped — jj 0.24+ provides dynamic completions that fish 4.0.2+ auto-loads. See `README.md` for user-facing docs and `LESSONS.md` for v0.1 review findings (read before touching external-command invocations or jj templates).

## Stack

- fish >= 3.6, jj >= 0.24, fzf (optional, only for pickers)
- Testing: fishtape, with shared mocks in `tests/test_helper.fish`
- Linting: `fish_indent --check`. CI: `.github/workflows/ci.yml`
- Layout: `conf.d/` (plugin entry), `functions/` (one function per file, autoloaded; includes `__jujutsu_fish_err` helper), `tests/` (fishtape)

## Commands

```fish
fishtape tests/*.test.fish                                              # test
fish_indent --check conf.d/*.fish functions/*.fish tests/*.fish         # lint (matches CI)
fish_indent -w conf.d/*.fish functions/*.fish tests/*.fish              # format
fisher install $PWD                                                     # local install for manual testing
```

## Sub-agent routing

Inherits global routing from `~/.claude/CLAUDE.md`. No project-specific overrides. For parallel review (code quality / simplicity / independent second opinion), dispatch `home-code-reviewer` + `home-simplify-reviewer` + `home-codex-reviewer` per the global workflow.

## Rules (path-scoped, load when matching files are in context)

@.claude/rules/fish.md
@.claude/rules/plugin.md
@.claude/rules/abbreviations.md
@.claude/rules/pickers.md
@.claude/rules/testing.md

## Skills (user-invoked)

- `/add-abbreviation` — add a new `j`-prefixed abbr with the required 4-places update
- `/add-picker` — scaffold a new `jj_fzf_*` picker and wire it into `jj_configure_bindings`
