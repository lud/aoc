defmodule Mix.Tasks.Aoc.Test do
  alias AoC.CLI
  alias AoC.CodeGen
  use Mix.Task

  @shortdoc "Runs the tests for a given year and day"

  @command CLI.year_day_command(__MODULE__,
             trace: [type: :boolean, doc: "forward option to `mix test`"],
             stale: [type: :boolean, doc: "forward option to `mix test`"],
             failed: [type: :boolean, doc: "forward option to `mix test`"],
             seed: [type: :integer, doc: "forward option to `mix test`"],
             max_failures: [type: :integer, doc: "forward option to `mix test`"]
           )

  @moduledoc """
  Runs your test file for the Advent of Code puzzle.

  Note that test files generated by the `mix aoc.create` command are regular
  ExUnit tests.

  You can always run `mix test` or a test specified by a file and an optional
  line number like this:

  ```shell
  mix test test/2023/day01_test.exs:123
  ```

  In order to use this command, you should define it as a test environment
  command in your `mix.exs` file by defining a `cli/0` function:

  ```elixir
  def cli do
    [
      preferred_envs: ["aoc.test": :test]
    ]
  end
  ```

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.init_env()
    CLI.compile()

    %{options: options} = CLI.parse_or_halt!(argv, @command)
    %{year: year, day: day} = CLI.validate_options!(options)

    test_file_path = "test/#{year}/day#{CodeGen.pad_day(day)}_test.exs"
    legacy_test_file_path = "test/#{year}/day#{day}_test.exs"

    cond do
      File.regular?(test_file_path) ->
        run_test(test_file_path, options)

      File.regular?(legacy_test_file_path) ->
        run_test(legacy_test_file_path, options)

      true ->
        CLI.halt_error("Could not find test file for year #{year} day #{day}")
    end
  end

  defp run_test(path, options) do
    Mix.Task.run("test", [path | mix_test_flags(options)])
  end

  defp mix_test_flags(options) do
    Enum.flat_map(options, fn
      {:trace, true} -> ["--trace"]
      {:max_failures, n} -> ["--max-failures", Integer.to_string(n)]
      {:stale, true} -> ["--stale"]
      {:seed, n} -> ["--seed", Integer.to_string(n)]
      {:failed, true} -> ["--failed"]
      _ -> []
    end)
  end
end
