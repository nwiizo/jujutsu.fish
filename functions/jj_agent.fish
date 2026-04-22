function jj_agent --description 'Create a jj workspace for a parallel coding-agent session and open it'
    # Usage:
    #   jj_agent <workspace-name> [-r <revset>] [-e <editor>]
    #
    # Creates a new jj workspace whose name is <workspace-name>, based at
    # <revset> (default: current `@`). The workspace directory is placed at
    # $jujutsu_agent_root/<workspace-name> (default: ../<workspace-name>),
    # then opened with $editor (default: $EDITOR, falling back to printing
    # the path for manual cd).
    #
    # Intended for coding-agent workflows where each agent session lives in
    # its own working copy. Non-destructive: it never rewrites existing
    # commits or workspaces — it only adds new ones.

    type -q jj; or begin
        echo "jj_agent: jj is not installed" >&2
        return 127
    end

    argparse 'r/revset=' 'e/editor=' h/help -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: jj_agent <workspace-name> [-r <revset>] [-e <editor>]'
        return 0
    end

    set -l name $argv[1]
    test -z "$name"; and begin
        echo "jj_agent: missing workspace name" >&2
        echo 'Usage: jj_agent <workspace-name> [-r <revset>] [-e <editor>]' >&2
        return 2
    end

    set -l revset (set -q _flag_revset; and echo $_flag_revset; or echo '@')
    set -q jujutsu_agent_root; or set -l jujutsu_agent_root (path dirname (jj workspace root 2>/dev/null))
    set -l path $jujutsu_agent_root/$name

    if test -e $path
        echo "jj_agent: path already exists: $path" >&2
        return 1
    end

    jj workspace add --name $name -r $revset $path
    or return $status

    set -l editor (set -q _flag_editor; and echo $_flag_editor; or echo $EDITOR)
    if test -n "$editor"
        pushd $path >/dev/null
        eval $editor .
        popd >/dev/null
    else
        echo "jj_agent: workspace ready at $path (no \$EDITOR set; cd manually)"
    end
end
