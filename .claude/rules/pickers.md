---
paths: ["functions/jj_fzf_*.fish", "functions/jj_configure_bindings.fish", "functions/jj_squash_into.fish"]
description: Shared contract for jj_fzf_* pickers and key-binding wiring
---

# fzf Picker Contract

When adding or modifying a `jj_fzf_*` picker, follow the shared contract below. `jj_configure_bindings` assumes it — breaking the contract breaks keybinding UX for every picker.

## MUST

- Guard dependencies at the top: `type -q jj; or ... return 127` and `type -q fzf; or ... return 127`.
- Return **`130`** when the user cancels fzf (empty selection).
- Produce `\t`-delimited machine-readable columns via a `jj` template, then hide internal columns from the user with fzf's `--delimiter='\t' --with-nth=...`.
- Keep side effects to a single kind per picker:
  - identifier pickers (log / bookmark / op) → `commandline -i` the selected id, finish with `commandline -f repaint`
  - navigation pickers (workspace) → `cd --`
  - edit pickers (status) → open in `$EDITOR`, falling back to `$VISUAL` then `vi`
  - mutating actions (squash, etc.) → confirm before executing

## Key bindings are opt-in

`jj_configure_bindings` follows fzf.fish's opt-in model: **no keys are bound by default**. Each `--<name>=<key>` flag binds one picker; an empty value explicitly disables it. Any new picker must be added to both the `argparse` list and a matching bind line — otherwise users have to write raw `bind` calls.

## Wiring checklist

After creating a picker function, reflect it in all three:

1. `functions/jj_configure_bindings.fish` — extend `argparse` and add the bind line
2. `README.md` — pickers list and the `jj_configure_bindings` example
3. `CLAUDE.md` — only if the picker introduces a new category

## Preview

- Prefer `--preview 'jj show --color=always --ignore-working-copy {1}'` and similar forms. Without `--ignore-working-copy`, every preview render triggers a working-copy snapshot and the picker becomes noticeably slow on large repos.
