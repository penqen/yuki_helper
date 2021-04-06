defmodule YukiHelper.Api.Yukicoder do
  use HTTPoison.Base
  import YukiHelper, only: [to_map_atom_keys: 1]

  def process_request_url(url) do
    "https://yukicoder.me/api/v1" <> url
  end

  def process_response_body(body) do
    body
    |> Jason.decode()
    |> case do
      {:ok, data} -> to_map_atom_keys(data)
      {:error, _} -> body
    end
  end
end