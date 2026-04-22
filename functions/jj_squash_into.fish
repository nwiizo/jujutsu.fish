function jj_squash_into --description 'Pick a target revision via fzf and squash @ into it'
    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end
    type -q fzf; or begin
        __jujutsu_fish_err 'fzf is not installed'
        return 127
    end

    # Default revset: parents of @ and their ancestors up to (but not
    # including) @ itself. We deliberately avoid `trunk()` in the default
    # because many repos do not define it and it resolves to the root
    # commit (immutable) when unset. Callers can pass any revset
    # explicitly, e.g. `jj_squash_into 'trunk()::@-'`.
    set -l revset $argv
    test -z "$revset"; and set revset '@-'

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

    # Highlight the command we are about to run so the user can spot a
    # misclick before confirming. Colors are gated on isatty so piped
    # invocations stay parseable.
    set -l hi (set_color yellow --bold)
    set -l em (set_color cyan)
    set -l rs (set_color normal)
    isatty stdout; or begin
        set hi ''
        set em ''
        set rs ''
    end
    printf '%sAbout to run:%s %sjj squash --into %s%s\n' $hi $rs $em $target $rs
    read -l -P 'Proceed? [y/N] ' answer
    switch $answer
        case y Y yes Yes
            jj squash --into $target
        case '*'
            return 130
    end
end
