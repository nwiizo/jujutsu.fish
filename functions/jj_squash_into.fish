function jj_squash_into --description 'Pick a target revision via fzf and squash @ into it'
    type -q jj; or begin
        echo "jj_squash_into: jj is not installed" >&2
        return 127
    end
    type -q fzf; or begin
        echo "jj_squash_into: fzf is not installed" >&2
        return 127
    end

    set -l revset $argv
    test -z "$revset"; and set revset '@- | trunk()::@-'

    set -l template 'change_id.shortest(8) ++ "\t" ++ description.first_line()'
    set -l selection (
        jj log --no-graph --color=always --ignore-working-copy \
            -r "$revset" -T "$template" 2>/dev/null \
        | fzf --ansi --no-sort --tac \
              --prompt='squash into > ' \
              --delimiter='\t' --with-nth=2 \
              --preview='jj show --color=always --ignore-working-copy {1}' \
              --preview-window='right:60%:wrap'
    )
    test -z "$selection"; and return 130

    set -l target (string split -f1 \t -- $selection)

    # Show the effective command before running so the user can bail out.
    # jj squash --into <rev> moves the diff from @ into the chosen
    # revision, leaving @ empty (safe default for accepting agent work).
    echo "jj squash --into $target"
    read -l -P 'Proceed? [y/N] ' answer
    switch $answer
        case y Y yes Yes
            jj squash --into $target
        case '*'
            return 130
    end
end
