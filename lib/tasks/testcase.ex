defmodule Mix.Tasks.Yuki.Testcase do
  @moduledoc """
  問題番号`No`のテストケース一覧を表示する。

      mix yuki.testcase --no `No`

  """
  use Mix.Task

  alias YukiHelper.{Config, Download}

  @switches [no: :integer]

  @shortdoc "List testcase"
  def run(argv) do
    Mix.Task.run("app.start")
    argv
    |> parse_opts()
    |> case do
      {[no: no], []} ->
        show_testcase_list(no)
      {_opts, []} ->
        Mix.Tasks.Help.run(["yuki.testcase"])
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

  defp show_testcase_list(no) do
    config = Config.load!()

    files = config
    |> Download.get_testcases!(no)
    |> Enum.map(&("  #{&1}"))

    ["problem no.#{no} / testcase : #{length(files)} files" | files] 
    |> Enum.join("\n")
    |> IO.puts 
  end
end