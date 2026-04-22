---
paths: ["conf.d/**/*.fish", "functions/**/*.fish"]
description: Plugin-level invariants — no completions, non-destructive defaults, uninstall hook integrity
---

# Plugin Invariants

## NEVER

- **Do not ship completions.** jj 0.24+ provides dynamic completions that fish 4.0.2+ auto-loads. Shipping our own causes collisions and duplicates.
- **Do not perform destructive operations by default.** `jj_agent` and similar helpers are additive only (e.g. `workspace add`). Never rewrite existing commits or forget workspaces automatically.
- **Do not add abbreviations just to grow the list.** The README explicitly rejects kitchen-sink abbr lists; ~30 is the intended ceiling.

## MUST

- Keep the Fisher uninstall hook (`_jujutsu_fish_uninstall` on the `jujutsu_fish_uninstall` event) working. Abbreviations live in universal variables, so skipping `erase` leaves them in the user's shell after `fisher remove`.
- Update the corresponding README table or list whenever a new public function, picker, or abbreviation is added.
- Make any potentially destructive feature (abandon/restore wrappers, etc.) opt-in via an environment variable or confirmation prompt. `JUJUTSU_FISH_CONFIRM=1` in the README's "Future ideas" section is the reference pattern.

## Agent workspace helpers

- `jj_agent` calls only `jj workspace add`. Do not add commit-rewriting or workspace-forgetting behavior.
- `$jujutsu_agent_root` defaults to the parent of the main workspace root. Write code that assumes users will override it.
- `--tmux` **requires an existing `$TMUX` session**. Do not spawn a tmux session — that would take over the user's session layout.
- `jj_agent_list` consumes `jj workspace list -T '<template>'` with `\t`-delimited columns, then pads with `printf '%-20s ...'`. Do not depend on the external `column` binary. If you add a column, update **both** the template and the `printf` format string.

## Competitor adoption (learned from 2026-04 gap analysis)

- When considering a feature that appears in another jj plugin (HotThoughts/jj.fish, kapsmudit/plugin-jj, omz-jj, tim-janik/jj-fzf), ask: **does this serve the parallel-agent thesis?** If not, decline, even if it looks convenient.
- Rejected in v0.1 with explicit rationale — do not re-propose without new evidence:
  - `jj_ai_describe` / AI commit-message helpers → Claude Code / Codex already do this; adding another layer doubles surface area for no gain.
  - `jj_fzf_interdiff` (2-rev picker) → fish readline handles one picker per binding well; chained pickers are fragile and rarely used.
  - AI-spinner / tool-auto-select UI → breaks under tmux / non-tty agent runs; `JJ_AI_TOOL` pinning is the only acceptable shape.
  - `jjrt` = `cd (jj root)` → one-character savings, outside the plugin's thesis.
  - `jj bisect` / `jj fix` / `jj arrange` / `jj parallelize` abbreviations → rare operations; adding them violates the curated-~30 ceiling.
- **Do** adopt when: (1) jj exposes a primitive daily operation (`next`, `prev`, `git remote`, `git push --change`), or (2) the feature composes a stack-friendly workflow (`jj_push_pr` chains push + `gh pr create`).
