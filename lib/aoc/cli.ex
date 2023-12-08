defmodule AoC.CLI do
  alias AoC.CLI
  use CliMate

  def init_env do
    Application.ensure_all_started(:aoc)
    Mix.Task.run("loadpaths")
  end

  def compile do
    Mix.Task.run("compile")
  end

  def year_day_command(module, opts \\ []) do
    [
      module: module,
      options:
        Keyword.merge(
          [
            year: [type: :integer, short: :y, doc: "Year of the puzzle", default: default_year()],
            day: [type: :integer, short: :d, doc: "Day of the puzzle"] ++ default_day_optlist()
          ],
          opts
        )
    ]
  end

  def part_command(module, opts \\ []) do
    year_day_command(
      module,
      [part: [type: :integer, short: :p, doc: "Part of the puzzle", default: nil]] ++ opts
    )
  end

  defguard is_valid_year(year) when is_integer(year) and year >= 2015
  defguard is_valid_day(day) when is_integer(day) and day in 1..25

  defguard is_valid_day(year, day)
           when is_integer(year) and year >= 2015 and is_integer(day) and day in 1..25

  defguard is_valid_part(part) when is_integer(part) and part in [1, 2]

  def validate_options!(options) do
    case Map.fetch(options, :year) do
      {:ok, year} when not is_valid_year(year) ->
        raise "Invalid year: #{year}"

      {:ok, year} ->
        if year != today_year() and year == default_year() do
          CLI.warn("Using default year #{year}")
        end

        :ok
    end

    case Map.fetch(options, :day) do
      {:ok, day} when not is_valid_day(day) ->
        raise "Invalid day: #{day}"

      :error ->
        raise "Missing day option"

      {:ok, day} ->
        if day != today_day() and day == default_day() do
          CLI.warn("Using default day #{day}")
        end
    end

    case Map.fetch(options, :part) do
      {:ok, nil} -> :ok
      {:ok, part} when not is_valid_part(part) -> raise "Invalid part: #{part}"
      _ -> :ok
    end

    options
  rescue
    e -> CLI.halt_error(e.message)
  end

  defp default_year do
    case read_defaults() do
      %{year: year} when is_valid_year(year) -> year
      _ -> today_year()
    end
  end

  defp today_year do
    Date.utc_today().year
  end

  defp default_day_optlist do
    case default_day() do
      day when is_valid_day(day) -> [default: day]
      _ -> []
    end
  end

  defp default_day do
    case read_defaults() do
      %{day: day} when is_valid_day(day) -> day
      _ -> today_day()
    end
  end

  defp today_day do
    Date.utc_today().day
  end

  defp defaults_file do
    Path.join(File.cwd!(), [".aoc.defaults"])
  end

  def write_defaults(defaults) do
    data =
      defaults
      |> Map.take([:year, :day])
      |> tap(&CLI.writeln(["New default options: ", inspect(&1)]))
      |> :erlang.term_to_binary()

    File.write(defaults_file(), data)
  end

  defp read_defaults do
    file = defaults_file()

    if File.exists?(file) do
      file |> File.read!() |> :erlang.binary_to_term([:safe])
    else
      %{}
    end
  end
end
