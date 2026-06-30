defmodule AoC.Input do
  @moduledoc ~S"""
  Reading and parsing helpers for puzzle inputs.

  Solution modules receive their input through `parse/2`, called with either the
  path of a downloaded input file or an `AoC.Input.TestInput` struct holding
  inline text. The helpers here accept both, so the same `parse/2` runs against
  the real input and against an example pasted into a test.

      def parse(input, _part) do
        input
        |> AoC.Input.stream!(trim: true)
        |> AoC.Input.list_of_integers()
      end

  Wrap inline text with `as_file/1` to send it through that same code in a test:

      "1\n2\n3"
      |> AoC.Input.as_file()
      |> MyApp.Solutions.Y23.Day01.parse(:part_one)
  """
  alias AoC.CodeGen

  defmodule TestInput do
    @moduledoc """
    Inline puzzle input held in memory.

    Built with `AoC.Input.as_file/1` and accepted everywhere a solution reads its
    input, so an example pasted into a test runs through the same `parse/2` code
    as the downloaded input file.
    """
    defstruct content: ""
  end

  @doc ~S"""
  Wraps inline text as input usable by a solution's `parse/2` function.

  Use this in tests to pass an example puzzle through the same code that reads
  the real input file. The returned `AoC.Input.TestInput` struct is accepted by
  `read!/1` and `stream!/2`.

      iex> "hello" |> AoC.Input.as_file() |> AoC.Input.read!()
      "hello"
  """
  def as_file(content) when is_binary(content) do
    %TestInput{content: content}
  end

  @doc """
  Returns the whole content of `input` as a string.

  `input` is either the path of an input file or an `AoC.Input.TestInput` struct
  built with `as_file/1`. For a path this mirrors `File.read!/1` and raises when
  the file cannot be read.
  """
  def read!(path) when is_binary(path) do
    File.read!(path)
  end

  def read!(%TestInput{content: content}) do
    content
  end

  @doc ~S"""
  Streams the lines of `input`, like `File.stream!/2` over the input file.

  `input` is either an input file path or an `AoC.Input.TestInput` struct from
  `as_file/1`. Each element is one line.

      iex> "1\n\n2\n" |> AoC.Input.as_file() |> AoC.Input.stream!(trim: true) |> Enum.to_list()
      ["1", "2"]

  ### Options

    * `:trim` - when `true`, trims whitespace from each line and drops the empty
      lines. Defaults to `false`.

  """
  def stream!(path, opts \\ []) do
    stream_file_lines(path, opts)
  end

  defp stream_file_lines(%TestInput{content: content}, opts) do
    content
    |> String.split("\n")
    |> apply_stream_opts(opts)
  end

  defp stream_file_lines(path, opts) when is_binary(path) do
    path
    |> File.stream!()
    |> apply_stream_opts(opts)
  end

  defp apply_stream_opts(stream, [{k, v} | opts]) do
    stream
    |> apply_stream_opt(k, v)
    |> apply_stream_opts(opts)
  end

  defp apply_stream_opts(stream, []) do
    stream
  end

  defp apply_stream_opt(stream, :trim, trim?) do
    if trim? do
      stream
      |> Stream.map(&String.trim/1)
      |> Stream.filter(fn
        "" -> false
        _ -> true
      end)
    else
      stream
    end
  end

  @doc ~S"""
  Returns a stream that parses each element of `input` as an integer.

  Lazily maps `String.to_integer/1` over `input`, which is typically a stream of
  lines coming from `stream!/2`.

      iex> ["1", "2", "3"] |> AoC.Input.stream_to_integers() |> Enum.to_list()
      [1, 2, 3]
  """
  def stream_to_integers(input) do
    Stream.map(input, &String.to_integer/1)
  end

  @doc ~S"""
  Returns the elements of `input` parsed as a list of integers.

  Eager counterpart of `stream_to_integers/1`, returning a list instead of a
  stream.

      iex> AoC.Input.list_of_integers(["1", "2", "3"])
      [1, 2, 3]
  """
  def list_of_integers(input) do
    Enum.map(input, &String.to_integer/1)
  end

  @doc ~S"""
  Pairs each element of `stream` with its index, index first.

  Like `Stream.with_index/2`, but each element becomes `{index, value}` instead
  of `{value, index}`. The index starts at `offset`, which defaults to `0`.

      iex> ["a", "b"] |> AoC.Input.with_index_first() |> Enum.to_list()
      [{0, "a"}, {1, "b"}]
  """
  def with_index_first(stream, offset \\ 0) do
    stream
    |> Stream.with_index(offset)
    |> Stream.map(fn {v, i} -> {i, v} end)
  end

  # ---------------------------------------------------------------------------
  #
  # Local input files management
  #
  # ---------------------------------------------------------------------------

  @doc """
  Returns the local path of a stored input file for `year` and `day`.

  The optional `suffix` selects an alternate input file, which is handy for
  example inputs saved next to the real one. With no suffix the path points to
  the downloaded puzzle input.

  Returns `{:ok, path}` when the file exists, or `{:error, :enoent}` otherwise.
  This function never downloads anything.

      # priv/input/2023/day-01-example.inp
      {:ok, path} = AoC.Input.resolve(2023, 1, "example")
  """
  def resolve(year, day, suffix \\ nil)

  def resolve(year, day, suffix) do
    path = input_path(year, day, suffix)

    if File.regular?(path) do
      {:ok, path}
    else
      {:error, :enoent}
    end
  end

  @doc """
  Returns the local path of the puzzle input for `year` and `day`, fetching it
  when needed.

  When the file is already present its path is returned. When it is missing and
  no `suffix` is given, the input is downloaded from the Advent of Code website
  and written under `priv/input`. A missing file with a `suffix` is not
  downloaded, since alternate inputs only exist locally.

  Returns `{:ok, path}` on success, `{:error, :enoent}` for a missing alternate
  input, or another `{:error, reason}` when the download fails.
  """
  def ensure_local(year, day, suffix \\ nil) do
    _path = input_path(year, day, suffix)

    case resolve(year, day, suffix) do
      {:ok, path} ->
        {:ok, path}

      {:error, :enoent} ->
        case suffix do
          nil ->
            download_input(year, day)

          _ ->
            {:error, :enoent}
        end
    end
  end

  defp download_input(year, day) do
    with :ok <- ensure_gitignore(),
         {:ok, content} <- AoC.API.fetch_input(year, day) do
      write_input(year, day, content)
    end
  end

  defp input_path(year, day, nil) do
    day_str = CodeGen.pad_day(day)
    Path.join(year_dir(year), "day-#{day_str}.inp")
  end

  defp input_path(year, day, suffix) when is_binary(suffix) do
    day_str = CodeGen.pad_day(day)
    Path.join(year_dir(year), "day-#{day_str}-#{suffix}.inp")
  end

  defp input_root_path do
    Path.join([File.cwd!(), "priv", "input"])
  end

  defp year_dir(year) when is_integer(year) do
    year_dir = Path.join(input_root_path(), Integer.to_string(year))
    File.mkdir_p!(year_dir)
    year_dir
  end

  defp write_input(year, day, content) do
    path = input_path(year, day, nil)
    IO.puts("Writing input #{year}--#{day} to #{path}")
    File.write!(path, content)
    {:ok, path}
  end

  defp ensure_gitignore do
    path = Path.join(input_root_path(), ".gitignore")

    if File.regular?(path) do
      :ok
    else
      File.write(path, """
      *
      !.gitignore
      """)
    end
  end
end
