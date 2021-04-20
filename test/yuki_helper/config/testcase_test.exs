defmodule YukiHelper.Config.TestcaseTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Testcase
  alias YukiHelper.Config.Testcase

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
end