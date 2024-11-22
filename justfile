test:
  mix test

credo:
  mix credo

dialyzer:
  mix dialyzer

format:
  mix format

readme:
  mix run tools/regen-readme.exs

_git_status:
  git status

check: format test credo dialyzer readme _git_status
