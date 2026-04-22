# fishtape test: verifies that conf.d/jujutsu.fish registers the expected
# abbreviations when jj is available.

# Stub jj so the guard in conf.d does not short-circuit on CI runners that
# lack a real jj binary. fishtape runs each test file in a subshell, so
# shadowing the command here is safe.
function jj
end

source (status dirname)/../conf.d/jujutsu.fish

@test "j expands to jj" (abbr --show | string match -rq '^abbr -a -- j jj$'; echo $status) -eq 0
@test "jst expands to status" (abbr --show | string match -rq '^abbr -a -- jst \'jj status\'$'; echo $status) -eq 0
@test "jw expands to workspace" (abbr --show | string match -rq '^abbr -a -- jw \'jj workspace\'$'; echo $status) -eq 0
@test "jgp expands to git push" (abbr --show | string match -rq '^abbr -a -- jgp \'jj git push\'$'; echo $status) -eq 0
