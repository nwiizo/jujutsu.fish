function jj_fzf_status --description 'Pick a changed file via fzf with diff preview and open it in $EDITOR'
    type -q jj; or begin
        echo "jj_fzf_status: jj is not installed" >&2
        return 127
    end
    type -q fzf; or begin
        echo "jj_fzf_status: fzf is not installed" >&2
        return 127
    end

    # `jj diff --summary` prints one line per changed file:
    #   M path/to/file
    #   A path/to/new
    #   R old/path -> new/path
    # For renames fzf should offer the destination path — strip the
    # "old -> " prefix.
    set -l lines (jj diff --summary 2>/dev/null)
    test (count $lines) -eq 0; and begin
        echo "jj_fzf_status: working copy is clean" >&2
        return 1
    end

    set -l selection (
        printf '%s\n' $lines \
        | fzf --no-sort \
              --prompt='jj diff > ' \
              --preview='set -l p (string replace -r "^[A-Z] (.* -> )?" "" -- {}); jj diff --color=always -- $p' \
              --preview-window='right:65%:wrap' \
    )
    test -z "$selection"; and return 130

    set -l path (string replace -r '^[A-Z] (.* -> )?' '' -- $selection)
    set -l editor $EDITOR
    test -z "$editor"; and set editor (set -q VISUAL; and echo $VISUAL; or echo vi)
    eval $editor $path
end
