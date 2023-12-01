defmodule AoC.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      cli: cli(),
      modkit: modkit()
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
      {:req, "~> 0.3.3"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.6", only: [:dev], runtime: false},
      {:cli_mate, "~> 0.1", runtime: false}
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
end
