defmodule YukiHelper.Language do
  @moduledoc """
  """

  @type testcase :: String.t()
  @type language :: atom()
  @type extension :: String.t()
  @type compiler :: Path.t()
  @type source :: Path.t()
  @type input :: Path.t()
  @type opts :: keyword()
  @type error :: term()
  @type msg :: String.t()
  @type time :: non_neg_integer()
  @type expect :: String.t()
  @type result :: String.t()
  @type status :: :time_limit | :wrong_answer | :runtime_error | :accept

  alias YukiHelper.Config
  alias YukiHelper.Exceptions.{LanguageError, CompileError}

  @callback me() :: language()
  @callback ext() :: extension()
  @callback handle?(Config.t(), opts()) :: boolean()
  @callback compiler(Config.t(), opts()) :: {:ok, compiler()} | {:error, error()}
  @callback compile(Config.t(), source(), opts()) :: {msg(), 0} | {msg(), 1}
  @callback run(Config.t(), Config.no(), source(), input(), opts())
    :: {time(), result(), status(), expect()}
  @callback clean_up() :: :ok

  @languages [
    YukiHelper.Languages.Cpp11,
    YukiHelper.Languages.Elixir,
    YukiHelper.Languages.Ruby
  ]

  @doc """
  Returns a list of language module
  """
  def languages(), do: @languages()

  @doc """
  Returns currnet language module
  """
  def get(config, opts) do
    with lang when is_binary(lang) <- Keyword.get(opts, :lang),
      mod when not is_nil(mod) <- find_module(lang) do
      mod
    else
      _ -> primary(config)
    end
  end

  @doc """
  Returns primary language module
  """
  def primary(config) do
    find_module(config.languages.primary)
  end

  defp find_module(lang) do
    Enum.find(languages(), &("#{&1.me()}" == lang))
  end

  @doc """
  Verifies that the language is supported and its executable compiler exists.
  """
  @spec verify(Config.t(), keyword()) :: {:ok, language, compiler} | {:error, term()}
  def verify(config, opts) do
    module = get(config, opts)

    with lang when is_binary(lang) <- Keyword.get(opts, :lang),
      nil <- find_module(lang) do
      {:error, %LanguageError{language: lang}} 
    else
      _ ->
        case module.compiler(config, opts) do
          {:ok, compiler_path} ->
            {:ok, module.me(), compiler_path}
          {_, _} = err ->
            err
        end
    end
  end

  @spec verify!(Config.t(), keyword()) :: {language, compiler}
  def verify!(config, opts) do
    case verify(config, opts) do
      {:ok, language, compiler} ->
        {language, compiler}
      {:error, err} ->
        raise err
    end
  end

  @spec compile(Config.t(), source(), opts()) :: {:ok, String.t()} | {:error, term()}
  def compile(config, source, opts) do
    case get(config, opts).compile(config, source, opts) do
      {msg, 0} ->
        {:ok, msg}
      {_msg, 1} ->
        {:error, %CompileError{source: source}}
    end
  end

  @spec run(Config.t(), Config.no(), testcase(), source(), opts()) :: {status(), time()} | status()
  def run(config, no, testcase, source, opts) do
    root = Config.Testcase.problem_path(config, no)
    input_file = "#{root}/in/#{testcase}"
    {output, 0} = System.cmd("cat", ["#{root}/out/#{testcase}"])

    get(config, opts)
    |> (fn module ->
      time_limit = Keyword.get(opts, :time_limit) || 5_000

      task = Task.async(fn ->
        module.run(config, no, source, input_file, opts)
      end)

      case Task.yield(task, time_limit) || Task.shutdown(task) do
        {:ok, result} ->
          result
        nil ->
          :time_limit
      end
    end).()
    |> (fn 
      {_, {_, 1}} ->
        :runtime_error
      {time, {ans, 0}} when ans != output ->
        {:wrong_answer, time / 1_000}
      {time, {ans, 0}} when ans == output ->
        {:accept, time / 1_000}
      time_limit ->
        time_limit
    end).()
  end

  @spec clean_up(Config.t(), opts()) :: :ok | :error
  def clean_up(config, opts) do
    get(config, opts).clean_up()
  end
end