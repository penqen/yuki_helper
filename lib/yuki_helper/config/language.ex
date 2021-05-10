defmodule YukiHelper.Config.Language do
  @moduledoc false

  defstruct source_directory: nil,
    path: nil,
    compiler_path: nil,
    prefix: nil

  @type t() :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{}
  
  @spec new(map() | any()) :: t()
  def new(%{} = config) do
    %__MODULE__{
      source_directory: config |> Map.get("source_directory") |> to_string_or_nil(),
      path: config |> Map.get("path") |> string_or_nil(),
      compiler_path: config |> Map.get("compiler_path") |> string_or_nil(),
      prefix: config |> Map.get("prefix") |> string_or_nil()
    }
  end

  def new(_), do: new()

  defp to_string_or_nil(v) when is_binary(v), do: v
  defp to_string_or_nil(v) when is_number(v), do: "#{v}"
  defp to_string_or_nil(_), do: nil

  defp string_or_nil(v) when is_binary(v), do: v
  defp string_or_nil(_), do: nil
end