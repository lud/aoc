defmodule Mix.Tasks.Aoc.Fetch do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Fetch the Advent of Code puzzle input"
  @requirements ["app.config"]

  @command CLI.year_day_command(__MODULE__)

  @moduledoc """
  This task will fetch the puzzle into `priv/inputs`.

  It will not overwrite an existing input file.

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)
    %{year: year, day: day} = CLI.validate_options!(options)

    case AoC.Input.ensure_local(year, day) do
      {:ok, path} -> IO.puts("Input #{year}--#{day}: #{path}")
      err -> IO.puts("Error: #{inspect(err)}")
    end
  end
end
