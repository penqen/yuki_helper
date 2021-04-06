defmodule Mix.Tasks.Yuki.Config do
  use Mix.Task

  alias YukiHelper.Config

  @shortdoc "Show configurations of yuki helper"
  def run(_) do
    Mix.Task.run("app.start")
    IO.puts "show configurations"
    Config.show_status(Config.load())
  end
end