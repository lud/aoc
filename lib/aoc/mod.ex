defmodule AoC.Mod do
  @moduledoc false
  def module_name(year, day) do
    Module.concat([prefix(), "Y#{year - 2000}", "Day#{day}"])
  end

  def test_module_name(year, day) do
    Module.concat([prefix(), "Y#{year - 2000}", "Day#{day}Test"])
  end

  defp prefix do
    Application.fetch_env!(:aoc, :prefix)
  end
end
