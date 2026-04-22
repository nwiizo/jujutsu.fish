function jj_agent --description 'Create a jj workspace for a parallel coding-agent session and open it'
    # Usage:
    #   jj_agent <workspace-name> [-r <revset>] [-e <editor>] [--tmux]
    #
    # Creates a new jj workspace whose name is <workspace-name>, based at
    # <revset> (default: current `@`). The workspace directory is placed at
    # $jujutsu_agent_root/<workspace-name> (default: ../<workspace-name>),
    # then opened with $editor (default: $EDITOR, falling back to printing
    # the path for manual cd).
    #
    # With --tmux, opens the workspace in a new tmux window inside the
    # current session instead of in $editor. When both --tmux and
    # --editor are passed, --tmux wins (you can always run $editor inside
    # the new tmux window).
    #
    # Intended for coding-agent workflows where each agent session lives in
    # its own working copy. Non-destructive: it never rewrites existing
    # commits or workspaces — it only adds new ones.

    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end

    argparse 'r/revset=' 'e/editor=' tmux h/help -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: jj_agent <workspace-name> [-r <revset>] [-e <editor>] [--tmux]'
        return 0
    end

    set -l name $argv[1]
    test -z "$name"; and begin
        __jujutsu_fish_err 'missing workspace name'
        echo 'Usage: jj_agent <workspace-name> [-r <revset>] [-e <editor>] [--tmux]' >&2
        return 2
    end

    # Pre-flight tmux check — do this BEFORE creating the workspace so we
    # do not leave a dangling workspace on the filesystem on failure.
    if set -q _flag_tmux
        if not set -q TMUX
            __jujutsu_fish_err '--tmux requires running inside a tmux session'
            return 1
        end
        if not type -q tmux
            __jujutsu_fish_err 'tmux is not installed'
            return 127
        end
    end

    set -l revset (set -q _flag_revset; and echo $_flag_revset; or echo '@')
    set -q jujutsu_agent_root; or set -l jujutsu_agent_root (path dirname (jj workspace root 2>/dev/null))
    set -l path $jujutsu_agent_root/$name

    if test -e $path
        __jujutsu_fish_err "path already exists: $path"
        return 1
    end

    jj workspace add --name $name -r $revset $path
    or return $status

    # Hint the terminal that the current shell is now associated with this
    # agent workspace. OSC 0 is honored by Ghostty/iTerm2/WezTerm/Kitty and
    # by tmux when `set-titles on`, so a sea of parallel tabs stays legible.
    __jujutsu_fish_set_title "jj:$name"

    if set -q _flag_tmux
        tmux new-window -c $path -n "jj:$name"
        return 0
    end

    # $editor may contain flags (e.g. "code --wait"). Split into tokens and
    # invoke directly instead of through eval so $path can contain shell
    # metacharacters safely.
    set -l editor (set -q _flag_editor; and echo $_flag_editor; or echo $EDITOR)
    if test -n "$editor"
        set -l editor_tokens (string split ' ' -- $editor)
        pushd $path >/dev/null
        $editor_tokens .
        popd >/dev/null
    else
        echo "jj_agent: workspace ready at $path (no \$EDITOR set; cd manually)"
    end
end
