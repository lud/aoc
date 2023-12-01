defmodule AoC.Input do
  defmodule FakeFile do
    defstruct content: ""
  end

  def as_file(content) when is_binary(content) do
    %FakeFile{content: content}
  end

  def read!(path) when is_binary(path) do
    File.read!(path)
  end

  def read!(%FakeFile{content: content}) do
    content
  end

  def read!(path) when is_binary(path) do
    File.read!(path)
  end

  def stream!(path, opts \\ []) do
    stream_file_lines(path, opts)
  end

  def stream_file_lines(path, opts \\ [])

  def stream_file_lines(%FakeFile{content: content}, opts) do
    content
    |> String.split("\n")
    |> apply_stream_opts(opts)
  end

  def stream_file_lines(path, opts) when is_binary(path) do
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

  def apply_stream_opt(stream, :trim, trim?) do
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

  def stream_to_integers(input) do
    Stream.map(input, &String.to_integer/1)
  end

  def list_of_integers(input) do
    Enum.map(input, &String.to_integer/1)
  end

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

  def resolve(year, day, suffix \\ nil)

  def resolve(year, day, suffix) do
    path = input_path(year, day, suffix)

    if File.regular?(path) do
      {:ok, path}
    else
      {:error, :enoent}
    end
  end

  def ensure_local(year, day, suffix \\ nil) do
    _path = input_path(year, day, suffix)

    case resolve(year, day, suffix) do
      {:ok, path} ->
        {:ok, path}

      {:error, :enoent} ->
        case suffix do
          nil ->
            with {:ok, content} <- AoC.API.fetch_input(year, day),
                 {:ok, wrote_path} <- write_input(year, day, content) do
              {:ok, wrote_path}
            end

          _ ->
            {:error, :enoent}
        end
    end
  end

  def input_path(year, day, suffix \\ nil)

  def input_path(year, day, nil) do
    Path.join(year_dir(year), "day-#{day}.inp")
  end

  def input_path(year, day, suffix) when is_binary(suffix) do
    Path.join(year_dir(year), "day-#{day}-#{suffix}.inp")
  end

  defp year_dir(year) when is_integer(year) do
    year_dir = Path.join([File.cwd!(), "priv", "input", Integer.to_string(year)])
    File.mkdir_p!(year_dir)
    year_dir
  end

  defp write_input(year, day, content) do
    path = input_path(year, day, nil)
    IO.puts("Writing input #{year}--#{day} to #{path}")
    File.write(path, content)
    {:ok, path}
  end
end
