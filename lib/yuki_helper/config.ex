defmodule YukiHelper.Config do
  @moduledoc """
  設定ファイルの読み込み、検証、項目取得などを行う。

  下記の順に読み込みを行い、同じ設定は上書きされる。
  1. `~/.yukihelper.config.yml`
  2. `~/.config/yukihelper/.config.yml`
  3. `./yuki_helper.config.yml`

  # 設定例

  ```./yuki_helper.config.yml
  testcase:
    aggregation: null     # 数値を設定する。 テストケースをその数値でサブディレクトリ化する。
    directory: "testcase" # テストケースを保存するディレクトリ名を設定する。
    prefix: "p"           # ある問題のテストケースを入れるディレクトリの接頭辞を指定する。
  yukicoder:
    access_token: null    # yukicoderのAPIアクセストークンを設定する。
  ```
  """

  import YukiHelper
  alias YamlElixir, as: Yaml
  alias YukiHelper.Exceptions.InvalidAccessTokenError

  @type t() :: map()

  @doc """
  設定ファイルを読み込む。
  """
  @spec load_without_validation() :: t()
  def load_without_validation() do
    [
      Path.expand("~/.yuki_helper.config.{yml,yaml}"),
      Path.expand("~/.config/yuki_helper/.config.{yml,yaml}"),
      Path.join(File.cwd!(), ".yuki_helper.config.{yml,yaml}")
    ]
    |> Enum.map(&(Path.wildcard(&1, [match_dot: true])))
    |> List.flatten()
    |> Enum.reduce(%{}, fn path, config ->
      case Yaml.read_from_file(path, [atoms: true]) do
        {:ok, yaml} ->
          deep_merge(config, yaml)
        {:error, err} ->
          IO.puts "[warning]: configuration file is invalid"
          IO.puts "  #{err.message} (line: #{err.line}, column: #{err.column})"
          IO.puts "  in #{path}"
          config
      end
    end)
    |> to_map_atom_keys()
  end

  @doc """
  設定ファイルの読み込み及びバリデーションを行う。
  """
  @spec load() :: {:ok, t()} | {:error, term()}
  def load() do
    validate(load_without_validation())
  end

  @doc """
  設定ファイルの読み込み及びバリデーションを行う。
  エラーがあれば、例外を発生させる。
  """
  @spec load!() :: t()
  def load!() do
    case load() do
      {:ok, config} ->
        config
      {:error, err} ->
        raise err
    end
  end

  @doc """
  設定内容を表示する。
  """
  @spec show_status(t()) :: none()
  def show_status(config) do
    IO.puts "testcase:"
    IO.puts "  aggregation: #{config[:testcase][:aggregation]}"
    IO.puts "  directory:   #{config[:testcase][:directory]}"
    IO.puts "  prefix:      #{config[:testcase][:prefix]}"
    IO.puts "testcase:"
    IO.write "  access_token: "
    case validate(config, [:yukicoder, :access_token]) do
      {:ok, _} ->
        IO.puts "[" <> success("ok") <> "]"
      {:error, _} ->
        IO.puts "[" <> error("error") <> "]"
    end
  end

  @doc """
  `HTTPoison`で使う`headers`情報を返す。
  """
  @spec headers(t()) :: list()
  def headers(config) do
    ["Authorization": "Bearer #{config[:yukicoder][:access_token]}", "Accept": "Application/json; Charset=utf-8"]
  end

  @doc """
  `HTTPoison`で使う`options`情報を返す。
  """
  @spec options(t()) :: list()
  def options(_config) do
    [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]
  end

  @doc """
  設定のバリデーションを行う。
  """
  @spec validate(map()) :: {:ok, map()} | {:error, term()}
  def validate(config) do
    validate(config, [:yukicoder, :access_token])
  end

  @spec validate(t(), list()) :: {:ok, t()} | {:error, term()} 
  def validate(config, keys)
  def validate(config, [:yukicoder, :access_token]) do
    with yuki when is_map(yuki) <- config[:yukicoder],
      token when not(token in ["", nil]) <- yuki[:access_token] do
        {:ok, config}
    else
      _ ->
        {:error, %InvalidAccessTokenError{message: "access token is invalid"}}
    end
  end

  @spec get(t(), list(atom())) :: term()
  def get(config, []), do: config
  def get(config, [key | tail]), do: get(config[key], tail)
end