defmodule Mix.Tasks.Aoc.Create do
  alias AoC.CLI
  alias AoC.CodeGen
  use Mix.Task

  @shortdoc "Create the files to solve a problem"
  def run(argv) do
    CLI.init_env()

    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    download_input = Task.async(AoC.Input, :ensure_local, [year, day])

    ensure_solution_module(year, day)
    ensure_test(year, day)
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

  defp ensure_solution_module(year, day) do
    module_dir = Path.join([File.cwd!(), "lib", "solutions", "#{year}"])
    File.mkdir_p!(module_dir)
    module_path = Path.join(module_dir, "day#{CodeGen.pad_day(day)}.ex")

    if not File.exists?(module_path) do
      module = AoC.Mod.module_name(year, day)
      code = module_code(module)
      Mix.Shell.IO.info("Creating module #{inspect(module)}")
      File.write!(module_path, code)
    end

    print_path("Solution module", module_path)
  end

  defp ensure_test(year, day) do
    test_dir = Path.join([File.cwd!(), "test", "#{year}"])
    File.mkdir_p!(test_dir)
    test_path = Path.join(test_dir, "day#{CodeGen.pad_day(day)}_test.exs")

    if not File.exists?(test_path) do
      test_module = AoC.Mod.test_module_name(year, day)
      module = AoC.Mod.module_name(year, day)
      code = test_code(test_module, module, test_path, year, day)
      Mix.Shell.IO.info("Creating test module #{inspect(test_module)}")
      File.write!(test_path, code)
    end

    print_path("Test module", test_path)

    :ok
  end

  def print_path(name, path) do
    CLI.writeln([CLI.color(:magenta, name), "\n", path])
  end

  defp module_code(module) do
    AoC.CodeGen.module_template(%{module: module})
  end

  defp test_code(test_module, module, _test_path, year, day) do
    AoC.CodeGen.test_template(%{
      module: module,
      test_module: test_module,
      year: year,
      day: day,
      padded_day: CodeGen.pad_day(day)
    })
  end
end
