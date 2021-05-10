defmodule YukiHelper.Config.ProvidersTest do
  use ExUnit.Case
  doctest YukiHelper.Config.Providers
  alias YukiHelper.Config.{Providers, Provider}

  @valid_params %{
    "yukicoder" => %{
      "access_token" => "dummy access token"
    }
  }

  @invalid_params %{
    "dummy" => %{
      "access_token" => "dummy access token"
    }
  }

  describe "new/0" do
    test "default value" do
      assert Providers.new() == %Providers{
        yukicoder: %Provider{}
      }
    end
  end

  describe "new/1" do
    test "if nil, default to new/0" do
      assert Providers.new(nil) == Providers.new()
    end

    test "valid params" do
      providers = Providers.new(@valid_params)

      assert providers.yukicoder == %Provider{
        access_token: "dummy access token"
      }
    end

    test "invalid params are ignored" do

      assert Providers.new(@invalid_params) == Providers.new()
    end
  end
end