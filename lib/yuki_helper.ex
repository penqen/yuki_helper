defmodule YukiHelper do
  @moduledoc """
  Documentation for YukiHelper.
  """

  @doc """
  Mapのディープマージを行う。

  ## Examples

      iex> YukiHelper.deep_merge(%{a: 1, b: %{c: 1}}, %{b: %{d: 1}})
      %{
        a: 1,
        b: %{c: 1, d: 1}
      }

  """
  def deep_merge(left, right) do
    Map.merge(left, right, fn
      _key, left = %{}, right = %{} -> deep_merge(left, right)
      _key, left, nil -> left
      _key, _left, right -> right
    end)
  end

  def to_map_atom_keys(map = %{}) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), to_map_atom_keys(v)} end)
  end
  def to_map_atom_keys(v), do: v

  def success(str), do: IO.ANSI.green() <> str <> IO.ANSI.reset()
  def warning(str), do: IO.ANSI.yellow() <> str <> IO.ANSI.reset()
  def error(str), do: IO.ANSI.red() <> str <> IO.ANSI.reset()
end
