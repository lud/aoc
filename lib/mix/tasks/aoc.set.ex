defmodule Mix.Tasks.Aoc.Set do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Sets or reset default year and day options for other commands"

  @defaults_file CLI.defaults_file()

  @command [
    module: __MODULE__,
    doc: "Sets the default year / day when not provided on other commands",
    options: [
      year: [type: :integer, short: :y, doc: "Year to use as default."],
      day: [type: :integer, short: :d, doc: "Day to force as default."],
      skip_comments: [
        type: :boolean,
        short: :C,
        doc:
          "Disable including comments as a default when generating Elixir files. Default inclusion can be explicitly enabled with --no-skip-comments."
      ],
      reset: [
        type: :boolean,
        short: :r,
        doc:
          "Resets the default values. Can be combined with other flags to reset unspecified flags only."
      ]
    ]
  ]

  @moduledoc """
  This task allows to configure the default values used by the other commands.

  Custom default values are stored in `#{@defaults_file}` at the root of your
  project.

  This is useful when working on a puzzle belonging to another year, or when
  solvig the day 20 puzzle takes a long time and you want to continue to work on
  it during day 21, 22, etc.

  By calling `mix aoc.set -d 20`, the other commands such as `mix aoc.run` will
  use `20` as the default day, unless the flag is explicitly given as in `mix
  aoc.run -d 20`.

  The command will accumulate values when called multiple times. For instance:

  ```shell
  mix aoc.set -d 20
  mix aoc.set -y 2020
  ```

  Executing the two commands above will lead to defaults of day 20 and year
  2020.

  Then, calling the command with the `-r` flag will reset other unspecified
  flags:

  ```shell
  mix aoc.set -r -d 22
  ```

  After the command above is executed, the default day will be 22 but the
  default year has been reset to be dynamically defined using today's date when
  other commands are called.

  Finally, you can reset everything using `mix aoc.set -r`. Deleting the
  `#{@defaults_file}` file is another way to do that.

  #{CLI.format_usage(@command, format: :moduledoc)}
  """

  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)

    base_defaults =
      case options do
        %{reset: true} -> %{}
        _ -> CLI.custom_defaults()
      end

    overwrites = Map.drop(options, [:reset, :help])

    CLI.write_defaults(Map.merge(base_defaults, overwrites))
  end
end
