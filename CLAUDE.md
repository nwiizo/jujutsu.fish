# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A fish-shell plugin for [Jujutsu (jj)](https://github.com/jj-vcs/jj). The plugin does four things:

1. ~30 `j`-prefixed abbreviations (prefix configurable via `$jujutsu_fish_prefix`)
2. fzf pickers for `log` / `bookmark` / `op` / `workspace` / `status` / `squash`
3. Full agent workspace lifecycle — `jj_agent` / `jj_agent_list` / `jj_agent_done` / `jj_agent_prune` / `jj_agent_diff` for parallel coding-agent sessions
4. Push → PR plumbing — `jj_push_pr` chains `jj git push --change` with `gh pr create`

Completions are deliberately not shipped — jj 0.24+ provides dynamic completions that fish 4.0.2+ auto-loads.

See `README.md` for user-facing docs (including a `git worktree` → `jj workspace` mapping table for new arrivals) and `LESSONS.md` for accumulated review findings: eval injection, fzf preview shell mismatch, abbr universal-var persistence, terminal integration, competitor-adoption discipline, jj authoring pitfalls, and jj-workspace-vs-git-worktree orientation. Read the latter before touching external-command invocations, jj templates, or before importing a feature from another plugin.

## Stack

- fish >= 3.6, jj >= 0.24, fzf (optional, only for pickers), gh (optional, only for `jj_push_pr`), tmux (optional, only for `jj_agent --tmux`)
- Testing: fishtape, shared mocks in `tests/test_helper.fish`
- Linting: `fish_indent --check`. CI: `.github/workflows/ci.yml`
- Layout: `conf.d/` (plugin entry), `functions/` (one function per file, autoloaded; includes `__jujutsu_fish_err` + `__jujutsu_fish_set_title` helpers), `tests/` (fishtape)

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
