source (status dirname)/test_helper.fish

function __test_given_jj_missing_when_jj_push_pr_runs_then_it_returns_127
    __jt_reset

    function type
        test "$argv[-1]" = jj
        and return 1
        return 0
    end

    set -l output (jj_push_pr 2>&1)

    test $status -eq 127
    and string match -q 'jj_push_pr: jj is not installed' -- $output
end

@test "Given jj is missing When jj_push_pr runs Then it returns 127" (__test_given_jj_missing_when_jj_push_pr_runs_then_it_returns_127) $status -eq 0

function __test_given_gh_missing_when_jj_push_pr_runs_then_it_returns_127
    __jt_reset

    function type
        switch "$argv[-1]"
            case jj
                return 0
            case gh
                return 1
        end
        return 0
    end

    set -l output (jj_push_pr 2>&1)

    test $status -eq 127
    and string match -q 'jj_push_pr: gh CLI is not installed' -- $output
end

@test "Given gh is missing When jj_push_pr runs Then it returns 127" (__test_given_gh_missing_when_jj_push_pr_runs_then_it_returns_127) $status -eq 0

function __test_given_push_output_when_jj_push_pr_runs_then_it_calls_gh_with_bookmark
    __jt_reset
    set -e __jt_gh_calls

    function jj
        # Mimic the exact stderr wording `jj git push --change` emits.
        printf 'Creating bookmark push-qqwkkoprlxuv for revision qqwkkoprlxuv\n'
        printf 'Changes to push to origin:\n'
        printf '  Add bookmark push-qqwkkoprlxuv to a00d11bd6cdd\n'
    end

    function gh
        set -ga __jt_gh_calls (string join ' ' -- $argv)
    end

    set -l output (jj_push_pr)
    set -l status_code $status

    test $status_code -eq 0
    and test "$__jt_gh_calls[-1]" = 'pr create --head push-qqwkkoprlxuv'
    and string match -q '*Creating bookmark push-qqwkkoprlxuv*' -- $output
end

@test "Given push output When jj_push_pr runs Then it calls gh with the bookmark" (__test_given_push_output_when_jj_push_pr_runs_then_it_calls_gh_with_bookmark) $status -eq 0

function __test_given_extra_args_when_jj_push_pr_runs_then_they_flow_through
    __jt_reset
    set -e __jt_gh_calls

    function jj
        printf 'Creating bookmark push-abcdef123456 for revision abcdef123456\n'
    end

    function gh
        set -ga __jt_gh_calls (string join ' ' -- $argv)
    end

    # Redirect the push echo so it does not leak into the fishtape
    # command substitution used by @test below (empty stdout lets the
    # assertion see $status cleanly).
    jj_push_pr -- --draft --title 'wire auth' >/dev/null
    set -l status_code $status

    test $status_code -eq 0
    and string match -q '*--draft --title wire auth*' -- $__jt_gh_calls[-1]
end

@test "Given gh pr create passthrough When jj_push_pr runs Then extra args flow through" (__test_given_extra_args_when_jj_push_pr_runs_then_they_flow_through) $status -eq 0
