defmodule YukiHelper.Config.LanguagesTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Languages
  alias YukiHelper.Config.{Languages, Language}

  @invalid_primaries [
    "worng ",
    "foo",
    "bar",
    nil
  ]

  defp languages(primary) do
    %Languages{
      primary: primary,
      elixir: Language.new(),
      "c++11": Language.new(),
      ruby: Language.new()
    }
  end

  describe "new/0" do
    test "default value" do
      assert Languages.new() == languages("elixir")
    end
  end

  describe "new/1" do
    test "if nil, equals to new/0" do
      assert Languages.new() == Languages.new(nil)
    end

    test "default value" do
      assert Languages.new(%{}) == Languages.new()
    end

    test "valid primary" do
      assert Languages.new(%{"primary" => "elixir"}).primary == "elixir"
      assert Languages.new(%{"primary" => "c++11"}).primary == "c++11"
      assert Languages.new(%{"primary" => "ruby"}).primary == "ruby"
    end

    test "if invalid primary, default to elixir" do
      Enum.each(@invalid_primaries, fn primary ->
        assert Languages.new(%{"primary" => primary}).primary == "elixir"
      end)
    end
  end
end