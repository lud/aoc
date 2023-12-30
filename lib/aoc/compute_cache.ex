defmodule AoC.ComputeCache do
  defmacro __using__(opts) do
    quote bind_quoted: binding() do
      cache_vsn = Keyword.get(opts, :version, 0)

      def cached(name, discriminant, callback) when is_function(callback, 0) do
        AoC.ComputeCache.cached(__MODULE__, name, [unquote(cache_vsn), discriminant], callback)
      end
    end
  end

  def cached(module, name, discriminant, callback) when is_atom(module) do
    mod =
      case inspect(module) do
        ":" <> m -> m
        m -> m
      end

    dir = Path.join(System.tmp_dir!(), mod)

    id = :erlang.phash2(discriminant)
    file = "#{name}-#{id}.cache"

    path = Path.join(dir, file)

    if File.exists?(path) do
      IO.puts("Returning computation #{name} from cache")
      path |> File.read!() |> :erlang.binary_to_term()
    else
      result = callback.()
      IO.puts("Caching computation #{name}")
      File.mkdir_p!(dir)
      File.write!(path, :erlang.term_to_binary(result))
      result
    end
  end
end
