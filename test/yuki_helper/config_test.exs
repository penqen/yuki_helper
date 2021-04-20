defmodule YukiHelper.ConfigTest do
  use ExUnit.Case
  doctest YukiHelper.Config
  alias YukiHelper.Config
  alias YukiHelper.Config.{Testcase, Provider}
  alias YukiHelper.Exceptions.{
    AccessTokenError,
    ConfigurationFileError
  }

  @invalid_params %{
    "testcase" => "testcase",
    "yukicoder" => "yukicoder"
  }

  @nil_params %{
    "testcase" => nil,
    "yukicoder" => nil 
  }

  @empty_params %{
    "testcase" => %{},
    "yukicoder" => %{}
  }

  @valid_testcase %{
    "prefix" => "a",
    "directory" => "abcdefg",
    "bundle" => 200
  }

  @valid_yukicoder %{
    "access_token" => "dummy_access_token"
  }

  @valid_params %{
    "testcase" => @valid_testcase,
    "yukicoder" => @valid_yukicoder
  }

  @default_config_yml %Config{
    testcase: %Testcase{
      bundle: nil,
      directory: "testcase",
      prefix: "p"
    },
    yukicoder: %Provider{
      access_token: "your access token"
    }
  }

  describe "default value" do
    test "testcase is default value" do
      assert Config.new().testcase == %Testcase{} 
    end

    test "yukicoder is default value" do
      assert Config.new().yukicoder == %Provider{} 
    end

    test "expects save value" do
      assert Config.new() == Config.new(%{})
    end
  end

  describe "new/1" do
    test "accepts valid params" do
      config = Config.new(@valid_params)

      assert config.yukicoder.access_token == @valid_yukicoder["access_token"]
      assert config.testcase.prefix == @valid_testcase["prefix"]
      assert config.testcase.directory == @valid_testcase["directory"]
      assert config.testcase.bundle == @valid_testcase["bundle"]
    end

    test "invalid params are ignored" do
      assert Config.new(@invalid_params) == Config.new()
      assert Config.new(@nil_params) == Config.new()
      assert Config.new(@empty_params) == Config.new()
    end
  end

  describe "get_target_files/1" do
    test "expects a list of configure file existed" do
      assert is_list(Config.get_target_files()) == true
    end
  end

  describe "load/1" do
    test "configuration file is not found" do
      {status, error} = Config.load(".yuki_helper.not_found.config.yml")
      assert status == :error
      assert error == %ConfigurationFileError{
        file: ".yuki_helper.not_found.config.yml",
        description: "is not found"
      }
    end

    test "wrong format configuration file is ignored" do
      {status, config} =  Config.load("mix.exs")
      assert status == :ok
      assert config == Config.new()
    end

    test "expects load .yuki_helper.default.config.yml" do
      {status, config} =  Config.load(".yuki_helper.default.config.yml")
      assert status == :ok
      assert config == @default_config_yml
    end
  end

  describe "to_string/1" do
    test "default config" do
      assert to_string(Config.new()) == """
      testcase:
        bundle: nil
        directory: testcase
        prefix: nil
      yukicoder:
        access_token: [#{YukiHelper.error("error")}]
      """
    end
    test ".yuki_helper.default.config.yml" do
      {:ok, config} = Config.load(".yuki_helper.default.config.yml")
      assert to_string(config) == """
      testcase:
        bundle: nil
        directory: testcase
        prefix: p
      yukicoder:
        access_token: [#{YukiHelper.success("ok")}]
      """
    end
  end

  describe "headers" do
    test "expects valid header" do
      {:ok, config} = Config.load(".yuki_helper.default.config.yml")
      assert Config.headers(config) == {:ok, ["Authorization": "Bearer your access token", "Accept": "Application/json; Charset=utf-8"]}
    end

    test "empty access token is invalid" do
      assert Config.headers(Config.new()) == {
        :error, 
        %AccessTokenError{description: "empty access token"}
      }
    end
  end

  describe "options/1" do
    test "expects valid header" do
      {:ok, config} = Config.load(".yuki_helper.default.config.yml")
      assert Config.options(config) == {:ok, [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]}
    end
  end

  describe "merge/2" do
    test "overrides any value" do
      init_config = Config.new(%{"testcase" => %{"directory" => "dir"}})
      {:ok, config} = Config.load(".yuki_helper.default.config.yml")

      assert Config.merge(init_config, config) == config
      assert Config.merge(config, init_config) == %{
        config |
        testcase: %{
          config.testcase |
          directory: "dir"
        }
      }
    end
  end
end
