defmodule YukiHelper.Languages.Cpp11 do
  @moduledoc false

  alias YukiHelper.Language
  alias YukiHelper.Exceptions.CompilerError

  @behaviour YukiHelper.Language

  def me(), do: :"c++11"

  def ext(), do: "cpp"

  def handle?(config, opts) do
    :"c++11" == Language.get(config, opts)
  end

  def compiler(config, _opts) do
    with compiler <- config.languages."c++11".compiler_path || "g++",
      nil <- System.find_executable(compiler) do
        {:error, %CompilerError{compiler: compiler}}
    else
      path ->
        {:ok, path}
    end
  end

  def compile(config, source, opts) do
    {:ok, compiler} = compiler(config, opts)
    System.cmd(
      compiler,
      ["-O2", "-lm", "-std=gnu++11", "-Wuninitialized", "-o", "a.out", source],
      [stderr_to_stdout: true]
    )
  end

  def run(_config, _no, _source, input_file, _opts) do
    :timer.tc(&System.cmd/3, [
      "bash", [
        "-c",
        "./a.out < #{input_file}"
      ],
      [stderr_to_stdout: true]
    ])
  end

  def clean_up do
    case System.cmd("bash", ["-c", "rm a.out"]) do
      {_, 0} ->
        :ok
      {_, 1} ->
        :error
    end
  end
end