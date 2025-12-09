defmodule AoC.CLI do
  alias AoC.CLI
  require CliMate
  CliMate.extend_cli()

  def init_env do
    {:ok, _} = Application.ensure_all_started(:aoc)
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
            year: [
              type: :integer,
              short: :y,
              doc: "Year of the puzzle",
              default: &__MODULE__.default_opt/1,
              default_doc: "Defaults to today's year or custom default."
            ],
            day: [
              type: :integer,
              short: :d,
              doc: "Day of the puzzle",
              default: &__MODULE__.default_opt/1,
              default_doc: "Defaults to today's day or custom default."
            ]
          ],
          opts
        )
    ]
  end

  # Use UTC-5 in December, thanks rvnash ;)
  defp current_day, do: DateTime.shift(DateTime.utc_now(), hour: -5).day
  defp current_year, do: Date.utc_today().year

  def part_command(module, opts \\ []) do
    year_day_command(
      module,
      [
        part: [
          type: :integer,
          short: :p,
          doc: "Part of the puzzle",
          default: nil,
          default_doc: "Defaults to both parts."
        ]
      ] ++ opts
    )
  end

  defp valid_year?(year), do: year in 2015..current_year()
  defp valid_day?(day), do: day in 1..25

  defp valid_day?(2025, day), do: day in 1..12
  defp valid_day?(_uear, day), do: day in 1..25

  defp valid_part?(part), do: part in [1, 2]

  def validate_options!(options) do
    year = Map.fetch!(options, :year)
    day = Map.fetch!(options, :day)
    part = Map.get(options, :part)

    if not valid_year?(year), do: raise("Invalid year: #{year}")
    if not valid_day?(year, day), do: raise("Invalid day: #{day}")
    if part && not valid_part?(part), do: raise("Invalid part: #{part}")

    options
  rescue
    e ->
      CLI.error(Exception.format(:error, e, __STACKTRACE__))
      CLI.halt_error(CLI.errmsg(e))
  end

  @doc """
  Returns a default value for the `--year` or `--day` CLI options.

  The current year or day based on today's date will be returned unless a forced
  default value has been set using `mix aoc.set`.
  """
  def default_opt(:year = key), do: use_default(key, &valid_year?/1, &current_year/0)
  def default_opt(:day = key), do: use_default(key, &valid_day?/1, &current_day/0)

  def default_opt(:skip_comments) do
    case custom_defaults() do
      %{skip_comments: skip?} when is_boolean(skip?) -> skip?
      _ -> false
    end
  end

  defp use_default(key, validate_fun, base_default) do
    with {:ok, value} <- Map.fetch(custom_defaults(), key),
         true <- validate_fun.(value) do
      warn_default(key, value)
      value
    else
      _ -> base_default.()
    end
  end

  defp warn_default(key, value) do
    CLI.warn("Using default #{key}: #{inspect(value)}")
  end

  def defaults_file, do: ".aoc.defaults"

  def write_defaults(defaults) do
    data =
      defaults
      |> tap(&CLI.writeln(["New default options: ", inspect(&1)]))
      |> encode_defaults()

    File.write(defaults_file(), data)
  end

  def custom_defaults do
    pt_key = :aoc_custom_defaults

    case :persistent_term.get(pt_key, nil) do
      nil ->
        defaults = read_defaults()
        :persistent_term.put(pt_key, defaults)
        defaults

      defaults ->
        defaults
    end
  end

  defp read_defaults do
    file = defaults_file()

    if File.exists?(file) do
      file |> File.read!() |> decode_defaults()
    else
      %{}
    end
  end

  @default_keys [:year, :day, :skip_comments]
  @default_keys_bin Enum.map(@default_keys, &Atom.to_string/1)

  Enum.each(@default_keys, fn atom ->
    defp load_default_key(unquote(Atom.to_string(atom))), do: unquote(atom)
  end)

  defp encode_defaults(map) when is_map(map) do
    map |> Map.take(@default_keys) |> Map.new() |> Jason.encode!(pretty: true) |> Kernel.<>("\n")
  end

  defp decode_defaults(json) do
    case Jason.decode(json) do
      {:ok, data} ->
        data |> Map.take(@default_keys_bin) |> Map.new(fn {k, v} -> {load_default_key(k), v} end)

      {:error, e} ->
        CLI.halt_error("Could not load defaults file: #{Exception.message(e)}")
    end
  end

  def errmsg(%{__exception__: true} = e), do: Exception.message(e)
  def errmsg(binary) when is_binary(binary), do: binary
  def errmsg(other), do: inspect(other)
end
