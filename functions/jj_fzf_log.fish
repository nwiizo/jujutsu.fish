function jj_fzf_log --description 'Pick a revision from `jj log` via fzf and insert its change-id at the cursor'
    type -q jj; or begin
        echo "jj_fzf_log: jj is not installed" >&2
        return 127
    end
    type -q fzf; or begin
        echo "jj_fzf_log: fzf is not installed" >&2
        return 127
    end

    set -l revset $argv
    test -z "$revset"; and set revset '::@ | @::'

    # Template: change_id short | commit_id short | description first line
    set -l template 'change_id.shortest(8) ++ "\t" ++ commit_id.shortest(8) ++ "\t" ++ description.first_line()'

    set -l selection (
        jj log --no-graph --color=always --ignore-working-copy \
            -r "$revset" -T "$template" 2>/dev/null \
        | fzf --ansi --no-sort --tac \
              --prompt='jj log > ' \
              --delimiter='\t' --with-nth=1,3 \
              --preview='jj show --color=always --ignore-working-copy {1}' \
              --preview-window='right:60%:wrap' \
    )

    test -z "$selection"; and return 130

    set -l change_id (string split -f1 \t -- $selection)
    commandline -i -- $change_id
    commandline -f repaint
end
