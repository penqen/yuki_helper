defmodule YukiHelper.Config.Providers do
  @moduledoc false

  alias YukiHelper.{Config, Config.Provider}

  defstruct yukicoder: %Provider{}

  @type t() :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec new(map() | any()) :: t()
  def new(%{} = config) do
    %__MODULE__{
      yukicoder: config |> Map.get("yukicoder") |> Provider.new()
    }
  end

  def new(_), do: new()
end