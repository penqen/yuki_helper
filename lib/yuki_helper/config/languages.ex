defmodule YukiHelper.Config.Languages do
  @moduledoc false

  alias YukiHelper.Config.Language
  
  defstruct primary: "elixir",
    "c++11": %Language{},
    elixir: %Language{},
    ruby: %Language{}

  @primaries [
    "c++11",
    "elixir",
    "ruby"
  ]

  @type t() :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec new(map() | any()) :: t()
  def new(%{} = config) do
    %__MODULE__{
      primary: config |> Map.get("primary") |> init_primary(),
      elixir: config |> Map.get("elixir") |> Language.new(),
      "c++11": config |> Map.get("c++11") |> Language.new(),
      ruby: config |> Map.get("ruby") |> Language.new()
    }
  end

  def new(_), do: new()

  defp init_primary(p) when p in @primaries, do: p
  defp init_primary(_), do: "elixir"
end