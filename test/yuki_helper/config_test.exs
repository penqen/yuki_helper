defmodule YukiHelper.ConfigTest do
  use ExUnit.Case
  doctest YukiHelper.Config
  alias YukiHelper.Config
  alias YukiHelper.Config.{
    Language,
    Languages,
    Provider,
    Providers,
    Testcase
  }
  alias YukiHelper.Exceptions.{
    AccessTokenError,
    ConfigFileError
  }

  @default_config %Config{
    languages: %Languages{
      primary: "elixir",
      "c++11": %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      },
      elixir: %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      },
      ruby: %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      }
    },
    testcase: %Testcase{
      bundle: nil,
      directory: "testcase",
      prefix: nil
    },
    providers: %Providers{
      yukicoder: %Provider{
        access_token: nil
      }
    }
  }

  @default_config_yml %Config{
    languages: %Languages{
      primary: "elixir",
      "c++11": %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      },
      elixir: %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: "p"
      },
      ruby: %Language{
        source_directory: nil,
        path: nil,
        compiler_path: nil,
        prefix: nil
      }
    },
    testcase: %Testcase{
      bundle: nil,
      directory: "testcase",
      prefix: "p"
    },
    providers: %Providers{
      yukicoder: %Provider{
        access_token: "your access token"
      }
    }
  }

  @invalid_params %{
    "languages" => "invalid",
    "testcase" => "invalid",
    "providers" => "invalid",
    "invlaid" => "invalid"
  }

  @nil_params %{
    "languages" => nil,
    "testcase" => nil,
    "providers" => nil
  }

  @empty_params %{
    "languages" => %{},
    "testcase" => %{},
    "providers" => %{}
  }

  @valid_languages %{
    "primary" => "c++11",
    "c++11" => %{
      "source_directory" => "c++11",
      "compiler_path" => "path/to/g++",
      "prefix" => "c11"
    },
    "elixir" => %{
      "source_directory" => "elixir",
      "path" => "path/to/elixir",
      "compiler_path" => "path/to/elixirc",
      "prefix" => "e"
    },
    "ruby" => %{
      "source_directory" => "ruby",
      "path" => "path/to/ruby",
      "prefix" => "r"
    }
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
    "languages" => @valid_languages,
    "testcase" => @valid_testcase,
    "providers" => %{
      "yukicoder" => @valid_yukicoder
    }
  }

  describe "new/0" do
    test "default value" do
      config = Config.new()
      assert config == @default_config
    end
  end

  describe "new/1" do
    test "if nil, defualt to new/0" do
      assert Config.new(nil) == Config.new()
    end

    test "accepts valid params" do
      config = Config.new(@valid_params)

      assert config.languages.primary == @valid_languages["primary"]
      assert config.languages."c++11".source_directory == @valid_languages["c++11"]["source_directory"]
      assert config.languages."c++11".compiler_path == @valid_languages["c++11"]["compiler_path"]
      assert config.languages."c++11".prefix == @valid_languages["c++11"]["prefix"]
      assert config.languages.elixir.source_directory == @valid_languages["elixir"]["source_directory"]
      assert config.languages.elixir.path == @valid_languages["elixir"]["path"]
      assert config.languages.elixir.compiler_path == @valid_languages["elixir"]["compiler_path"]
      assert config.languages.elixir.prefix == @valid_languages["elixir"]["prefix"]
      assert config.languages.ruby.source_directory == @valid_languages["ruby"]["source_directory"]
      assert config.languages.ruby.path == @valid_languages["ruby"]["path"]
      assert config.languages.ruby.prefix == @valid_languages["ruby"]["prefix"]
      assert config.providers.yukicoder.access_token == @valid_yukicoder["access_token"]
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
      assert error == %ConfigFileError{
        file: ".yuki_helper.not_found.config.yml",
        description: "config file not found"
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
      languages:
        primary: elixir
        c++11:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: nil
        elixir:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: nil
        ruby:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: nil
      testcase:
        bundle: nil
        directory: testcase
        prefix: nil
      providers:
        yukicoder:
          access_token: [#{YukiHelper.error("error")}]
      """
    end

    test ".yuki_helper.default.config.yml" do
      {:ok, config} = Config.load(".yuki_helper.default.config.yml")
      assert to_string(config) == """
      languages:
        primary: elixir
        c++11:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: nil
        elixir:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: p
        ruby:
          source_directory: nil
          path: nil
          compiler_path: nil
          prefix: nil
      testcase:
        bundle: nil
        directory: testcase
        prefix: p
      providers:
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
