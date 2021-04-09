defmodule YukiHelper.Test do
  @moduledoc """
  対象ファイルのビルド、及びそのファイルの実行、その結果の表示を行う。
  """
  alias YukiHelper.{Config, Problem}
  alias YukiHelper.Exceptions.{CompilerNotFound, CompileFailed}

  @spec compile(Path.t()) :: {:ok, String.t()} | {:error, term()}
  def compile(file) do
    with path when not is_nil(path) <- System.find_executable("elixirc"),
      {msg, 0} <- System.cmd("elixirc", [file], stderr_to_stdout: true) do
        {:ok, msg}
    else
      nil ->
        raise %CompilerNotFound{message: "\"elixirc\" is not found"}
      {_msg, 1} ->
        {:error, %CompileFailed{message: "could not compile `#{file}`"}}
    end
  end

  @spec run(Config.t(), Problem.no(), String.t()) :: {non_neg_integer(), {any(), 1 | 0}, String.t()}
  def run(config, no, testcase) do
    module = Problem.get_module_name(config, no)
    root = Problem.problem_root(config, no)
    input_file = "#{root}/in/#{testcase}"
    {output, 0} = System.cmd("cat", ["#{root}/out/#{testcase}"])

    {time, ans} = :timer.tc(&System.cmd/3, [
      "bash", [
        "-c",
        "elixir -e #{module}.main < #{input_file}"
      ],
      [stderr_to_stdout: true]
    ])

    {time / 1_000, ans, output}
  end
end