defmodule YukiHelper do
  @moduledoc """
  Documentation for YukiHelper.
  """

  use Application

  @typedoc """
  Types when arguments failed to parse.
  """
  @type invalid_type :: :invalid_arguments | :invalid_option

  @typedoc """
  Arguments to parse.
  """
  @type arguments() :: list(:integer | :string)

  @typedoc """
  Parsed results.
  """
  @type options() :: {keyword(), list()} | []

  @typedoc """
  Any string message.
  """
  @type message() :: String.t()

  @typedoc """
  Results when arguments failed to parse.
  """
  @type invalid_options() :: {invalid_type, message()}

  @doc false
  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end
 
  @doc """
  Returns message with green color.
  """
  @spec success(message()) :: message()
  def success(message), do: IO.ANSI.green() <> message <> IO.ANSI.reset()
  
  @doc """
  Returns message with yellow color.
  """
  @spec warning(message()) :: message()
  def warning(message), do: IO.ANSI.yellow() <> message <> IO.ANSI.reset()

  @doc """
  Returns message with red color.
  """
  @spec error(message()) :: message()
  def error(message), do: IO.ANSI.red() <> message <> IO.ANSI.reset()

  @doc """
  Parses common options.
  """
  @spec parse_options(list(), arguments(), keyword()) :: options() | invalid_options()
  def parse_options(argv, arguments, switches) do
    case OptionParser.parse(argv, strict: switches) do
      {_opts, _argv, [switch | _] = _invalid} ->
        {
          :invalid_option,
          "Invalid option: " <> (fn
            {name, nil} -> name
            {name, val} -> name <> "=" <> val
          end).(switch)
        }
      {[version: true], [], []} ->
        :version
      {opts, argv, []} when length(argv) == length(arguments) ->
        argv = parse_args(argv, arguments)
        if Enum.find_value(argv, &(&1 == :error)) do
          {:invalid_arguments, "Invalid arguments"}
        else
          {opts, argv}
        end
      {[], [], []} ->
        :help
      _ ->
        {:invalid_arguments, "Invalid arguments"}
    end
  end

  defp parse_args([], []), do: []
  defp parse_args([v | args0], [:string | args1]),
    do: [v | parse_args(args0, args1)]
  defp parse_args([v | args0], [:integer | args1]) do
    case Integer.parse(v) do
      {value, ""} ->
        [value | parse_args(args0, args1)]
      _ ->
        [:error]
    end
  end
end
