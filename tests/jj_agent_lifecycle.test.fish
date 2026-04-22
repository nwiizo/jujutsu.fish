source (status dirname)/test_helper.fish

# ─── jj_agent_done ──────────────────────────────────────────────────────

function __test_given_unknown_workspace_when_done_runs_then_it_errors
    __jt_reset
    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default\n'
            case '*'
                return 0
        end
    end
    set -l output (jj_agent_done ghost 2>&1)
    test $status -eq 1
    and string match -q '*unknown workspace: ghost*' -- $output
end
@test "Given unknown workspace When jj_agent_done runs Then it errors" (__test_given_unknown_workspace_when_done_runs_then_it_errors) $status -eq 0

function __test_given_flags_when_done_runs_then_it_chains_push_pr_and_forget
    __jt_reset
    set -e __jt_gh_calls

    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default\n'
                printf 'feature-x\n'
            case 'log --no-graph'
                printf 'ab12cd34 | WIP agent\n'
            case 'diff --stat'
                return 0
            case 'git push'
                # Minimal emission so jj_push_pr can extract a bookmark.
                # Real jj change-ids are lowercase alpha (no hyphens);
                # match the regex jj_push_pr uses.
                printf 'Creating bookmark push-qqwkkoprlxuv for revision feature-x@\n'
            case 'workspace forget'
                set -ga __jt_jj_calls (string join ' ' -- $argv)
            case '*'
                return 0
        end
    end
    function gh
        set -ga __jt_gh_calls (string join ' ' -- $argv)
    end

    jj_agent_done feature-x --push-pr --forget >/dev/null 2>&1
    set -l rc $status

    test $rc -eq 0
    and string match -q 'pr create --head push-qqwkkoprlxuv' -- $__jt_gh_calls[-1]
    and contains -- 'workspace forget feature-x' $__jt_jj_calls
end
@test "Given flags When jj_agent_done runs Then it chains push-pr and forget" (__test_given_flags_when_done_runs_then_it_chains_push_pr_and_forget) $status -eq 0

# ─── jj_agent_prune ─────────────────────────────────────────────────────

function __test_given_no_empty_workspaces_when_prune_runs_then_it_exits_clean
    __jt_reset
    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default\tnonempty\n'
                printf 'busy-agent\tnonempty\n'
            case '*'
                return 0
        end
    end

    set -l output (jj_agent_prune --dry-run)
    set -l rc $status

    test $rc -eq 0
    and string match -q '*nothing to prune*' -- $output
end
@test "Given no empty workspaces When jj_agent_prune runs Then it exits clean" (__test_given_no_empty_workspaces_when_prune_runs_then_it_exits_clean) $status -eq 0

function __test_given_empty_workspaces_when_prune_dry_run_then_it_lists_them
    __jt_reset
    function jj
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default\tempty\n'
                printf 'abandoned-1\tempty\n'
                printf 'busy-agent\tnonempty\n'
                printf 'abandoned-2\tempty\n'
            case '*'
                return 0
        end
    end

    set -l output (jj_agent_prune --dry-run)
    set -l rc $status

    # The default workspace must never appear even if it is empty.
    test $rc -eq 0
    and string match -q '*would forget: abandoned-1*' -- $output
    and string match -q '*would forget: abandoned-2*' -- $output
    and not string match -q '*would forget: default*' -- $output
    and not string match -q '*would forget: busy-agent*' -- $output
end
@test "Given empty workspaces When jj_agent_prune --dry-run runs Then it lists them" (__test_given_empty_workspaces_when_prune_dry_run_then_it_lists_them) $status -eq 0

# ─── jj_agent_diff ──────────────────────────────────────────────────────

function __test_given_two_workspaces_when_diff_runs_then_it_calls_jj_diff_from_to
    __jt_reset
    function jj
        set -ga __jt_jj_calls (string join ' ' -- $argv)
        switch "$argv[1] $argv[2]"
            case 'workspace list'
                printf 'default\n'
                printf 'agent-a\n'
                printf 'agent-b\n'
            case '*'
                return 0
        end
    end

    jj_agent_diff agent-a agent-b >/dev/null 2>&1
    set -l rc $status

    test $rc -eq 0
    and string match -q '*diff*--from*agent-a@*--to*agent-b@*' -- (string join ' ' -- $__jt_jj_calls)
end
@test "Given two workspaces When jj_agent_diff runs Then it calls jj diff --from --to" (__test_given_two_workspaces_when_diff_runs_then_it_calls_jj_diff_from_to) $status -eq 0

function __test_given_missing_second_arg_when_diff_runs_then_it_errors
    __jt_reset
    function jj
        return 0
    end

    set -l output (jj_agent_diff only-one 2>&1)

    test $status -eq 2
    and string match -q '*usage: jj_agent_diff*' -- $output
end
@test "Given missing second arg When jj_agent_diff runs Then it errors" (__test_given_missing_second_arg_when_diff_runs_then_it_errors) $status -eq 0
