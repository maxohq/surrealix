defmodule Surrealix.MixProject do
  use Mix.Project
  @source_url "https://github.com/maxohq/surrealix"
  @version "0.1.6"

  def project do
    [
      app: :surrealix,
      version: @version,
      source_url: @source_url,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      test_paths: ["lib"],
      test_pattern: "*_test.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :wx, :observer],
      mod: {Surrealix.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:websockex, "~> 0.4"},
      {:telemetry, "~> 1.2"},
      {:maxo_test_iex, "~> 0.1", only: [:test]},
      {:mneme, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.30", only: [:dev]}
    ]
  end

  defp description() do
    "Lightweight, correct and up-to-date Elixir SDK for SurrealDB."
  end

  defp package() do
    [
      name: "surrealix",
      files: ~w(lib .formatter.exs mix.exs README* CHANGELOG* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md"
      }
    ]
  end
end
