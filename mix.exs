defmodule Pinglix.Mixfile do
  use Mix.Project

  def project do
    [app: :pinglix,
     description: description,
     package: package,
     version:  "1.1.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    "Plug compatible health check system in Elixir based on https://github.com/jbarnette/pinglish."
  end

  defp package do
    [
      contributors: ["Paul Van de Vreede"],
      links: %{"Github" => "https://github.com/pvdvreede/pinglix"},
      licenses: ["MIT License"],
      files: ["lib", "mix.exs", "README.md", "LICENSE"]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:timex, "~> 3.0"},
      {:poison, "~> 3.1.0"},
      {:plug, "~> 1.0"}]
  end
end
