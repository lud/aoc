defmodule Mix.Tasks.Aoc.Test do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Runs the tests for a given year and day"

  def run(argv) do
    CLI.init_env()
    CLI.compile()

    command_spec =
      CLI.year_day_command(__MODULE__,
        trace: [type: :boolean, doc: "forward option to `mix test`"],
        stale: [type: :boolean, doc: "forward option to `mix test`"],
        max_failures: [type: :integer, doc: "forward option to `mix test`"]
      )

    %{options: options} = CLI.parse_or_halt!(argv, command_spec)
    %{year: year, day: day} = CLI.validate_options!(options)

    Mix.Task.run("test", ["test/#{year}/day#{day}_test.exs" | mix_test_flags(options)])
  end

  defp mix_test_flags(options) do
    Enum.flat_map(options, fn
      {:trace, true} -> ["--trace"]
      {:max_failures, n} -> ["--max-failures", Integer.to_string(n)]
      {:stale, true} -> ["--stale"]
      _ -> []
    end)
  end
end
