defmodule YukiHelper.Languages.Elixir do
  @moduledoc false

  alias YukiHelper.{Config, Language}
  alias YukiHelper.Exceptions.CompilerError

  @behaviour YukiHelper.Language

  def module_name(config, no, opts) do
    name = Keyword.get(opts, :module) || Config.Testcase.problem_directory(config, no)
    String.capitalize(name)
  end

  def me(), do: :elixir

  def ext(), do: "ex"

  def handle?(config, opts) do
    __MODULE__ == Language.get(config, opts)
  end

  def compiler(config, _opts) do
    with compiler <- config.languages.elixir.compiler_path || "elixirc",
      nil <- System.find_executable(compiler) do
        {:error, %CompilerError{compiler: compiler}}
    else
      path ->
        {:ok, path}
    end
  end

  def compile(config, source, opts) do
    {:ok, compiler} = compiler(config, opts)
    System.cmd(compiler, [source], [stderr_to_stdout: true])
  end

  def run(config, no, _source, input_file, opts) do
    module = module_name(config, no, opts)
    :timer.tc(&System.cmd/3, [
      "bash", [
        "-c",
        "elixir -e #{module}.main < #{input_file}"
      ],
      [stderr_to_stdout: true]
    ])
  end

  def clean_up do
    case System.cmd("bash", ["-c", "rm Elixir.*"]) do
      {_, 0} ->
        :ok
      {_, 1} ->
        :error
    end
  end
end