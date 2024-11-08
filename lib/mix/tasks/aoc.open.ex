defmodule Mix.Tasks.Aoc.Open do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Opens the problem puzzle on adventofcode.com"
  @command CLI.year_day_command(__MODULE__)

  @moduledoc """
  Opens the puzzle page with your defined browser on on adventofcode.com.

  The command to call with the URL will be defined in the following order:

  * Using the `AOC_BROWSER` environment variable.
  * Using the `BROWSER` environment variable.
  * Fallback to `xdg-open`.

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)
    %{year: year, day: day} = CLI.validate_options!(options)

    {:ok, open_com} = browser()
    url = "https://adventofcode.com/#{year}/day/#{day}"
    os_command = String.to_charlist(open_com <> " '#{url}'")

    # credo:disable-for-next-line
    :os.cmd(os_command)
  end

  def browser do
    with :error <- System.fetch_env("AOC_BROWSER"),
         :error <- System.fetch_env("BROWSER") do
      {:ok, "xdg-open"}
    end
  end
end
