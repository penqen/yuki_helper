defmodule YukiHelper.Config.TestcaseTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Testcase
  alias YukiHelper.Config
  alias YukiHelper.Config.Testcase

  @default_config %{
    "testcase" => %{
      "prefix" => nil,
      "directory" => nil,
      "bundle" => nil
    }
  }

  @custom_config %{
    "testcase" => %{
      "prefix" => "p",
      "directory" => "testdir",
      "bundle" => 11
    }
  }

  describe "default value" do
    test "directory is `testcase`" do
      assert Testcase.new().directory == "testcase"
    end

    test "prefix is `p`" do
      assert Testcase.new().prefix == nil
    end

    test "bundle is 'nil`" do
      assert Testcase.new().bundle == nil
    end

    test "expects same value" do
      assert Testcase.new() == Testcase.new(%{})
    end
  end

  describe "new/1" do
    test "expects defalut value" do
      assert Testcase.new(%{}) == %Testcase{}
    end

    test "invalid value is ignored" do
      assert Testcase.new(%{"directory" => nil}) == %Testcase{}
    end

    test "bundle is `nil` or more than 10" do
      assert Testcase.new(%{"bundle" => nil}) == %Testcase{}
      assert Testcase.new(%{"bundle" => "foo"}) == %Testcase{}
      assert Testcase.new(%{"bundle" => 9}) == %Testcase{}
      assert Testcase.new(%{"bundle" => 10}) == %Testcase{bundle: 10}
      assert Testcase.new(%{"bundle" => 100}) == %Testcase{bundle: 100}
    end
  end

  describe "problem_path/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Testcase.problem_path(config, 1) == "testcase/1"
      assert Testcase.problem_path(config, 11) == "testcase/11"
      assert Testcase.problem_path(config, 12) == "testcase/12"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Testcase.problem_path(config, 1)  == "testdir/11/p1"
      assert Testcase.problem_path(config, 11) == "testdir/11/p11"
      assert Testcase.problem_path(config, 12) == "testdir/22/p12"
      assert Testcase.problem_path(config, 22) == "testdir/22/p22"
      assert Testcase.problem_path(config, 23) == "testdir/33/p23"
    end
  end

  describe "testcase_directory/1" do
    test "default value" do
      config = Config.new(@default_config)
      assert Testcase.testcase_directory(config) == "testcase"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Testcase.testcase_directory(config) == "testdir"
    end
  end

  describe "bundle_directory/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Testcase.bundle_directory(config, 1) == ""
      assert Testcase.bundle_directory(config, 11) == ""
      assert Testcase.bundle_directory(config, 12) == ""
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Testcase.bundle_directory(config, 1) == "11"
      assert Testcase.bundle_directory(config, 11) == "11"
      assert Testcase.bundle_directory(config, 12) == "22"
      assert Testcase.bundle_directory(config, 22) == "22"
      assert Testcase.bundle_directory(config, 23) == "33"
    end
  end

  describe "problem_directory/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Testcase.problem_directory(config, 1) == "1"
      assert Testcase.problem_directory(config, 11) == "11"
      assert Testcase.problem_directory(config, 12) == "12"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Testcase.problem_directory(config, 1) == "p1"
      assert Testcase.problem_directory(config, 11) == "p11"
      assert Testcase.problem_directory(config, 12) == "p12"
      assert Testcase.problem_directory(config, 22) == "p22"
      assert Testcase.problem_directory(config, 23) == "p23"
    end
  end
end