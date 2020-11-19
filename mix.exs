defmodule Yax.MixProject do
  use Mix.Project

  def project do
    [
      app: :yax,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:bodyguard, "~> 2.4.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:nimble_parsec, "~> 1.0"}
    ]
  end
end
