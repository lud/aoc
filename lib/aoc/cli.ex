defmodule AoC.CLI do
  alias AoC.CLI
  use CliMate

  @current_year Date.utc_today().year
  @current_day Date.utc_today().day
  @custom_defaults_keys [:year, :day]

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
            year: [type: :integer, short: :y, doc: "Year of the puzzle", default: &default_opt/1],
            day: [type: :integer, short: :d, doc: "Day of the puzzle", default: &default_opt/1]
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

  defguard is_valid_year(year) when is_integer(year) and year in 2015..@current_year
  defguard is_valid_day(day) when is_integer(day) and day in 1..25

  defguard is_valid_day(year, day)
           when is_integer(year) and year >= 2015 and is_integer(day) and day in 1..25

  defguard is_valid_part(part) when is_integer(part) and part in [1, 2]

  def validate_options!(options) do
    case Map.fetch(options, :year) do
      {:ok, year} when not is_valid_year(year) -> raise "Invalid year: #{year}"
      {:ok, _} -> :ok
    end

    case Map.fetch(options, :day) do
      {:ok, day} when not is_valid_day(day) -> raise "Invalid day: #{day}"
      {:ok, _} -> :ok
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

  defp default_opt(:year) do
    case custom_defaults() do
      %{year: year} -> year
      _ -> @current_year
    end
  end

  defp default_opt(:day) do
    case custom_defaults() do
      %{day: day} when is_valid_day(day) -> day
      _ -> @current_day
    end
  end

  defp defaults_file do
    Path.join(File.cwd!(), [".aoc.defaults"])
  end

  def write_defaults(defaults) do
    data =
      defaults
      |> Map.take(@custom_defaults_keys)
      |> tap(&CLI.writeln(["New default options: ", inspect(&1)]))
      |> :erlang.term_to_binary()

    File.write(defaults_file(), data)
  end

  defp custom_defaults do
    pt_key = :aoc_custom_defaults

    case :persistent_term.get(pt_key, nil) do
      nil ->
        defaults = read_defaults()
        dump_defaults(defaults)
        :persistent_term.put(pt_key, defaults)
        defaults

      defaults ->
        defaults
    end
  end

  defp read_defaults do
    file = defaults_file()

    if File.exists?(file) do
      file |> File.read!() |> :erlang.binary_to_term([:safe]) |> Map.take(@custom_defaults_keys)
    else
      %{}
    end
  end

  defp dump_defaults(defaults) do
    Enum.each(@custom_defaults_keys, fn key ->
      case Map.fetch(defaults, key) do
        {:ok, v} -> CLI.warn("Using default #{key}: #{inspect(v)}")
      end
    end)
  end
end
