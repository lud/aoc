defmodule AoC.MixProject do
  use Mix.Project

  @source_url "https://github.com/lud/aoc"
  @version "0.14.0"

  def project do
    [
      app: :aoc,
      version: @version,
      elixir: "~> 1.14",
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
      {:cli_mate, "~> 0.6", runtime: false},
      {:req, "~> 0.5"},
      {:benchee, "~> 1.2"},
      {:modkit, "~> 0.6.0"},
      {:jason, "> 1.0.0"},

      # DX
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp modkit do
    [
      mount: [
        {AoC, "lib/aoc"},
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
      formatters: ["html"]
    ]
  end

  defp dialyzer do
    [
      flags: [:unmatched_returns, :error_handling, :unknown, :extra_return],
      list_unused_filters: true,
      # plt_add_deps: :app_tree,
      plt_add_apps: [:mix],
      plt_local_path: "_build/plts"
    ]
  end

  defp versioning do
    [
      annotate: true,
      before_commit: [
        &update_readme/1,
        {:add, "README.md"},
        &gen_changelog/1,
        {:add, "CHANGELOG.md"}
      ]
    ]
  end

  def update_readme(vsn) do
    case System.cmd("mix", ["run", "tools/regen-readme.exs", vsn]) do
      {_, 0} -> :ok
      {out, _} -> {:error, out}
    end
  end

  defp gen_changelog(vsn) do
    case System.cmd("git", ["cliff", "--tag", vsn, "-o", "CHANGELOG.md"], stderr_to_stdout: true) do
      {_, 0} -> IO.puts("Updated CHANGELOG.md with #{vsn}")
      {out, _} -> {:error, "Could not update CHANGELOG.md:\n\n #{out}"}
    end
  end
end
