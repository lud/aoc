defmodule Mix.Tasks.Aoc.Url do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Prints problem page URL"

  @command CLI.year_day_command(__MODULE__)

  @moduledoc """
  Outputs the on adventofcode.com URL for a puzzle.

  Useful to use in custom shell commands.

  Note that due to Elixir compilation outputs you may need to grep for the URL.
  For instance:

  ```shell
  xdg-open $(mix aoc.url | grep 'https')
  ```

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)
    %{year: year, day: day} = CLI.validate_options!(options)

    IO.puts("https://adventofcode.com/#{year}/day/#{day}")
  end
end
