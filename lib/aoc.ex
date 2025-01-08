defmodule AoC do
  alias AoC.Input
  alias AoC.Mod

  @type input_path :: binary
  @type file :: input_path | %AoC.Input.TestInput{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  def run(year, day, part) when part in [:part_one, :part_two] do
    case find_module(year, day) do
      {:ok, module} -> do_run(year, day, module, part)
      {:error, _} = err -> err
    end
  end

  def find_module(year, day) do
    with {:error, _} <- Code.ensure_loaded(Mod.module_name(year, day)),
         {:error, _} <- Code.ensure_loaded(Mod.legacy_module_name(year, day)) do
      {:error, :not_implemented}
    else
      {:module, mod} -> {:ok, mod}
    end
  end

  defp do_run(year, day, module, part) when is_atom(module) and part in [:part_one, :part_two] do
    with {:ok, input_path} <- Input.ensure_local(year, day),
         :ok <- ensure_part(module, part) do
      {:ok, call_part(module, part, input_path)}
    else
      {:error, :nofile} -> {:error, :not_implemented}
      {:error, _} = err -> err
    end
  end

  defp ensure_part(module, part) do
    if function_exported?(module, part, 1) do
      :ok
    else
      {:error, :not_implemented}
    end
  end

  defp call_part(module, part, input_path) do
    problem = generate_problem(module, part, input_path)
    apply(module, part, [problem])
  end

  defp generate_problem(module, part, input_path) do
    cond do
      function_exported?(module, :parse, 2) ->
        module.parse(input_path, part)

      function_exported?(module, :read_file, 2) and
          function_exported?(module, :parse_input, 2) ->
        input = module.read_file(input_path, part)
        _problem = module.parse_input(input, part)

      true ->
        raise "no function #{inspect(module)}.parse/2"
    end
  end
end
