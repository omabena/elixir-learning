defmodule BeliefStructure.MixProject do
  use Mix.Project

  def aliases do
    [
       ensure_consistency: ["test",  "credo --strict", "coveralls"]
    ]
  end

  def project do
    [
      app: :belief_structure,
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_deps: :transitive],
      aliases: aliases(),
      version: "0.1.0",
      elixir: "~> 1.10",
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:credo, "~> 0.8.8", only: [:dev], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:test], runtime: false}
    ]
  end
end
