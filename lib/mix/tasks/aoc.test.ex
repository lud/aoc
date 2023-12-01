defmodule Mix.Tasks.Aoc.Test do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Runs the tests for a given year and day"

  def run(argv) do
    Application.ensure_all_started(:aoc)
    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    Mix.Task.run("test", ["test/#{year}/day#{day}_test.exs"])
  end
end
