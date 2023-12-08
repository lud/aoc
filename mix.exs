defmodule AoC.MixProject do
  use Mix.Project

  @source_url "https://github.com/lud/aoc"
  @version "0.10.0"

  def project do
    [
      app: :aoc,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      cli: cli(),
      deps: deps(),
      docs: docs(),
      modkit: modkit(),
      package: package()
    ]
  end

  defp package do
    [
      description: "A small framework to solve Advent of Code problems in Elixir",
      licenses: ["MIT"],
      maintainers: ["Ludovic Demblans <ludovic@demblans.com>"],
      links: %{"GitHub" => @source_url}
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
      {:cli_mate, "~> 0.1", runtime: false},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4.5"},
      {:benchee, "~> 1.2"},

      # DX
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
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
      preferred_envs: ["aoc.test": :test]
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
end
