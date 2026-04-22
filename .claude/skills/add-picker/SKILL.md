---
name: add-picker
description: Scaffold a new jj_fzf_* picker following the shared contract — dependency guards, cancel code 130, tab-delimited templates, binding wiring, README entry. Invoke manually; has side effects.
disable-model-invocation: true
---

# Add Picker

Procedure for adding a new `jj_fzf_<name>` picker. Must obey the shared contract in `.claude/rules/pickers.md`.

## Inputs

Ask the user for:

1. **name** — suffix after `jj_fzf_` (e.g. `branch`, `conflict`). Filename will be `functions/jj_fzf_<name>.fish`.
2. **source** — what `jj` subcommand produces the candidates (e.g. `jj log`, `jj bookmark list`, `jj op log`).
3. **side effect** — exactly one of:
   - insert identifier at cursor (`commandline -i`)
   - `cd` into a path
   - open in `$EDITOR`
   - run a mutating `jj` command (requires confirmation prompt)
4. **preview** — optional `jj show`-style preview command. If `jj show` is used, **always add `--ignore-working-copy`**.

Do not mix side-effect types in a single picker.

## Steps

### 1. Create `functions/jj_fzf_<name>.fish`

Use this skeleton. Guards and exit codes are mandatory; see `.claude/rules/fish.md`.

```fish
function jj_fzf_<name> --description '<one-line description>'
    type -q jj; or begin
        echo "jj_fzf_<name>: jj is not installed" >&2
        return 127
    end
    type -q fzf; or begin
        echo "jj_fzf_<name>: fzf is not installed" >&2
        return 127
    end

    # Emit \t-delimited columns: <id>\t<human-visible>\t...
    set -l template '<jj template expression>'

    set -l selection (
        jj <source> --color=always --ignore-working-copy \
            -T "$template" 2>/dev/null \
        | fzf --ansi --no-sort \
              --prompt='jj <name> > ' \
              --delimiter='\t' --with-nth=2 \
              --preview='<preview command> {1}' \
              --preview-window='right:60%:wrap'
    )

    test -z "$selection"; and return 130

    set -l id (string split -f1 \t -- $selection)
    # Exactly one of:
    commandline -i -- $id; and commandline -f repaint
    # --- or ---
    # cd -- $path; and commandline -f repaint
    # --- or ---
    # set -l editor $EDITOR; test -z "$editor"; and set editor (set -q VISUAL; and echo $VISUAL; or echo vi)
    # eval $editor $path
end
```

### 2. Wire into `functions/jj_configure_bindings.fish`

Two edits:

- Add `'<name>=?'` to the `argparse` list
- Add the corresponding bind line:

```fish
set -q _flag_<name>; and test -n "$_flag_<name>"; and bind $_flag_<name> jj_fzf_<name>
```

### 3. Update `README.md`

- Add a row to the "Jobs this plugin hires itself to do" table
- Add a bullet under the **Available pickers** list
- Add the flag to the `jj_configure_bindings` example snippet

### 4. Update `CLAUDE.md` (only if the picker list is referenced there)

Currently `CLAUDE.md` references pickers by category, not by name — edit only if the new picker changes the category description.

## Verification

```fish
fish_indent --check functions/jj_fzf_<name>.fish functions/jj_configure_bindings.fish
fishtape tests/*.test.fish
```

Then manually in an interactive fish session with `jj` and `fzf` installed:

```fish
source functions/jj_fzf_<name>.fish
jj_fzf_<name>                  # pick something → verify side effect
jj_fzf_<name>                  # press Esc → command returns 130, no side effect
```

If the picker mutates state, also test the confirmation prompt path.

## Done when

- New function file exists and loads cleanly
- `jj_configure_bindings` accepts the new flag
- README is updated in all three places (table, pickers list, example snippet)
- `fish_indent --check` and `fishtape` pass
- Manual smoke test (pick + cancel) succeeds
