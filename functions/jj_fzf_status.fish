function jj_fzf_status --description 'Pick a changed file via fzf with diff preview and open it in $EDITOR'
    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end
    type -q fzf; or begin
        __jujutsu_fish_err 'fzf is not installed'
        return 127
    end

    # `jj diff --summary` prints one line per changed file:
    #   M path/to/file
    #   A path/to/new
    #   D path/to/removed
    #   R old/path -> new/path
    #   C old/path -> new/path
    # Reshape to <letter>\t<dest-path>. For rename/copy the destination is
    # what the user cares about, so strip the "old -> " prefix here once.
    # Tab-delimiting lets fzf pass the path directly as {2}; we avoid piping
    # preview bodies through $SHELL and the argv-splitting that entailed.
    set -l lines (jj diff --summary 2>/dev/null \
        | string replace -r '^([A-Z]) (?:.* -> )?(.*)$' '$1'\t'$2')
    test (count $lines) -eq 0; and begin
        __jujutsu_fish_err 'working copy is clean'
        return 1
    end

    set -l selection (
        printf '%s\n' $lines \
        | fzf --no-sort \
              --prompt='jj diff > ' \
              --delimiter=\t --with-nth=1,2 \
              --preview='jj diff --color=always --ignore-working-copy -- {2}' \
              --preview-window='right:65%:wrap'
    )
    test -z "$selection"; and return 130

    set -l path (string split -f2 \t -- $selection)

    # Determine the editor. $EDITOR may contain flags (e.g. "code --wait"),
    # so split on whitespace into a token array and invoke without `eval`.
    # This avoids command injection when $path contains shell metacharacters.
    set -l editor $EDITOR
    test -z "$editor"; and set editor (set -q VISUAL; and echo $VISUAL; or echo vi)
    set -l editor_tokens (string split ' ' -- $editor)
    $editor_tokens -- $path
end
