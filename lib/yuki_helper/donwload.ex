defmodule YukiHelper.Download do
  @moduledoc """
  テストケースのダウンロードに必要なモジュールを提供する。
  """
  alias YukiHelper.{Config, Problem, Api.Yukicoder, Exceptions.DownloadFailed}

  @type filetype() :: :in | :out
  @type filename() :: String.t()
  @type filename_list() :: list(filename())
  @type data() :: String.t()

  @doc """
  指定された問題番号`no`のテストケース一覧を取得する。
  """
  @spec get_testcases(Config.t(), Problem.no()) :: {:ok, filename_list()} | {:error, term()}
  def get_testcases(config, no) do
    uri = "/problems/no/#{no}/file/in"
    headers = Config.headers(config)
    options = Config.options(config)

    with res <- Yukicoder.get!(uri, headers, options),
      200 <- Map.get(res, :status_code),
      body <- Map.get(res, :body) do
        {:ok, body}
    else
      404 ->
        {:error, %DownloadFailed{message: "could not find testcases"}}
      _ ->
        {:error, %DownloadFailed{message: "an unexpected error has occurred"}}
    end
  end

  @spec get_testcases!(Config.t(), Problem.no()) :: filename_list()
  def get_testcases!(config, no) do
    case get_testcases(config, no) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @doc """
  """
  @spec get_testcase(Config.t(), Problem.no(), filename(), filetype()) :: {:ok, data()} | {:error, term()}
  def get_testcase(config, no, filename, type) do
    uri = "/problems/no/#{no}/file/#{type}/#{filename}"
    headers = Config.headers(config)
    options = Config.options(config)

    with res <- Yukicoder.get!(uri, headers, options),
      200 <- Map.get(res, :status_code),
      body <- Map.get(res, :body) do
        body = if is_number(body), do: "#{body}\n", else: body
        {:ok, body}
    else
      404 ->
        {:error, %DownloadFailed{message: "could not find testcases"}}
      _ ->
        {:error, %DownloadFailed{message: "an unexpected error has occurred"}}
    end
  end

  @spec get_testcase!(Config.t(), Problem.no(), filename(), filetype()) :: data()
  def get_testcase!(config, no, filename, type) do
    case get_testcase(config, no, filename, type) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @spec download_tastcases?(filename_list(), Config.t(), Problem.no()) :: boolean()
  def download_tastcases?(testcase_list, config, no) do
    root = Path.expand(Problem.problem_root(config, no))

    Enum.reduce(testcase_list, true, fn file, download? ->
      Enum.reduce([:in, :out], download?, fn filetype, download? ->
        download? && File.exists?(Path.join([root, "#{filetype}", file]))
      end)
    end)
  end
end