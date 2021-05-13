defmodule Mix.Tasks.Yuki.Test do
  @shortdoc "Tests all testcase"
  @moduledoc """
  Tests your source code for the specified problem.

  From mix task:

      mix yuki.test NO [--problem-id] [--lang LANG] [--source SOURCE] [--time-limit TIME_LIMIT] [--module MODULE]

  From escript:

      yuki test NO [--problem-id] [--lang LANG] [--source SOURCE] [--time-limit TIME_LIMIT] [--module MODULE]

  In order to test your source code, solves a path of the source code.
  If there is prefix configuration, decides its filename consisting prefix, problem number, and, extention.
  For example, if prefix, problem number, and, language is `p`, `10`, and, `elixir`,
  respectively, the filename is `p10.ex`.
  Finds its file from directories `src` and `lib` recursively.

  > Note: If there is not any testcase for the problem, first, downloads its testcases.

  ## Options

  - `--problem-id`: if `true`, `NO` is the problem ID. If `false`, `NO` is the problem number.

  - `--lang`: this option specifies language to use.
  See `mix help yuki.lang.list` or `yuki help lang.list` for a list of available language.
  Without `language.primary` in config file, default to `elixir`.

  - `--source`: this option specifies a  path of source code
  if source code is out of scope for auto search on `src` or `lib`.

  - `--time-limit`: this option redefines `TIME_LIMIT`.
  Default to 5000 ms.

  - `--module` : this option is only valid for `elixir` and specifies custom entry point `MODULE.main` on executing.

  """
  use Mix.Task
  use YukiHelper.Docs

  import YukiHelper

  alias YukiHelper.{
    Config,
    Download,
    Problem,
    Language
  }
  alias YukiHelper.Exceptions.CompileError

  @arguments [:integer]
  @switches [
    problem_id: :boolean,
    version: :boolean,
    source: :string,
    lang: :atom,
    time_limit: :integer
  ]
  @version Mix.Project.config()[:version]
  @name Mix.Project.config()[:name]

  @impl true
  def run(argv) do
    {:ok, _} = Application.ensure_all_started(:yuki_helper)

    argv
    |> parse_options(@arguments, @switches)
    |> case do
      :version -> Mix.shell().info("#{@name} v#{@version}")
      :help -> Mix.Tasks.Help.run(["yuki.test"])
      {:invalid_option, msg} -> Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
      {opts, [no]} -> run_test(no, opts)
    end
  end

  defp run_test(no, opts) do
    config = Config.load_all()

    {language, compiler} = Language.verify!(config, opts)
    Mix.shell().info("Language : #{language}")
    Mix.shell().info("Compiler : #{compiler}")

    src = Problem.source_file!(config, no, opts)
    Mix.shell().info("Source   : #{src}\n")

    testcase_list = Download.get_testcases!(config, no, opts)

    testcase_list
    |> Download.download_tastcases?(config, no)
    |> if do
      Mix.shell().info("download testcases : [skipped]")
    else
      problem_path = Path.expand(Problem.problem_path(config, no))

      paths =
        %{}
        |> Map.put(:in, Path.join(problem_path, "in"))
        |> Map.put(:out, Path.join(problem_path, "out"))

      if not File.exists?(problem_path) do
        :ok = File.mkdir_p(paths[:in])
        :ok = File.mkdir_p(paths[:out])
        Mix.shell().info("create directories\n  #{paths[:in]}\n  #{paths[:out]}")
      end

      Mix.shell().info("download testcases : #{length(testcase_list)} files")

      Enum.each(testcase_list, fn file ->
        [:in, :out]
        |> Enum.each(fn filetype ->
          path = Path.join(paths[filetype], file)
          data = YukiHelper.Download.get_testcase!(config, no, file, filetype)
          :ok = File.write(path, data)
        end)

        Mix.shell().info("  #{file} : [#{success("ok")}]")
      end)
    end

    Mix.shell().info("")

    case Language.compile(config, src, opts) do
      {:error, %CompileError{}} ->
        Mix.shell().info("compile : [#{warning("CE")}]")
      {:ok, msg} ->
        Mix.shell().info("compile : [#{success("ok")}]")
        if 0 < String.length(msg) do
          Mix.shell().info(warning(msg))
        end
        Mix.shell().info("run testcases: #{length(testcase_list)} files")
        execute_cmd(config, no, testcase_list, src, opts)
    end

    Language.clean_up(config, opts)
  end

  defp execute_cmd(config, no, testcase_list, source, opts) do
    Enum.reduce(testcase_list, true, fn
      _testcase, false = next ->
        next
      testcase, true = next ->
        case Language.run(config, no, testcase, source, opts) do
          :runtime_error ->
            Mix.shell().info("  #{testcase} : [#{warning("RE")}]")
            next && false
          :time_limit ->
            Mix.shell().info("  #{testcase} : [#{warning("TLE")}]")
            next
          {:wrong_answer, time} ->
            Mix.shell().info("  #{testcase} : [#{warning("WA")}] / #{time} ms")
            next
          {:accept, time} ->
            Mix.shell().info("  #{testcase} : [#{success("AC")}] / #{time} ms")
            next
        end
    end)
  end
end
