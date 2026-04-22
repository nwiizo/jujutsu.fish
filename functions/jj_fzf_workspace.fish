function jj_fzf_workspace --description 'Pick a workspace via fzf and cd into its path'
    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end
    type -q fzf; or begin
        __jujutsu_fish_err 'fzf is not installed'
        return 127
    end

    # `jj workspace list` prints "<name>: <change-id> <description>" — not
    # directly a path. We enumerate workspaces, then resolve each one's
    # working-copy path via `jj workspace root --name <name>`. Workspaces
    # whose path cannot be resolved are skipped rather than shown in the
    # picker so the user cannot select a broken entry.

    set -l names
    for line in (jj workspace list 2>/dev/null)
        set -a names (string split -m1 ':' -- $line)[1]
    end
    test (count $names) -eq 0; and begin
        __jujutsu_fish_err 'no workspaces found'
        return 1
    end

    set -l rows
    for name in $names
        set -l path (jj workspace root --name $name 2>/dev/null)
        or continue
        set -a rows "$name"\t"$path"
    end
    test (count $rows) -eq 0; and begin
        __jujutsu_fish_err 'could not resolve any workspace paths'
        return 1
    end

    set -l selection (
        printf '%s\n' $rows \
        | fzf --no-sort \
              --prompt='jj workspace > ' \
              --delimiter='\t' \
    )
    test -z "$selection"; and return 130

    set -l path (string split -f2 \t -- $selection)
    test -d "$path"; or begin
        __jujutsu_fish_err "workspace path does not exist: $path"
        return 1
    end

    cd -- $path
    commandline -f repaint
end
