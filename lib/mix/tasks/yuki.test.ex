defmodule Mix.Tasks.Yuki.Test do
  @shortdoc "Tests all testcase"
  @moduledoc """
  Tests your source code for the specified problem.

      mix yuki.test NO [--problem-id]

  `--problem-id` option specifies that `NO` is the problem ID, not the problem number.

  This command has the following steps.

  1. downloads testcases for the specified problem if nessesary.
  2. finds the source code `lib/path/to/10.ex`
  3. finds the compiler `elixirc`
  4. executes the command `elixirc lib/path/to/10.ex`
  5. executes the command `elixir -e P10.main`
  6. prints result
  """
  use Mix.Task
  import YukiHelper
  alias YukiHelper.{Config, Download, Problem}
  alias YukiHelper.Exceptions.CompileError

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
      :help -> Mix.Tasks.Help.run(["yuki.test"])
      {:invalid_option, msg} ->  Mix.raise(msg)
      {:invalid_arguments, msg} -> Mix.raise(msg)
      {opts, [no]} -> run_test(no, opts)
    end
  end

  defp run_test(no, opts) do
    config = Config.load_all()
    Mix.shell().info("load configurations : [#{success("ok")}]")

    testcase_list = Download.get_testcases!(config, no, opts)

    testcase_list
    |> Download.download_tastcases?(config, no) 
    |> if do
      Mix.shell().info("download testcases : [skipped]")
    else
      problem_path = Path.expand(Problem.problem_root(config, no))
      paths = %{}
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

    compile_target = Problem.find_compile_target!(config, no)
    Mix.shell().info("compile target : #{compile_target}")

    case YukiHelper.Test.compile(compile_target) do
      {:error, %CompileError{}} ->
        Mix.shell().info("compile : [#{warning("CE")}]")
      {:ok, msg} ->
        Mix.shell().info("compile : [#{success("ok")}]")

        if 0 < String.length(msg) do
          Mix.shell().info(warning(msg))
        end

        Mix.shell.info("run testcases: #{length(testcase_list)} files")
        execute_cmd(config, no, testcase_list)
    end

    # clean up
    System.cmd("bash", ["-c", "rm Elixir.*"])
  end

  defp execute_cmd(config, no, testcase_list) do
    Enum.reduce(testcase_list, true, fn
      _testcase, false = next ->
        next
      testcase, true = next ->
        case YukiHelper.Test.run(config, no, testcase) do
          {_time, {"", 1}, _} ->
            Mix.shell().info("  #{testcase} : [#{warning("RE")}]")
            next && false
          {time, {_ans, 0}, _output} when 5_000 < time ->
            Mix.shell().info("  #{testcase} : [#{warning("TLE")}]")
            next
          {time, {ans, 0}, output} when ans != output ->
            Mix.shell().info("  #{testcase} : [#{warning("WA")}] / #{time} ms")
            next
          {time, {ans, 0}, output} when ans == output ->
            Mix.shell().info("  #{testcase} : [#{success("AC")}] / #{time} ms")
            next
        end
    end)
  end
end