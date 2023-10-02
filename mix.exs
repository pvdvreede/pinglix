defmodule Pinglix.Mixfile do
  use Mix.Project

  @source_url "https://github.com/pvdvreede/pinglix"
  @version "1.1.4"

  def project do
    [
      app: :pinglix,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp package do
    [
      description:
        "Plug compatible health check system in Elixir based " <>
          "on https://github.com/jbarnette/pinglish.",
      contributors: ["Paul Van de Vreede"],
      maintainers: ["Paul Van de Vreede"],
      licenses: ["MIT License"],
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:timex, "~> 3.0"},
      {:poison, "~> 5.0"},
      {:plug, "~> 1.0"}
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
      formatters: ["html"]
    ]
  end
end
