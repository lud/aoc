defmodule Mix.Tasks.Aoc.Create do
  alias AoC.CLI
  alias AoC.CodeGen
  use Mix.Task

  @shortdoc "Creates the files to solve an Advent of Code puzzle"
  @requirements ["app.config"]

  @command CLI.year_day_command(__MODULE__)

  @moduledoc """
  This task will execute the following operations:

  * Download the input from Advent of Code website into the `priv/inputs`
    directory.
  * Create the solution module.
  * Create a test module.

  Existing files will not be overwritten. It is safe to call the command again
  if you need to regenerate a deleted file.

  The generated files will contain some comment blocks to help you get
  accustomed to using this library. This can be annoying after some time. You
  may disable generating those comments by setting the appropriate configuration
  option:

      config :aoc, generate_comments: false

  #{CLI.format_usage(@command, format: :moduledoc)}
  """
  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, @command)

    %{year: year, day: day} = CLI.validate_options!(options)
    comments? = AoC.Config.generate_comments?()

    download_input = Task.async(AoC.Input, :ensure_local, [year, day])

    ensure_solution_module(year, day, comments?)
    ensure_test(year, day, comments?)
    Mix.Task.run("format")
    Mix.Task.run("compile")

    case Task.await(download_input) do
      {:ok, path} ->
        print_path("Input file", path)

      {:error, reason} ->
        CLI.warn("""
        Warning: Could not download input: #{CLI.errmsg(reason)}

        Make sure your cookie is set in #{AoC.API.cookie_path()} .
        """)
    end
  end

  defp ensure_solution_module(year, day, comments?) do
    module = AoC.Mod.module_name(year, day)
    module_path = AoC.Mod.module_path(module)
    module_dir = Path.dirname(module_path)

    if not File.exists?(module_path) do
      code = module_code(module, comments?)
      Mix.Shell.IO.info("Creating module #{inspect(module)}")
      File.mkdir_p!(module_dir)
      File.write!(module_path, code)
    end

    print_path("Solution module", module_path)
  end

  defp ensure_test(year, day, comments?) do
    test_dir = Path.join([File.cwd!(), "test", "#{year}"])
    File.mkdir_p!(test_dir)
    test_path = Path.join(test_dir, "day#{CodeGen.pad_day(day)}_test.exs")

    if not File.exists?(test_path) do
      test_module = AoC.Mod.test_module_name(year, day)
      module = AoC.Mod.module_name(year, day)
      code = test_code(test_module, module, year, day, comments?)
      Mix.Shell.IO.info("Creating test module #{inspect(test_module)}")
      File.write!(test_path, code)
    end

    print_path("Test module", test_path)

    :ok
  end

  def print_path(name, path) do
    CLI.writeln([CLI.color(name, :magenta), "\n", path])
  end

  defp module_code(module, comments?) do
    AoC.CodeGen.module_template(%{module: module, comments?: comments?})
  end

  defp test_code(test_module, module, year, day, comments?) do
    AoC.CodeGen.test_template(%{
      module: module,
      test_module: test_module,
      year: year,
      day: day,
      padded_day: CodeGen.pad_day(day),
      comments?: comments?
    })
  end
end
