defmodule Mix.Tasks.Aoc.Set do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Sets or reset default year and day options for other commands"

  def run(argv) do
    CLI.init_env()

    command = [
      module: __MODULE__,
      doc: "Sets the default year / day when not provided on other commands",
      options: [
        year: [type: :integer, short: :y, doc: "Year to force"],
        day: [type: :integer, short: :d, doc: "Day to force"]
      ]
    ]

    %{options: options} = CLI.parse_or_halt!(argv, command)

    CLI.write_defaults(options)
  end
end
