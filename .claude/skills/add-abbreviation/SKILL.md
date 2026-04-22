---
name: add-abbreviation
description: Add a new jj abbreviation across the 4 required sites (register, erase, README, test) with verification. Invoke manually; has side effects.
disable-model-invocation: true
---

# Add Abbreviation

Procedure for adding a new `j`-prefixed abbreviation. Updating all 4 sites simultaneously is mandatory — see `.claude/rules/abbreviations.md`.

## Inputs

Ask the user for these three (confirm if any are missing):

1. **suffix** — the part after `j` (e.g. `re` for `jre`)
2. **expansion** — the command it expands to (e.g. `jj restore`)
3. **category** — which group of the README table it belongs to (Core / Log / Change editing / Bookmarks / Operation log / Git bridge / Workspace)

Verify the new abbr does not collide with an existing one, and that it stays unique under a custom `$jujutsu_fish_prefix` (multi-char prefixes are supported).

## Steps

### 1. `conf.d/jujutsu.fish` — register

Add one line under the matching category comment block inside `__jujutsu_fish_register_abbrs`:

```fish
abbr -a {$p}<suffix> '<expansion>'
```

Use `$p` (= `$jujutsu_fish_prefix`). Never hardcode `j`.

### 2. `conf.d/jujutsu.fish` — erase

Add `<suffix>` to the `for short in ...` list inside `__jujutsu_fish_erase_abbrs`. **If you skip this, the abbr survives `fisher remove` as a universal variable.**

### 3. `README.md` — abbreviations table

Add one row to the matching category block under `## Usage → ### Abbreviations`:

```
| `j<suffix>` | `<expansion>` |
```

### 4. `tests/abbreviations.test.fish` — test

Add at least one assertion for the default-prefix case:

```fish
@test "j<suffix> expansion" (abbr --show | string match -rq "^abbr -a -- j<suffix> '<expansion>'\$") $status -eq 0
```

If the expansion contains spaces or special characters, mirror the quoting style used by the existing `jgpa` row.

## Verification

Run both, in order, and confirm both are green:

```fish
fish_indent --check conf.d/jujutsu.fish tests/abbreviations.test.fish
fishtape tests/abbreviations.test.fish
```

A missing erase-list entry will **not** fail the test suite — visually confirm the suffix exists in the erase loop.

## Done when

- All 4 files are modified
- `fishtape` passes every abbreviation test
- `fish_indent --check` passes
- Diff shows a new row in the README table
