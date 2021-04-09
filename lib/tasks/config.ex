defmodule Mix.Tasks.Yuki.Config do
  @moduledoc """
  設定ファイルを確認する。

      mix yuki.config

  """
  use Mix.Task

  alias YukiHelper.Config

  @switches []

  @shortdoc "Show configurations of yuki helper"
  def run(argv) do
    Mix.Task.run("app.start")
    argv
    |> parse_opts()
    |> case do
      {[], []} ->
        config()
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

  defp config() do
    IO.puts "show configurations"
    Config.show_status(Config.load_without_validation() )
  end
end