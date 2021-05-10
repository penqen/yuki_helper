defmodule YukiHelper.Config.LanguagesTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Languages
  alias YukiHelper.{
    Config, 
    Config.Languages,
    Config.Language
  }

  @valid_params [
    "elixir",
    "ruby",
    "c++11"
  ]

  @invalid_params [
    "worng ",
    "foo",
    "bar",
    nil
  ]

  defp config(primary) do
    %Config{
      languages: %Languages{
        primary: primary,
        elixir: Language.new(),
        "c++11": Language.new(),
        ruby: Language.new()
      }
    }
  end

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
  end

  describe "primary/1" do
    test "if primary is nil or wrong, default to :elixir" do
      @invalid_params
      |> Enum.each(fn wrong ->
        assert Languages.primary(config(wrong)) == :elixir
      end)
    end

    test "if valid value, atom value" do
      @valid_params
      |> Enum.each(fn valid ->
        assert Languages.primary(config(valid)) == String.to_atom(valid)
      end)
    end
  end

  describe "get/2" do
    @tag :sample
    test "if lang is wrong, return primary" do
      @invalid_params
      |> Enum.each(fn wrong ->
        @valid_params
        |> Enum.each(fn prime ->
          assert Languages.get(config(prime), [{:lang, wrong}]) == String.to_atom(prime)
        end)
      end)
    end

    test "if lang is valid, return atom value of lang" do
      @valid_params
      |> Enum.each(fn lang ->
        @valid_params
        |> Enum.each(fn prime ->
          assert Languages.get(config(prime), [{:lang, lang}]) == String.to_atom(lang)
        end)
      end)
    end
  end

  describe "extension/2" do
    test "if opts contain lang, return its extension" do
      @valid_params
      |> Enum.each(fn prime ->
        assert Languages.extension(config(prime), [{:lang, "elixir"}]) == "ex"
        assert Languages.extension(config(prime), [{:lang, "ruby"}]) == "rb"
        assert Languages.extension(config(prime), [{:lang, "c++11"}]) == "cpp"
      end)
    end

    test "if wrong lang opts , return primary's extension" do
      @invalid_params
      |> Enum. each(fn lang ->
        assert Languages.extension(config("elixir"), [{:lang, lang}]) == "ex"
        assert Languages.extension(config("ruby"), [{:lang, lang}]) == "rb"
        assert Languages.extension(config("c++11"), [{:lang, lang}]) == "cpp"
      end)
    end
  end
end