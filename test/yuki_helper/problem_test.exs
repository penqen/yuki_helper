defmodule YukiHelper.ProblemTest do
  use ExUnit.Case
  doctest YukiHelper.Problem
  alias YukiHelper.{Config, Problem}

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

  describe "problem_path/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Problem.problem_path(config, 1) == "testcase/1"
      assert Problem.problem_path(config, 11) == "testcase/11"
      assert Problem.problem_path(config, 12) == "testcase/12"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Problem.problem_path(config, 1)  == "testdir/11/p1"
      assert Problem.problem_path(config, 11) == "testdir/11/p11"
      assert Problem.problem_path(config, 12) == "testdir/22/p12"
      assert Problem.problem_path(config, 22) == "testdir/22/p22"
      assert Problem.problem_path(config, 23) == "testdir/33/p23"
    end
  end

  describe "testcase_directory/1" do
    test "default value" do
      config = Config.new(@default_config)
      assert Problem.testcase_directory(config) == "testcase"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Problem.testcase_directory(config) == "testdir"
    end
  end

  describe "bundle_directory/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Problem.bundle_directory(config, 1) == ""
      assert Problem.bundle_directory(config, 11) == ""
      assert Problem.bundle_directory(config, 12) == ""
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Problem.bundle_directory(config, 1) == "11"
      assert Problem.bundle_directory(config, 11) == "11"
      assert Problem.bundle_directory(config, 12) == "22"
      assert Problem.bundle_directory(config, 22) == "22"
      assert Problem.bundle_directory(config, 23) == "33"
    end
  end

  describe "problem_directory/2" do
    test "default value" do
      config = Config.new(@default_config)
      assert Problem.problem_directory(config, 1) == "1"
      assert Problem.problem_directory(config, 11) == "11"
      assert Problem.problem_directory(config, 12) == "12"
    end

    test "custom value" do
      config = Config.new(@custom_config)
      assert Problem.problem_directory(config, 1) == "p1"
      assert Problem.problem_directory(config, 11) == "p11"
      assert Problem.problem_directory(config, 12) == "p12"
      assert Problem.problem_directory(config, 22) == "p22"
      assert Problem.problem_directory(config, 23) == "p23"
    end
  end
end