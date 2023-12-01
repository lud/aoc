defmodule Mix.Tasks.Aoc.Open do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Open the problem page"

  def run(argv) do
    Application.ensure_all_started(:aoc)

    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    System.cmd("xdg-open", ["https://adventofcode.com/#{year}/day/#{day}"])
  end
end
