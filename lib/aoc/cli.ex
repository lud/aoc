defmodule AoC.CLI do
  alias AoC.CLI
  use CliMate

  def init_env do
    Mix.Task.run("loadpaths")
    Application.ensure_all_started(:aoc)
  end

  def year_day_command(module) do
    [
      module: module,
      options: [
        year: [type: :integer, short: :y, doc: "Year of the puzzle", default: default_year()],
        day: [type: :integer, short: :d, doc: "Day of the puzzle"] ++ default_day_optlist()
      ]
    ]
  end

  def part_command(module) do
    module
    |> year_day_command()
    |> put_in([:options, :part],
      type: :integer,
      short: :p,
      doc: "Part of the puzzle",
      default: nil
    )
  end

  defguard is_valid_year(year) when is_integer(year) and year >= 2015
  defguard is_valid_day(day) when is_integer(day) and day in 1..25

  defguard is_valid_day(year, day)
           when is_integer(year) and year >= 2015 and is_integer(day) and day in 1..25

  defguard is_valid_part(part) when is_integer(part) and part in [1, 2]

  def validate_options!(options) do
    case Map.fetch(options, :year) do
      {:ok, year} when not is_valid_year(year) -> raise "Invalid year: #{year}"
      _ -> :ok
    end

    case Map.fetch(options, :day) do
      {:ok, day} when not is_valid_day(day) -> raise "Invalid day: #{day}"
      :error -> raise "Missing day option"
      _ -> :ok
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
      %{year: year} when is_valid_year(year) ->
        CLI.writeln(CLI.color(:yellow, "Using forced default year #{year}"))
        year

      _ ->
        Date.utc_today().year
    end
  end

  defp default_day_optlist do
    case read_defaults() do
      %{day: day} when is_valid_day(day) ->
        CLI.writeln(CLI.color(:yellow, "Using forced default day #{day}"))
        [default: day]

      _ ->
        case Date.utc_today().day do
          day when is_valid_day(day) -> [default: day]
          _ -> []
        end
    end
  end

  defp defaults_file do
    Path.join(File.cwd!(), [".aoc.defaults"])
  end

  def write_defaults(defaults) do
    data =
      defaults
      |> Map.take([:year, :day])
      |> IO.inspect(label: "New default options")
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
