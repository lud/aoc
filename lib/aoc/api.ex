defmodule AoC.API do
  require AoC.CLI

  def fetch_input(year, day) do
    get_http(input_url(year, day))
  end

  defp input_url(year, day) do
    "https://adventofcode.com/#{year}/day/#{day}/input"
  end

  defp get_http(url) do
    IO.puts("Fetching #{url}")

    cookie = read_cookie!()

    headers = [
      "user-agent": "github.com/lud/aoc",
      cookie: "session=#{cookie}"
    ]

    case Req.request(method: :get, url: url, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_status, status, body}}

      {:error, _} = err ->
        err
    end
  end

  defp read_cookie! do
    home = System.fetch_env!("HOME")
    path = Path.join(home, ".adventofcode.session")

    if !File.exists?(path) do
      raise "Missing session cookie file: #{path}"
    end

    path |> File.read!() |> String.trim()
  end
end
