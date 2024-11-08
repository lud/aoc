defmodule AoC.MixProject do
  use Mix.Project

  @source_url "https://github.com/lud/aoc"
  @version "0.11.5"

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
      package: package()
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
      # {:cli_mate, "~> 0.2", runtime: false},
      {:cli_mate, path: "../cli_mate", runtime: false},
      {:req, "~> 0.5"},
      {:benchee, "~> 1.2"},

      # DX
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
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

  defp update_readme(vsn) do
    version = Version.parse!(vsn)
    readme_vsn = "#{version.major}.#{version.minor}"
    readme = File.read!("README.md")
    re = ~r/:aoc, "~> \d+\.\d+"/
    readme = String.replace(readme, re, ":aoc, \"~> #{readme_vsn}\"")
    File.write!("README.md", readme)
    :ok
  end

  defp gen_changelog(vsn) do
    case System.cmd("git", ["cliff", "--tag", vsn, "-o", "CHANGELOG.md"], stderr_to_stdout: true) do
      {_, 0} -> IO.puts("Updated CHANGELOG.md with #{vsn}")
      {out, _} -> {:error, "Could not update CHANGELOG.md:\n\n #{out}"}
    end
  end
end
