function jj_fzf_op --description 'Pick an operation from `jj op log` via fzf and insert its id at the cursor'
    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end
    type -q fzf; or begin
        __jujutsu_fish_err 'fzf is not installed'
        return 127
    end

    set -l template 'id.short(12) ++ "\t" ++ time.start() ++ "\t" ++ description.first_line()'

    set -l selection (
        jj op log --no-graph --color=always -T "$template" 2>/dev/null \
        | fzf --ansi --no-sort \
              --prompt='jj op > ' \
              --delimiter='\t' --with-nth=2,3 \
              --preview='jj op show --color=always {1}' \
              --preview-window='right:60%:wrap' \
    )

    test -z "$selection"; and return 130

    set -l op_id (string split -f1 \t -- $selection)
    commandline -i -- $op_id
    commandline -f repaint
end
