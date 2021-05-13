defmodule YukiHelper.Language do
  @moduledoc """
  Provides a module to verify compiler, compile and, execute compiled target.
  """

  alias YukiHelper.{Config, Problem}
  alias YukiHelper.Exceptions.{LanguageError, CompileError}

  @typedoc """
  A list of language module.
  """
  @type modules :: [module()]

  @typedoc """
  Filename of testcase
  """
  @type testcase :: String.t()

  @typedoc """
  Atom value which specifies language.
  """
  @type language :: atom()

  @typedoc """
  Extension of source file.
  """
  @type extension :: String.t()

  @typedoc """
  Path of compiler.
  """
  @type compiler :: Path.t()

  @typedoc """
  Path of source file.
  """
  @type source :: Path.t()

  @typedoc """
  Path of input file.
  """
  @type input :: Path.t()

  @typedoc """
  A list of option.
  """
  @type opts :: keyword()

  @typedoc """
  Any error.
  """
  @type error :: term()

  @typedoc """
  Message which occurred on compiling.
  """
  @type message :: String.t()

  @typedoc """
  Execution time.
  """
  @type exec_time() :: non_neg_integer()

  @typedoc """
  Content of ouptput file.
  """
  @type expect :: String.t()

  @typedoc """
  Result when execute compiled target.
  """
  @type result :: String.t()

  @typedoc """
  Status which judge the answer.
  """
  @type status :: :time_limit | :wrong_answer | :runtime_error | :accept

  @doc """
  Returns atom value which of the language is handled by the module.
  """
  @callback me() :: language()

  @doc """
  Returns extension of the language.
  """
  @callback ext() :: extension()

  @doc """
  Returns whether the language module does handling or not.
  """
  @callback handle?(Config.t(), opts()) :: boolean()

  @doc """
  Returns the path of the compiler if there is valid compiler.
  """
  @callback compiler(Config.t(), opts()) :: {:ok, compiler()} | {:error, error()}

  @doc """
  Returns the message and status code when the source code was compiled.
  """
  @callback compile(Config.t(), source(), opts()) :: {message(), 0} | {message(), 1}

  @doc """
  Returns the results when the compiled target was executed.
  """
  @callback run(Config.t(), Problem.no(), source(), input(), opts())
    :: {exec_time(), result(), status(), expect()}


  @doc """
  """
  @callback clean_up() :: :ok | :error

  @languages [
    YukiHelper.Languages.Cpp11,
    YukiHelper.Languages.Elixir,
    YukiHelper.Languages.Ruby
  ]

  @doc """
  Returns a list of language module
  """
  @spec languages() :: modules()
  def languages(), do: @languages()

  @doc """
  Returns currnet language module
  """
  @spec get(Config.t(), opts()) :: module()
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
  @spec primary(Config.t()) :: module()
  def primary(config) do
    find_module(config.languages.primary)
  end

  defp find_module(lang) do
    Enum.find(languages(), &("#{&1.me()}" == lang))
  end

  @doc """
  Verifies that the language is supported and its executable compiler exists.
  """
  @spec verify(Config.t(), keyword())
    :: {:ok, language, compiler} | {:error, term()}
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

  @spec compile(Config.t(), source(), opts())
    :: {:ok, String.t()} | {:error, term()}
  def compile(config, source, opts) do
    case get(config, opts).compile(config, source, opts) do
      {msg, 0} ->
        {:ok, msg}
      {_msg, 1} ->
        {:error, %CompileError{source: source}}
    end
  end

  @doc """
  Runs compiled target and returns `status` and execution time.
  """
  @spec run(Config.t(), Problem.no(), testcase(), source(), opts())
    :: {status(), exec_time()} | status()
  def run(config, no, testcase, source, opts) do
    root = Problem.problem_path(config, no)
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
      {exec_time, {ans, 0}} when ans != output ->
        {:wrong_answer, exec_time / 1_000}
      {exec_time, {ans, 0}} when ans == output ->
        {:accept, exec_time / 1_000}
      time_limit ->
        time_limit
    end).()
  end

  @doc """
  Cleans up objects (executable files etc.) depending on each language.
  """
  @spec clean_up(Config.t(), opts()) :: :ok | :error
  def clean_up(config, opts) do
    get(config, opts).clean_up()
  end
end