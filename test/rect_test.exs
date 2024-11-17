defmodule AoC.RectTest do
  alias AoC.Grid
  alias AoC.Rect
  use ExUnit.Case, async: true

  defp to_grid(rectangles, f) do
    Enum.reduce(rectangles, %{}, fn rect, grid ->
      for x <- rect.xa..rect.xo, y <- rect.ya..rect.yo, reduce: grid do
        grid -> Map.update(grid, {x, y}, f.(nil, rect.value), fn v -> f.(v, rect.value) end)
      end
    end)
  end

  defp print_rects(rectangles, f \\ fn _, value -> value end) do
    _ =
      ExUnit.CaptureIO.capture_io(fn ->
        rectangles
        |> to_grid(f)
        |> Grid.print(fn
          nil -> "⋅"
          char when is_binary(char) -> char
          n when is_integer(n) -> Integer.to_string(n)
          {:split, 1} -> "X"
        end)
      end)
  end

  test "building a rectangle" do
    assert %Rect{xa: 1, ya: 2, xo: 3, yo: 4} = Rect.from_points({1, 2}, {3, 4})
    assert %Rect{xa: 1, ya: 2, xo: 3, yo: 4} = Rect.from_points({1, 4}, {3, 2})
  end

  test "printing" do
    print_rects([Rect.from_points({1, 4}, {3, 2}, "X")])

    print_rects(
      [
        Rect.from_points({0, 0}, {2, 2}, "A"),
        Rect.from_points({1, 1}, {3, 3}, "B")
      ],
      fn
        nil, v -> v
        _, _ -> "X"
      end
    )
  end

  describe "splitting" do
    test "from topleft" do
      #   012
      # 0 AAA
      # 1 AXXB
      # 2 AXXB
      # 3  BBB

      rect = Rect.from_points({0, 0}, {2, 2}, "A")
      splitter = Rect.from_points({1, 1}, {3, 3}, "B")

      expected_split = [
        Rect.from_points({1, 1}, {2, 2}, {:split, 1})
      ]

      print_rects([rect, splitter], &show_overlap/2)

      expected_remain =
        sort([
          Rect.from_points({0, 0}, {2, 0}, 1),
          Rect.from_points({0, 1}, {0, 2}, 2)
        ])

      assert {^expected_split, ^expected_remain} = test_split(rect, splitter)
    end

    test "from top no-overflow" do
      # The splitter and the rectangle share the same bottom row

      # AAA
      # XXX
      # XXX

      rect = Rect.from_points({0, 0}, {2, 2}, "A")
      splitter = Rect.from_points({0, 1}, {2, 2}, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        Rect.from_points({0, 1}, {2, 2}, {:split, 1})
      ]

      expected_remain = [Rect.from_points({0, 0}, {2, 0}, 1)]

      assert {^expected_split, ^expected_remain} = test_split(rect, splitter)
    end

    test "from top overflow" do
      # The splitter and the rectangle share the same bottom row

      # AAA
      # XXX
      # XXX
      # BBB

      rect = Rect.from_points({0, 0}, {2, 2}, "A")
      splitter = Rect.from_points({0, 1}, {2, 3}, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        Rect.from_points({0, 1}, {2, 2}, {:split, 1})
      ]

      expected_remain = [Rect.from_points({0, 0}, {2, 0}, 1)]

      assert {^expected_split, ^expected_remain} = test_split(rect, splitter)
    end

    test "from bottom right" do
      rect = Rect.from_ranges(10..12, 10..12, "A")
      splitter = Rect.from_ranges(9..11, 9..11, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        Rect.from_ranges(10..11, 10..11, {:split, 1})
      ]

      # Expect in the "reading order", (first topmost then leftmost)
      expected_remain = [
        # right
        Rect.from_ranges(12..12, 10..12, 1),
        # below
        Rect.from_ranges(10..11, 12..12, 2)
      ]

      {splitted, remain} = test_split(rect, splitter)
      assert expected_split == splitted
      assert expected_remain == remain
    end

    test "no overlap" do
      rect = Rect.from_ranges(0..5, 0..5, "A")
      splitter = Rect.from_ranges(6..10, 6..10, "B")
      print_rects([rect, splitter], &show_overlap/2)

      assert {[], [%{rect | value: 1}]} == test_split(rect, splitter)
    end

    test "fully covered" do
      rect = Rect.from_ranges(2..4, 2..4, "A")
      splitter = Rect.from_ranges(0..6, 0..6, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        Rect.from_ranges(2..4, 2..4, {:split, 1})
      ]

      expected_remain = []

      {splitted, remain} = test_split(rect, splitter)
      assert expected_split == splitted
      assert expected_remain == remain
    end

    test "splitter contained" do
      rect = Rect.from_ranges(0..6, 0..6, "A")
      splitter = Rect.from_ranges(2..4, 2..4, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        %{splitter | value: {:split, 1}}
      ]

      expected_remain = [
        # top
        Rect.from_ranges(0..6, 0..1, 1),
        # left and bottom
        Rect.from_ranges(0..1, 2..6, 2),
        # right and bottom
        Rect.from_ranges(5..6, 2..6, 3),
        # bottom center
        Rect.from_ranges(2..4, 5..6, 4)
      ]

      {splitted, remain} = test_split(rect, splitter)
      assert expected_split == splitted
      assert expected_remain == remain
    end

    test "splitter contained, single cell" do
      rect = Rect.from_ranges(0..2, 0..2, "A")
      splitter = Rect.from_ranges(1..1, 1..1, "B")

      print_rects([rect, splitter], &show_overlap/2)

      expected_split = [
        %{splitter | value: {:split, 1}}
      ]

      expected_remain = [
        # top
        Rect.from_ranges(0..2, 0..0, 1),
        # left and bottom
        Rect.from_ranges(0..0, 1..2, 2),
        # right and bottom
        Rect.from_ranges(2..2, 1..2, 3),
        # bottom center
        Rect.from_ranges(1..1, 2..2, 4)
      ]

      {splitted, remain} = test_split(rect, splitter)
      assert expected_split == splitted
      assert expected_remain == remain
    end
  end

  defp show_overlap(nil, v), do: v
  defp show_overlap(_, _), do: "X"

  defp test_split(%Rect{} = rect, %Rect{} = splitter) do
    {splitted, remains} = Rect.split(rect, splitter)

    splitted =
      splitted
      |> sort()
      |> Enum.with_index(1)
      |> Enum.map(fn {rect, n} -> Rect.put_value(rect, {:split, n}) end)

    remains =
      remains
      |> sort()
      |> Enum.with_index(1)
      |> Enum.map(fn {rect, n} -> Rect.put_value(rect, n) end)

    print_rects(splitted ++ remains)

    {splitted, remains}
  end

  defp sort(rectangles), do: Rect.sort(rectangles)

  test "area" do
    rect = Rect.from_points({0, 0}, {2, 2})
    assert 9 == Rect.area(rect)
  end
end
