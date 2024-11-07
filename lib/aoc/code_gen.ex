defmodule AoC.CodeGen do
  require EEx
  @template_dir __ENV__.file |> Path.dirname() |> Path.join("templates")
  @module_tpl Path.join(@template_dir, "module.solution.eex")
  @test_tpl Path.join(@template_dir, "unit.tests.eex")
  EEx.function_from_file(:def, :module_template, @module_tpl, [:vars])
  EEx.function_from_file(:def, :test_template, @test_tpl, [:vars])

  def pad_day(day) when is_integer(day) do
    pad_day(Integer.to_string(day))
  end

  def pad_day(day) when is_binary(day) do
    String.pad_leading(day, 2, "0")
  end
end
