defmodule YukiHelperTest do
  use ExUnit.Case
  doctest YukiHelper

  test "greets the world" do
    assert YukiHelper.hello() == :world
  end
end
