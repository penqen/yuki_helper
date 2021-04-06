defmodule Mix.Tasks.Yuki.Download do
  use Mix.Task
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

  import YukiHelper
  alias YukiHelper.{Config, Api.Yukicoder}

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
    config = Config.load()
    headers = Config.headers(config)
    options = Config.options(config)

    problem_path = Path.expand(problem_path(config, no))
    in_path = Path.join(problem_path, "in")
    out_path = Path.join(problem_path, "out")

    if not File.exists?(problem_path) do
      :ok = File.mkdir_p(in_path)
      :ok = File.mkdir_p(out_path)
      IO.puts "create directories\n  #{in_path}\n  #{out_path}"
    end

    download_list = "/problems/no/#{no}/file/in"
    |> Yukicoder.get!(headers, options)
    |> Map.get(:body)

    IO.puts "download testcases"
    download_list
    |> Enum.each(fn file ->
      in_file_path = Path.join(in_path, file)
      out_file_path = Path.join(out_path, file)

      IO.write "  #{file} : "

      if File.exists?(in_file_path) && File.exists?(out_file_path) do
        IO.puts "[" <> warning("already exists") <> "]"
      else
        data = "/problems/no/#{no}/file/in/#{file}"
        |> Yukicoder.get!(headers, options)
        |> Map.get(:body)
        :ok = File.write(in_file_path, "#{data}")

        data = "/problems/no/#{no}/file/out/#{file}"
        |> Yukicoder.get!(headers, options)
        |> Map.get(:body)
        :ok = File.write(out_file_path, "#{data}")

        IO.puts "[" <> success("ok") <> "]"
      end
    end)
  end

  defp problem_path(config, no) do
    testcase_dir(config) <> aggr_dir(config, no) <> prefix_dir(config, no)
  end

  defp testcase_dir(config), do: config[:testcase][:directory]
  defp aggr_dir(config, n) do
    aggr = config[:testcase][:aggregation]
    if aggr, do: "/#{aggregation(aggr, n, 1)}", else: ""
  end
  defp prefix_dir(config, no) do
    prefix = config[:testcase][:prefix]
    (if prefix, do: "/#{prefix}", else: "/") <> "#{no}"
  end
  defp aggregation(aggr, n, times) when aggr * times < n, do: aggregation(aggr, n, times + 1)
  defp aggregation(aggr, n, times) when n <= aggr * times, do: aggr * times
end