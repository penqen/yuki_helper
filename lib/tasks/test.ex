defmodule Mix.Tasks.Yuki.Test do
  @moduledoc """
  指定された問題番号`No`のテストケースを実行する。
  テストケースがダウンロードされていない場合は、先にダウンロードを実行する。

      mix yuki.test --no `No`

  """
  use Mix.Task
  import YukiHelper
  alias YukiHelper.{Config, Download, Problem}
  alias YukiHelper.Test, as: TestHelper

  @switches [no: :integer, module: :binary]

  @shortdoc "Test all testcase"
  def run(argv) do
    Mix.Task.run("app.start")
    argv
    |> parse_opts()
    |> case do
      {[no: no], []} ->
        test(no) 
      {_opts, []} ->
        Mix.Tasks.Help.run(["yuki.test"])
      {_opts, [opt]} ->
        Mix.raise "Invalid option: #{opt}"
    end
  end

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: @switches) do
      {opts, argv, []} ->
        {opts, argv}
      {_opts, _argv, [switch | _]} ->
        Mix.raise "Invalid option: " <> (fn
          {name, nil} -> name
          {name, val} -> name <> "=" <> val
        end).(switch)
    end
  end

  defp test(no) do
    config = Config.load!()
    IO.puts "load configurations : [#{success("ok")}]"

    testcase_list = Download.get_testcases!(config, no)

    testcase_list
    |> Download.download_tastcases?(config, no) 
    |> if do
      IO.puts "download testcases : [skipped]"
    else
      problem_path = Path.expand(Problem.problem_root(config, no))
      paths = %{}
      |> Map.put(:in, Path.join(problem_path, "in"))
      |> Map.put(:out, Path.join(problem_path, "out"))

      if not File.exists?(problem_path) do
        :ok = File.mkdir_p(paths[:in])
        :ok = File.mkdir_p(paths[:out])
        IO.puts "create directories\n  #{paths[:in]}\n  #{paths[:out]}"
      end

      IO.puts "download testcases : #{length(testcase_list)} files"
      Enum.each(testcase_list, fn file ->
        IO.write "  #{file} : "
        [:in, :out]
        |> Enum.each(fn filetype ->
          path = Path.join(paths[filetype], file)
          data = YukiHelper.Download.get_testcase!(config, no, file, filetype)
          :ok = File.write(path, data)
        end)
        IO.puts success("ok")
      end)
    end

    IO.write "compile target : "
    compile_target = Problem.find_compile_target!(config, no)
    IO.puts "#{compile_target}"

    IO.write "compile : "
    case TestHelper.compile(compile_target) do
      {:error, %CompileError{}} ->
        IO.puts warning("CE")
      {:ok, msg} ->
        IO.puts "[#{success("ok")}]"
        if msg != "", do: IO.write(warning(msg))
        IO.puts "run testcases: #{length(testcase_list)} files"
        Enum.reduce(testcase_list, true, fn
          _testcase, false = next ->
            next
          testcase, true = next ->
            IO.write("  #{testcase} : ")
            case TestHelper.run(config, no, testcase) do
              {_time, {"", 1}, _} ->
                IO.puts "[#{warning("RE")}]"
                next && false
              {time, {_ans, 0}, _output} when 5_000 < time ->
                IO.puts "[#{warning("TLE")}]"
                next
              {time, {ans, 0}, output} when ans != output ->
                IO.puts "[#{warning("WA")}] / #{time} ms"
                next
              {time, {ans, 0}, output} when ans == output ->
                IO.puts "[#{success("AC")}] / #{time} ms"
                next
            end
        end)
    end

    # clean up
    :os.cmd(:"rm Elixir.*")
  end
end