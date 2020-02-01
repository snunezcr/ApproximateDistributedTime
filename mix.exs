defmodule Adt.MixProject do
  use Mix.Project

  def project do
    [
      app: :adt,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger, :sqlite_ecto2, :ecto],
      extra_applications: [:logger],
      mod: {Adt.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sqlite_ecto2, "~> 2.2"},
      {:micro_timer, "~> 0.1.0"},
      {:enum_type, "~> 1.0.0"},
      {:statistex, "~> 1.0"}
    ]
  end
end
