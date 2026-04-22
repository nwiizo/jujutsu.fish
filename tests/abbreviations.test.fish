# fishtape test: verifies that __jujutsu_fish_register_abbrs registers the
# expected abbreviations. We call the registration function directly so
# the conf.d interactive guard does not interfere (fishtape runs in a
# non-interactive subshell).

source (status dirname)/../conf.d/jujutsu.fish
__jujutsu_fish_register_abbrs

@test "j is registered" (abbr --query j) $status -eq 0
@test "jst expansion" (abbr --show | string match -rq '^abbr -a -- jst \'jj status\'$') $status -eq 0
@test "jw expansion" (abbr --show | string match -rq '^abbr -a -- jw \'jj workspace\'$') $status -eq 0
@test "jgp expansion" (abbr --show | string match -rq '^abbr -a -- jgp \'jj git push\'$') $status -eq 0
@test "jgpa expansion" (abbr --show | string match -rq "^abbr -a -- jgpa 'jj git push --allow-new'\$") $status -eq 0
@test "jnx expansion" (abbr --show | string match -rq "^abbr -a -- jnx 'jj next'\$") $status -eq 0
@test "jpv expansion" (abbr --show | string match -rq "^abbr -a -- jpv 'jj prev'\$") $status -eq 0
@test "jgpc expansion" (abbr --show | string match -rq "^abbr -a -- jgpc 'jj git push --change @'\$") $status -eq 0
@test "jgra expansion" (abbr --show | string match -rq "^abbr -a -- jgra 'jj git remote add'\$") $status -eq 0
@test "jgrl expansion" (abbr --show | string match -rq "^abbr -a -- jgrl 'jj git remote list'\$") $status -eq 0

__jujutsu_fish_erase_abbrs
set -g jujutsu_fish_prefix vc
__jujutsu_fish_register_abbrs
@test "custom prefix registers" (abbr --query vcst) $status -eq 0
@test "default prefix erased" (abbr --query jst) $status -eq 1

__jujutsu_fish_erase_abbrs
set -e jujutsu_fish_prefix
