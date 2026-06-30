install:
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
  mix run tools/regen-readme.exs

_libdev_check:
  mix libdev.check

_git_status:
  git status

check: format readme _libdev_check _git_status
