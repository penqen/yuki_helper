defmodule Mix.Tasks.Yuki.Download do
  @moduledoc """
  指定された問題番号`No`のテストケースをダウンロードする。  
  同名のファイルが存在する場合は、スキップする。

      mix yuki.download --no `No`

  各問題のテストケースは、`testcase`ディレクトリに保存される。
  - `aggregation: null`の場合
  ```
   .
   └── `testcase`
       ├── `No`
       │   ├── in
       │   │   ├── 1.txt
       │   │   └── 2.txt
       │   └── out
       │      ├── 1.txt
       │      └── 2.txt
  ```

  - `aggregation: 100`の場合
  ```
  .
  └── `testcase`
      ├── 100
      │   ├── `No`
      │   │   ├── in
      │   │   │   ├── 1.txt
      │   │   │   └── 2.txt
      │   │   └── out
      │   │       ├── 1.txt
      │   │       └── 2.txt
      │   └── ***
      ├── 200
  ```

  """
  use Mix.Task

  import YukiHelper
  alias YukiHelper.{Config, Problem}

  @switches [no: :integer, force: :boolean]

  @shortdoc "Download testcase"
  def run(argv) do
    Mix.Task.run("app.start")
    argv
    |> parse_opts()
    |> case do
      {[no: no], []} ->
        download(no)
      {_opts, []} ->
        Mix.Tasks.Help.run(["yuki.download"])
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

  defp download(no) do
    config = Config.load!()

    problem_path = Path.expand(Problem.problem_root(config, no))
    paths = %{}
    |> Map.put(:in, Path.join(problem_path, "in"))
    |> Map.put(:out, Path.join(problem_path, "out"))

    if not File.exists?(problem_path) do
      :ok = File.mkdir_p(paths[:in])
      :ok = File.mkdir_p(paths[:out])
      IO.puts "create directories\n  #{paths[:in]}\n  #{paths[:out]}"
    end

    testcase_list = YukiHelper.Download.get_testcases!(config, no)

    testcase_list
    |> YukiHelper.Download.download_tastcases?(config, no)
    |> if do
      IO.puts "testcases have already been downloaded"
    else
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
  end
end