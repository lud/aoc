defmodule AoC.AoC.PermutationsTest do
  alias AoC.Permutations
  use ExUnit.Case, async: true

  test "empty list" do
    assert [] = Permutations.of([])
  end

  test "single" do
    assert [[1]] = Permutations.of([1]) |> Enum.to_list()
  end

  defp assert_same_sorted(expected, stream) do
    assert Enum.sort(expected) == Enum.sort(stream)
  end

  test "two" do
    assert_same_sorted([[1, 2], [2, 1]], Permutations.of([1, 2]))
  end

  test "three" do
    assert_same_sorted(
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]],
      Permutations.of([1, 2, 3])
    )
  end

  test "it is a stream" do
    # Computing all permutations with 100 elements would take a very long time.
    # But we return a sream so this test should complete quickly.

    generated =
      1..100
      |> Permutations.of()
      |> Enum.take(10)

    assert 10 = length(generated)
    assert 10 = length(Enum.uniq(generated))
    assert true = Enum.all?(generated, fn list -> length(list) == 100 end)
  end

  test "it generates the correct amount of permutations" do
    range = 1..5
    n = Enum.count(range)
    expected_count = factorial(n)

    stream = Permutations.of(range)
    assert expected_count == Enum.count(stream)
    assert expected_count == stream |> Enum.uniq() |> Enum.count()
  end

  defp factorial(0) do
    raise "zero"
  end

  defp factorial(1) do
    1
  end

  defp factorial(n) do
    n * factorial(n - 1)
  end
end
