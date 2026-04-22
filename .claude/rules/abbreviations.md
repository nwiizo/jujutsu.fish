---
paths: ["conf.d/jujutsu.fish", "tests/abbreviations.test.fish", "README.md"]
description: 4-places update rule for adding/removing jj-prefixed abbreviations
---

# Abbreviation Rules

## Why register/erase are split

`__jujutsu_fish_register_abbrs` and `__jujutsu_fish_erase_abbrs` are defined as **plain functions, not event handlers**, so that tests (running inside a non-interactive fishtape subshell) can call them directly. The `status is-interactive; or return` guard at the top of `conf.d/jujutsu.fish` only runs in the file's top-level scope — it does not protect the functions themselves.

The erase function carries its **own hardcoded suffix list** and is not auto-synced from register. You must update both sides on any add/remove, or the abbr survives `fisher remove` as a universal variable on the user's shell.

## 4-places update

When adding, renaming, or removing an abbreviation, update all four sites in the same change. Skipping any one of them either pollutes the user's universal variables or causes a regression.

1. `__jujutsu_fish_register_abbrs` in `conf.d/jujutsu.fish`
2. `__jujutsu_fish_erase_abbrs` suffix list in the same file (hardcoded, not auto-synced)
3. The abbreviations table in `README.md`
4. `tests/abbreviations.test.fish` — at least one assertion per new abbr

## Prefix safety

- Every abbr is built as `{$p}<suffix>` where `$p = $jujutsu_fish_prefix` (default `j`).
- **Never hardcode `j`.** The test suite verifies registration under a custom prefix (`vc`); hardcoded literals break it.

## Scope

- Only abbreviate commands that users actually type daily. Infrequent ones are fine as plain `jj <subcmd>`. Aim for ~30 total.
