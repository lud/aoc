defmodule Mix.Tasks.Aoc.Fetch do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Fetch the problem input"

  def run(argv) do
    Application.ensure_all_started(:aoc)

    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    case AoC.Input.ensure_local(year, day) do
      {:ok, path} -> IO.puts("Input #{year}--#{day}: #{path}")
      err -> IO.puts("Error: #{inspect(err)}")
    end
  end
end
