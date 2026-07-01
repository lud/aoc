_mix_deps:
  mix deps.get

test:
  mix test

credo:
  mix credo

dialyzer:
  mix dialyzer

format:
  mix format --migrate

readme:
  mix rdmx.update README.md

_libdev_check:
  mix libdev.check

_git_status:
  git status

check: _mix_deps format readme _libdev_check _git_status
