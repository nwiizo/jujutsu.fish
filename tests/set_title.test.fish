source (status dirname)/test_helper.fish

function __test_given_non_tty_when_set_title_runs_then_it_emits_nothing
    __jt_reset

    # fishtape captures output via command substitution, so stdout is not
    # a tty. The helper must no-op rather than leak escape sequences into
    # captured output.
    set -l out (__jujutsu_fish_set_title 'jj:demo')
    set -l status_code $status

    test $status_code -eq 0
    and test -z "$out"
end

@test "Given non-tty stdout When __jujutsu_fish_set_title runs Then it emits nothing" (__test_given_non_tty_when_set_title_runs_then_it_emits_nothing) $status -eq 0
