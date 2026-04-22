# jujutsu.fish — abbreviations
#
# Loaded on shell startup. All abbreviations are guarded so that:
#   - non-interactive shells do not pay the cost,
#   - shells without `jj` installed do not create dead abbreviations.
#
# Users who want their own prefix can set $jujutsu_fish_prefix before this
# file is sourced (via ~/.config/fish/conf.d/ override or a preceding conf.d
# file). Default is `j`.

status is-interactive; or exit 0
type -q jj; or exit 0

set -q jujutsu_fish_prefix; or set -g jujutsu_fish_prefix j

function __jujutsu_fish_abbr --argument-names short expansion
    # Prepend the configured prefix to the short form and register the abbr.
    abbr -a $jujutsu_fish_prefix$short $expansion
end

# ─── Core ────────────────────────────────────────────────────────────────
__jujutsu_fish_abbr '' jj
__jujutsu_fish_abbr st 'jj status'
__jujutsu_fish_abbr sh 'jj show'
__jujutsu_fish_abbr d 'jj diff'
__jujutsu_fish_abbr ds 'jj describe'
__jujutsu_fish_abbr n 'jj new'
__jujutsu_fish_abbr ed 'jj edit'

# ─── Log ─────────────────────────────────────────────────────────────────
__jujutsu_fish_abbr l 'jj log'
__jujutsu_fish_abbr la 'jj log -r "all()"'
__jujutsu_fish_abbr lo 'jj log --no-graph'

# ─── Change editing ──────────────────────────────────────────────────────
__jujutsu_fish_abbr sq 'jj squash'
__jujutsu_fish_abbr sp 'jj split'
__jujutsu_fish_abbr ab 'jj absorb'
__jujutsu_fish_abbr rb 'jj rebase'
__jujutsu_fish_abbr dp 'jj duplicate'
__jujutsu_fish_abbr bk 'jj backout'
__jujutsu_fish_abbr an 'jj abandon'

# ─── Bookmarks ───────────────────────────────────────────────────────────
__jujutsu_fish_abbr b 'jj bookmark'
__jujutsu_fish_abbr bl 'jj bookmark list'
__jujutsu_fish_abbr bs 'jj bookmark set'
__jujutsu_fish_abbr bm 'jj bookmark move'
__jujutsu_fish_abbr bd 'jj bookmark delete'
__jujutsu_fish_abbr bt 'jj bookmark track'

# ─── Operation log ───────────────────────────────────────────────────────
__jujutsu_fish_abbr op 'jj op log'
__jujutsu_fish_abbr ou 'jj op undo'
__jujutsu_fish_abbr or 'jj op restore'

# ─── Git bridge ──────────────────────────────────────────────────────────
__jujutsu_fish_abbr gf 'jj git fetch'
__jujutsu_fish_abbr gp 'jj git push'
__jujutsu_fish_abbr gpa 'jj git push --allow-new'
__jujutsu_fish_abbr gc 'jj git clone'

# ─── Workspace ───────────────────────────────────────────────────────────
__jujutsu_fish_abbr w 'jj workspace'
__jujutsu_fish_abbr wl 'jj workspace list'
__jujutsu_fish_abbr wa 'jj workspace add'
__jujutsu_fish_abbr wf 'jj workspace forget'

functions -e __jujutsu_fish_abbr
