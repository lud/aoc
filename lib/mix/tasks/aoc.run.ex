defmodule Mix.Tasks.Aoc.Run do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Runs the solution for a puzzle"
  @requirements ["app.config"]

  @command CLI.part_command(__MODULE__,
             benchmark: [
               type: :boolean,
               default: false,
               short: :b,
               doc:
                 "Runs the solution parts repeatedly for 5 seconds to print statistics about execution time."
             ]
           )

  @moduledoc """
  Runs your solution with the corresponding year/day input from `priv/inputs`.

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.compile()
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)
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

    benchmarkable_parts =
      part
      |> expand_parts()
      |> Stream.map(fn part -> {part, run_part(year, day, part)} end)
      |> Stream.map(fn {part, {usecs, result}} ->
        print_result(result, usecs, year, day, part)
        {part, result}
      end)
      |> Stream.filter(fn {_part, result} -> match?({:ok, _}, result) end)
      |> Enum.map(fn {part, _} -> part end)

    if options.benchmark do
      benchmark(year, day, benchmarkable_parts)
    end
  end

  defp expand_parts(n) do
    case n do
      1 -> [:part_one]
      2 -> [:part_two]
      nil -> [:part_one, :part_two]
    end
  end

  defp run_part(year, day, part) do
    {_usecs, _result} = spawn_run(year, day, part)
  end

  defp spawn_run(year, day, part) do
    task =
      Task.async(fn ->
        {_usecs, _result} = :timer.tc(fn -> run(year, day, part) end)
      end)

    Task.await(task, :infinity)
  end

  defp run(year, day, part) do
    AoC.run(year, day, part)
  rescue
    e -> {:error, {:run_error, e, __STACKTRACE__}}
  catch
    t, e -> {:error, {:run_error, {t, e}, __STACKTRACE__}}
  end

  defp print_result({:ok, result}, usecs, _year, _day, part) do
    Mix.Shell.IO.info([
      "#{part}: ",
      IO.ANSI.cyan(),
      IO.ANSI.bright(),
      inspect(result, charlists: :as_lists, pretty: true),
      IO.ANSI.normal(),
      IO.ANSI.default_color(),
      " in #{format_time(usecs)}"
    ])
  end

  defp print_result({:error, :not_implemented}, _usecs, year, day, part) do
    Mix.Shell.IO.info([
      IO.ANSI.yellow(),
      "#{part}: #{inspect(AoC.Mod.module_name(year, day))}.#{part}/1 is not implemented",
      IO.ANSI.default_color()
    ])
  end

  defp print_result({:error, {:run_error, e, stack}}, _usecs, year, day, part) do
    CLI.error(
      "#{part}: #{inspect(AoC.Mod.module_name(year, day))}.#{part}/1 error: #{run_error_message(e, stack)}"
    )
  end

  defp run_error_message(%{__exception__: true} = e, stack) do
    Exception.format(:error, e, stack)
  end

  defp run_error_message({kind, e}, stack) when kind in [:error, :throw, :exit] do
    Exception.format_banner(kind, e, stack)
  end

  defp benchmark(year, day, parts) do
    benchables = Enum.map(parts, fn part -> {part, fn -> AoC.run(year, day, part) end} end)

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
