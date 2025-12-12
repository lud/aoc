defmodule AoC.API do
  @mix_version Mix.Project.get!().project() |> Keyword.fetch!(:version)
  def user_agent do
    "github.com/lud/aoc #{@mix_version}"
  end

  def fetch_input(year, day) do
    get_http(input_url(year, day))
  end

  defp input_url(year, day) do
    "https://adventofcode.com/#{year}/day/#{day}/input"
  end

  def headers do
    cookie = read_cookie!()

    [
      "user-agent": user_agent(),
      cookie: "session=#{cookie}"
    ]
  end

  defp get_http(url) do
    IO.puts("Fetching #{url}")

    case Req.request(method: :get, url: url, headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_status, status, body}}

      {:error, _} = err ->
        err
    end
  end

  def cookie_path do
    home = find_home_dir()
    Path.join(home, ".adventofcode.session")
  end

  defp find_home_dir do
    case :os.type() do
      {:unix, _} -> System.fetch_env!("HOME")
      {:win32, _} -> System.fetch_env!("USERPROFILE")
    end
  end

  defp read_cookie! do
    path = cookie_path()

    if !File.exists?(path) do
      raise "Missing session cookie file: #{path}"
    end

    path |> File.read!() |> String.trim()
  end
end
