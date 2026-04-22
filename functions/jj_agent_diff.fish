function jj_agent_diff --description 'Diff two agent workspaces against each other (<nameA>@ vs <nameB>@)'
    # Usage:
    #   jj_agent_diff <nameA> <nameB>
    #
    # When two agents run the same task in parallel (two workspaces),
    # this prints the diff between their current @ commits so a human
    # can decide which one to land.

    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end

    test -n "$argv[1]"; and test -n "$argv[2]"; or begin
        __jujutsu_fish_err 'usage: jj_agent_diff <nameA> <nameB>'
        return 2
    end

    set -l a $argv[1]
    set -l b $argv[2]

    set -l known (jj workspace list -T 'name ++ "\n"' 2>/dev/null)
    for wname in $a $b
        contains -- $wname $known; or begin
            __jujutsu_fish_err "unknown workspace: $wname"
            return 1
        end
    end

    # Header so the reader can tell which side is which even when the
    # diff is long. Colors only when stdout is a tty.
    if isatty stdout
        set -l hi (set_color --bold cyan)
        set -l rs (set_color normal)
        printf '%s%s@%s vs %s%s@%s\n\n' $hi $a $rs $hi $b $rs
    else
        printf '%s@ vs %s@\n\n' $a $b
    end

    jj diff --color=always --ignore-working-copy --from $a'@' --to $b'@'
end
