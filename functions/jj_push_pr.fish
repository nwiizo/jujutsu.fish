function jj_push_pr --description 'jj git push --change <rev> and open a GitHub PR from the created bookmark'
    # Usage:
    #   jj_push_pr [-r <rev>] [-- <gh pr create args>...]
    #
    # Pushes <rev> (default @) to the git remote using `jj git push -c`,
    # which creates a fresh `push-<change-id>` bookmark, then hands it off
    # to `gh pr create --head <bookmark>`. Any arguments after `--` are
    # forwarded to `gh pr create` verbatim (`--draft`, `--title`, etc).

    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end
    type -q gh; or begin
        __jujutsu_fish_err 'gh CLI is not installed'
        return 127
    end

    argparse 'r/revset=' h/help -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: jj_push_pr [-r <rev>] [-- <gh pr create args>...]'
        return 0
    end

    set -l rev (set -q _flag_revset; and echo $_flag_revset; or echo '@')

    # `jj git push -c` prints "Creating bookmark push-<id> for revision ..."
    # on stderr. Merge into stdout so we can scan it with `string match`.
    set -l push_output (jj git push --change $rev 2>&1)
    set -l push_status $status
    printf '%s\n' $push_output
    test $push_status -eq 0; or return $push_status

    # Extract the bookmark name. jj emits `push-<12+ chars>` where the
    # suffix is the change-id prefix. If the bookmark already existed,
    # jj emits `Move forward bookmark push-<id> ...` instead; cover both.
    set -l bookmark (string match -rg '(push-[a-z0-9]+)' -- $push_output | head -n1)
    if test -z "$bookmark"
        __jujutsu_fish_err 'could not determine bookmark name from push output'
        return 1
    end

    gh pr create --head $bookmark $argv
end
