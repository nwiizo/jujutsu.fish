# jujutsu.fish — plugin entry point
#
# Abbreviations are registered via `__jujutsu_fish_register_abbrs`, which
# is deliberately defined as a regular function so tests can call it
# without going through the interactive guard below.
#
# Users who want a different prefix can set $jujutsu_fish_prefix in a
# conf.d file that loads before this one. Default is `j`.

function __jujutsu_fish_register_abbrs --description 'Register jujutsu.fish abbreviations'
    set -q jujutsu_fish_prefix; or set -g jujutsu_fish_prefix j
    set -l p $jujutsu_fish_prefix

    # Core
    abbr -a $p jj
    abbr -a {$p}st 'jj status'
    abbr -a {$p}sh 'jj show'
    abbr -a {$p}d 'jj diff'
    abbr -a {$p}ds 'jj describe'
    abbr -a {$p}n 'jj new'
    abbr -a {$p}ed 'jj edit'
    abbr -a {$p}nx 'jj next'
    abbr -a {$p}pv 'jj prev'

    # Log
    abbr -a {$p}l 'jj log'
    abbr -a {$p}la 'jj log -r "all()"'
    abbr -a {$p}lo 'jj log --no-graph'

    # Change editing
    abbr -a {$p}sq 'jj squash'
    abbr -a {$p}sp 'jj split'
    abbr -a {$p}ab 'jj absorb'
    abbr -a {$p}rb 'jj rebase'
    abbr -a {$p}dp 'jj duplicate'
    abbr -a {$p}bk 'jj backout'
    abbr -a {$p}an 'jj abandon'

    # Bookmarks
    abbr -a {$p}b 'jj bookmark'
    abbr -a {$p}bl 'jj bookmark list'
    abbr -a {$p}bs 'jj bookmark set'
    abbr -a {$p}bm 'jj bookmark move'
    abbr -a {$p}bd 'jj bookmark delete'
    abbr -a {$p}bt 'jj bookmark track'

    # Operation log
    abbr -a {$p}op 'jj op log'
    abbr -a {$p}ou 'jj op undo'
    abbr -a {$p}or 'jj op restore'

    # Git bridge
    abbr -a {$p}gf 'jj git fetch'
    abbr -a {$p}gp 'jj git push'
    abbr -a {$p}gpa 'jj git push --allow-new'
    abbr -a {$p}gpc 'jj git push --change @'
    abbr -a {$p}gc 'jj git clone'
    abbr -a {$p}gr 'jj git remote'
    abbr -a {$p}gra 'jj git remote add'
    abbr -a {$p}grl 'jj git remote list'

    # Workspace
    abbr -a {$p}w 'jj workspace'
    abbr -a {$p}wl 'jj workspace list'
    abbr -a {$p}wa 'jj workspace add'
    abbr -a {$p}wf 'jj workspace forget'
end

function __jujutsu_fish_erase_abbrs --description 'Erase jujutsu.fish abbreviations'
    set -q jujutsu_fish_prefix; or set -g jujutsu_fish_prefix j
    set -l p $jujutsu_fish_prefix
    for short in '' st sh d ds n ed nx pv l la lo sq sp ab rb dp bk an \
        b bl bs bm bd bt op ou or gf gp gpa gpc gc gr gra grl w wl wa wf
        abbr -e {$p}$short 2>/dev/null
    end
end

# Fisher uninstall hook — remove abbreviations from this shell. Abbrs are
# persisted in universal variables, so without this users would keep
# seeing them expand after `fisher remove nwiizo/jujutsu.fish`.
function _jujutsu_fish_uninstall --on-event jujutsu_fish_uninstall
    __jujutsu_fish_erase_abbrs
    functions -e __jujutsu_fish_register_abbrs __jujutsu_fish_erase_abbrs
end

# Register abbrs only in interactive shells that actually have `jj`.
status is-interactive; or return
type -q jj; or return
__jujutsu_fish_register_abbrs
