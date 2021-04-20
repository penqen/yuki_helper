defmodule YukiHelper.Config.ProviderTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Provider
  alias YukiHelper.Config.Provider

  describe "default value" do
    test "access token is nil" do
      assert Provider.new().access_token == nil
    end

    test "expects same value" do
      assert Provider.new() == Provider.new(%{})
    end
  end

  describe "new/1" do
    test "expects default value" do
      assert Provider.new(nil) == %Provider{}
      assert Provider.new(%{}) == %Provider{}
    end

    test "invalid access token is ignored" do
      assert Provider.new(%{"access_token" => ""}) == %Provider{}
      assert Provider.new(%{"access_token" => 100}) == %Provider{}
    end

    test "access token is string" do
      token = "dummy"
      assert Provider.new(%{"access_token" => token}) == %Provider{access_token: token}
    end
  end
end