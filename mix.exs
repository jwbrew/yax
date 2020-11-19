defmodule Yax.MixProject do
  use Mix.Project

  def project do
    [
      app: :yax,
      source_url: "https://github.com/jwbrew/yax",
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        name: "Yax",
        description:
          "Cut out the middle man. Turn a URI into a scoped, preloaded, encoded response. Automagically.",
        organization: "jwbrew",
        links: %{"jbrew.co.uk" => "https://www.jbrew.co.uk"},
        licenses: ["GPL-3.0-only"]
      ]
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
      {:nimble_parsec, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
    ]
  end
end
