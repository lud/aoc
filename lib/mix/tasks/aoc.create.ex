defmodule Mix.Tasks.Aoc.Create do
  alias AoC.CLI
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
      {:ok, path} -> print_path("Input file", path)
      {:error, reason} -> CLI.warn("Warning: Could not download input: #{inspect(reason)}")
    end
  end

  defp ensure_solution_module(year, day) do
    module_dir = Path.join([File.cwd!(), "lib", "solutions", "#{year}"])
    File.mkdir_p!(module_dir)
    module_path = Path.join(module_dir, "day#{day}.ex")

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
    test_path = Path.join(test_dir, "day#{day}_test.exs")

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
    """
    defmodule #{inspect(module)} do
      alias AoC.Input, warn: false

      def read_file(file, _part) do
        # Return each line
        Input.stream!(file, trim: true)
        # Or return the whole file
        # Input.read!(file)
      end

      def parse_input(input, _part) do
        input
      end

      def part_one(problem) do
        problem
      end

      def part_two(problem) do
        problem
      end
    end
    """
  end

  defp test_code(test_module, module, _test_path, year, day) do
    ~s'
    defmodule #{inspect(test_module)} do
      alias AoC.Input, warn: false
      alias #{inspect(module)}, as: Solution, warn: false
      use ExUnit.Case, async: true

      # To run the test, run one of the following commands:
      #
      #     mix AoC.test --year #{year} --day #{day}
      #
      #     mix test test/#{year}/day#{day}_test.exs
      #
      # To run the solution
      #
      #     mix AoC.run --year #{year} --day #{day} --part 1
      #
      # Use sample input file, for instance in priv/input/#{year}/"day-#{day}-sample.inp"
      #
      #     {:ok, path} = Input.resolve(#{year}, #{day}, "sample")
      #
      # Good luck!

      defp solve(input, part) do
        problem =
          input
          |> Input.as_file()
          |> Solution.read_file(part)
          |> Solution.parse_input(part)

        apply(Solution, part, [problem])
      end

      test "part one example" do
        input = """
        This is an
        example input.
        replace with
        an example from
        the AoC website.
        """

        assert CHANGE_ME == solve(input, :part_one)
      end

      # Once your part one was successfully sumbitted, you may uncomment this test
      # to ensure your implementation was not altered when you implement part two.

      # @part_one_solution CHANGE_ME
      #
      # test "part one solution" do
      #   assert {:ok, @part_one_solution} == AoC.run(#{year}, #{day}, :part_one)
      # end

      # test "part two example" do
      #   input = """
      #   This is an
      #   example input.
      #   replace with
      #   an example from
      #   the AoC website.
      #   """
      #
      #   assert CHANGE_ME == solve(input, :part_two)
      # end

      # You may also implement a test to validate the part two to ensure that you
      # did not broke your shared modules when implementing another problem.

      # @part_two_solution CHANGE_ME
      #
      # test "part two solution" do
      #   assert {:ok, @part_two_solution} == AoC.run(#{year}, #{day}, :part_two)
      # end

    end
    '
  end
end
