source (status dirname)/test_helper.fish

function __test_given_a_selected_revision_when_jj_fzf_log_runs_then_it_inserts_the_change_id
    __jt_reset
    __jt_mock_commandline

    function jj
        set -ga __jt_jj_calls (string join ' ' -- $argv)
        printf 'qpvuntsm\t12345678\tship it\n'
    end

    function fzf
        cat
    end

    jj_fzf_log
    set -l status_code $status

    test $status_code -eq 0
    and contains -- qpvuntsm $__jt_commandline_inserts
    and contains -- repaint $__jt_commandline_actions
    and string match -q '* -r ::@ | @:: *' -- $__jt_jj_calls[1]
end

@test "Given a selected revision When jj_fzf_log runs Then it inserts the change id" (__test_given_a_selected_revision_when_jj_fzf_log_runs_then_it_inserts_the_change_id) $status -eq 0

function __test_given_a_selected_bookmark_when_jj_fzf_bookmark_runs_then_it_inserts_the_name
    __jt_reset
    __jt_mock_commandline

    function jj
        printf 'main\t12345678\ttrunk head\n'
    end

    function fzf
        cat
    end

    jj_fzf_bookmark
    set -l status_code $status

    test $status_code -eq 0
    and contains -- main $__jt_commandline_inserts
    and contains -- repaint $__jt_commandline_actions
end

@test "Given a selected bookmark When jj_fzf_bookmark runs Then it inserts the name" (__test_given_a_selected_bookmark_when_jj_fzf_bookmark_runs_then_it_inserts_the_name) $status -eq 0

function __test_given_a_selected_operation_when_jj_fzf_op_runs_then_it_inserts_the_operation_id
    __jt_reset
    __jt_mock_commandline

    function jj
        printf 'op1234567890\t2026-04-22\tundo marker\n'
    end

    function fzf
        cat
    end

    jj_fzf_op
    set -l status_code $status

    test $status_code -eq 0
    and contains -- op1234567890 $__jt_commandline_inserts
    and contains -- repaint $__jt_commandline_actions
end

@test "Given a selected operation When jj_fzf_op runs Then it inserts the operation id" (__test_given_a_selected_operation_when_jj_fzf_op_runs_then_it_inserts_the_operation_id) $status -eq 0

function __test_given_a_selected_workspace_when_jj_fzf_workspace_runs_then_it_changes_directory
    __jt_reset
    __jt_mock_commandline

    set -l root (mktemp -d)
    mkdir -p $root/feature-x
    set -g __jt_root $root

    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default: qpvuntsm wire auth\n'
                printf 'feature-x: yostqsxw WIP\n'
            case 'workspace root'
                if test "$argv[-1]" = feature-x
                    printf '%s/feature-x\n' $__jt_root
                else
                    printf '%s/default\n' $__jt_root
                end
            case '*'
                return 1
        end
    end

    function fzf
        cat | tail -n 1
    end

    function cd
        set -ga __jt_cd_targets $argv[-1]
    end

    jj_fzf_workspace
    set -l status_code $status

    rm -rf $root
    set -e __jt_root

    test $status_code -eq 0
    and test "$__jt_cd_targets[1]" = "$root/feature-x"
    and contains -- repaint $__jt_commandline_actions
end

@test "Given a selected workspace When jj_fzf_workspace runs Then it changes directory" (__test_given_a_selected_workspace_when_jj_fzf_workspace_runs_then_it_changes_directory) $status -eq 0

function __test_given_a_renamed_file_when_jj_fzf_status_runs_then_it_opens_the_destination_path
    __jt_reset

    function jj
        printf 'R old/path.txt -> new/path.txt\n'
    end

    function fzf
        cat
    end

    function test_editor
        set -ga __jt_editor_calls $argv[-1]
        return 0
    end

    set -g EDITOR test_editor

    jj_fzf_status
    set -l status_code $status

    test $status_code -eq 0
    and test "$__jt_editor_calls[1]" = 'new/path.txt'
end

@test "Given a renamed file When jj_fzf_status runs Then it opens the destination path" (__test_given_a_renamed_file_when_jj_fzf_status_runs_then_it_opens_the_destination_path) $status -eq 0

function __test_given_confirmation_when_jj_squash_into_runs_then_it_executes_the_squash
    __jt_reset

    function jj
        switch "$argv[1] $argv[2]"
            case 'log --no-graph'
                printf 'target123\tship it\n'
            case 'squash --into'
                set -ga __jt_jj_calls (string join ' ' -- $argv)
            case '*'
                return 1
        end
    end

    function fzf
        cat
    end

    function __jt_run_confirmed_squash
        printf 'y\n' | jj_squash_into 2>&1
        return $pipestatus[-1]
    end

    set -l output (__jt_run_confirmed_squash)
    set -l status_code $status

    test $status_code -eq 0
    and contains -- 'squash --into target123' $__jt_jj_calls
    and string match -q 'About to run: jj squash --into target123' -- $output[1]
end

@test "Given confirmation When jj_squash_into runs Then it executes the squash" (__test_given_confirmation_when_jj_squash_into_runs_then_it_executes_the_squash) $status -eq 0

function __test_given_rejection_when_jj_squash_into_runs_then_it_returns_130
    __jt_reset

    function jj
        printf 'target123\tship it\n'
    end

    function fzf
        cat
    end

    function __jt_run_rejected_squash
        printf 'n\n' | jj_squash_into >/dev/null 2>/dev/null
        return $pipestatus[-1]
    end

    __jt_run_rejected_squash
    test $status -eq 130
end

@test "Given rejection When jj_squash_into runs Then it returns 130" (__test_given_rejection_when_jj_squash_into_runs_then_it_returns_130) $status -eq 0
