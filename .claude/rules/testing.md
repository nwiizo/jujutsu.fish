---
paths: ["tests/**/*.fish"]
description: fishtape + BDD-style conventions, mocking fish builtins and external commands
---

# Testing Rules

## Framework

- Use `fishtape`. Fish does not have a mainstream native BDD framework comparable to RSpec, so express BDD intent through descriptive test names: `Given ... When ... Then ...`.
- Shared setup and mocks live in `tests/test_helper.fish`. Source it from every new test file.

## Mocking

- Mock fish builtins and external commands with plain fish functions: `commandline`, `bind`, `cd`, `jj`, `fzf`, `tmux`. Mock `type` too when the test covers a missing-command branch.
- Do **not** redefine `read` to test confirmation prompts — feed stdin instead (e.g. `printf 'y\n' | jj_squash_into`). That path is far more reliable in fish.

## Assertions

- Assert observable behavior only: text inserted into the commandline, path passed to `cd`, error text on stderr, exit status.
- Do not assert on internal helper calls or private variables.

## Tests live where fish can find them

- Source the unit under test directly at the top of each test file (e.g. `source (status dirname)/../conf.d/jujutsu.fish`). Do not rely on autoloading — fishtape runs in a non-interactive subshell and the `status is-interactive` guard in `conf.d/` will otherwise skip registration.

## fishtape gotchas (learned the hard way)

- `@test "..." (__test_fn) $status -eq 0` — fishtape reads the **stdout** of the test function as the "actual" expression. If the function prints anything, the comparison breaks. Redirect noisy calls (`cmd >/dev/null`) or capture into a local (`set -l out (cmd)`) before assertions.
- Test-global state accumulates across `@test` blocks. Mocks using `set -ga __jt_<name>_calls ...` keep appending; a later test sees earlier invocations at `[1]`. Either reset explicitly (`set -e __jt_<name>_calls` at the top of the test) or assert against `[-1]` (latest call) rather than `[1]`.
- `__jt_reset` does **not** know about every mock list — if you invent a new accumulator (e.g. `__jt_gh_calls`), clear it yourself.
