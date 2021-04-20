defmodule YukiHelper.MixProject do
  use Mix.Project

  @source_url "https://github.com/penqen/yuki_helper"

  def project do
    [
      app: :yuki_helper,
      version: "0.1.0",
      elixir: "~> 1.11.4",
      description: "helper for yukicoder",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "YukiHelper",
      package: package(),
      source_url: @source_url,
      docs: [
        main: "YukiHelper",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :httpoison
      ]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:yaml_elixir, "~> 2.6"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24.1", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Tatsuya Hashimoto"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
