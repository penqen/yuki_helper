defmodule YukiHelper.Config.LanguageTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Language
  alias YukiHelper.Config.Language

  @valid_params %{
    "source_directory" => "src_dir",
    "path" => "path/to/bin",
    "compiler_path" => "path/to/compiler",
    "prefix" => "prefix"
  }

  @invalid_params %{
    "source_directory" => 1,
    "path" => 1,
    "compiler_path" => 1,
    "prefix" => 1
  }

  describe "new/0" do
    test "default value" do
      assert Language.new() == %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      }
    end
  end

  describe "new/1" do
    test "if nil, default to new/0" do
      assert Language.new(nil) == Language.new()
    end

    test "valid params" do
      language = Language.new(@valid_params)

      assert language.source_directory == "src_dir"
      assert language.path == "path/to/bin"
      assert language.compiler_path == "path/to/compiler"
      assert language.prefix == "prefix"
    end

    test "any invalid value is ignored" do
      language = Language.new(@invalid_params)
      assert language.source_directory == "1"
      assert language.path == nil
      assert language.compiler_path == nil
      assert language.prefix == nil
    end
  end
end