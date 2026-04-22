function jj_agent_prune --description 'Forget agent workspaces whose @ is empty (conservative: no state is discarded)'
    # Usage:
    #   jj_agent_prune [--dry-run]
    #
    # Lists non-default workspaces whose @ commit is empty (`target.empty()`
    # is true) and offers to forget each. Empty @ is a reliable signal for
    # "finished or never used" — it leaves nothing in the dag that depends
    # on the workspace. The default workspace is never touched.

    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end

    argparse dry-run h/help -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: jj_agent_prune [--dry-run]'
        return 0
    end

    # Template emits one row per workspace: name\tempty?
    set -l template '
        name ++ "\t" ++
        if(target.empty(), "empty", "nonempty") ++ "\n"
    '
    set -l rows (jj workspace list -T "$template" 2>/dev/null)
    test (count $rows) -eq 0; and begin
        __jujutsu_fish_err 'no workspaces found'
        return 1
    end

    set -l candidates
    for row in $rows
        set -l parts (string split \t -- $row)
        set -l wname $parts[1]
        test "$wname" = default; and continue
        test "$parts[2]" = empty; and set -a candidates $wname
    end

    if test (count $candidates) -eq 0
        echo 'jj_agent_prune: nothing to prune (no non-default workspace has an empty @)'
        return 0
    end

    for wname in $candidates
        if set -q _flag_dry_run
            echo "would forget: $wname"
        else
            read -l -P "forget workspace '$wname'? [y/N] " ans
            switch $ans
                case y Y yes Yes
                    jj workspace forget $wname
                    or return $status
            end
        end
    end
end
