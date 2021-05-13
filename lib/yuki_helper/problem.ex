defmodule YukiHelper.Problem do
  @moduledoc """
  Provides the module to handle problem.
  """

  alias YukiHelper.Config
  alias YukiHelper.Exceptions.SourceFileError

  @typedoc """
  Problem No. or Problem Id.
  """
  @type no() :: pos_integer()

  @doc """
  Returns the path of source file.
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

  @spec source_file!(Config.t(), no(), keyword()) :: Path.t()
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
  Returns the path of the directory of testcases for the problem to download.
  """
  @spec problem_path(Config.t(), no()) :: Path.t()
  def problem_path(config, no) do
    [
      testcase_directory(config),
      bundle_directory(config, no),
      problem_directory(config, no)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("/")
  end

  @doc """
  Returns the root directory of testcases to donwload.
  """
  @spec testcase_directory(Config.t()) :: Path.t()
  def testcase_directory(config) do
    config.testcase.directory
  end

  @doc """
  Returns the bundled directory if nessesary.
  """
  @spec bundle_directory(Config.t(), no()) :: Path.t()
  def bundle_directory(config, no) do
    case config.testcase.bundle do
      nil -> ""
      bundle -> "#{find_bundle(bundle, no, 1)}"
    end
  end

  defp find_bundle(bundle, no, times) when bundle * times < no,
    do: find_bundle(bundle, no, times + 1)
  defp find_bundle(bundle, no, times) when no <= bundle * times,
    do: bundle * times

  @doc """
  Returns the directory for the problem.
  """
  @spec problem_directory(Config.t(), no()) :: Path.t()
  def problem_directory(config, no) do
    case config.testcase.prefix do
      nil -> "#{no}"
      prefix -> "#{prefix}#{no}"
    end
  end
end