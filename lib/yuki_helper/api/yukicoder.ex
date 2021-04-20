defmodule YukiHelper.Api.Yukicoder do
  @moduledoc false
  use HTTPoison.Base

  def process_request_url(url) do
    "https://yukicoder.me/api/v1" <> url
  end

  def process_response_body(body) do
    body
    |> Jason.decode()
    |> case do
      {:ok, data} -> to_atom_keys(data)
      {:error, _} -> body
    end
  end

  def to_atom_keys(%{} = map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_keys(v)} end)
  end
  def to_atom_keys(v), do: v
end