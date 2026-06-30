defmodule AoC.MixProject do
  use Mix.Project

  @source_url "https://github.com/lud/aoc"
  @version "0.16.4"

  def project do
    [
      app: :aoc,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      cli: cli(),
      deps: deps(),
      docs: docs(),
      versioning: versioning(),
      modkit: modkit(),
      package: package(),
      dialyzer: dialyzer()
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      description: "A small framework to solve Advent of Code problems in Elixir",
      licenses: ["MIT"],
      maintainers: ["Ludovic Demblans <ludovic@demblans.com>"],
      links: %{
        "GitHub" => @source_url,
        "Change Log" => "https://github.com/lud/aoc/blob/main/CHANGELOG.md"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Lib
      {:cli_mate, "~> 0.8", runtime: false},
      {:req, "~> 0.5"},
      {:benchee, "~> 1.2"},
      {:modkit, "~> 0.9.0"},
      {:jason, "> 1.0.0"},

      # DX
      {:libdev, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:readmix, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp modkit do
    [
      mount: [
        {AoC, "lib/aoc"},
        {AoC.DocGen, "dev/doc_gen"},
        {Mix.Tasks, "lib/mix/tasks", flavor: :mix_task}
      ]
    ]
  end

  def cli do
    [
      preferred_envs: ["aoc.test": :test, dialyzer: :test]
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html", "markdown"]
    ]
  end

  defp dialyzer do
    [
      flags: [:unmatched_returns, :error_handling, :unknown, :extra_return],
      list_unused_filters: true,
      # plt_add_deps: :app_tree,
      plt_add_apps: [:mix, :cli_mate],
      plt_local_path: "_build/plts"
    ]
  end

  defp versioning do
    [
      annotate: true,
      before_commit: [
        &readmix/1,
        {:add, "README.md"},
        &gen_changelog/1,
        {:add, "CHANGELOG.md"}
      ]
    ]
  end

  def readmix(vsn) do
    rdmx = Readmix.new(vars: %{app_vsn: vsn})
    Readmix.update_file(rdmx, "README.md")
  end

  defp gen_changelog(vsn) do
    case System.cmd("git", ["cliff", "--tag", vsn, "-o", "CHANGELOG.md"], stderr_to_stdout: true) do
      {_, 0} -> IO.puts("Updated CHANGELOG.md with #{vsn}")
      {out, _} -> {:error, "Could not update CHANGELOG.md:\n\n #{out}"}
    end
  end
end
