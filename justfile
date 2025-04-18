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

_git_status:
  git status

check: install format test credo dialyzer readme _git_status
