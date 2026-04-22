source (status dirname)/test_helper.fish

function __test_given_selected_keys_when_jj_configure_bindings_runs_then_it_binds_only_those_pickers
    __jt_reset

    function bind
        set -ga __jt_bind_calls (string join ' ' -- $argv)
    end

    jj_configure_bindings --log='\cj' --workspace='\cy' --status='' --squash='\cs'
    set -l status_code $status

    test $status_code -eq 0
    and test (count $__jt_bind_calls) -eq 3
    and contains -- '\cj jj_fzf_log' $__jt_bind_calls
    and contains -- '\cy jj_fzf_workspace' $__jt_bind_calls
    and contains -- '\cs jj_squash_into' $__jt_bind_calls
end

@test "Given selected keys When jj_configure_bindings runs Then it binds only those pickers" (__test_given_selected_keys_when_jj_configure_bindings_runs_then_it_binds_only_those_pickers) $status -eq 0
