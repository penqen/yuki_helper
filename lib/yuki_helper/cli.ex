defmodule YukiHelper.CLI do
  @moduledoc """
  Provides the following commands:

  ```console
  yuki help
  yuki config
  yuki lang.list
  yuki test
  yuki testcase.list
  yuki testcase.download
  ```

  Usage of each command refer to help command.

  ```console
  yuki help COMMAND
  ```

  """

  @commands [
    "config",
    "lang.list",
    "test",
    "testcase.list",
    "testcase.download"
  ]

  @version Mix.Project.config()[:version]
  @name Mix.Project.config()[:name]

  def main([]), do: main(["help"])

  def main(["--version"]) do
    IO.puts("#{@name} v#{@version}")
  end

  def main(["help" = command]) do
    opts = Application.get_env(:mix, :colors)
    opts = [width: 80, enabled: IO.ANSI.enabled?()] ++ opts
    print_doc(command, @moduledoc, opts)
  end

  def main(["help", command]) when command in @commands do
    doc = module(command).doc()
    opts = Application.get_env(:mix, :colors)
    opts = [width: 80, enabled: IO.ANSI.enabled?()] ++ opts
    print_doc(command, doc, opts)
  end

  def main([command | args]) when command in @commands do
    Mix.Task.run("yuki.#{command}", args)
  end

  def main(args) do
    opts = Application.get_env(:mix, :colors)
    opts = [width: 80, enabled: IO.ANSI.enabled?()] ++ opts

    """
    `#{Enum.join(args, " ")}` is not supported command.
    Please refer to `help` command.
    """
    |> IO.ANSI.Docs.print("text/markdown", opts)
  end

  defp print_doc(command, doc, opts) do
    IO.ANSI.Docs.print_headings(["yuki #{command}"], opts)
    IO.ANSI.Docs.print(doc, "text/markdown", opts)
  end

  defp module(command)
  defp module("config"), do: Mix.Tasks.Yuki.Config
  defp module("lang.list"), do: Mix.Tasks.Yuki.Lang.List
  defp module("test"), do: Mix.Tasks.Yuki.Test
  defp module("testcase.list"), do: Mix.Tasks.Yuki.Testcase.List
  defp module("testcase.download"), do: Mix.Tasks.Yuki.Testcase.Download
end