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
    # For renames/copies the destination is what the user wants to open —
    # strip the status letter and any "old -> " prefix.
    set -l lines (jj diff --summary 2>/dev/null)
    test (count $lines) -eq 0; and begin
        __jujutsu_fish_err 'working copy is clean'
        return 1
    end

    # fzf runs preview commands through $SHELL, which may be bash/zsh on
    # macOS defaults. Explicitly invoke fish so the preview body below is
    # portable. The variable $p is set inside fish -c, not inherited.
    set -l preview_cmd 'fish -c \'set p (string replace -r "^[A-Z] (.* -> )?" "" -- $argv[1]); jj diff --color=always -- $p\' fish {}'

    set -l selection (
        printf '%s\n' $lines \
        | fzf --no-sort \
              --prompt='jj diff > ' \
              --preview=$preview_cmd \
              --preview-window='right:65%:wrap'
    )
    test -z "$selection"; and return 130

    set -l path (string replace -r '^[A-Z] (.* -> )?' '' -- $selection)

    # Determine the editor. $EDITOR may contain flags (e.g. "code --wait"),
    # so split on whitespace into a token array and invoke without `eval`.
    # This avoids command injection when $path contains shell metacharacters.
    set -l editor $EDITOR
    test -z "$editor"; and set editor (set -q VISUAL; and echo $VISUAL; or echo vi)
    set -l editor_tokens (string split ' ' -- $editor)
    $editor_tokens -- $path
end
