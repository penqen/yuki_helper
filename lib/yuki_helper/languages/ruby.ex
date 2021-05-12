defmodule YukiHelper.Languages.Ruby do
  @moduledoc false

  alias YukiHelper.Language
  alias YukiHelper.Exceptions.CompilerError

  @behaviour YukiHelper.Language

  def me(), do: :ruby

  def ext(), do: "rb"

  def handle?(config, opts) do
    __MODULE__ == Language.get(config, opts)
  end

  def compiler(config, _opts) do
    with compiler <- config.languages.ruby.compiler_path || "ruby",
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
     ["--disable-gems", "-w", "-c", source],
     [stderr_to_stdout: true]
    )
  end

  def run(_config, _no, source, input_file, _opts) do
    :timer.tc(&System.cmd/3, [
      "bash", [
        "-c",
        "ruby --disable-gems #{source} < #{input_file}"
      ],
      [stderr_to_stdout: true]
    ])
  end

  def clean_up do
    :ok
  end
end