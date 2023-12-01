defmodule Mix.Tasks.Aoc.Create do
  alias AoC.CLI
  use Mix.Task

  @shortdoc "Create the files to solve a problem"
  def run(argv) do
    Application.ensure_all_started(:aoc)

    %{options: options} = CLI.parse_or_halt!(argv, CLI.year_day_command(__MODULE__))
    %{year: year, day: day} = CLI.validate_options!(options)

    download_input = Task.async(AoC.Input, :ensure_local, [year, day])

    ensure_solution_module(year, day)
    ensure_test(year, day)
    Mix.Task.run("format")
    Mix.Task.run("compile")

    case Task.await(download_input) do
      {:ok, path} ->
        Mix.Shell.IO.info("Input file exists in #{path}")

      {:error, reason} ->
        Mix.Shell.IO.info("Warning: Could not download input: #{inspect(reason)}")
    end

    Mix.Shell.IO.info("ok")
  end

  defp ensure_solution_module(year, day) do
    module_dir = Path.join([File.cwd!(), "lib", "solutions", "#{year}"])
    File.mkdir_p!(module_dir)
    module_path = Path.join(module_dir, "day#{day}.ex")

    if File.exists?(module_path) do
      Mix.Shell.IO.info("Module exists in #{module_path}")
    else
      module = AoC.Mod.module_name(year, day)
      code = module_code(module)
      Mix.Shell.IO.info("Creating module #{inspect(module)} in #{module_path}")
      File.write!(module_path, code)
    end

    :ok
  end

  defp ensure_test(year, day) do
    test_dir = Path.join([File.cwd!(), "test", "#{year}"])
    File.mkdir_p!(test_dir)
    test_path = Path.join(test_dir, "day#{day}_test.exs")

    if File.exists?(test_path) do
      Mix.Shell.IO.info("Test module exists in #{test_path}")
    else
      test_module = AoC.Mod.test_module_name(year, day)
      module = AoC.Mod.module_name(year, day)
      code = test_code(test_module, module, test_path, year, day)
      Mix.Shell.IO.info("Creating test module #{inspect(test_module)} in #{test_path}")
      File.write!(test_path, code)
    end

    :ok
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
    ~s[
    defmodule #{inspect(test_module)} do
      alias AoC.Input, warn: false
      alias #{inspect(module)}, as: Solution, warn: false
      use ExUnit.Case, async: true

      # To run the test, run one of the following commands:
      #
      #     mix test test/#{year}/day#{day}_test.exs
      #     mix AoC.test --year #{year} --day #{day}
      #
      # To run the solution
      #
      #     mix AoC.run --year #{year} --day #{day} --part 1
      #
      # Use sample input file, for instance in priv/input/#{year}/"day-#{day}-sample.inp"
      #
      #     {:ok, path} = Input.resolve(#{year}, #{day}, "sample")
      #

      @sample_1 """
      This is
      A Fake
      Data file
      """

      test "verify #{year}/#{day} part_one - samples" do
        problem =
          @sample_1
          |> Input.as_file()
          |> Solution.read_file(:part_one)
          |> Solution.parse_input(:part_one)

        expected = CHANGE_ME
        assert expected == Solution.part_one(problem)
      end

      # test "verify #{year}/#{day} part_two - samples" do
      #   problem =
      #     @sample_1
      #     |> Input.as_file()
      #     |> Solution.read_file(:part_two)
      #     |> Solution.parse_input(:part_two)
      #
      #   expected = CHANGE_ME
      #   assert expected == Solution.part_two(problem)
      # end

      # Once your part one was successfully sumbitted, you may uncomment this test
      # to ensure your implementation was not altered when you implement part two.

      # @part_one_solution CHANGE_ME
      #
      # test "verify #{year}/#{day} part one" do
      #   assert {:ok, @part_one_solution} == AoC.run(#{year}, #{day}, :part_one)
      # end

      # You may also implement a test to validate the part two to ensure that you
      # did not broke your shared modules when implementing another problem.

      # @part_two_solution CHANGE_ME
      #
      # test "verify #{year}/#{day} part two" do
      #   assert {:ok, @part_two_solution} == AoC.run(#{year}, #{day}, :part_two)
      # end

    end
    ]
  end
end
