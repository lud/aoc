defmodule AoC.Permutations do
  @moduledoc """
  A helper module to generate permutations from a list of items.

  Each permutation will contain all the elements of the list, in a different and
  unique order.
  """

  @doc """
  Returns a stream of permutations. This allows to generate a large amount of
  permutations without using too much memory.

  The function accepts either a list or a range. Other enums must be converted
  to list manually before calling this function.
  """
  def of([_ | tail] = list) do
    stream = [{[], list}]

    tail
    |> Enum.reduce(stream, fn _iter, stream -> Stream.flat_map(stream, &permutation_step/1) end)
    |> Stream.map(&unwrap_permutations/1)
  end

  def of([]), do: []

  def of(_.._//_ = range) do
    of(Enum.to_list(range))
  end

  defp permutation_step({used, left}) do
    Stream.map(left, fn item -> {[item | used], left -- [item]} end)
  end

  defp unwrap_permutations({used, [last]}) do
    [last | used]
  end
end
