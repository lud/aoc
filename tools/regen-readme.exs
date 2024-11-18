defmodule Readme do
  def run(vsn) do
    "README.md"
    |> File.read!()
    |> String.split("\n")
    |> update_block("as_dep", block_dep(vsn))
    |> update_command_blocks()
    |> Enum.join("\n")
    |> then(&File.write!("README.md", &1))

    IO.puts("Regenerated README.md")
    :ok
  end

  def version_requirement(vsn) do
    %{major: major, minor: minor} = Version.parse!(vsn)

    "~> #{major}.#{minor}"
  end

  defp update_block(lines, block_name, block_content) do
    open = "<!-- block:#{block_name} -->"
    close = "<!-- endblock:#{block_name} -->"

    {before, rest} = Enum.split_while(lines, &(&1 != open))
    [^open | rest] = rest
    {_old_block, rest} = Enum.split_while(rest, &(&1 != close))
    [^close | after_] = rest

    before ++ [open, block_content, close] ++ after_
  end

  defp block_dep(vsn) do
    """
    ```elixir
    defp deps do
      [
        {:aoc, #{inspect(version_requirement(vsn))}},
      ]
    end
    ```
    """
    |> String.trim()
  end

  defp update_command_blocks(lines_in) do
    blocks =
      %{
        "mix.aoc.open" => Mix.Tasks.Aoc.Open,
        "mix.aoc.create" => Mix.Tasks.Aoc.Create,
        "mix.aoc.test" => Mix.Tasks.Aoc.Test,
        "mix.aoc.run" => Mix.Tasks.Aoc.Run,
        "mix.aoc.fetch" => Mix.Tasks.Aoc.Fetch,
        "mix.aoc.url" => Mix.Tasks.Aoc.Url
      }

    Enum.reduce(blocks, lines_in, fn {block_name, module}, lines ->
      block_content =
        module
        |> Code.fetch_docs()
        |> elem(4)
        |> Map.fetch!("en")
        |> String.replace("## Usage", "#### Usage")
        |> String.replace("## Options", "#### Options")

      block_content = ["### ", block_name, "\n\n" | block_content]

      update_block(lines, block_name, block_content)
    end)
  end
end

vsn =
  case System.argv() do
    [vsn] -> vsn
    [] -> Mix.Project.get().project() |> Keyword.fetch!(:version)
  end

Readme.run(vsn)
