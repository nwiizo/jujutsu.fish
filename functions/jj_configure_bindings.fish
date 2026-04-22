function jj_configure_bindings --description 'Configure key bindings for jujutsu.fish pickers'
    # Inspired by fzf.fish's opt-in binding model. Call from
    # `fish_user_key_bindings` with any subset of the flags:
    #
    #   jj_configure_bindings \
    #       --log=\cj \        # Ctrl-J
    #       --bookmark=\ck \   # Ctrl-K
    #       --op= \            # '' disables
    #       --workspace=\cy
    #
    # Defaults (all off). Passing an empty value explicitly disables a
    # binding, matching fzf.fish's convention.

    argparse 'log=?' 'bookmark=?' 'op=?' 'workspace=?' -- $argv
    or return 2

    set -q _flag_log; and test -n "$_flag_log"; and bind $_flag_log jj_fzf_log
    set -q _flag_bookmark; and test -n "$_flag_bookmark"; and bind $_flag_bookmark jj_fzf_bookmark
    set -q _flag_op; and test -n "$_flag_op"; and bind $_flag_op jj_fzf_op
    set -q _flag_workspace; and test -n "$_flag_workspace"; and bind $_flag_workspace jj_fzf_workspace
end
