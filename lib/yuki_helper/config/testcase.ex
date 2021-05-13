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
end