defmodule Mix.Tasks.Aoc.Url do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Prints problem page URL"

  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    IO.puts("https://adventofcode.com/#{year}/day/#{day}")
  end
end
