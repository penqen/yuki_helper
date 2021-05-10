defmodule YukiHelper.Config.Testcase do
  @moduledoc false
  defstruct directory: "testcase", prefix: nil, bundle: nil

  alias YukiHelper.Config

  @type t() :: %__MODULE__{}

  @doc """
  Expects that `bundle` is `nil` or positive integer >= 10.
  Otherwise it will be ignored.
  """
  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec new(map() | any()) :: t()
  def new(%{} = config) do
    testcase = Config.merge(%__MODULE__{}, %__MODULE__{
      directory: Map.get(config, "directory"),
      prefix: Map.get(config, "prefix"),
    })
    case Map.get(config, "bundle") do
      v when is_integer(v) and 10 <= v ->
        %{testcase | bundle: v}
      _ ->
        testcase
    end
  end

  def new(_), do: new()

  @spec problem_path(Config.t(), Config.no()) :: Path.t()
  def problem_path(config, no) do
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

  @spec bundle_directory(Config.t(), Config.no()) :: Path.t()
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

  @spec problem_directory(Config.t(), Config.no()) :: Path.t()
  def problem_directory(config, no) do
    case config.testcase.prefix do
      nil -> "#{no}"
      prefix -> "#{prefix}#{no}"
    end
  end
end