defmodule AoC.Mod do
  @moduledoc false
  alias AoC.CodeGen

  def module_name(year, day) do
    Module.concat([prefix(), "Y#{year - 2000}", "Day#{CodeGen.pad_day(day)}"])
  end

  @doc false
  def legacy_module_name(year, day) do
    Module.concat([prefix(), "Y#{year - 2000}", "Day#{day}"])
  end

  def test_module_name(year, day) do
    Module.concat([prefix(), "Y#{year - 2000}", "Day#{CodeGen.pad_day(day)}Test"])
  end

  defp prefix do
    Application.fetch_env!(:aoc, :prefix)
  end
end
