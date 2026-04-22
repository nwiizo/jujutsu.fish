function jj_fzf_bookmark --description 'Pick a bookmark via fzf and insert its name at the cursor'
    type -q jj; or begin
        echo "jj_fzf_bookmark: jj is not installed" >&2
        return 127
    end
    type -q fzf; or begin
        echo "jj_fzf_bookmark: fzf is not installed" >&2
        return 127
    end

    # `jj bookmark list -T` lets us format each bookmark on a single line
    # regardless of how many remotes it tracks. Keep the template minimal:
    # <name>\t<target commit short id>\t<description first line>
    set -l template '
        name ++ "\t" ++
        normal_target.commit_id().shortest(8) ++ "\t" ++
        normal_target.description().first_line() ++ "\n"
    '

    set -l selection (
        jj bookmark list --all-remotes --color=always -T "$template" 2>/dev/null \
        | fzf --ansi --no-sort \
              --prompt='jj bookmark > ' \
              --delimiter='\t' --with-nth=1,3 \
              --preview='jj log --color=always --ignore-working-copy -r {1}' \
              --preview-window='right:60%:wrap' \
    )

    test -z "$selection"; and return 130

    set -l bookmark (string split -f1 \t -- $selection)
    commandline -i -- $bookmark
    commandline -f repaint
end
