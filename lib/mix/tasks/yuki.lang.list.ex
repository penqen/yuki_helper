defmodule Mix.Tasks.Yuki.Lang.List do
  @shortdoc "Prints a list of supported language"
  @moduledoc """
  Prints a list of supported language.

  From mix task:

      mix yuki.lang.list

  From escript:

      yuki lang.list

  """
  use Mix.Task
  use YukiHelper.Docs

  import YukiHelper, only: [parse_options: 3]

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
      {[], []} -> lang()
      {:invalid_option, msg} ->  Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
    end
  end

  defp lang() do
    Mix.shell.info("The available languages are:")
    YukiHelper.Language.list()
    |> Enum.map(&("  #{&1}"))
    |> Enum.join("\n")
    |> Mix.shell.info()
  end
end