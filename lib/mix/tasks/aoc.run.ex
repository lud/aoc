defmodule Mix.Tasks.Aoc.Run do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Run the solution for a given year and day"

  def run(argv) do
    CLI.compile()
    CLI.init_env()

    command =
      CLI.part_command(__MODULE__,
        benchmark: [type: :boolean, short: :b, doc: "Benchmark the solution"]
      )

    %{options: options} = CLI.parse_or_halt!(argv, command)
    %{year: year, day: day, part: part} = CLI.validate_options!(options)

    case AoC.Input.ensure_local(year, day) do
      {:ok, _} -> :ok
      {:error, reason} -> CLI.halt_error(inspect(reason))
    end

    CLI.writeln([
      "Solution for ",
      CLI.color(:yellow, to_string(year)),
      " day ",
      CLI.color(:yellow, to_string(day))
    ])

    part = translate_part(part)
    run_print(year, day, part)

    if options.benchmark do
      benchmark(year, day, [part])
    end
  end

  defp translate_part(n) do
    case n do
      1 -> :part_one
      2 -> :part_two
      nil -> nil
    end
  end

  defp run_print(year, day, nil) do
    run_print(year, day, :part_one)
    run_print(year, day, :part_two)
  end

  defp run_print(year, day, part) do
    result = run(year, day, part)
    print_result(result, year, day, part)
  end

  defp run(year, day, part) do
    AoC.run(year, day, part, _timer = true)
  rescue
    e -> {:error, {:run_error, e, __STACKTRACE__}}
  catch
    t, e -> {:error, {:run_error, {t, e}, __STACKTRACE__}}
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

  defp print_result({:error, {:run_error, e, stack}}, year, day, part) do
    CLI.error(
      "#{part}: #{inspect(AoC.Mod.module_name(year, day))}.#{part}/1 error: #{run_error_message(e, stack)}"
    )
  end

  defp run_error_message(%{__exception__: true} = e, stack) do
    Exception.format_banner(:error, e, stack)
  end

  defp run_error_message({kind, e}, stack) when kind in [:error, :throw, :exit] do
    Exception.format_banner(kind, e, stack)
  end

  defp benchmark(year, day, [nil]) do
    benchmark(year, day, [:part_one, :part_two])
  end

  defp benchmark(year, day, parts) do
    parts = Enum.filter(parts, &match?({:ok, _}, run(year, day, &1)))
    benchables = Enum.map(parts, fn part -> {part, fn -> AoC.run(year, day, part, false) end} end)

    case benchables do
      [] ->
        CLI.warn("No part to benchmark")

      _ ->
        Benchee.run(Map.new(benchables),
          warmup: 0,
          time: 5,
          memory_time: 0,
          print: %{
            benchmarking: true,
            configuration: false,
            fast_warning: false
          }
        )
    end
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
