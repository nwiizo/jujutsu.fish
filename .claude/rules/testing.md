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
