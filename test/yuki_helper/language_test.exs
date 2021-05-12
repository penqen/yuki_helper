defmodule YukiHelper.LanguageTest do
	use ExUnit.Case
	doctest YukiHelper.Language
	alias YukiHelper.{Config, Language, Languages}

  @invalid_languages [
    "worng ",
    "foo",
    "bar",
    nil
  ]

  defp config(primary) do
    Config.new(%{
      "languages" => %{
        "primary" => primary
      }
    })
  end

  describe "languages/0" do
    test "returns a list of language module" do
      assert Language.languages() == [
        Languages.Cpp11,
        Languages.Elixir,
        Languages.Ruby
      ]
    end
  end

  describe "get/2" do
    test "if default primary without --lang option, returns primary module" do
      assert Language.get(Config.new(), []) == Languages.Elixir
    end

    test "if custom primary without --lang option, return primary module" do
      assert Language.get(config("c++11"), []) == Languages.Cpp11
      assert Language.get(config("elixir"), []) == Languages.Elixir
      assert Language.get(config("ruby"), []) == Languages.Ruby
    end

    test "if --lang option exist, return its module" do
      assert Language.get(Config.new(), [{:lang, "c++11"}]) == Languages.Cpp11
      assert Language.get(Config.new(), [{:lang, "elixir"}]) == Languages.Elixir
      assert Language.get(Config.new(), [{:lang, "ruby"}]) == Languages.Ruby
    end

    test "if wrong --lang option, return primary module" do
      Enum.each(@invalid_languages, fn lang ->
        assert Language.get(config("c++11"), [{:lang, lang}]) == Languages.Cpp11
        assert Language.get(config("elixir"), [{:lang, lang}]) == Languages.Elixir
        assert Language.get(config("ruby"), [{:lang, lang}]) == Languages.Ruby
      end)
    end
  end

  describe "primary/1" do
    test "if default primary, return Elixir module" do
      assert Language.primary(Config.new()) == Languages.Elixir
    end

    test "if any primary, return its module" do
      assert Language.primary(config("c++11")) == Languages.Cpp11
      assert Language.primary(config("elixir")) == Languages.Elixir
      assert Language.primary(config("ruby")) == Languages.Ruby
    end
  end
end