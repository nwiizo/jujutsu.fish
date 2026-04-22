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
