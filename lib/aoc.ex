defmodule AoC do
  alias AoC.Mod
  alias AoC.Input

  @type input_path :: binary
  @type file :: input_path | %AoC.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  def run(year, day, part, timer? \\ false) when part in [:part_one, :part_two] do
    module = Mod.module_name(year, day)

    case do_run(year, day, module, part) do
      {:ok, {_time, solution}} = result ->
        if timer? do
          result
        else
          {:ok, solution}
        end

      other ->
        other
    end
  end

  defp do_run(year, day, module, part) when is_atom(module) and part in [:part_one, :part_two] do
    with {:module, _} <- Code.ensure_loaded(module),
         {:ok, input_path} <- Input.ensure_local(year, day),
         :ok <- ensure_part(module, part) do
      {:ok, do_run_part(module, part, input_path)}
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

  defp do_run_part(module, part, input_path) do
    :timer.tc(fn ->
      input = module.read_file(input_path, part)
      problem = module.parse_input(input, part)
      apply(module, part, [problem])
    end)
  end
end
