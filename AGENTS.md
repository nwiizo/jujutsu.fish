# Repository Guidelines

## Project Structure & Module Organization
`conf.d/jujutsu.fish` is the plugin entry point and owns abbreviation registration plus uninstall cleanup. Autoloaded commands live in `functions/*.fish`; keep one public function per file and match the filename to the function name, for example `functions/jj_agent.fish`. Tests live in `tests/*.test.fish` and currently use `fishtape`. CI is defined in `.github/workflows/ci.yml`. `README.md` is the user-facing contract, so update it when behavior or command surface changes. `LESSONS.md` records traps from prior review rounds — consult it before touching `eval`, fzf previews, `conf.d` side-effects, abbr lifecycle, jj templates, terminal-integration escapes, competitor-feature adoption, or jj history hygiene (`jj describe` vs `jj new`, `jj split -- <paths>`).

## Build, Test, and Development Commands
There is no build step; this is a Fish plugin.

```fish
fishtape tests/*.test.fish
```
Runs the test suite.

```fish
for f in (find conf.d functions tests -name '*.fish')
    fish_indent --check $f
end
```
Matches the CI formatting check.

```fish
fish_indent -w conf.d/*.fish functions/*.fish tests/*.fish
```
Formats all Fish sources.

```fish
fisher install $PWD
```
Installs the plugin locally for manual testing.

## Coding Style & Naming Conventions
Follow `fish_indent`; existing files use its default four-space indentation. Prefer small, single-purpose functions and early guards such as `type -q jj; or return`. Private helpers in `conf.d/jujutsu.fish` use the `__jujutsu_fish_*` prefix. Never hardcode the `j` abbreviation prefix; read `$jujutsu_fish_prefix` and preserve custom-prefix behavior.

## Testing Guidelines
Add or update `tests/*.test.fish` for every behavior change. This repo uses `fishtape` with BDD-style names, for example `Given a selected revision When jj_fzf_log runs Then it inserts the change id`. Shared mocks live in `tests/test_helper.fish`. For Fish builtins such as `commandline`, `bind`, or `cd`, prefer function-based mocks; for `read`, pipe input instead of trying to redefine it. New abbreviations should be covered for both the default prefix and a custom prefix. Run `fishtape tests/*.test.fish` before opening a PR.

## Commit & Pull Request Guidelines
Recent history uses scoped, imperative subjects such as `feat: ...`, `fix(review): ...`, and `init: ...`. Keep commits focused and easy to review. PRs should include a short behavior summary, note any README updates, and list the commands you ran. Screenshots are usually unnecessary unless documentation output changes.

## Change-Specific Notes
If you add an abbreviation, update registration, erase logic, README tables, and tests together. If you add a picker, add its function, wire it through `jj_configure_bindings`, document it in `README.md`, and keep cancellation/error behavior consistent with the existing `jj_fzf_*` commands.
