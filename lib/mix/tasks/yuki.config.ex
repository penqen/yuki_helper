defmodule Mix.Tasks.Yuki.Config do
  @shortdoc "Shows current configuration"
  @moduledoc """
  Prints current configuration.

      mix yuki.config

  """
  use Mix.Task

  import YukiHelper, only: [parse_options: 3]

  alias YukiHelper.Config

  @arguments []
  @switches [version: :boolean]
  @version Mix.Project.config()[:version]
  @name Mix.Project.config()[:name]

  @impl true
  def run(argv) do
    argv
    |> parse_options(@arguments, @switches)
    |> case do
      :version -> Mix.shell().info("#{@name} v#{@version}")
      {[], []} -> config()
      {:invalid_option, msg} ->  Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
    end
  end

  defp config() do
    Mix.shell().info("Show current configuration")

    Config.load_all()
    |> to_string()
    |> Mix.shell().info()
  end
end