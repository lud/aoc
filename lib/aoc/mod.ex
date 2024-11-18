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

  def module_path(module) do
    modkit_mount = Modkit.load_current_project().mount

    case Modkit.Mount.preferred_path(modkit_mount, module) do
      {:ok, path} ->
        path

      {:error, :not_mounted} ->
        raise """
        invalid modkit configuration

        If you use Modkit in your project, make sure that the configured prefix
        for AoC is defined in your mount points.

        # Module
        #{inspect(module)}

        # AoC config
        config :aoc, prefix: #{inspect(prefix())}

        # Modkit config
        #{inspect(modkit_mount)}
        """
    end
  end
end
