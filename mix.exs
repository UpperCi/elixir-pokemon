defmodule Pkmn.MixProject do
  use Mix.Project

  def project do
    [
      app: :pkmn,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript_config()
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
      {:httpoison, "~> 1.0.0"},
      {:jason, "~> 1.4.0"}
    ]
  end

  defp escript_config do
    [
      main_module: Pkmn.CLI
    ]
  end
end
