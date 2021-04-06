defmodule YukiHelper.MixProject do
  use Mix.Project

  def project do
    [
      app: :yuki_helper,
      version: "0.0.1",
      elixir: "~> 1.11.4",
      description: "yukicoder helper",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :httpoison
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:yaml_elixir, "~> 2.6"},
      {:ex_doc, "~> 0.24.1", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
