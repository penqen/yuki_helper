defmodule YukiHelper.Config do
  @moduledoc """
  Provides module related to config files.

  Loading config files are the following:

  1. `~/.yukihelper.config.yml`
  2. `~/.config/yukihelper/.config.yml`
  3. `./yuki_helper.config.yml`

  If there are multiple configuration filles, any same option is overridden.

  # Configuration File

  ```yaml
  # .yuki_helper.default.config.yml
  #
  # Configures about languages.
  #
  languages:
    # Specifies default language using on testing.
    # If `null`, default to `elixir`.
    primary: null
    #
    # Configure each languages.
    # `source_directory`: if `nil`, finds a source file from `./lib` and `./src`.
    # `path`: is optional.
    # `compiler_path`: set value if there is difference between `path` and `compiler_path`.
    # `prefix`: is optional.
    #
    elixir:
      # If `null`, finds a source file from `./lib` and `./src`.
      # If found multiple find, selects first found file. 
      source_directory: null
      # If 'null', solves `elixir` automatically.
      # Because of finding from export path, does not consider any version.
      path: null
      # If 'null', solves `elixirc` automatically.
      # Because of finding from export path, does not consider any version.
      compiler_path: null
      # If 'null', in case problem number is 10, name of source file is `10.ex`.
      # However, in Elixir, relates closely between file name and module name in point of naming rules.
      # In the above, regards module name as `P10`.
      # Strongly recommends to set `prefix` in Elixir.
      prefix: "p"
    c++11:
      source_directory: null
      path: null
      compiler_path: null
      prefix: null
    ruby:
      source_directory: null
      path: null
      compiler_path: null
      prefix: null
  #
  # Configures about testcase to download.
  #
  testcase:
    # Positive integer value more than 10.
    # If `bundile` is 100, directory of testcase for problem 10 is `testcase/100/p10`.
    bundle: null
    # Root direcotry of testcases to download
    directory: "testcase"
    # Prefix of testcase `testcase/p10`
    prefix: "p"
  #
  # Configures about providers to need to login.
  # Supports for only YukiCoder in current version.
  #
  providers:
    yukicoder:
      # Access Token for Yukicoder. Be careful to treat.
      access_token: "your access token"
  ```
  """

  alias YamlElixir, as: Yaml
  alias YukiHelper.Config
  alias YukiHelper.Config.{
    Languages,
    Providers,
    Testcase
  }
  alias YukiHelper.Exceptions.{
    AccessTokenError,
    ConfigFileError,
    SourceFileError
  }

  defstruct languages: %Languages{},
    testcase: %Testcase{},
    providers: %Providers{}

  @type t() :: %__MODULE__{}
  @type no() :: pos_integer()

  @spec new() :: t()
  def new(), do: %__MODULE__{
    languages: Languages.new(),
    testcase: Testcase.new(),
    providers: Providers.new()
  }

  @spec new(map() | any()) :: t()
  def new(%{} = config) do
    %__MODULE__{
      languages: config |> Map.get("languages") |> Languages.new(),
      testcase: config |> Map.get("testcase") |> Testcase.new(),
      providers: config |> Map.get("providers") |> Providers.new()
    }
  end

  def new(_), do: new()

  @doc """
  Returns cofing files to load.
  """
  @spec config_files() :: list(Path.t())
  def config_files() do
    [
      Path.expand("~/.yuki_helper.config.{yml,yaml}"),
      Path.expand("~/.config/yuki_helper/.config.{yml,yaml}"),
      Path.join(File.cwd!(), ".yuki_helper.config.{yml,yaml}")
    ]
    |> Enum.map(&(Path.wildcard(&1, [match_dot: true])))
    |> List.flatten()
  end

  @doc """
  Loads a config file.
  """
  @spec load(Path.t()) :: {:ok, Config.t()} | {:error, term()}
  def load(path) do
    if File.exists?(path) do
      case Yaml.read_from_file(path, [atoms: true]) do
        {:ok, yaml} ->
          {:ok, Config.new(yaml)}
        {:error, err = %YamlElixir.ParsingError{}} ->
          [
            "[warning]: config file is invalid",
            "  #{YamlElixir.ParsingError.message(err)}",
            "  in #{path}"
          ]
          |> Enum.join("\n")
          |> Mix.shell().info()

          {:ok, Config.new()}
        _ ->
          raise "an unexpected error has been occured"
      end
    else
      {:error, %ConfigFileError{file: path}}
    end
  end

  @doc """
  Loads all config files with ignoring any error. 
  """
  @spec load_all() :: Config.t()
  def load_all() do
    Enum.reduce(config_files(), new(), fn path, config ->
      case load(path) do
        {:ok, next} ->
          merge(config, next)
        {:error, _} ->
          config
      end
    end)
  end

  @doc """
  returns `headers` for `HTTPoison`.
  """
  @spec headers(t()) :: {:ok, list()} | {:error, term()}
  def headers(config) do
    with token <- config.providers.yukicoder.access_token,
      token when not(token in [nil, ""]) <- token do
      {
        :ok, [
          "Authorization": "Bearer #{token}",
          "Accept": "Application/json; Charset=utf-8"
        ]
      }
    else
      _ ->
        {:error, %AccessTokenError{}}
    end
  end

  @spec headers!(t()) :: list()
  def headers!(config) do
    case headers(config) do
      {:ok, headers} -> headers
      {:error, err} -> raise err
    end
  end

  @doc """
  returns `options` for `HTTPoison`.
  """
  @spec options(t()) :: {:ok, list()} | {:error, term()}
  def options(_config) do
    {:ok, [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]}
  end

  @spec options!(t()) :: list()
  def options!(config) do
    case options(config) do
      {:ok, opts} -> opts
      {:error, err} -> raise err
    end
  end

  @doc """
  returns the path of source file.
  """
  @spec source_file(Config.t(), no(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def source_file(config, no, opts) do
    with nil <- Keyword.get(opts, :source),
      source <- find_source_file(config, no, opts) do
        source
    else
      path when is_binary(path) ->
        if File.exists?(path) do
          {:ok, path}
        else
          {:error, path}
        end
    end
    |> case do
      {:ok, path} ->
        {:ok, path}
      {:error, path} ->
        {:error, %SourceFileError{source: path}}
    end
  end

  @spec source_file(Config.t(), no(), keyword()) :: Path.t()
  def source_file!(config, no, opts) do
    case source_file(config, no, opts) do
      {:ok, path} ->
        path
      {:error, err} ->
        raise err
    end
  end

  defp find_source_file(config, no, opts) do
    prefix = prefix(config)
    ext = YukiHelper.Language.get(config, opts).ext()

    case Path.wildcard("{lib,src}/**/#{prefix}#{no}.#{ext}") do
      [] ->
        {:error, "#{prefix}#{no}.#{ext}"}
      [file | _] ->
        {:ok, file}
    end
  end

  defp prefix(config) do
    case config.testcase.prefix do
      nil -> ""
      p -> p
    end
  end

  @doc """
  Merges two configurations.
  Prioritizes to select a not `nil` value as well as possible.
  """
  def merge(%{} = c0, %{} = c1) do
    Map.merge(c0, c1, fn
      _key, v0, nil -> v0
      _key, %{} = v0, %{} = v1 -> merge(v0, v1)
      _key, _v0, v1 -> v1
    end)
  end

  defimpl String.Chars do
    def to_string(%Config{} = config) do
      access_token = if config.providers.yukicoder.access_token in [nil, ""] do
        YukiHelper.error("error")
      else
        YukiHelper.success("ok")
      end

      """
      languages:
        primary: #{to_str(config.languages.primary)}
        c++11:
          source_directory: #{to_str(config.languages."c++11".source_directory)}
          path: #{to_str(config.languages."c++11".path)}
          compiler_path: #{to_str(config.languages."c++11".compiler_path)}
          prefix: #{to_str(config.languages."c++11".prefix)}
        elixir:
          source_directory: #{to_str(config.languages.elixir.source_directory)}
          path: #{to_str(config.languages.elixir.path)}
          compiler_path: #{to_str(config.languages.elixir.compiler_path)}
          prefix: #{to_str(config.languages.elixir.prefix)}
        ruby:
          source_directory: #{to_str(config.languages.ruby.source_directory)}
          path: #{to_str(config.languages.ruby.path)}
          compiler_path: #{to_str(config.languages.ruby.compiler_path)}
          prefix: #{to_str(config.languages.ruby.prefix)}
      testcase:
        bundle: #{to_str(config.testcase.bundle)}
        directory: #{to_str(config.testcase.directory)}
        prefix: #{to_str(config.testcase.prefix)}
      providers:
        yukicoder:
          access_token: [#{access_token}]
      """
    end

    defp to_str(nil), do: "nil"
    defp to_str(v), do: v
  end
end