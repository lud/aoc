defmodule Mix.Tasks.Aoc.Run do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Run the solution for a given year and day"

  def run(argv) do
    Application.ensure_all_started(:aoc)
    %{options: options} = CLI.parse_or_halt!(argv, CLI.part_command(__MODULE__))
    %{year: year, day: day, part: part} = CLI.validate_options!(options)

    case AoC.Input.ensure_local(year, day) do
      {:ok, _} ->
        Mix.Shell.IO.info([
          "Solution for ",
          [IO.ANSI.yellow(), to_string(year), IO.ANSI.default_color()],
          " day ",
          [IO.ANSI.yellow(), to_string(day), IO.ANSI.default_color()]
        ])

        run(year, day, part)

      {:error, reason} ->
        Mix.Shell.IO.error("Error: #{inspect(reason)}")
    end
  end

  defp run(year, day, nil) do
    run(year, day, 1)
    run(year, day, 2)
  end

  defp run(year, day, 1) do
    AoC.run(year, day, :part_one, _timer = true)
    |> print_result(year, day, :part_one)
  end

  defp run(year, day, 2) do
    result = AoC.run(year, day, :part_two, _timer = true)
    result |> print_result(year, day, :part_two)
  end

  defp print_result({:ok, {time, result}}, _year, _day, part) do
    Mix.Shell.IO.info([
      "#{part}: ",
      IO.ANSI.cyan(),
      IO.ANSI.bright(),
      inspect(result, charlists: :as_lists, pretty: true),
      IO.ANSI.normal(),
      IO.ANSI.default_color(),
      " in #{format_time(time)}"
    ])
  end

  defp print_result({:error, :not_implemented}, year, day, part) do
    Mix.Shell.IO.info([
      IO.ANSI.yellow(),
      "#{part}: #{inspect(AoC.Mod.module_name(year, day))}.#{part}/1 is not implemented",
      IO.ANSI.default_color()
    ])
  end

  defp format_time(time) do
    [IO.ANSI.bright(), do_format_time(time), IO.ANSI.normal()]
  end

  defp do_format_time(time) when time > 999_999 do
    "#{Float.round(time / 1_000_000, 2)}s"
  end

  defp do_format_time(time) when time > 999 do
    "#{Float.round(time / 1000, 2)}ms"
  end

  defp do_format_time(time) do
    "#{time}µs"
  end
end
