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
            year: [
              type: :integer,
              short: :y,
              doc: "Year of the puzzle",
              default: &__MODULE__.default_opt/1,
              default_doc:
                "Default value can be defined using `mix aoc.set`, otherwise uses today's year."
            ],
            day: [
              type: :integer,
              short: :d,
              doc: "Day of the puzzle",
              default: &__MODULE__.default_opt/1,
              default_doc:
                "Default value can be defined using `mix aoc.set`, otherwise uses today's day."
            ]
          ],
          opts
        )
    ]
  end

  defp current_year, do: Date.utc_today().year
  defp current_day, do: Date.utc_today().day

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
  defp valid_part?(part), do: part in [1, 2]

  def validate_options!(options) do
    year = Map.fetch!(options, :year)
    day = Map.fetch!(options, :day)
    part = Map.get(options, :part)

    if not valid_year?(year), do: raise("Invalid year: #{year}")
    if not valid_day?(day), do: raise("Invalid day: #{day}")
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
    case custom_defaults() |> dbg() do
      %{skip_comments: skip?} when is_boolean(skip?) -> skip?
      _ -> false
    end
    |> dbg()
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
      |> :erlang.term_to_binary()

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
      file |> File.read!() |> :erlang.binary_to_term([:safe])
    else
      %{}
    end
  end

  def errmsg(%{__exception__: true} = e), do: Exception.message(e)
  def errmsg(binary) when is_binary(binary), do: binary
  def errmsg(other), do: inspect(other)
end
