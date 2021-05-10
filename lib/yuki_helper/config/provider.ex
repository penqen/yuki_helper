defmodule YukiHelper.Config.Provider do
  @moduledoc false
  defstruct access_token: nil

  @type t() :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec new(map() | any()) :: t()
  def new(%{"access_token" => ""}), do: %__MODULE__{}
  def new(%{"access_token" => token}) when is_binary(token),
    do: %__MODULE__{access_token: token}
  def new(_), do: new()
end