set -l __jujutsu_test_dir (status dirname)

source $__jujutsu_test_dir/../conf.d/jujutsu.fish
for file in $__jujutsu_test_dir/../functions/*.fish
    source $file
end

function __jt_reset
    set -e __jt_jj_calls
    set -e __jt_bind_calls
    set -e __jt_commandline_inserts
    set -e __jt_commandline_actions
    set -e __jt_editor_calls
    set -e __jt_tmux_calls
    set -e __jt_cd_targets
    set -e __jt_read_reply
    set -e __jt_root

    set -e EDITOR
    set -e VISUAL
    set -e TMUX
    set -e jujutsu_agent_root

    for fn in jj fzf commandline bind tmux read cd test_editor test_visual type
        functions -q $fn; and functions -e $fn
    end
end

function __jt_mock_commandline
    function commandline
        switch $argv[1]
            case -i
                set -ga __jt_commandline_inserts $argv[-1]
            case -f
                set -ga __jt_commandline_actions $argv[2]
        end
    end
end
