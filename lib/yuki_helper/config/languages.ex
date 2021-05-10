defmodule YukiHelper.Config.Languages do
  @moduledoc false

  alias YukiHelper.{Config, Config.Language}
  
  defstruct primary: "elixir",
    "c++11": %Language{},
    elixir: %Language{},
    ruby: %Language{}

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

  defp init_primary(nil), do: "elixir"
  defp init_primary(v), do: v

  defp find_module(_modules, nil), do: nil
  defp find_module(modules, lang) do
    Enum.find(modules, fn module ->
      "#{module.me()}" == "#{lang}"
    end)
  end

  @spec primary(Config.t()) :: atom()
  def primary_module(config) do
    with primary when is_binary(primary) <- config.languages.primary,
      primary <- String.to_atom(primary),
      modules <- YukiHelper.Language.languages(),
      module when not is_nil(module) <- find_module(modules, primary) do
      module
    else
      nil -> YukiHelper.Languages.Elixir
    end
  end

  @spec primary(Config.t()) :: atom()
  def primary(config) do
    primary_module(config).me()
  end

  @spec get(Config.t(), keyword()) :: atom()
  def get(config, opts) do
    with lang when is_binary(lang) <- Keyword.get(opts, :lang),
      modules <- YukiHelper.Language.languages(),
      module when not is_nil(module) <- find_module(modules, lang) do
      module.me()
    else
      _ -> primary(config)
    end
  end

  @spec extension(Config.t(), keyword()) :: String.t() | nil
  def extension(config, opts) do
    YukiHelper.Language.languages()
    |> Enum.find(fn module ->
      module.handle?(config, opts)
    end)
    |> (fn
      nil ->
        primary_module(config).ext()
      module ->
        module.ext()
    end).()
  end
end