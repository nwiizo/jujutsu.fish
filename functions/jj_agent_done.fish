function jj_agent_done --description 'Close out an agent workspace: summarize, optionally push PR, optionally forget'
    # Usage:
    #   jj_agent_done <name> [--push-pr] [--forget]
    #
    # Prints a summary of the named workspace's @ (change-id, description,
    # diff stat, log). With --push-pr, chains `jj_push_pr` on that @. With
    # --forget, runs `jj workspace forget <name>` after the user confirms.
    #
    # Default (no flags): interactive — asks y/N for each side-effect.

    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end

    argparse push-pr forget h/help -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: jj_agent_done <name> [--push-pr] [--forget]'
        return 0
    end

    set -l name $argv[1]
    test -z "$name"; and begin
        __jujutsu_fish_err 'missing workspace name'
        return 2
    end

    # Validate: workspace must exist. `jj workspace list -T name` prints
    # one name per line.
    set -l known (jj workspace list -T 'name ++ "\n"' 2>/dev/null)
    contains -- $name $known; or begin
        __jujutsu_fish_err "unknown workspace: $name"
        return 1
    end

    # Summary block. The workspace revset `<name>@` is the @ of the
    # named workspace (see jj docs on revsets). --ignore-working-copy so
    # we do not fight the current workspace's @ update.
    set -l rs $name'@'
    echo '── '$name' ──'
    jj log --no-graph --color=always --ignore-working-copy \
        -r $rs -T 'change_id.shortest(8) ++ " | " ++ description.first_line() ++ "\n"'
    jj diff --stat --ignore-working-copy -r $rs 2>/dev/null
    echo

    # Side-effect 1: push + PR.
    set -l do_push 0
    if set -q _flag_push_pr
        set do_push 1
    else
        read -l -P 'push and open PR via gh? [y/N] ' ans
        switch $ans
            case y Y yes Yes
                set do_push 1
        end
    end
    if test $do_push -eq 1
        if functions -q jj_push_pr
            jj_push_pr -r $rs
            or return $status
        else
            __jujutsu_fish_err 'jj_push_pr function is not available'
        end
    end

    # Side-effect 2: forget the workspace (non-destructive to the change
    # itself — `jj workspace forget` just removes the workspace entry).
    set -l do_forget 0
    if set -q _flag_forget
        set do_forget 1
    else
        read -l -P "forget workspace '$name'? [y/N] " ans
        switch $ans
            case y Y yes Yes
                set do_forget 1
        end
    end
    if test $do_forget -eq 1
        jj workspace forget $name
        or return $status
    end
end
