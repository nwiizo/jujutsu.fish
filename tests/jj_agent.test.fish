source (status dirname)/test_helper.fish

function __test_given_jj_is_missing_when_jj_agent_runs_then_it_returns_127
    __jt_reset

    function type
        test "$argv[-1]" = jj
        and return 1
        return 0
    end

    set -l output (jj_agent demo 2>&1)

    test $status -eq 127
    and string match -q 'jj_agent: jj is not installed' -- $output
end

@test "Given jj is missing When jj_agent runs Then it returns 127" (__test_given_jj_is_missing_when_jj_agent_runs_then_it_returns_127) $status -eq 0

function __test_given_name_is_missing_when_jj_agent_runs_then_it_shows_usage
    __jt_reset

    function jj
        return 0
    end

    set -l output (jj_agent 2>&1)

    test $status -eq 2
    and string match -q 'jj_agent: missing workspace name*' -- $output
    and string match -q '*Usage: jj_agent <workspace-name>*' -- $output
end

@test "Given a missing name When jj_agent runs Then it shows usage" (__test_given_name_is_missing_when_jj_agent_runs_then_it_shows_usage) $status -eq 0

function __test_given_the_workspace_path_exists_when_jj_agent_runs_then_it_refuses_to_overwrite
    __jt_reset

    set -l root (mktemp -d)
    mkdir -p $root/demo
    set -g jujutsu_agent_root $root

    function jj
        return 0
    end

    set -l output (jj_agent demo 2>&1)
    set -l status_code $status

    rm -rf $root

    test $status_code -eq 1
    and string match -q "jj_agent: path already exists: */demo" -- $output
end

@test "Given an existing workspace path When jj_agent runs Then it refuses to overwrite" (__test_given_the_workspace_path_exists_when_jj_agent_runs_then_it_refuses_to_overwrite) $status -eq 0

function __test_given_no_editor_when_jj_agent_creates_a_workspace_then_it_prints_the_ready_path
    __jt_reset

    set -l root (mktemp -d)
    set -g __jt_root $root

    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace root'
                printf '%s/main\n' $__jt_root
            case 'workspace add'
                set -ga __jt_jj_calls (string join ' ' -- $argv)
                mkdir -p $argv[-1]
            case '*'
                return 1
        end
    end

    set -l output (jj_agent demo 2>&1)
    set -l status_code $status

    rm -rf $root
    set -e __jt_root

    test $status_code -eq 0
    and test "$__jt_jj_calls[1]" = 'workspace add --name demo -r @ '"$root"'/demo'
    and string match -q "jj_agent: workspace ready at $root/demo*" -- $output
end

@test "Given no editor When jj_agent creates a workspace Then it prints the ready path" (__test_given_no_editor_when_jj_agent_creates_a_workspace_then_it_prints_the_ready_path) $status -eq 0

function __test_given_tmux_mode_when_jj_agent_runs_inside_tmux_then_it_opens_a_new_window
    __jt_reset

    set -l root (mktemp -d)
    set -g jujutsu_agent_root $root
    set -g TMUX 1

    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace add'
                mkdir -p $argv[-1]
            case '*'
                return 0
        end
    end

    function tmux
        set -ga __jt_tmux_calls (string join ' ' -- $argv)
    end

    jj_agent demo --tmux
    set -l status_code $status

    rm -rf $root

    test $status_code -eq 0
    and test "$__jt_tmux_calls[1]" = "new-window -c $root/demo -n jj:demo"
end

@test "Given tmux mode When jj_agent runs inside tmux Then it opens a new window" (__test_given_tmux_mode_when_jj_agent_runs_inside_tmux_then_it_opens_a_new_window) $status -eq 0
