if Code.ensure_loaded?(Readmix.Generator) do
  defmodule AoC.DocGen.Generator do
    use Readmix.Generator

    @moduledoc false

    @tasks %{
      "aoc.open" => Mix.Tasks.Aoc.Open,
      "aoc.create" => Mix.Tasks.Aoc.Create,
      "aoc.test" => Mix.Tasks.Aoc.Test,
      "aoc.run" => Mix.Tasks.Aoc.Run,
      "aoc.fetch" => Mix.Tasks.Aoc.Fetch,
      "aoc.url" => Mix.Tasks.Aoc.Url
    }

    action :task_doc, params: [task: [type: :string, required: true]]

    @spec task_doc(term, term) :: {:ok, iodata()}
    def task_doc(params, _context) do
      task = Keyword.fetch!(params, :task)
      module = Map.fetch!(@tasks, task)

      content =
        module
        |> Code.fetch_docs()
        |> elem(4)
        |> Map.fetch!("en")
        |> String.replace("## Synopsis", "#### Usage")
        |> String.replace("## Options", "#### Options")

      {:ok, ["### mix ", task, "\n\n", content]}
    end
  end
end
