defmodule YukiHelper.Problem do
  @moduledoc """
  Provides a module to manage any problem.
  """
  alias YukiHelper.Config
  alias YukiHelper.Exceptions.BadTargetError

  @type no() :: pos_integer()

  @spec problem_root(Config.t(), no()) :: Path.t()
  def problem_root(config, no) do
    [
      testcase_directory(config),
      bundle_directory(config, no),
      problem_directory(config, no)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("/")
  end

  @spec testcase_directory(Config.t()) :: Path.t()
  def testcase_directory(config) do
    config.testcase.directory
  end

  @spec bundle_directory(Config.t(), no()) :: Path.t()
  def bundle_directory(config, no) do
    case config.testcase.bundle do
      nil -> ""
      bundle -> "#{find_bundle(bundle, no, 1)}"
    end
  end

  defp find_bundle(bundle, no, times) when bundle * times < no,
    do: find_bundle(bundle, no, times + 1)
  defp find_bundle(bundle, no, times) when no <= bundle * times,
    do: bundle * times

  @spec problem_directory(Config.t(), no()) :: Path.t()
  def problem_directory(config, no) do
    case config.testcase.prefix do
      nil -> "#{no}"
      prefix -> "#{prefix}#{no}"
    end
  end

  @spec find_compile_target(Config.t(), no()) :: {:ok, String.t()} | {:error, term()}
  def find_compile_target(config, no) do
    prefix = case config.testcase.prefix do
      nil -> ""
      v -> v
    end

    case Path.wildcard("lib/**/#{prefix}#{no}.ex") do
      [] ->
        {:error, %BadTargetError{target: "#{prefix}#{no}.ex"}}
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