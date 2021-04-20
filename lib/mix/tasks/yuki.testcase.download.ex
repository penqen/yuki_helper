defmodule Mix.Tasks.Yuki.Testcase.Download do
  @shortdoc "Downloads a list of testcases"
  @moduledoc """
  Downloads a list of the specified problem.

  If the specified file already exists, the download will be skipped.

      mix yuki.testcase.download NO [--problem-id]

  `--problem-id` option specifies that `NO` is the problem ID, not the problem number.

  Name of the download directory varies in depending on your configuration file.
  There are two main patterns in configuration example.

  Example 1: `prefix` option is `p`

      testcase/
        p10/        # `prefix` is `p`
          in/       # input files
            1.txt
            2.txt
          out/      # output files
            1.txt
            2.txt

  Example 2: `bundle` option is `100`

      testcase/
        100/
          p10/
            in/
            out/
        200/

  """
  use Mix.Task

  import YukiHelper
  alias YukiHelper.{Config, Problem}

  @arguments [:integer]
  @switches [problem_id: :boolean, version: :boolean]
  @version Mix.Project.config()[:version]
  @name Mix.Project.config()[:name]

  @requirements ["app.start"]
  @impl true
  def run(argv) do
    argv
    |> parse_options(@arguments, @switches)
    |> case do
      :version -> Mix.shell().info("#{@name} v#{@version}")
      :help -> Mix.Tasks.Help.run(["yuki.testcase.download"])
      {:invalid_option, msg} ->  Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
      {opts, [no]} -> download(no, opts)
    end
  end

  defp download(no, opts) do
    config = Config.load_all()
    problem_path = Path.expand(Problem.problem_root(config, no))
    paths = %{}
    |> Map.put(:in, Path.join(problem_path, "in"))
    |> Map.put(:out, Path.join(problem_path, "out"))

    if not File.exists?(problem_path) do
      :ok = File.mkdir_p(paths[:in])
      :ok = File.mkdir_p(paths[:out])
      Mix.shell().info("create directories\n  #{paths[:in]}\n  #{paths[:out]}")
    end

    testcase_list = YukiHelper.Download.get_testcases!(config, no, opts)

    testcase_list
    |> YukiHelper.Download.download_tastcases?(config, no)
    |> if do
      Mix.shell().info("testcases have already been downloaded")
    else
      Mix.shell().info("download testcases : #{length(testcase_list)} files")

      Enum.each(testcase_list, fn file ->
        [:in, :out]
        |> Enum.each(fn filetype ->
          path = Path.join(paths[filetype], file)
          data = YukiHelper.Download.get_testcase!(config, no, file, filetype, opts)
          :ok = File.write(path, data)
        end)
        Mix.shell().info("  #{file} : [#{success("ok")}]")
      end)
    end
  end
end