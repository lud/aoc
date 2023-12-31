defmodule AoC.Rect do
  defstruct [:xa, :ya, :xo, :yo, :value]

  defimpl Inspect do
    def inspect(%{xa: xa, ya: ya, xo: xo, yo: yo, value: value}, opts) do
      ~s"Rect.from_points({#{xa}, #{ya}}, {#{xo}, #{yo}}, #{Inspect.inspect(value, opts)})"
    end
  end

  def from_points({x1, y1}, {x2, y2}, value \\ nil) do
    xa = min(x1, x2)
    ya = min(y1, y2)
    xo = max(x1, x2)
    yo = max(y1, y2)
    %__MODULE__{xa: xa, ya: ya, xo: xo, yo: yo, value: value}
  end

  def from_ranges(x1..x2, y1..y2, value \\ nil) do
    xa = min(x1, x2)
    ya = min(y1, y2)
    xo = max(x1, x2)
    yo = max(y1, y2)
    %__MODULE__{xa: xa, ya: ya, xo: xo, yo: yo, value: value}
  end

  @doc """
  Sort rectangles by reading order:
  * First, the topmost rectangle.
  * Then, the leftmost rectangle.
  """
  def sort(rectangles) do
    Enum.sort_by(rectangles, fn %{xa: xa, ya: ya} -> {ya, xa} end)
  end

  def put_value(%{value: _} = rect, value), do: %{rect | value: value}

  def area(%{xa: xa, ya: ya, xo: xo, yo: yo}) do
    (xo - xa + 1) * (yo - ya + 1)
  end

  @doc """
  Returns a tuple `{covered, remains}` where

  * `covered` is a list with zero or one item, the parts of the rectangle that
    are covered by the `splitter`.
  * `remains` is a list of the parts of the rectangle that are not covered. It
    can be an empty list if the original rectangle is fully covered by the
    splitter.

  The algorithm follow the reading directions, meaning that it will first cut
  the uncovered part above the splitter, then the uncovered part left to the
  splitter, then right, then below.

  As we use the standard Erlang list building mechanism, those parts will be in
  reverse order in the `remains` list. This is an implementation detail and the
  order of this list should not be relied upon.
  """

  def split(
        %{xa: rxa, ya: rya, xo: rxo, yo: ryo} = rect,
        %{xa: sxa, ya: sya, xo: sxo, yo: syo} = _splitter
      )
      when syo < rya
      when sya > ryo
      when sxo < rxa
      when sxa > rxo do
    # No overlap
    {[], [rect]}
  end

  def split(rect, splitter) do
    %{xa: sxa, ya: sya, xo: sxo, yo: syo} = splitter

    {rect, top} = cut_top(rect, sya)
    remains = top

    {rect, left} = cut_left(rect, sxa)
    remains = left ++ remains

    {rect, right} = cut_right(rect, sxo)
    remains = right ++ remains

    {rect, bottom} = cut_bottom(rect, syo)
    remains = bottom ++ remains

    {[rect], remains}
  end

  # Splitting the rectangle. In those functions we know that the rectangle does
  # overlap with the splitter, so for each cut (top, left, etc.) we want to
  # extract the part that is not covered, and we consider the rest covered and
  # to-be-cut later.

  # The split line is below the rectangle. The rectangle is returned as-is.
  defp cut_top(%{ya: ya, yo: yo} = rect, y) when y > ya do
    top = %{rect | ya: ya, yo: y - 1}
    keep = %{rect | ya: y, yo: yo}

    {keep, [top]}
  end

  # There is no top above the split line. If the split line is the top row of
  # the rectange (y == ya) then there is no top part too.
  defp cut_top(rect, _y) do
    {rect, []}
  end

  defp cut_left(%{xa: xa, xo: xo} = rect, x) when x > xa do
    left = %{rect | xa: xa, xo: x - 1}
    keep = %{rect | xa: x, xo: xo}

    {keep, [left]}
  end

  defp cut_left(rect, _x) do
    {rect, []}
  end

  defp cut_right(%{xa: xa, xo: xo} = rect, x) when x < xo do
    right = %{rect | xa: x + 1, xo: xo}
    keep = %{rect | xa: xa, xo: x}

    {keep, [right]}
  end

  defp cut_right(rect, _x) do
    {rect, []}
  end

  defp cut_bottom(%{ya: ya, yo: yo} = rect, y) when y < yo do
    bottom = %{rect | ya: y + 1, yo: yo}
    keep = %{rect | ya: ya, yo: y}

    {keep, [bottom]}
  end

  defp cut_bottom(rect, _y) do
    {rect, []}
  end
end
