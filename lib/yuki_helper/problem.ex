defmodule YukiHelper.Problem do
  @moduledoc """
  問題番号`no`に関する`Path`関係を扱うモジュールを提供する。
  """
  alias YukiHelper.Config
  alias YukiHelper.Exceptions.CompileTargetNotFound

  @type no() :: pos_integer()

  @doc """
  問題番号`no`のテストケースのディレクトリルートを返す。
  """
  @spec problem_root(Config.t(), no()) :: Path.t()
  def problem_root(config, no) do
    [
      testcase_directory(config),
      aggregation_directory(config, no),
      problem_directory(config, no)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("/")
  end

  @doc """
  テストケースのディレクトリ名を返す。
  """
  @spec testcase_directory(Config.t()) :: Path.t()
  def testcase_directory(config) do
    Config.get(config, [:testcase, :directory])
  end

  @doc """
  アグリゲーションディレクトリ名を返す。
  """
  @spec aggregation_directory(Config.t(), no()) :: Path.t()
  def aggregation_directory(config, no) do
    case Config.get(config, [:testcase, :aggregation]) do
      nil -> ""
      aggr -> "#{find_aggregation(aggr, no, 1)}"
    end
  end

  defp find_aggregation(aggr, no, times) when aggr * times < no,
    do: find_aggregation(aggr, no, times + 1)
  defp find_aggregation(aggr, no, times) when no <= aggr * times,
    do: aggr * times

  @doc """
  問題番号`no`のディレクトリ名を返す。
  """
  @spec problem_directory(Config.t(), no()) :: Path.t()
  def problem_directory(config, no) do
    config
    |> Config.get([:testcase, :prefix])
    |> case do
      nil -> "#{no}"
      prefix -> "#{prefix}#{no}"
    end
  end

  @spec find_compile_target(Config.t(), no()) :: {:ok, String.t()} | {:error, term()}
  def find_compile_target(config, no) do
    prefix = config
    |> Config.get([:testcase, :prefix]) 
    |> case do
      nil -> ""
      v -> v
    end

    case Path.wildcard("lib/**/#{prefix}#{no}.ex") do
      [] ->
        {:error, %CompileTargetNotFound{}}
      [file | _] ->
        {:ok, file}
    end
  end

  @spec find_compile_target!(Config.t(), no()) :: String.t()
  def find_compile_target!(config, no) do
    case find_compile_target(config, no) do
      {:ok, file} -> file
      {:error, err} -> raise err
    end
  end

  @spec get_module_name(Config.t(), no()) :: String.t()
  def get_module_name(config, no) do
    config
    |> problem_directory(no)
    |> String.capitalize()
  end
end