defmodule YukiHelper.Download do
  @moduledoc """
  Provides a module related to downloading teastcases.
  """
  
  alias YukiHelper.{Config, Config.Testcase, Api.Yukicoder}
  alias YukiHelper.Exceptions.DownloadError

  @type filetype() :: :in | :out
  @type filename() :: String.t()
  @type filename_list() :: list(filename())
  @type data() :: String.t()

  @doc """
  gets a list of testcase for the specified problem.
  """
  @spec get_testcases(Config.t(), Problem.no(), keyword()) :: {:ok, filename_list()} | {:error, term()}
  def get_testcases(config, no, opts \\ []) do
    path = if Keyword.get(opts, :problem_id),
      do: "/problems/#{no}/file/in",
      else: "/problems/no/#{no}/file/in"
    headers = Config.headers!(config)
    options = Config.options!(config)

    with res <- Yukicoder.get!(path, headers, options),
      200 <- Map.get(res, :status_code),
      body <- Map.get(res, :body) do
        {:ok, body}
    else
      404 ->
        {
          :error,
          %DownloadError{
            path: path,
            status: 404,
            description: "a target was not found"
          }
        }
      code ->
        {
          :error,
          %DownloadError{
            path: path,
            status: code,
            description: "an unexpected error has occurred"
          }
        }
    end
  end

  @spec get_testcases!(Config.t(), Problem.no(), keyword()) :: filename_list()
  def get_testcases!(config, no, opts \\ []) do
    case get_testcases(config, no, opts) do
      {:ok, body} -> body
      {:error, err} -> Mix.raise err
    end
  end

  @doc """
  downloads the specified testcase for the problem.
  """
  @spec get_testcase(Config.t(), Problem.no(), filename(), filetype(), keyword()) :: {:ok, data()} | {:error, term()}
  def get_testcase(config, no, filename, type, opts \\ []) do
    path = if Keyword.get(opts, :problem_id),
      do: "/problems/#{no}/file/#{type}/#{filename}",
      else: "/problems/no/#{no}/file/#{type}/#{filename}"
    headers = Config.headers!(config)
    options = Config.options!(config)

    with res <- Yukicoder.get!(path, headers, options),
      200 <- Map.get(res, :status_code),
      body <- Map.get(res, :body) do
        body = if is_number(body), do: "#{body}\n", else: body
        {:ok, body}
    else
      404 ->
        {
          :error,
          %DownloadError{
            path: path,
            status: 404,
            description: "a target was not found"
          }
        }
      code ->
        {
          :error,
          %DownloadError{
            path: path,
            status: code,
            description: "an unexpected error has occurred"
          }
        }
    end
  end

  @spec get_testcase!(Config.t(), Problem.no(), filename(), filetype(), keyword()) :: data()
  def get_testcase!(config, no, filename, type, opts \\ []) do
    case get_testcase(config, no, filename, type, opts) do
      {:ok, body} -> body
      {:error, err} -> Mix.raise err
    end
  end

  @doc """
  Returns whetheir testcases have already been downloaded or not.
  """
  @spec download_tastcases?(filename_list(), Config.t(), Problem.no()) :: boolean()
  def download_tastcases?(testcase_list, config, no) do
    root = Path.expand(Testcase.problem_path(config, no))

    Enum.reduce(testcase_list, true, fn file, download? ->
      Enum.reduce([:in, :out], download?, fn filetype, download? ->
        download? && File.exists?(Path.join([root, "#{filetype}", file]))
      end)
    end)
  end
end