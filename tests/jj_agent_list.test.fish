source (status dirname)/test_helper.fish

function __test_given_jj_is_missing_when_jj_agent_list_runs_then_it_returns_127
    __jt_reset

    function type
        test "$argv[-1]" = jj
        and return 1
        return 0
    end

    set -l output (jj_agent_list 2>&1)

    test $status -eq 127
    and string match -q 'jj_agent_list: jj is not installed' -- $output
end

@test "Given jj is missing When jj_agent_list runs Then it returns 127" (__test_given_jj_is_missing_when_jj_agent_list_runs_then_it_returns_127) $status -eq 0

function __test_given_no_workspaces_when_jj_agent_list_runs_then_it_reports_the_empty_state
    __jt_reset

    function jj
        return 0
    end

    set -l output (jj_agent_list 2>&1)

    test $status -eq 1
    and string match -q 'jj_agent_list: no workspaces found' -- $output
end

@test "Given no workspaces When jj_agent_list runs Then it reports the empty state" (__test_given_no_workspaces_when_jj_agent_list_runs_then_it_reports_the_empty_state) $status -eq 0

function __test_given_workspace_rows_when_jj_agent_list_runs_then_it_prints_the_table
    __jt_reset

    function jj
        printf 'default\tqqwkkopr\tclean\twire auth\n'
        printf 'feature-x\txpmzzqor\tdirty\tWIP: agent pass\n'
    end

    set -l output (jj_agent_list)
    set -l status_code $status

    test $status_code -eq 0
    and string match -rq '^NAME\s+CHANGE\s+STATE\s+DESCRIPTION$' -- $output[1]
    and string match -rq '^default\s+qqwkkopr\s+clean\s+wire auth$' -- $output[2]
    and string match -rq '^feature-x\s+xpmzzqor\s+dirty\s+WIP: agent pass$' -- $output[3]
end

@test "Given workspace rows When jj_agent_list runs Then it prints the table" (__test_given_workspace_rows_when_jj_agent_list_runs_then_it_prints_the_table) $status -eq 0
