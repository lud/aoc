defmodule AoC.Grid do
  def parse_stream(lines, char_parser) when is_function(char_parser, 1) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line(&1, char_parser))
    |> Map.new()
  end

  defp parse_line({string, y}, char_parser) do
    string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(&parse_cell(&1, y, char_parser))
  end

  defp parse_cell({"\n", _x}, _y, _char_parser) do
    []
  end

  defp parse_cell({cell, x}, y, char_parser) do
    case char_parser.(cell) do
      :ignore -> []
      {:ok, value} -> [{{x, y}, value}]
      other -> raise "Invalid return value from parser function in AoC.Grid.parse_stream/2, expected {:ok, value} or :ignore, got: #{inspect(other)}"
    end
  end

  def min_x(list) when is_list(list), do: Enum.reduce(list, &min_x/2)
  def min_x(map) when is_map(map), do: map |> Map.keys() |> min_x()

  def max_x(map) when is_map(map), do: map |> Map.keys() |> max_x()
  def max_x(list) when is_list(list), do: Enum.reduce(list, &max_x/2)

  def min_y(map) when is_map(map), do: map |> Map.keys() |> min_y()
  def min_y(list) when is_list(list), do: Enum.reduce(list, &min_y/2)

  def max_y(map) when is_map(map), do: map |> Map.keys() |> max_y()
  def max_y(list) when is_list(list), do: Enum.reduce(list, &max_y/2)

  def max_x({a, _}, {b, _}), do: max(a, b)
  def max_x({a, _}, b) when is_integer(b), do: max(a, b)
  def min_x({a, _}, {b, _}), do: min(a, b)
  def min_x({a, _}, b) when is_integer(b), do: min(a, b)
  def max_y({_, a}, {_, b}), do: max(a, b)
  def max_y({_, a}, b) when is_integer(b), do: max(a, b)
  def min_y({_, a}, {_, b}), do: min(a, b)
  def min_y({_, a}, b) when is_integer(b), do: min(a, b)

  def bounds(map) when map_size(map) == 1 do
    [{x, y}] = Map.keys(map)
    {x, x, y, y}
  end

  def bounds(map) when is_map(map) do
    keys = Map.keys(map)
    {min_x(keys), max_x(keys), min_y(keys), max_y(keys)}
  end

  def print_map(map, print_char \\ &self_char/1) do
    {xl, xh, yl, yh} = bounds(map)

    for y <- yl..yh do
      [
        "\n",
        for x <- xl..xh do
          print_char.(Map.get(map, {x, y}))
        end
      ]
    end
    |> IO.puts()

    map
  end

  defp self_char(nil), do: " "
  defp self_char(<<a>>), do: a

  def bfs_path(map, start_pos, end_pos, get_neighs) do
    bfs_path(
      map,
      [start_pos],
      end_pos,
      get_neighs,
      _round = 1,
      _seen = %{start_pos => true}
    )
  catch
    {:found, x} -> x
  end

  defp bfs_path(map, [_ | _] = open, end_pos, get_neighs, round, seen) do
    neighs =
      open
      |> Enum.flat_map(fn pos -> get_neighs.(pos, map) end)
      |> Enum.uniq()
      |> Enum.filter(&(not Map.has_key?(seen, &1)))

    if end_pos in neighs do
      throw({:found, round})
    end

    seen = Map.merge(seen, Map.new(neighs, &{&1, true}))

    bfs_path(map, neighs, end_pos, get_neighs, round + 1, seen)
  end

  defp bfs_path(_, [], _, _, _, _) do
    throw(:not_found)
  end

  def cardinal4(xy) do
    [
      translate(xy, :n),
      translate(xy, :s),
      translate(xy, :w),
      translate(xy, :e)
    ]
  end

  def cardinal8(xy) do
    [
      translate(xy, :n),
      translate(xy, :nw),
      translate(xy, :ne),
      translate(xy, :s),
      translate(xy, :se),
      translate(xy, :sw),
      translate(xy, :w),
      translate(xy, :e)
    ]
  end

  def translate({x, y}, :n), do: {x, y - 1}
  def translate({x, y}, :ne), do: {x + 1, y - 1}
  def translate({x, y}, :nw), do: {x - 1, y - 1}
  def translate({x, y}, :s), do: {x, y + 1}
  def translate({x, y}, :se), do: {x + 1, y + 1}
  def translate({x, y}, :sw), do: {x - 1, y + 1}
  def translate({x, y}, :w), do: {x - 1, y}
  def translate({x, y}, :e), do: {x + 1, y}
end
