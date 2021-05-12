defmodule Mix.Tasks.Yuki.Testcase.List do
  @shortdoc "Prints a list of testcases"
  @moduledoc """
  Prints a list of testcases for the specified problem.

  From mix task:

      mix yuki.testcase.list NO [--problem-id]

  From escript:

      yuki testcase.list NO [--problem-id]

  # Option

  - `--problem-id`: if `true`, `NO` is the problem ID. If `false`, `NO` is the problem number.
  
  """
  use Mix.Task
  use YukiHelper.Docs

  import YukiHelper, only: [parse_options: 3]

  alias YukiHelper.{Config, Download}

  @arguments [:integer]
  @switches [problem_id: :boolean, version: :boolean]
  @version Mix.Project.config()[:version]
  @name Mix.Project.config()[:name]

  @impl true
  def run(argv) do
    {:ok, _} = Application.ensure_all_started(:yuki_helper)

    argv
    |> parse_options(@arguments, @switches)
    |> case do
      :version -> Mix.shell().info("#{@name} v#{@version}")
      :help -> Mix.Tasks.Help.run(["yuki.testcase.list"])
      {:invalid_option, msg} ->  Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
      {opts, [no]} -> show_testcase_list(no, opts)
    end
  end

  defp show_testcase_list(no, opts) do
    files = Config.load_all()
    |> Download.get_testcases!(no, opts)
    |> Enum.map(&("  #{&1}"))

    Mix.shell().info("Problem #{id_or_no(opts)} #{no}")
    Mix.shell().info("Testcases : #{length(files)} files") 
    Mix.shell().info(Enum.join(files, "\n")) 
  end

  defp id_or_no(opts) do
    if Keyword.get(opts, :problem_id), do: "ID", else: "No."
  end
end